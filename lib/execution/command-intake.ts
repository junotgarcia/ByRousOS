// lib/execution/command-intake.ts
// Phase 2.1 — Execution Core Basic
// Governance: audit_log write BEFORE os.commands insert.
// command_id generated once — used in both audit_log.entity_id and os.commands.id
// No real execution. No agents. No autonomy. No external channels.

import { getDb } from '@/lib/db/server'
import { randomUUID } from 'crypto'
import type {
  AutonomyLevel,
  CommandStatus,
  CreateCommandInput,
  CommandIntakeResult,
} from './command-types'

// ---------------------------------------------------------------------------
// Autonomy Classification
// ---------------------------------------------------------------------------
const IRREVERSIBLE_TYPES = ['delete_agent', 'drop_schema', 'revoke_access', 'system_shutdown']

export function classifyAutonomyLevel(
  type: string,
  confidence_score: number
): AutonomyLevel {
  if (IRREVERSIBLE_TYPES.includes(type)) return 'D'
  if (confidence_score < 0.7) return 'C'
  if (confidence_score >= 0.9) return 'A'
  return 'B'
}

// ---------------------------------------------------------------------------
// Governance Decision
// ---------------------------------------------------------------------------
function applyGovernance(
  level: AutonomyLevel
): { governance_passed: boolean; status: CommandStatus } {
  if (level === 'D' || level === 'C') {
    return { governance_passed: false, status: 'blocked' }
  }
  return { governance_passed: true, status: 'approved' }
}

// ---------------------------------------------------------------------------
// Command Intake
// ---------------------------------------------------------------------------
export async function intakeCommand(
  input: CreateCommandInput
): Promise<CommandIntakeResult> {
  const sql = getDb()
  // Generate IDs once — command_id used in both audit_log.entity_id and os.commands.id
  const command_id = randomUUID()
  const correlation_id = input.correlation_id ?? randomUUID()
  const confidence_score = input.confidence_score ?? 1.0
  const autonomy_level = classifyAutonomyLevel(input.type, confidence_score)
  const { governance_passed, status } = applyGovernance(autonomy_level)

  // 1. Write audit_log BEFORE inserting command (governance: logs before actions)
  try {
    await sql`
      INSERT INTO os.audit_log (
        entity_type,
        entity_id,
        action,
        autonomy_level,
        actor_type,
        new_value,
        correlation_id,
        notes
      ) VALUES (
        'os.commands',
        ${command_id}::uuid,
        'command_intake',
        ${autonomy_level},
        'system',
        ${JSON.stringify({
          command_id,
          type: input.type,
          payload: input.payload,
          confidence_score,
          governance_passed,
          status,
        })}::jsonb,
        ${correlation_id},
        ${'Phase 2.1 — command intake — governance middleware'}
      )
    `
  } catch (auditError) {
    // Governance rule: if audit_log write fails, do NOT proceed
    return {
      success: false,
      error: `audit_log write failed — command not created: ${String(auditError)}`,
    }
  }

  // 2. Insert command into os.commands using same command_id
  try {
    await sql`
      INSERT INTO os.commands (
        id,
        type,
        payload,
        autonomy_level,
        confidence_score,
        governance_passed,
        status,
        correlation_id
      ) VALUES (
        ${command_id}::uuid,
        ${input.type},
        ${JSON.stringify(input.payload)}::jsonb,
        ${autonomy_level},
        ${confidence_score},
        ${governance_passed},
        ${status},
        ${correlation_id}
      )
    `

    return {
      success: true,
      command_id,
      autonomy_level,
      status,
      governance_passed,
    }
  } catch (insertError) {
    return {
      success: false,
      error: `os.commands insert failed: ${String(insertError)}`,
    }
  }
}

// ---------------------------------------------------------------------------
// Get Command by ID
// ---------------------------------------------------------------------------
export async function getCommand(id: string) {
  const sql = getDb()
  const rows = await sql`
    SELECT
      id, type, payload, autonomy_level, confidence_score,
      governance_passed, status, created_at, updated_at,
      executed_at, error_message, correlation_id
    FROM os.commands
    WHERE id = ${id}::uuid
    LIMIT 1
  `
  return rows[0] ?? null
}

// ---------------------------------------------------------------------------
// List Commands
// ---------------------------------------------------------------------------
export async function listCommands(limit = 20, offset = 0) {
  const sql = getDb()
  const rows = await sql`
    SELECT
      id, type, autonomy_level, confidence_score,
      governance_passed, status, created_at, correlation_id
    FROM os.commands
    ORDER BY created_at DESC
    LIMIT ${limit}
    OFFSET ${offset}
  `
  return rows
}
