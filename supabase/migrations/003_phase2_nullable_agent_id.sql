-- supabase/migrations/003_phase2_nullable_agent_id.sql
-- Phase 2.1 — Allow Command Intake without active agents
-- Makes os.commands.agent_id nullable to support system-originated commands
-- before agent registration (Fase 3).
-- Approved by: CEO — 2026-05-14
-- Reversible: YES — ALTER TABLE os.commands ALTER COLUMN agent_id SET NOT NULL

ALTER TABLE os.commands ALTER COLUMN agent_id DROP NOT NULL;

COMMENT ON COLUMN os.commands.agent_id IS
  'NULL allowed from Phase 2.1: system-originated commands have no registered agent. '
  'Will be required again when active agents are registered in Phase 3.';
