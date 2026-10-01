-- =============================================================================
-- Migration: 20260930000003_fix_bookings_select_own.sql
-- Description: Allow users to SELECT their own bookings regardless of status
-- =============================================================================
--
-- Without this policy, cancelBooking() fails with "new row violates row-level
-- security policy". Root cause: PostgREST checks that the updated row is
-- visible via SELECT after writing. When status flips ACTIVE → CANCELLED, the
-- existing bookings_select_active policy (requires status = 'ACTIVE') blocks
-- visibility of the resulting row and PostgREST rejects the UPDATE.
--
-- This also makes getMyBookings() return cancelled bookings so users can see
-- their full booking history.
-- =============================================================================

DROP POLICY IF EXISTS "bookings_select_own" ON public.bookings;
CREATE POLICY "bookings_select_own" ON public.bookings
  FOR SELECT USING (auth.uid() = user_id);
