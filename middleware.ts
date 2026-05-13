import { NextRequest, NextResponse } from 'next/server';
export const CORRELATION_HEADER = 'x-correlation-id';
export const REQUEST_START_HEADER = 'x-request-start';
function generateCorrelationId(): string { const ts = Date.now().toString(36); const rand = Math.random().toString(36).slice(2, 8); return `byrous-${ts}-${rand}`; }
export function middleware(request: NextRequest) {
  const startMs = Date.now();
  const correlationId = request.headers.get(CORRELATION_HEADER) ?? generateCorrelationId();
  const reqHeaders = new Headers(request.headers);
  reqHeaders.set(CORRELATION_HEADER, correlationId);
  reqHeaders.set(REQUEST_START_HEADER, String(startMs));
  const response = NextResponse.next({ request: { headers: reqHeaders } });
  response.headers.set(CORRELATION_HEADER, correlationId);
  console.log(JSON.stringify({ timestamp: new Date(startMs).toISOString(), level: 'info', component: 'middleware', correlationId, message: 'request_in', meta: { method: request.method, pathname: request.nextUrl.pathname } }));
  return response;
}
export const config = { matcher: ['/api/:path*'] };
