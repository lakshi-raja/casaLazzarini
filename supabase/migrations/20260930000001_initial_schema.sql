-- =============================================================================
-- Migration: 20260930000001_initial_schema.sql
-- Description: Initial schema for Casa Lazzarini — profiles, suites, bookings
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Utility: auto-update updated_at on row modification
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: profiles
-- One row per auth.users entry, created automatically by handle_new_user().
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT        NOT NULL,
  -- role is intentionally limited to known values; elevation requires a
  -- privileged server-side operation — never a client-supplied value.
  role        TEXT        NOT NULL DEFAULT 'user'
                          CHECK (role IN ('user', 'super_admin')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index: fast admin queries by role
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles (role);

-- Trigger: keep updated_at current
CREATE TRIGGER trg_profiles_set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Table: suites
-- The three bookable suites of the property.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.suites (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code         TEXT        NOT NULL UNIQUE,
  display_name TEXT        NOT NULL,
  active       BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- Table: bookings
-- A booking ties a user to a suite for a specific date and time-slot.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bookings (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  suite_id     UUID        NOT NULL REFERENCES public.suites(id),
  booking_date DATE        NOT NULL,
  -- Time-slot within the day:
  --   AFTERNOON_MORNING  — afternoon + next morning
  --   MORNING_NIGHT      — morning + night of the same day
  --   NIGHT              — night slot only
  booking_type TEXT        NOT NULL
                           CHECK (booking_type IN (
                             'AFTERNOON_MORNING',
                             'MORNING_NIGHT',
                             'NIGHT'
                           )),
  status       TEXT        NOT NULL DEFAULT 'ACTIVE'
                           CHECK (status IN ('ACTIVE', 'CANCELLED')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes: common query access patterns
CREATE INDEX IF NOT EXISTS idx_bookings_user_id      ON public.bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_suite_id     ON public.bookings (suite_id);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_date ON public.bookings (booking_date);

-- ANTI-DOUBLE-BOOKING GUARANTEE
-- A plain UNIQUE constraint would prevent re-use of a (suite, date, slot) tuple
-- even after a booking is cancelled. A PARTIAL UNIQUE INDEX scoped to
-- status = 'ACTIVE' allows cancelled bookings to coexist while still
-- preventing two active bookings from occupying the same slot.
-- This is the database-level enforcement — the app layer is a secondary check.
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookings_no_conflict
  ON public.bookings (suite_id, booking_date, booking_type)
  WHERE status = 'ACTIVE';

-- Trigger: keep updated_at current
CREATE TRIGGER trg_bookings_set_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Trigger: auto-create a profile row when a new auth user is registered.
--
-- SECURITY: role is hardcoded to 'user' here.
-- The Flutter client cannot supply a privileged role during signup because
-- raw_user_meta_data is client-controlled. Only a server-side privileged
-- operation (direct DB or service-role call) can set role = 'super_admin'.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Utente'),
    'user'  -- always default to 'user'; never trust client-supplied role
  );
  RETURN NEW;
END;
$$;

-- Drop before recreate to make this idempotent
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
