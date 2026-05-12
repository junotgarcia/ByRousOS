// lib/supabase/server.ts
// Cliente Supabase server-side — service role key
// Solo para: API routes, Server Components, Server Actions
// Bypassea RLS — nunca exponer al cliente

import { createClient } from "@supabase/supabase-js";
import { getServerEnv } from "@/lib/env.server";

export function createSupabaseServerClient() {
  const env = getServerEnv();
  return createClient(
    env.NEXT_PUBLIC_SUPABASE_URL,
    env.SUPABASE_SERVICE_ROLE_KEY,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}
