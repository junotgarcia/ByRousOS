import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET() {
  const start = Date.now();

  try {
    const supabase = createSupabaseServerClient();
    const { data, error } = await supabase
      .schema("os")
      .from("system_config")
      .select("operational_mode, version")
      .limit(1)
      .single();

    if (error) throw error;

    return NextResponse.json({
      ok: true,
      service: "byrous-os-web",
      time: new Date().toISOString(),
      latency_ms: Date.now() - start,
      supabase: "connected",
      system: {
        operational_mode: data.operational_mode,
        version: data.version,
      },
    });
  } catch (err) {
    return NextResponse.json(
      {
        ok: false,
        service: "byrous-os-web",
        time: new Date().toISOString(),
        latency_ms: Date.now() - start,
        supabase: "error",
        error: err instanceof Error ? err.message : "unknown",
      },
      { status: 503 }
    );
  }
}
