import { NextResponse } from "next/server";

import { getServerEnv } from "@/lib/env.server";

/** Does not expose secret values — only readiness hints for dashboards/ops. */
export function GET() {
  try {
    const env = getServerEnv();
    const hasOpenAi = Boolean(env.OPENAI_API_KEY);
    const hasAnthropic = Boolean(env.ANTHROPIC_API_KEY);
    const configured = hasOpenAi || hasAnthropic;
    const provider =
      env.AI_PROVIDER ?? (hasOpenAi ? "openai" : hasAnthropic ? "anthropic" : "none");

    const openaiModel = env.OPENAI_CHAT_MODEL ?? "gpt-4o-mini";
    const anthropicModel = env.ANTHROPIC_CHAT_MODEL ?? "claude-sonnet-4-20250514";

    return NextResponse.json({
      ai: {
        configured,
        provider,
        models: {
          openai: openaiModel,
          anthropic: anthropicModel,
        },
      },
    });
  } catch {
    return NextResponse.json(
      { ai: { configured: false, provider: "error" } },
      { status: 500 },
    );
  }
}
