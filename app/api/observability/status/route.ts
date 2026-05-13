import { NextRequest, NextResponse } from 'next/server';
import { logger } from '@/lib/observability/logger';
import { writeAuditLog, verifyAppendOnly } from '@/lib/audit/audit';
const COMPONENT = 'api/observability/status';
export async function GET(request: NextRequest) {
  const correlationId = request.headers.get('x-correlation-id') ?? `byrous-${Date.now().toString(36)}-fallback`;
  const startMs = parseInt(request.headers.get('x-request-start') ?? '0', 10);
  logger.info(COMPONENT, 'observability_check_start', {}, correlationId);
  const checks: Record<string, { ok: boolean; detail: string; [k: string]: unknown }> = {};
  try { logger.info(COMPONENT, 'logger_self_test', {}, correlationId); checks.operationalLogger = { ok: true, detail: 'Structured JSON logger operational' }; }
  catch { checks.operationalLogger = { ok: false, detail: 'Logger self-test failed' }; }
  const auditResult = await writeAuditLog({ agent_code: 'system', action_type: 'EXECUTE', entity_type: 'api/observability/status', autonomy_level: 'A', risk_level: 'LOW', notes: `Observability check — correlationId: ${correlationId}`, state_after: { check: 'observability_status' } });
  checks.auditLogWrite = { ok: auditResult.ok, auditEntryId: auditResult.id ?? null, detail: auditResult.ok ? 'INSERT to os.audit_log succeeded' : `INSERT FAILED: ${auditResult.error}` };
  const appendCheck = await verifyAppendOnly();
  checks.auditLogAppendOnly = { ok: appendCheck.ok, detail: appendCheck.detail };
  const fromMiddleware = !!request.headers.get('x-correlation-id');
  checks.correlationId = { ok: true, fromMiddleware, value: correlationId, detail: fromMiddleware ? 'Correlation ID injected by middleware' : 'Generated at handler' };
  const allOk = Object.values(checks).every((c) => c.ok);
  const durationMs = startMs > 0 ? Date.now() - startMs : null;
  logger.info(COMPONENT, 'observability_check_complete', { status: allOk ? 'operational' : 'degraded', durationMs }, correlationId);
  return NextResponse.json({ system: 'ByRousOS', component: 'observability', status: allOk ? 'operational' : 'degraded', correlationId, ...(durationMs !== null && { durationMs }), checks }, { status: allOk ? 200 : 207 });
}
