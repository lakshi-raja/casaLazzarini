import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:casa_lazzarini/core/theme/cl_colors.dart';
import 'package:casa_lazzarini/core/theme/cl_radius.dart';
import 'package:casa_lazzarini/core/theme/cl_spacing.dart';
import 'package:casa_lazzarini/core/theme/cl_typography.dart';
import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_type.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';
import 'package:casa_lazzarini/shared/widgets/cl_card.dart';
import 'package:casa_lazzarini/shared/widgets/cl_empty_state.dart';

import '../../domain/admin_providers.dart';
import '../admin_booking_detail_screen.dart';

class AdminDashboardTab extends ConsumerWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);
    final suitesAsync = ref.watch(adminSuitesProvider);

    return RefreshIndicator(
      color: CLColors.primary,
      onRefresh: () async {
        ref.invalidate(adminDashboardProvider);
        ref.invalidate(adminSuitesProvider);
        await ref.read(adminDashboardProvider.future);
      },
      child: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CLColors.primary),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(CLSpacing.base),
          children: [
            const SizedBox(height: CLSpacing.sm),
            _StatsGrid(stats: stats),
            const SizedBox(height: CLSpacing.xl),
            Text('Prenotazioni recenti', style: CLTypography.label),
            const SizedBox(height: CLSpacing.sm),
            if (stats.recentBookings.isEmpty)
              const CLEmptyState(
                icon: Icons.calendar_today_outlined,
                message: 'Nessuna prenotazione',
              )
            else
              ...stats.recentBookings.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: CLSpacing.sm),
                  child: _BookingTile(
                    booking: b,
                    suites: suitesAsync.valueOrNull ?? [],
                    onTap: () =>
                        _openDetail(context, b, suitesAsync.valueOrNull ?? []),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Booking booking, List<Suite> suites) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminBookingDetailScreen(booking: booking, suites: suites),
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: CLSpacing.sm,
      mainAxisSpacing: CLSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Prenotazioni attive',
          value: '${stats.activeBookings}',
          color: CLColors.available,
          icon: Icons.check_circle_outline,
        ),
        _StatCard(
          label: 'Cancellate',
          value: '${stats.cancelledBookings}',
          color: CLColors.unavailable,
          icon: Icons.cancel_outlined,
        ),
        _StatCard(
          label: 'Suite attive',
          value: '${stats.activeSuites} / ${stats.totalSuites}',
          color: CLColors.partiallyAvailable,
          icon: Icons.hotel_outlined,
        ),
        _StatCard(
          label: 'Ospiti registrati',
          value: '${stats.totalProfiles}',
          color: CLColors.primary,
          icon: Icons.people_outline,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CLCard(
      padding: const EdgeInsets.all(CLSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: CLTypography.headline.copyWith(color: color)),
              Text(label, style: CLTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Booking tile ──────────────────────────────────────────────────────────────

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.booking,
    required this.suites,
    required this.onTap,
  });

  final Booking booking;
  final List<Suite> suites;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final suite = suites.where((s) => s.id == booking.suiteId).firstOrNull;
    final suiteName = suite?.displayName ?? booking.suiteId.substring(0, 8);
    final dateLabel = DateFormat(
      'd MMM yyyy',
      'it',
    ).format(booking.bookingDate);
    final isActive = booking.status.name == 'active';

    return CLCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.base,
        vertical: CLSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? CLColors.available : CLColors.unavailable,
              borderRadius: CLRadius.smAll,
            ),
          ),
          const SizedBox(width: CLSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suiteName, style: CLTypography.label),
                Text(
                  '$dateLabel · ${booking.bookingType.italianLabel}',
                  style: CLTypography.caption,
                ),
              ],
            ),
          ),
          _StatusChip(isActive: isActive),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? CLColors.available.withValues(alpha: 0.12)
            : CLColors.unavailable.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isActive ? 'Attiva' : 'Cancellata',
        style: CLTypography.caption.copyWith(
          color: isActive ? CLColors.available : CLColors.unavailable,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CLSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: CLColors.destructive,
            ),
            const SizedBox(height: CLSpacing.md),
            Text(
              'Errore nel caricamento',
              style: CLTypography.label,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CLSpacing.xs),
            Text(
              message,
              style: CLTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: CLSpacing.lg),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Riprova',
                style: CLTypography.label.copyWith(color: CLColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
