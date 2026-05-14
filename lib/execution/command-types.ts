// lib/execution/command-types.ts
// Phase 2.1 — Execution Core Basic — Type definitions aligned to os.commands schema

export type AutonomyLevel = 'A' | 'B' | 'C' | 'D'

// Aligned to os.execution_status ENUM in schema
export type CommandStatus =
  | 'pending'
  | 'queued'
  | 'running'
  | 'completed'
  | 'failed'
  | 'rolled_back'
  | 'cancelled'

export interface CommandRecord {
  id: string
  agent_id: string | null
  command_type: string
  target_entity: string
  payload: Record<string, unknown>
  autonomy_level: AutonomyLevel
  confidence_score: number
  risk_level: string
  governance_passed: boolean | null
  status: CommandStatus
  agent_code: string
  created_at: string
  updated_at: string
  audit_log_id: string | null
}

export interface CreateCommandInput {
  type: string
  payload: Record<string, unknown>
  confidence_score?: number
  correlation_id?: string
}

export interface CommandIntakeResult {
  success: boolean
  command_id?: string
  autonomy_level?: AutonomyLevel
  status?: CommandStatus
  governance_passed?: boolean
  error?: string
}
