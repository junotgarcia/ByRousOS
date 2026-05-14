// lib/execution/command-types.ts
// Phase 2.1 — Execution Core Basic — Type definitions aligned to os.commands schema

export type AutonomyLevel = 'A' | 'B' | 'C' | 'D'

export type CommandStatus =
  | 'pending'
  | 'approved'
  | 'blocked'
  | 'executing'
  | 'executed'
  | 'failed'
  | 'cancelled'

export interface CommandRecord {
  id: string
  agent_id: string | null
  type: string
  payload: Record<string, unknown>
  autonomy_level: AutonomyLevel
  confidence_score: number
  governance_passed: boolean | null
  status: CommandStatus
  created_at: string
  updated_at: string
  executed_at: string | null
  error_message: string | null
  correlation_id: string | null
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
