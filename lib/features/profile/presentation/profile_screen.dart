import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_radius.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../features/auth/domain/auth_providers.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/cl_bottom_navigation.dart';
import '../../../shared/widgets/cl_section_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;
    final email = Supabase.instance.client.auth.currentUser?.email ?? '—';

    return Scaffold(
      extendBody: true,
      backgroundColor: CLColors.background,
      appBar: AppBar(
        backgroundColor: CLColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: CLColors.textPrimary,
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Text('Profilo', style: CLTypography.label),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: CLSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: CLSpacing.xxl),

              // Avatar
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: CLColors.surfaceElevated,
                    borderRadius: CLRadius.xlAll,
                    border: Border.all(color: CLColors.divider),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 32,
                    color: CLColors.textMuted,
                  ),
                ),
              ),

              if (profile != null) ...[
                const SizedBox(height: CLSpacing.base),
                Center(
                  child: Text(
                    profile.fullName,
                    style: CLTypography.displaySmall,
                  ),
                ),
              ],

              const SizedBox(height: CLSpacing.xxxl),

              const CLSectionHeader(title: 'Informazioni'),
              const SizedBox(height: CLSpacing.base),

              _InfoRow(label: 'Email', value: email),
              if (profile != null) ...[
                const SizedBox(height: CLSpacing.sm),
                _InfoRow(
                  label: 'Ruolo',
                  value: profile.role == UserRole.superAdmin
                      ? 'Amministratore'
                      : 'Ospite',
                ),
              ],

              const SizedBox(height: CLSpacing.xxxl),

              const CLSectionHeader(title: 'Account'),
              const SizedBox(height: CLSpacing.base),

              _SignOutTile(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CLBottomNavigation(currentIndex: 2),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.xl,
        vertical: CLSpacing.base,
      ),
      decoration: BoxDecoration(
        color: CLColors.surface,
        borderRadius: CLRadius.lgAll,
        border: Border.all(color: CLColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: CLTypography.caption.copyWith(color: CLColors.textMuted),
            ),
          ),
          Text(value, style: CLTypography.label),
        ],
      ),
    );
  }
}

class _SignOutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(appAuthProvider.notifier).signOut(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CLSpacing.xl,
          vertical: CLSpacing.base,
        ),
        decoration: BoxDecoration(
          color: CLColors.surface,
          borderRadius: CLRadius.lgAll,
          border: Border.all(color: CLColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Esci',
                style: CLTypography.label.copyWith(color: CLColors.destructive),
              ),
            ),
            const Icon(
              Icons.exit_to_app_rounded,
              size: 18,
              color: CLColors.destructive,
            ),
          ],
        ),
      ),
    );
  }
}
