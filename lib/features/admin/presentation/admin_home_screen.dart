import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../features/auth/domain/auth_providers.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;

    return Scaffold(
      backgroundColor: CLColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CLSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CLSpacing.xxxl),

              // ── Header ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CLSpacing.md,
                  vertical: CLSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: CLColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: CLColors.available,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: CLSpacing.xs),
                    Text(
                      'Amministratore',
                      style: CLTypography.caption.copyWith(
                        color: CLColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: CLSpacing.xl),

              Text(
                'Casa\nLazzarini',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: CLColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              if (profile != null) ...[
                const SizedBox(height: CLSpacing.sm),
                Text(
                  profile.fullName,
                  style: CLTypography.body.copyWith(
                    color: CLColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: CLSpacing.huge),

              // ── Placeholder notice ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(CLSpacing.xl),
                decoration: BoxDecoration(
                  color: CLColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CLColors.divider, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pannello di amministrazione',
                      style: CLTypography.label,
                    ),
                    const SizedBox(height: CLSpacing.xs),
                    Text(
                      'La gestione delle prenotazioni e degli ospiti '
                      'sarà disponibile nella Fase 3.',
                      style: CLTypography.caption,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () => ref.read(appAuthProvider.notifier).signOut(),
                child: Text(
                  'Esci',
                  style: CLTypography.label.copyWith(
                    color: CLColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: CLSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
