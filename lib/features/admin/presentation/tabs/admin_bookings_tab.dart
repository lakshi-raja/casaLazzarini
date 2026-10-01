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
import 'package:casa_lazzarini/shared/models/suite.dart';
import 'package:casa_lazzarini/shared/widgets/cl_card.dart';
import 'package:casa_lazzarini/shared/widgets/cl_empty_state.dart';

import '../../domain/admin_providers.dart';
import '../../domain/booking_filter.dart';
import '../admin_booking_detail_screen.dart';

class AdminBookingsTab extends ConsumerWidget {
  const AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(bookingFilterProvider);
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final suitesAsync = ref.watch(adminSuitesProvider);
    final suites = suitesAsync.valueOrNull ?? [];

    return Column(
      children: [
        _FilterBar(filter: filter, suites: suites),
        Expanded(
          child: RefreshIndicator(
            color: CLColors.primary,
            onRefresh: () async {
              ref.invalidate(adminBookingsProvider);
              await ref.read(adminBookingsProvider.future);
            },
            child: bookingsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: CLColors.primary),
              ),
              error: (e, _) => _ErrorRetry(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminBookingsProvider),
              ),
              data: (bookings) => bookings.isEmpty
                  ? const CLEmptyState(
                      icon: Icons.calendar_today_outlined,
                      message: 'Nessuna prenotazione trovata',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(CLSpacing.base),
                      itemCount: bookings.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: CLSpacing.sm),
                      itemBuilder: (context, i) {
                        final b = bookings[i];
                        return _BookingRow(
                          booking: b,
                          suites: suites,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AdminBookingDetailScreen(
                                booking: b,
                                suites: suites,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter, required this.suites});
  final BookingFilter filter;
  final List<Suite> suites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(bookingFilterProvider.notifier);

    return Container(
      color: CLColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: CLSpacing.base,
              vertical: CLSpacing.sm,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tutte',
                  selected: filter.status == null,
                  onTap: () => notifier.setStatus(null),
                ),
                const SizedBox(width: CLSpacing.xs),
                _FilterChip(
                  label: 'Attive',
                  selected: filter.status == BookingStatus.active,
                  onTap: () => notifier.setStatus(BookingStatus.active),
                  selectedColor: CLColors.available,
                ),
                const SizedBox(width: CLSpacing.xs),
                _FilterChip(
                  label: 'Cancellate',
                  selected: filter.status == BookingStatus.cancelled,
                  onTap: () => notifier.setStatus(BookingStatus.cancelled),
                  selectedColor: CLColors.unavailable,
                ),
                if (suites.isNotEmpty) ...[
                  const SizedBox(width: CLSpacing.sm),
                  _SuiteDropdown(
                    suites: suites,
                    selectedId: filter.suiteId,
                    onChanged: notifier.setSuiteId,
                  ),
                ],
                const SizedBox(width: CLSpacing.sm),
                _DateRangeButton(filter: filter, notifier: notifier),
                if (!filter.isEmpty) ...[
                  const SizedBox(width: CLSpacing.sm),
                  GestureDetector(
                    onTap: notifier.clear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CLSpacing.sm,
                        vertical: CLSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: CLColors.divider),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.close,
                            size: 14,
                            color: CLColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Reset',
                            style: CLTypography.caption.copyWith(
                              color: CLColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: CLColors.divider),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? CLColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.md,
          vertical: CLSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: selected ? accent : CLColors.divider),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: CLTypography.caption.copyWith(
            color: selected ? accent : CLColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SuiteDropdown extends StatelessWidget {
  const _SuiteDropdown({
    required this.suites,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Suite> suites;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.md,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedId != null ? CLColors.primary : CLColors.divider,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          hint: Text('Suite', style: CLTypography.caption),
          style: CLTypography.caption.copyWith(color: CLColors.textPrimary),
          isDense: true,
          borderRadius: CLRadius.mdAll,
          icon: const Icon(
            Icons.expand_more,
            size: 14,
            color: CLColors.textSecondary,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Tutte le suite', style: CLTypography.caption),
            ),
            ...suites.map(
              (s) => DropdownMenuItem<String?>(
                value: s.id,
                child: Text(s.displayName, style: CLTypography.caption),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.filter, required this.notifier});
  final BookingFilter filter;
  final BookingFilterNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final hasRange = filter.dateFrom != null || filter.dateTo != null;
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.md,
          vertical: CLSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: hasRange
              ? CLColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: hasRange ? CLColors.primary : CLColors.divider,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_outlined,
              size: 14,
              color: hasRange ? CLColors.primary : CLColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              hasRange ? _label() : 'Periodo',
              style: CLTypography.caption.copyWith(
                color: hasRange ? CLColors.primary : CLColors.textSecondary,
                fontWeight: hasRange ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label() {
    final fmt = DateFormat('d MMM', 'it');
    if (filter.dateFrom != null && filter.dateTo != null) {
      return '${fmt.format(filter.dateFrom!)} – ${fmt.format(filter.dateTo!)}';
    }
    if (filter.dateFrom != null) return '≥ ${fmt.format(filter.dateFrom!)}';
    return '≤ ${fmt.format(filter.dateTo!)}';
  }

  Future<void> _pick(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: filter.dateFrom != null && filter.dateTo != null
          ? DateTimeRange(start: filter.dateFrom!, end: filter.dateTo!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: CLColors.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      notifier.setDateRange(range.start, range.end);
    }
  }
}

// ── Booking row ───────────────────────────────────────────────────────────────

class _BookingRow extends StatelessWidget {
  const _BookingRow({
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
    final suiteName = suite?.displayName ?? '—';
    final dateLabel = DateFormat(
      'd MMM yyyy',
      'it',
    ).format(booking.bookingDate);
    final isActive = booking.status == BookingStatus.active;

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
            height: 44,
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
                Row(
                  children: [
                    Text(suiteName, style: CLTypography.label),
                    const Spacer(),
                    _StatusChip(isActive: isActive),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel · ${booking.bookingType.italianLabel}',
                  style: CLTypography.caption,
                ),
                Text(
                  booking.userId.substring(0, 8),
                  style: CLTypography.caption.copyWith(
                    color: CLColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CLSpacing.sm),
          const Icon(Icons.chevron_right, size: 18, color: CLColors.textMuted),
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

// ── Error / retry ─────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
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
            Text('Errore nel caricamento', style: CLTypography.label),
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
