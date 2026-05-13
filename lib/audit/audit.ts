import { getDb } from '@/lib/db/server';
export type AutonomyLevel = 'A' | 'B' | 'C' | 'D';
export type RiskLevel = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
export interface AuditEntry {
  agent_code: string;
  action_type: string;
  entity_type: string;
  entity_id?: string;
  autonomy_level: AutonomyLevel;
  risk_level?: RiskLevel;
  state_before?: Record<string, unknown>;
  state_after?: Record<string, unknown>;
  correlation_id?: string;
  notes?: string;
}
export interface AuditResult { ok: boolean; id?: string; error?: string; }
export async function writeAuditLog(entry: AuditEntry): Promise<AuditResult> {
  try {
    const sql = getDb();
    const rows = await sql<{ id: string }[]>`
      INSERT INTO os.audit_log (agent_code, action_type, entity_type, entity_id, autonomy_level, risk_level, state_before, state_after, notes, logged_at)
      VALUES (${entry.agent_code}, ${entry.action_type}, ${entry.entity_type}, ${entry.entity_id ?? null}, ${entry.autonomy_level}, ${entry.risk_level ?? 'LOW'},
        ${entry.state_before ? JSON.stringify(entry.state_before) : null},
        ${entry.state_after ? JSON.stringify({ ...entry.state_after, ...(entry.correlation_id ? { correlation_id: entry.correlation_id } : {}) }) : entry.correlation_id ? JSON.stringify({ correlation_id: entry.correlation_id }) : null},
        ${entry.notes ?? null}, NOW()) RETURNING id::text`;
    return { ok: true, id: rows[0]?.id };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(JSON.stringify({ level: 'error', component: 'audit', message: `AUDIT_WRITE_FAILED: ${msg}`, timestamp: new Date().toISOString() }));
    return { ok: false, error: msg };
  }
}
export async function verifyAppendOnly(): Promise<{ ok: boolean; detail: string }> {
  const sql = getDb();
  try {
    await sql.begin(async (tx) => {
      const rows = await tx`
        INSERT INTO os.audit_log (agent_code, action_type, entity_type, autonomy_level, risk_level, logged_at)
        VALUES ('__verify_append_only__', 'SYSTEM_CHECK', 'SYSTEM', 'A', 'LOW', NOW())
        RETURNING id::text
      `;
      const insertedId = rows[0]?.id;
      if (!insertedId) {
        throw new Error('append_only_test_insert_failed');
      }
      try {
        await tx`UPDATE os.audit_log SET notes = notes WHERE id = ${insertedId}::uuid`;
        throw new Error('append_only_test_failed_update_allowed');
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        if (msg.includes('append-only')) {
          throw new Error('append_only_test_success_trigger_blocked');
        }
        throw err;
      }
    });
    return {
      ok: false,
      detail: 'WARNING: append-only verification transaction completed unexpectedly.'
    };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('append_only_test_success_trigger_blocked')) {
      return {
        ok: true,
        detail: 'VERIFIED: UPDATE blocked by trigger trg_prevent_audit_log_mutation.'
      };
    }
    if (msg.includes('append_only_test_failed_update_allowed')) {
      return {
        ok: false,
        detail: 'WARNING: UPDATE did not throw. Trigger trg_prevent_audit_log_mutation may not be active.'
      };
    }
    return {
      ok: false,
      detail: `UNEXPECTED ERROR: ${msg}`
    };
  }
}
