export type LogLevel = 'debug' | 'info' | 'warn' | 'error';
export interface OperationalLog {
  timestamp: string;
  level: LogLevel;
  correlationId: string;
  component: string;
  message: string;
  durationMs?: number;
  statusCode?: number;
  meta?: Record<string, unknown>;
}
export function generateCorrelationId(): string {
  const ts = Date.now().toString(36);
  const rand = Math.random().toString(36).slice(2, 8);
  return `byrous-${ts}-${rand}`;
}
function write(level: LogLevel, component: string, message: string, extra?: Partial<Pick<OperationalLog, 'durationMs' | 'statusCode' | 'meta'>>, correlationId?: string): void {
  if (level === 'debug' && process.env.NODE_ENV === 'production') return;
  const entry: OperationalLog = { timestamp: new Date().toISOString(), level, correlationId: correlationId ?? 'none', component, message, ...extra };
  const out = JSON.stringify(entry);
  level === 'error' || level === 'warn' ? console.error(out) : console.log(out);
}
export const logger = {
  debug: (c: string, m: string, meta?: Record<string, unknown>, cid?: string) => write('debug', c, m, { meta }, cid),
  info:  (c: string, m: string, meta?: Record<string, unknown>, cid?: string) => write('info',  c, m, { meta }, cid),
  warn:  (c: string, m: string, meta?: Record<string, unknown>, cid?: string) => write('warn',  c, m, { meta }, cid),
  error: (c: string, m: string, meta?: Record<string, unknown>, cid?: string) => write('error', c, m, { meta }, cid),
  request: (c: string, status: number, durationMs: number, cid?: string) => write('info', c, 'request_completed', { statusCode: status, durationMs }, cid),
};
