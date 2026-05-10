import { NextResponse } from "next/server";
import { z } from "zod";

import { completeChat } from "@/lib/ai";

const bodySchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(["system", "user", "assistant"]),
      content: z.string().min(1),
    }),
  ),
});

/** Example JSON endpoint reserved for assistants (protect with auth before production). */
export async function POST(req: Request) {
  try {
    const json = await req.json();
    const parsed = bodySchema.safeParse(json);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid body" }, { status: 400 });
    }
    const result = await completeChat(parsed.data);
    return NextResponse.json(result);
  } catch {
    return NextResponse.json({ error: "Chat failed" }, { status: 500 });
  }
}
