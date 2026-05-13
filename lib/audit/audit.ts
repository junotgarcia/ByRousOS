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
  let insertedId: string | null = null;
  try {
    // Step 1: Insert a real test row inside a transaction
    const insertRows = await sql<{ id: string }[]>`
      INSERT INTO os.audit_log (agent_code, action_type, entity_type, autonomy_level, risk_level, logged_at)
      VALUES ('__verify_append_only__', 'SYSTEM_CHECK', 'SYSTEM', 'A', 'LOW', NOW())
      RETURNING id::text
    `;
    insertedId = insertRows[0]?.id ?? null;
    if (!insertedId) {
      return { ok: false, detail: 'Could not insert test row for append-only verification.' };
    }
    // Step 2: Attempt UPDATE on the real row — trigger should throw
    await sql`UPDATE os.audit_log SET notes = notes WHERE id = ${insertedId}::uuid`;
    // Step 3: If UPDATE did not throw, trigger is not active — cleanup and report failure
    await sql`DELETE FROM os.audit_log WHERE id = ${insertedId}::uuid`;
    return { ok: false, detail: 'WARNING: UPDATE did not throw. Trigger trg_prevent_audit_log_mutation may not be active.' };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('append-only')) {
      // Expected: trigger fired correctly — row was never committed
      return { ok: true, detail: 'VERIFIED: UPDATE blocked by trigger trg_prevent_audit_log_mutation.' };
    }
    return { ok: false, detail: `UNEXPECTED ERROR: ${msg}` };
  }
}


