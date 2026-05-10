import { NextResponse } from "next/server";

export function GET() {
  return NextResponse.json({
    ok: true,
    service: "byrous-os-web",
    time: new Date().toISOString(),
  });
}
