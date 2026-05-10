export type AiProviderId = "openai" | "anthropic" | "mock";

export type AiChatMessageRole = "system" | "user" | "assistant";

export interface AiChatMessage {
  role: AiChatMessageRole;
  content: string;
}

/**
 * Narrow surface for assistants (CRM drafting, inbox triage, etc.).
 * Extend with tool-calling payloads when workflows need it.
 */
export interface AiChatRequest {
  messages: AiChatMessage[];
  metadata?: Record<string, string>;
}

export interface AiChatResult {
  text: string;
  model: string;
  provider: AiProviderId;
  usage?: {
    promptTokens?: number;
    completionTokens?: number;
    totalTokens?: number;
  };
}
