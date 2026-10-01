import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:casa_lazzarini/core/theme/cl_colors.dart';
import 'package:casa_lazzarini/core/theme/cl_spacing.dart';
import 'package:casa_lazzarini/core/theme/cl_typography.dart';
import 'package:casa_lazzarini/shared/models/profile.dart';
import 'package:casa_lazzarini/shared/models/user_role.dart';
import 'package:casa_lazzarini/shared/widgets/cl_card.dart';
import 'package:casa_lazzarini/shared/widgets/cl_empty_state.dart';

import '../../domain/admin_providers.dart';

class AdminProfilesTab extends ConsumerWidget {
  const AdminProfilesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(adminProfilesProvider);

    return RefreshIndicator(
      color: CLColors.primary,
      onRefresh: () async {
        ref.invalidate(adminProfilesProvider);
        await ref.read(adminProfilesProvider.future);
      },
      child: profilesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CLColors.primary),
        ),
        error: (e, _) => _ErrorRetry(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminProfilesProvider),
        ),
        data: (profiles) => profiles.isEmpty
            ? const CLEmptyState(
                icon: Icons.people_outline,
                message: 'Nessun ospite registrato',
              )
            : Column(
                children: [
                  _CountBar(count: profiles.length),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(CLSpacing.base),
                      itemCount: profiles.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: CLSpacing.sm),
                      itemBuilder: (_, i) => _ProfileTile(profile: profiles[i]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Count bar ─────────────────────────────────────────────────────────────────

class _CountBar extends StatelessWidget {
  const _CountBar({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CLColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.base,
        vertical: CLSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'ospite' : 'ospiti'}',
            style: CLTypography.caption.copyWith(color: CLColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Profile tile ──────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.fullName);
    final isSuperAdmin = profile.role == UserRole.superAdmin;
    final joinDate = DateFormat('d MMM yyyy', 'it').format(profile.createdAt);

    return CLCard(
      padding: const EdgeInsets.all(CLSpacing.base),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isSuperAdmin
                ? CLColors.primary.withValues(alpha: 0.12)
                : CLColors.surfaceElevated,
            child: Text(
              initials,
              style: CLTypography.label.copyWith(
                color: isSuperAdmin ? CLColors.primary : CLColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: CLSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName, style: CLTypography.label),
                Text('Iscritto il $joinDate', style: CLTypography.caption),
              ],
            ),
          ),
          _RoleBadge(isSuperAdmin: isSuperAdmin),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.isSuperAdmin});
  final bool isSuperAdmin;

  @override
  Widget build(BuildContext context) {
    if (!isSuperAdmin) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: CLColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Admin',
        style: CLTypography.caption.copyWith(
          color: CLColors.primary,
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
