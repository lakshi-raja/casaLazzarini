import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_radius.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_status.dart';
import '../../../shared/models/booking_type.dart';
import '../../../shared/models/suite.dart';
import '../../../shared/widgets/cl_empty_state.dart';
import '../domain/booking_providers.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBookingsAsync = ref.watch(myBookingsProvider);
    final suitesAsync = ref.watch(suitesProvider);

    return Scaffold(
      backgroundColor: CLColors.background,
      appBar: AppBar(
        backgroundColor: CLColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: CLColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text('Le mie prenotazioni', style: CLTypography.label),
        centerTitle: true,
      ),
      body: SafeArea(
        child: myBookingsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(CLSpacing.xl),
              child: Text(
                e is AppException ? e.message : 'Errore nel caricamento.',
                style: CLTypography.body.copyWith(color: CLColors.destructive),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (bookings) => suitesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (_, _) => const SizedBox(),
            data: (suites) {
              if (bookings.isEmpty) {
                return const CLEmptyState(
                  icon: Icons.bookmark_outline_rounded,
                  message: 'Nessuna prenotazione ancora.',
                );
              }
              return _BookingList(bookings: bookings, suites: suites);
            },
          ),
        ),
      ),
    );
  }
}

// ── List with upcoming / past sections ────────────────────────────────────

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings, required this.suites});

  final List<Booking> bookings;
  final List<Suite> suites;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final upcoming =
        bookings.where((b) => !b.bookingDate.isBefore(today)).toList()
          ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

    final past = bookings.where((b) => b.bookingDate.isBefore(today)).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

    final suiteMap = {for (final s in suites) s.id: s};

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.xl,
        vertical: CLSpacing.base,
      ),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(label: 'Prossime'),
          const SizedBox(height: CLSpacing.sm),
          for (final b in upcoming)
            _BookingCard(booking: b, suite: suiteMap[b.suiteId]),
        ],
        if (past.isNotEmpty) ...[
          if (upcoming.isNotEmpty) const SizedBox(height: CLSpacing.base),
          _SectionLabel(label: 'Passate'),
          const SizedBox(height: CLSpacing.sm),
          for (final b in past)
            _BookingCard(booking: b, suite: suiteMap[b.suiteId]),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: CLTypography.caption.copyWith(
        color: CLColors.textMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Individual booking card ────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.suite});

  final Booking booking;
  final Suite? suite;

  static const _italianMonths = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];

  @override
  Widget build(BuildContext context) {
    final d = booking.bookingDate;
    final dateLabel = '${d.day} ${_italianMonths[d.month - 1]} ${d.year}';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.bookingDetailPath(booking.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: CLSpacing.base),
        padding: const EdgeInsets.all(CLSpacing.xl),
        decoration: BoxDecoration(
          color: CLColors.surface,
          borderRadius: CLRadius.lgAll,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    suite?.displayName ?? '—',
                    style: CLTypography.label,
                  ),
                ),
                const SizedBox(width: CLSpacing.sm),
                _StatusBadge(status: booking.status),
                const SizedBox(width: CLSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: CLColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: CLSpacing.xs),
            Text(
              '$dateLabel  ·  ${booking.bookingType.italianLabel}',
              style: CLTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == BookingStatus.active;
    final color = isActive ? CLColors.available : CLColors.textMuted;
    final label = isActive ? 'Attiva' : 'Cancellata';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.sm,
        vertical: CLSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: CLRadius.smAll,
      ),
      child: Text(
        label,
        style: CLTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
