// lib/execution/command-intake.ts
// Phase 2.1 — Execution Core Basic
// Governance: audit_log write BEFORE os.commands insert.
// audit_log.id captured and passed into os.commands.audit_log_id.
// audit_log.command_id set to command_id for full traceability.
// agent_id nullable from Phase 2.1 (migration 003).
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
  const command_id = randomUUID()
  const confidence_score = input.confidence_score ?? 1.0
  const autonomy_level = classifyAutonomyLevel(input.type, confidence_score)
  const { governance_passed, status } = applyGovernance(autonomy_level)

  // 1. Write audit_log BEFORE inserting command (governance: logs before actions)
  // command_id included in audit_log for full traceability audit_log <-> os.commands
  let audit_log_id: string | null = null
  try {
    const auditRows = await sql`
      INSERT INTO os.audit_log (
        entity_type,
        entity_id,
        action_type,
        autonomy_level,
        confidence_score,
        agent_code,
        risk_level,
        command_id,
        state_after,
        notes
      ) VALUES (
        'os.commands',
        ${command_id},
        'command_intake',
        ${autonomy_level},
        ${confidence_score},
        'system',
        'LOW',
        ${command_id}::uuid,
        ${JSON.stringify({
          command_id,
          command_type: input.type,
          payload: input.payload,
          governance_passed,
          status,
        })}::jsonb,
        ${'Phase 2.1 — command intake — governance middleware'}
      )
      RETURNING id
    `
    audit_log_id = auditRows[0]?.id ?? null
  } catch (auditError) {
    return {
      success: false,
      error: `audit_log write failed — command not created: ${String(auditError)}`,
    }
  }

  // 2. Insert command into os.commands (agent_id nullable per migration 003)
  try {
    await sql`
      INSERT INTO os.commands (
        id,
        command_type,
        target_entity,
        payload,
        autonomy_level,
        confidence_score,
        risk_level,
        governance_passed,
        status,
        agent_code,
        audit_log_id
      ) VALUES (
        ${command_id}::uuid,
        ${input.type},
        'os.commands',
        ${JSON.stringify(input.payload)}::jsonb,
        ${autonomy_level},
        ${confidence_score},
        'LOW',
        ${governance_passed},
        ${status},
        'system',
        ${audit_log_id}::uuid
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
      id, command_type, target_entity, payload, autonomy_level,
      confidence_score, risk_level, governance_passed, status,
      agent_code, created_at, updated_at, audit_log_id
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
      id, command_type, target_entity, autonomy_level,
      confidence_score, governance_passed, status, created_at
    FROM os.commands
    ORDER BY created_at DESC
    LIMIT ${limit}
    OFFSET ${offset}
  `
  return rows
}
