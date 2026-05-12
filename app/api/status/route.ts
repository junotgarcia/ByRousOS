// app/api/status/route.ts
// GET /api/status
// Consulta os.system_config via PostgreSQL directo

import { NextResponse } from "next/server";
import { getDb } from "@/lib/db/server";

export async function GET() {
  const start = Date.now();

  try {
    const sql = getDb();

    const [config] = await sql`
      SELECT operational_mode, version, maintenance_mode, degraded_mode_active
      FROM os.system_config
      LIMIT 1
    `;

    const [{ count: agentCount }] = await sql`
      SELECT COUNT(*)::int AS count FROM os.agents
    `;

    const [{ count: alertCount }] = await sql`
      SELECT COUNT(*)::int AS count
      FROM os.system_alerts
      WHERE status = 'open' AND severity = 'CRITICAL'
    `;

    return NextResponse.json({
      status: "operational",
      time: new Date().toISOString(),
      latency_ms: Date.now() - start,
      system: config,
      agents: { registered: agentCount },
      alerts: { critical_open: alertCount },
      database: { schema_os: "verified" },
    });
  } catch (err) {
    console.error("[status] DB error:", err);
    return NextResponse.json(
      {
        status: "error",
        time: new Date().toISOString(),
        latency_ms: Date.now() - start,
        error: err instanceof Error ? err.message : JSON.stringify(err),
      },
      { status: 503 }
    );
  }
}
