-- =============================================================================
-- seed.sql
-- Description: Seed data for Casa Lazzarini
-- Safe to run multiple times — ON CONFLICT DO NOTHING makes it idempotent.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Suites
-- Fixed UUIDs allow deterministic references in tests and local dev.
-- ---------------------------------------------------------------------------
INSERT INTO public.suites (id, code, display_name, active)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'SUITE_1', 'Suite n.1', TRUE),
  ('00000000-0000-0000-0000-000000000002', 'SUITE_2', 'Suite n.2', TRUE),
  ('00000000-0000-0000-0000-000000000003', 'SUITE_3', 'Suite n.3', TRUE)
ON CONFLICT (code) DO NOTHING;
