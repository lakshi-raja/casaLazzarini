import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:casa_lazzarini/core/theme/cl_colors.dart';
import 'package:casa_lazzarini/core/theme/cl_spacing.dart';
import 'package:casa_lazzarini/core/theme/cl_typography.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';
import 'package:casa_lazzarini/shared/widgets/cl_card.dart';
import 'package:casa_lazzarini/shared/widgets/cl_empty_state.dart';

import '../../domain/admin_providers.dart';

class AdminSuitesTab extends ConsumerWidget {
  const AdminSuitesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suitesAsync = ref.watch(adminSuitesProvider);

    return RefreshIndicator(
      color: CLColors.primary,
      onRefresh: () async {
        ref.invalidate(adminSuitesProvider);
        await ref.read(adminSuitesProvider.future);
      },
      child: suitesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CLColors.primary),
        ),
        error: (e, _) => _ErrorRetry(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminSuitesProvider),
        ),
        data: (suites) => suites.isEmpty
            ? const CLEmptyState(
                icon: Icons.hotel_outlined,
                message: 'Nessuna suite trovata',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(CLSpacing.base),
                itemCount: suites.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: CLSpacing.sm),
                itemBuilder: (context, i) => _SuiteTile(suite: suites[i]),
              ),
      ),
    );
  }
}

// ── Suite tile ────────────────────────────────────────────────────────────────

class _SuiteTile extends ConsumerStatefulWidget {
  const _SuiteTile({required this.suite});
  final Suite suite;

  @override
  ConsumerState<_SuiteTile> createState() => _SuiteTileState();
}

class _SuiteTileState extends ConsumerState<_SuiteTile> {
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateSuiteActive(widget.suite.id, active: value);
      ref.invalidate(adminSuitesProvider);
      ref.invalidate(adminDashboardProvider);
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
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suite = widget.suite;

    return CLCard(
      padding: const EdgeInsets.all(CLSpacing.base),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: suite.active
                  ? CLColors.available.withValues(alpha: 0.12)
                  : CLColors.textMuted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.hotel_outlined,
              size: 22,
              color: suite.active ? CLColors.available : CLColors.textMuted,
            ),
          ),
          const SizedBox(width: CLSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(suite.displayName, style: CLTypography.label),
                Text(
                  suite.code,
                  style: CLTypography.caption.copyWith(
                    color: CLColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CLColors.primary,
              ),
            )
          else
            Switch.adaptive(
              value: suite.active,
              activeThumbColor: CLColors.available,
              activeTrackColor: CLColors.available.withValues(alpha: 0.4),
              onChanged: _toggle,
            ),
        ],
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
