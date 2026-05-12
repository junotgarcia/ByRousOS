// lib/db/server.ts
// Cliente PostgreSQL directo — exclusivo para os.* (sistema operativo)
// Bypasea PostgREST. Solo server-side.

import postgres from "postgres";
import { getServerEnv } from "@/lib/env.server";

let _sql: ReturnType<typeof postgres> | null = null;

export function getDb() {
  if (!_sql) {
    const { DATABASE_URL } = getServerEnv();
    _sql = postgres(DATABASE_URL, { max: 5 });
  }
  return _sql;
}
