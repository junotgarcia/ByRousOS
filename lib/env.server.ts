import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).optional(),
  OPENAI_API_KEY: z.string().min(1).optional(),
  ANTHROPIC_API_KEY: z.string().min(1).optional(),
  OPENAI_CHAT_MODEL: z.string().min(1).optional(),
  ANTHROPIC_CHAT_MODEL: z.string().min(1).optional(),
  AI_PROVIDER: z.enum(["openai", "anthropic", "mock"]).optional(),
  // Supabase (PostgREST — sbr.* únicamente)
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  // PostgreSQL directo — os.* únicamente
  DATABASE_URL: z.string().min(1),
});

/**
 * Validates process.env (call from Route Handlers, Server Actions, `lib/server/*`).
 */
export function getServerEnv() {
  const parsed = schema.safeParse(process.env);
  if (!parsed.success) {
    const msg = parsed.error.flatten().fieldErrors;
    throw new Error(`Invalid environment: ${JSON.stringify(msg)}`);
  }
  return parsed.data;
}

export type ServerEnv = z.infer<typeof schema>;
