import { anthropic } from "@ai-sdk/anthropic";
import { openai } from "@ai-sdk/openai";
import { generateText } from "ai";

import type { AiChatMessage, AiChatRequest, AiChatResult } from "./types";
import { getServerEnv } from "@/lib/env.server";

function toAiSdkMessages(messages: AiChatMessage[]) {
  return messages.map((m) => ({
    role: m.role as "system" | "user" | "assistant",
    content: m.content,
  }));
}

export async function completeChat(req: AiChatRequest): Promise<AiChatResult> {
  const env = getServerEnv();
  const hasOpenAi = Boolean(env.OPENAI_API_KEY);
  const hasAnthropic = Boolean(env.ANTHROPIC_API_KEY);

  const resolved =
    env.AI_PROVIDER ?? (hasOpenAi ? "openai" : hasAnthropic ? "anthropic" : "mock");

  if (resolved === "mock" || (!hasOpenAi && !hasAnthropic)) {
    return {
      provider: "mock",
      model: "mock-v0",
      text: "AI no configurado: define OPENAI_API_KEY y/o ANTHROPIC_API_KEY y AI_PROVIDER opcionalmente.",
    };
  }

  if (resolved === "openai") {
    if (!env.OPENAI_API_KEY) {
      throw new Error("AI_PROVIDER is openai but OPENAI_API_KEY is unset");
    }

    const modelId = env.OPENAI_CHAT_MODEL ?? "gpt-4o-mini";
    const { text, usage } = await generateText({
      model: openai(modelId),
      messages: toAiSdkMessages(req.messages),
      temperature: 0.35,
      maxRetries: 1,
    });

    return {
      provider: "openai",
      model: modelId,
      text,
      usage: usage
        ? {
            promptTokens: usage.promptTokens ?? undefined,
            completionTokens: usage.completionTokens ?? undefined,
            totalTokens: usage.totalTokens ?? undefined,
          }
        : undefined,
    };
  }

  if (!env.ANTHROPIC_API_KEY) {
    throw new Error("AI_PROVIDER is anthropic but ANTHROPIC_API_KEY is unset");
  }

  const modelId = env.ANTHROPIC_CHAT_MODEL ?? "claude-sonnet-4-20250514";

  const { text, usage } = await generateText({
    model: anthropic(modelId),
    messages: toAiSdkMessages(req.messages),
    temperature: 0.35,
    maxRetries: 1,
  });

  return {
    provider: "anthropic",
    model: modelId,
    text,
    usage: usage
      ? {
          promptTokens: usage.promptTokens ?? undefined,
          completionTokens: usage.completionTokens ?? undefined,
          totalTokens: usage.totalTokens ?? undefined,
        }
      : undefined,
  };
}
