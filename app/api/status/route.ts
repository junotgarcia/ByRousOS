// app/api/status/route.ts
// GET /api/status — estado detallado del sistema ByRousOS
// Lee: system_config, agents (count), system_alerts (critical open), sbr.config (ping)

import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET() {
  const start = Date.now();

  try {
    const supabase = createSupabaseServerClient();

    const [systemConfig, agentCount, alertCount, sbrPing] = await Promise.all([
      supabase
        .schema("os")
        .from("system_config")
        .select("operational_mode, version, maintenance_mode, degraded_mode_active")
        .limit(1)
        .single(),

      supabase
        .schema("os")
        .from("agents")
        .select("*", { count: "exact", head: true }),

      supabase
        .schema("os")
        .from("system_alerts")
        .select("*", { count: "exact", head: true })
        .eq("status", "open")
        .eq("severity", "CRITICAL"),

      supabase
        .schema("sbr")
        .from("config")
        .select("clave", { count: "exact", head: true }),
    ]);

    if (systemConfig.error) throw systemConfig.error;

    return NextResponse.json({
      status: "operational",
      time: new Date().toISOString(),
      latency_ms: Date.now() - start,
      system: systemConfig.data,
      agents: { registered: agentCount.count ?? 0 },
      alerts: { critical_open: alertCount.count ?? 0 },
      database: {
        schema_os: "verified",
        schema_sbr: sbrPing.error ? "error" : "verified",
      },
    });
  } catch (err) {
    return NextResponse.json(
      {
        status: "error",
        time: new Date().toISOString(),
        latency_ms: Date.now() - start,
        error: err instanceof Error ? err.message : "unknown",
      },
      { status: 503 }
    );
  }
}
