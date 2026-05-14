// app/api/commands/route.ts
// Phase 2.1 — Execution Core Basic
// POST /api/commands — intake a new command
// GET  /api/commands — list recent commands

import { NextRequest, NextResponse } from 'next/server'
import { intakeCommand, listCommands } from '@/lib/execution/command-intake'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()

    if (!body.type || typeof body.type !== 'string') {
      return NextResponse.json(
        { error: 'Missing or invalid field: type' },
        { status: 400 }
      )
    }

    if (!body.payload || typeof body.payload !== 'object') {
      return NextResponse.json(
        { error: 'Missing or invalid field: payload' },
        { status: 400 }
      )
    }

    const result = await intakeCommand({
      type: body.type,
      payload: body.payload,
      confidence_score: body.confidence_score,
      correlation_id: body.correlation_id,
    })

    if (!result.success) {
      return NextResponse.json({ error: result.error }, { status: 500 })
    }

    return NextResponse.json(result, { status: 201 })
  } catch (err) {
    return NextResponse.json(
      { error: `Unexpected error: ${String(err)}` },
      { status: 500 }
    )
  }
}

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url)
    const limit = Math.min(parseInt(searchParams.get('limit') ?? '20'), 100)
    const offset = parseInt(searchParams.get('offset') ?? '0')

    const commands = await listCommands(limit, offset)

    return NextResponse.json({ commands, limit, offset })
  } catch (err) {
    return NextResponse.json(
      { error: `Unexpected error: ${String(err)}` },
      { status: 500 }
    )
  }
}
