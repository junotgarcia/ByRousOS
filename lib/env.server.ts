import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).optional(),
  OPENAI_API_KEY: z.string().min(1).optional(),
  ANTHROPIC_API_KEY: z.string().min(1).optional(),
  OPENAI_CHAT_MODEL: z.string().min(1).optional(),
  ANTHROPIC_CHAT_MODEL: z.string().min(1).optional(),
  AI_PROVIDER: z.enum(["openai", "anthropic", "mock"]).optional(),
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
