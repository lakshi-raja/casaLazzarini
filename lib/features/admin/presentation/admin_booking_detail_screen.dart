import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:casa_lazzarini/core/theme/cl_colors.dart';
import 'package:casa_lazzarini/core/theme/cl_radius.dart';
import 'package:casa_lazzarini/core/theme/cl_spacing.dart';
import 'package:casa_lazzarini/core/theme/cl_typography.dart';
import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:casa_lazzarini/shared/models/booking_type.dart';
import 'package:casa_lazzarini/shared/models/profile.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';
import 'package:casa_lazzarini/shared/widgets/cl_card.dart';

import '../domain/admin_providers.dart';

class AdminBookingDetailScreen extends ConsumerStatefulWidget {
  const AdminBookingDetailScreen({
    super.key,
    required this.booking,
    required this.suites,
  });

  final Booking booking;
  final List<Suite> suites;

  @override
  ConsumerState<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState
    extends ConsumerState<AdminBookingDetailScreen> {
  bool _cancelling = false;

  Suite? get _suite =>
      widget.suites.where((s) => s.id == widget.booking.suiteId).firstOrNull;

  Profile? _guestProfile(List<Profile> profiles) =>
      profiles.where((p) => p.id == widget.booking.userId).firstOrNull;

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CLColors.surface,
        shape: RoundedRectangleBorder(borderRadius: CLRadius.lgAll),
        title: Text('Cancella prenotazione', style: CLTypography.title),
        content: Text(
          'Vuoi cancellare questa prenotazione? L\'azione non può essere annullata.',
          style: CLTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annulla',
              style: CLTypography.label.copyWith(color: CLColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Conferma',
              style: CLTypography.label.copyWith(color: CLColors.destructive),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);

    try {
      await ref.read(adminRepositoryProvider).cancelBooking(widget.booking.id);
      ref.invalidate(adminBookingsProvider);
      ref.invalidate(adminDashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Prenotazione cancellata.',
              style: CLTypography.caption.copyWith(
                color: CLColors.textOnPrimary,
              ),
            ),
            backgroundColor: CLColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore: ${e.toString()}',
              style: CLTypography.caption.copyWith(
                color: CLColors.textOnPrimary,
              ),
            ),
            backgroundColor: CLColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isActive = booking.status == BookingStatus.active;
    final profilesAsync = ref.watch(adminProfilesProvider);
    final guest = profilesAsync.whenOrNull(data: _guestProfile);
    final suite = _suite;
    final dateFmt = DateFormat('d MMMM yyyy', 'it');
    final tsFmt = DateFormat('d MMM yyyy – HH:mm', 'it');

    return Scaffold(
      backgroundColor: CLColors.background,
      appBar: AppBar(
        backgroundColor: CLColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Dettaglio prenotazione', style: CLTypography.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CLColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CLSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status banner ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CLSpacing.base,
                vertical: CLSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? CLColors.available.withValues(alpha: 0.10)
                    : CLColors.unavailable.withValues(alpha: 0.10),
                borderRadius: CLRadius.mdAll,
                border: Border.all(
                  color: isActive
                      ? CLColors.available.withValues(alpha: 0.30)
                      : CLColors.unavailable.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: isActive ? CLColors.available : CLColors.unavailable,
                    size: 20,
                  ),
                  const SizedBox(width: CLSpacing.sm),
                  Text(
                    isActive
                        ? 'Prenotazione attiva'
                        : 'Prenotazione cancellata',
                    style: CLTypography.label.copyWith(
                      color: isActive
                          ? CLColors.available
                          : CLColors.unavailable,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: CLSpacing.base),

            // ── Booking details ─────────────────────────────────────────────
            CLCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.hotel_outlined,
                    label: 'Suite',
                    value: suite?.displayName ?? '—',
                    subtitle: suite?.code,
                  ),
                  _Divider(),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Data',
                    value: dateFmt.format(booking.bookingDate),
                  ),
                  _Divider(),
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Tipo',
                    value: booking.bookingType.italianLabel,
                  ),
                ],
              ),
            ),

            const SizedBox(height: CLSpacing.sm),

            // ── Guest info ──────────────────────────────────────────────────
            CLCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Ospite',
                    value: guest?.fullName ?? '—',
                    subtitle: booking.userId.substring(0, 16),
                    loading: profilesAsync.isLoading,
                  ),
                ],
              ),
            ),

            const SizedBox(height: CLSpacing.sm),

            // ── Timestamps ──────────────────────────────────────────────────
            CLCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.add_circle_outline,
                    label: 'Creata il',
                    value: tsFmt.format(booking.createdAt.toLocal()),
                  ),
                  _Divider(),
                  _DetailRow(
                    icon: Icons.update_outlined,
                    label: 'Aggiornata il',
                    value: tsFmt.format(booking.updatedAt.toLocal()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: CLSpacing.xl),

            // ── Cancel action ───────────────────────────────────────────────
            if (isActive)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CLColors.destructiveContainer,
                    foregroundColor: CLColors.destructive,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: CLRadius.mdAll),
                  ),
                  onPressed: _cancelling ? null : _confirmCancel,
                  child: _cancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CLColors.destructive,
                          ),
                        )
                      : Text(
                          'Cancella prenotazione',
                          style: CLTypography.label.copyWith(
                            color: CLColors.destructive,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: CLSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CLSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: CLColors.textSecondary),
          const SizedBox(width: CLSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: CLTypography.caption),
                if (loading)
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: CLColors.textMuted,
                    ),
                  )
                else
                  Text(value, style: CLTypography.body),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: CLTypography.caption.copyWith(
                      color: CLColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: CLColors.divider);
}
