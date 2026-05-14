// app/api/commands/[id]/route.ts
// Phase 2.1 — Execution Core Basic
// GET /api/commands/:id — get command status and detail

import { NextRequest, NextResponse } from 'next/server'
import { getCommand } from '@/lib/execution/command-intake'

export async function GET(
  _req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params

    if (!id || typeof id !== 'string') {
      return NextResponse.json({ error: 'Invalid command id' }, { status: 400 })
    }

    const command = await getCommand(id)

    if (!command) {
      return NextResponse.json({ error: 'Command not found' }, { status: 404 })
    }

    return NextResponse.json({ command })
  } catch (err) {
    return NextResponse.json(
      { error: `Unexpected error: ${String(err)}` },
      { status: 500 }
    )
  }
}
