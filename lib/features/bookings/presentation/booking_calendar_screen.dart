import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_radius.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_type.dart';
import '../../../shared/models/suite.dart';
import '../../../shared/widgets/cl_primary_button.dart';
import '../domain/availability.dart';
import '../domain/booking_providers.dart';

class BookingCalendarScreen extends ConsumerWidget {
  const BookingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final bookingsAsync = ref.watch(monthActiveBookingsProvider);
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
        title: Text('Prenota', style: CLTypography.label),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MonthHeader(month: month),
            const _WeekdayLabels(),
            const SizedBox(height: CLSpacing.xs),
            Expanded(
              child: bookingsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, _) => _ErrorBody(
                  message: e is AppException
                      ? e.message
                      : 'Errore nel caricamento disponibilità.',
                ),
                data: (bookings) => suitesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  error: (e, _) => _ErrorBody(
                    message: e is AppException
                        ? e.message
                        : 'Errore nel caricamento suite.',
                  ),
                  data: (suites) => _CalendarGrid(
                    month: month,
                    bookings: bookings,
                    suites: suites,
                    onDayTap: (date) =>
                        _showBookingSheet(context, date, suites, bookings),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(
    BuildContext context,
    DateTime date,
    List<Suite> suites,
    List<Booking> activeBookings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CLColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: CLRadius.xlTop),
      builder: (_) => _BookingSheet(
        date: date,
        suites: suites,
        activeBookings: activeBookings,
      ),
    );
  }
}

// ── Month navigation header ────────────────────────────────────────────────

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.month});

  final DateTime month;

  static const _italianMonths = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final canGoBack =
        month.year > now.year ||
        (month.year == now.year && month.month > now.month);
    final label = '${_italianMonths[month.month - 1]} ${month.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.base,
        vertical: CLSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: canGoBack ? CLColors.textPrimary : CLColors.textMuted,
            onPressed: canGoBack
                ? () => ref.read(calendarMonthProvider.notifier).state =
                      DateTime(month.year, month.month - 1, 1)
                : null,
          ),
          Expanded(
            child: Text(
              label,
              style: CLTypography.label,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: CLColors.textPrimary,
            onPressed: () => ref.read(calendarMonthProvider.notifier).state =
                DateTime(month.year, month.month + 1, 1),
          ),
        ],
      ),
    );
  }
}

// ── Weekday row ────────────────────────────────────────────────────────────

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  static const _labels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CLSpacing.base),
      child: Row(
        children: [
          for (final l in _labels)
            Expanded(
              child: Center(
                child: Text(
                  l,
                  style: CLTypography.caption.copyWith(
                    color: CLColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Calendar grid ──────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.bookings,
    required this.suites,
    required this.onDayTap,
  });

  final DateTime month;
  final List<Booking> bookings;
  final List<Suite> suites;
  final void Function(DateTime) onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: 1=Mon … 7=Sun; offset for Monday-first grid
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    final cells = <Widget>[
      for (var i = 0; i < startOffset; i++) const SizedBox(),
      for (var day = 1; day <= daysInMonth; day++)
        Builder(
          builder: (context) {
            final date = DateTime(month.year, month.month, day);
            final isPast = date.isBefore(todayNorm);
            final isToday = date == todayNorm;
            final avail = isPast
                ? null
                : computeDateAvailability(bookings, date, suites.length);

            return _DayCell(
              day: day,
              isPast: isPast,
              isToday: isToday,
              availability: avail,
              onTap: isPast || avail == DateAvailability.unavailable
                  ? null
                  : () => onDayTap(date),
            );
          },
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.base,
        vertical: CLSpacing.xs,
      ),
      childAspectRatio: 0.95,
      children: cells,
    );
  }
}

// ── Day cell ───────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isPast,
    required this.isToday,
    required this.availability,
    required this.onTap,
  });

  final int day;
  final bool isPast;
  final bool isToday;
  final DateAvailability? availability;
  final VoidCallback? onTap;

  Color get _dotColor {
    if (isPast || availability == null) return Colors.transparent;
    switch (availability!) {
      case DateAvailability.available:
        return CLColors.available;
      case DateAvailability.partial:
        return CLColors.partiallyAvailable;
      case DateAvailability.unavailable:
        return CLColors.unavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isPast ? 0.35 : 1.0,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isToday ? CLColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday ? Border.all(color: CLColors.divider) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: CLTypography.caption.copyWith(
                  color: isDisabled && !isPast
                      ? CLColors.textMuted
                      : CLColors.textPrimary,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Booking bottom sheet ───────────────────────────────────────────────────

class _BookingSheet extends ConsumerStatefulWidget {
  const _BookingSheet({
    required this.date,
    required this.suites,
    required this.activeBookings,
  });

  final DateTime date;
  final List<Suite> suites;
  final List<Booking> activeBookings;

  @override
  ConsumerState<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<_BookingSheet> {
  Suite? _suite;
  BookingType? _type;
  String? _errorMessage;

  static const _italianMonths = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];

  String get _dateLabel {
    final d = widget.date;
    return '${d.day} ${_italianMonths[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: CLSpacing.xl,
        right: CLSpacing.xl,
        top: CLSpacing.base,
        bottom: MediaQuery.viewInsetsOf(context).bottom + CLSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CLColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: CLSpacing.base),

          Text(_dateLabel, style: CLTypography.headline),
          const SizedBox(height: CLSpacing.xl),

          // Suite selection
          Text('Suite', style: CLTypography.label),
          const SizedBox(height: CLSpacing.sm),
          Wrap(
            spacing: CLSpacing.sm,
            runSpacing: CLSpacing.sm,
            children: [
              for (final s in widget.suites)
                _Chip(
                  label: s.displayName,
                  selected: _suite?.id == s.id,
                  onTap: () => setState(() {
                    _suite = s;
                    _type = null;
                    _errorMessage = null;
                  }),
                ),
            ],
          ),

          if (_suite != null) ...[
            const SizedBox(height: CLSpacing.xl),
            Text('Tipologia', style: CLTypography.label),
            const SizedBox(height: CLSpacing.sm),
            _TypeRow(
              suite: _suite!,
              activeBookings: widget.activeBookings,
              date: widget.date,
              selectedType: _type,
              onSelect: (t) => setState(() {
                _type = t;
                _errorMessage = null;
              }),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: CLSpacing.base),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(CLSpacing.base),
              decoration: BoxDecoration(
                color: CLColors.destructiveContainer,
                borderRadius: CLRadius.mdAll,
              ),
              child: Text(
                _errorMessage!,
                style: CLTypography.caption.copyWith(
                  color: CLColors.destructive,
                ),
              ),
            ),
          ],

          const SizedBox(height: CLSpacing.xl),

          CLPrimaryButton(
            label: 'Prenota',
            isLoading: isLoading,
            onPressed: _suite != null && _type != null && !isLoading
                ? _confirm
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    try {
      await ref
          .read(bookingActionsProvider.notifier)
          .createBooking(suiteId: _suite!.id, date: widget.date, type: _type!);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prenotazione confermata!')),
        );
      }
    } on BookingConflictException catch (e) {
      setState(() => _errorMessage = e.message);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }
}

// ── Type availability row ──────────────────────────────────────────────────

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.suite,
    required this.activeBookings,
    required this.date,
    required this.selectedType,
    required this.onSelect,
  });

  final Suite suite;
  final List<Booking> activeBookings;
  final DateTime date;
  final BookingType? selectedType;
  final void Function(BookingType) onSelect;

  @override
  Widget build(BuildContext context) {
    final availability = computeSuiteTypeAvailability(
      activeBookings,
      date,
      suite.id,
    );

    return Wrap(
      spacing: CLSpacing.sm,
      runSpacing: CLSpacing.sm,
      children: [
        for (final type in BookingType.values)
          _Chip(
            label: type.italianLabel,
            selected: selectedType == type,
            enabled: availability[type] ?? false,
            onTap: availability[type] == true ? () => onSelect(type) : null,
          ),
      ],
    );
  }
}

// ── Selection chip ─────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.base,
          vertical: CLSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? CLColors.primary
              : (enabled ? CLColors.surfaceElevated : CLColors.inputFill),
          borderRadius: const BorderRadius.all(CLRadius.full),
          border: Border.all(
            color: selected ? CLColors.primary : CLColors.divider,
          ),
        ),
        child: Text(
          label,
          style: CLTypography.caption.copyWith(
            color: selected
                ? CLColors.textOnPrimary
                : (enabled ? CLColors.textPrimary : CLColors.textMuted),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Error body ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CLSpacing.xl),
        child: Text(
          message,
          style: CLTypography.body.copyWith(color: CLColors.destructive),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
