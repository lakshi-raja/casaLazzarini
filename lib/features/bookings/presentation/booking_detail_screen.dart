import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/navigation_utils.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_radius.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_status.dart';
import '../../../shared/models/booking_type.dart';
import '../../../shared/models/suite.dart';
import '../../../shared/widgets/cl_dialog.dart';
import '../../../shared/widgets/cl_empty_state.dart';
import '../../../shared/widgets/cl_primary_button.dart';
import '../../../shared/widgets/cl_secondary_button.dart';
import '../domain/booking_providers.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final suitesAsync = ref.watch(suitesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) goBackOrHome(context);
      },
      child: Scaffold(
        backgroundColor: CLColors.background,
        appBar: AppBar(
          backgroundColor: CLColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: CLColors.textPrimary,
            onPressed: () => goBackOrHome(context),
          ),
          title: Text('Prenotazione', style: CLTypography.label),
          centerTitle: true,
        ),
        body: SafeArea(
          child: bookingsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(CLSpacing.xl),
                child: Text(
                  e is AppException ? e.message : 'Errore nel caricamento.',
                  style: CLTypography.body.copyWith(
                    color: CLColors.destructive,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (bookings) {
              final booking = bookings
                  .where((b) => b.id == bookingId)
                  .firstOrNull;
              if (booking == null) {
                return const CLEmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'Prenotazione non trovata.',
                );
              }
              return suitesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, _) => const SizedBox(),
                data: (suites) {
                  final suite = suites
                      .where((s) => s.id == booking.suiteId)
                      .firstOrNull;
                  return _DetailBody(booking: booking, suite: suite);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.booking, required this.suite});

  final Booking booking;
  final Suite? suite;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = booking.bookingDate;
    final dateLabel = '${d.day} ${_italianMonths[d.month - 1]} ${d.year}';
    final isActive = booking.status == BookingStatus.active;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(CLSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: CLSpacing.xl,
              vertical: CLSpacing.base,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? CLColors.available.withValues(alpha: 0.1)
                  : CLColors.textMuted.withValues(alpha: 0.08),
              borderRadius: CLRadius.lgAll,
              border: Border.all(
                color: isActive
                    ? CLColors.available.withValues(alpha: 0.25)
                    : CLColors.divider,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? CLColors.available : CLColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: CLSpacing.sm),
                Text(
                  isActive ? 'Prenotazione attiva' : 'Prenotazione cancellata',
                  style: CLTypography.label.copyWith(
                    color: isActive ? CLColors.available : CLColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: CLSpacing.xl),

          // Details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CLSpacing.xl),
            decoration: BoxDecoration(
              color: CLColors.surface,
              borderRadius: CLRadius.lgAll,
              border: Border.all(color: CLColors.divider, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Suite', value: suite?.displayName ?? '—'),
                const SizedBox(height: CLSpacing.base),
                _DetailRow(label: 'Data', value: dateLabel),
                const SizedBox(height: CLSpacing.base),
                _DetailRow(
                  label: 'Tipologia',
                  value: booking.bookingType.italianLabel,
                ),
              ],
            ),
          ),

          if (isActive) ...[
            const SizedBox(height: CLSpacing.xl),
            CLSecondaryButton(
              label: 'Cancella prenotazione',
              onPressed: () => _confirmCancel(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await CLDialog.show<bool>(
      context: context,
      title: 'Cancella prenotazione',
      content: const Text(
        'Sei sicuro di voler cancellare questa prenotazione? '
        "L'operazione non è reversibile.",
      ),
      actions: [
        CLSecondaryButton(
          label: 'Mantieni',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CLPrimaryButton(
          label: 'Cancella',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed != true) return;

    try {
      await ref.read(bookingActionsProvider.notifier).cancelBooking(booking.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prenotazione cancellata.')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: CLTypography.caption.copyWith(color: CLColors.textMuted),
          ),
        ),
        Expanded(child: Text(value, style: CLTypography.label)),
      ],
    );
  }
}
