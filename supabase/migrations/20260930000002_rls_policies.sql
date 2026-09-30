-- =============================================================================
-- Migration: 20260930000002_rls_policies.sql
-- Description: Row-Level Security policies for all public tables
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enable RLS
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suites   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- Helper: is_super_admin()
--
-- SECURITY: SECURITY DEFINER with a locked search_path prevents search_path
-- injection attacks. The function reads the authoritative profiles table —
-- NOT a client-supplied JWT claim — so a user cannot self-elevate by crafting
-- a token with app_metadata.role = 'super_admin'.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

-- =============================================================================
-- profiles policies
-- =============================================================================

-- Users may read their own profile row.
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Users may read the profile of anyone who has an ACTIVE booking.
-- Required so the calendar can display "Prenotata da <full_name>".
DROP POLICY IF EXISTS "profiles_select_booking_owner" ON public.profiles;
CREATE POLICY "profiles_select_booking_owner" ON public.profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.bookings b
      WHERE b.user_id = profiles.id
        AND b.status  = 'ACTIVE'
    )
  );

-- Users may update their own profile (name), but CANNOT elevate their role.
--
-- SECURITY: The WITH CHECK subquery re-reads the stored role from the DB
-- and requires the new row's role to match it. This prevents a user from
-- sneaking in a different role value through an UPDATE statement.
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Prevent self-elevation: new role must equal the current stored role
    AND role = (SELECT role FROM public.profiles WHERE id = auth.uid())
  );

-- Super admin may read any profile.
DROP POLICY IF EXISTS "profiles_select_admin" ON public.profiles;
CREATE POLICY "profiles_select_admin" ON public.profiles
  FOR SELECT USING (is_super_admin());

-- Super admin may update any profile (including role promotion/demotion).
DROP POLICY IF EXISTS "profiles_update_admin" ON public.profiles;
CREATE POLICY "profiles_update_admin" ON public.profiles
  FOR UPDATE USING (is_super_admin());

-- =============================================================================
-- suites policies
-- =============================================================================

-- Authenticated users see active suites only.
DROP POLICY IF EXISTS "suites_select_authenticated" ON public.suites;
CREATE POLICY "suites_select_authenticated" ON public.suites
  FOR SELECT USING (auth.role() = 'authenticated' AND active = TRUE);

-- Super admin sees all suites regardless of active flag.
DROP POLICY IF EXISTS "suites_select_admin" ON public.suites;
CREATE POLICY "suites_select_admin" ON public.suites
  FOR SELECT USING (is_super_admin());

-- Only super admin can INSERT / UPDATE / DELETE suites.
DROP POLICY IF EXISTS "suites_admin_all" ON public.suites;
CREATE POLICY "suites_admin_all" ON public.suites
  FOR ALL USING (is_super_admin());

-- =============================================================================
-- bookings policies
-- =============================================================================

-- All authenticated users can read ACTIVE bookings.
-- This is intentional: the calendar must show which slots are taken so that
-- any user can see availability before attempting to book.
DROP POLICY IF EXISTS "bookings_select_active" ON public.bookings;
CREATE POLICY "bookings_select_active" ON public.bookings
  FOR SELECT USING (auth.role() = 'authenticated' AND status = 'ACTIVE');

-- Users may insert bookings only for themselves.
DROP POLICY IF EXISTS "bookings_insert_own" ON public.bookings;
CREATE POLICY "bookings_insert_own" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users may update only their own ACTIVE bookings (e.g. to cancel them).
DROP POLICY IF EXISTS "bookings_update_own" ON public.bookings;
CREATE POLICY "bookings_update_own" ON public.bookings
  FOR UPDATE
  USING (auth.uid() = user_id AND status = 'ACTIVE')
  WITH CHECK (auth.uid() = user_id);

-- Super admin can read all bookings (including cancelled ones).
DROP POLICY IF EXISTS "bookings_select_admin" ON public.bookings;
CREATE POLICY "bookings_select_admin" ON public.bookings
  FOR SELECT USING (is_super_admin());

-- Super admin can update any booking.
DROP POLICY IF EXISTS "bookings_update_admin" ON public.bookings;
CREATE POLICY "bookings_update_admin" ON public.bookings
  FOR UPDATE USING (is_super_admin());

-- =============================================================================
-- Schema usage and table privileges for the authenticated role
--
-- RLS controls row visibility; these GRANTs allow the role to reach the tables
-- in the first place. Without GRANT USAGE ON SCHEMA the client receives a
-- "permission denied for schema public" error even when RLS would allow the row.
-- RLS policies remain the security boundary — these grants are additive only.
-- =============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;

GRANT SELECT                       ON TABLE public.profiles TO authenticated;
GRANT SELECT                       ON TABLE public.suites   TO authenticated;
GRANT SELECT, INSERT, UPDATE       ON TABLE public.bookings TO authenticated;

GRANT INSERT, UPDATE, DELETE       ON TABLE public.profiles TO authenticated;
GRANT INSERT, UPDATE, DELETE       ON TABLE public.suites   TO authenticated;
GRANT DELETE                       ON TABLE public.bookings TO authenticated;
