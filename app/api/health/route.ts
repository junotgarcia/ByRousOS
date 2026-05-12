// app/api/health/route.ts
// GET /api/health
// Verifica conexion PostgreSQL directa (os.*) con SELECT 1

import { NextResponse } from "next/server";
import { getDb } from "@/lib/db/server";

export async function GET() {
  const start = Date.now();

  try {
    const sql = getDb();
    await sql`SELECT 1`;

    return NextResponse.json({
      ok: true,
      service: "byrous-os-web",
      time: new Date().toISOString(),
      latency_ms: Date.now() - start,
      database: "connected",
    });
  } catch (err) {
    console.error("[health] DB error:", err);
    return NextResponse.json(
      {
        ok: false,
        service: "byrous-os-web",
        time: new Date().toISOString(),
        latency_ms: Date.now() - start,
        database: "error",
        error: err instanceof Error ? err.message : JSON.stringify(err),
      },
      { status: 503 }
    );
  }
}
