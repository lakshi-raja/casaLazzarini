import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../features/auth/domain/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;
    final name = profile?.fullName ?? '';

    return Scaffold(
      backgroundColor: CLColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CLSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CLSpacing.xxxl),

              // ── Greeting ─────────────────────────────────────────────────
              Text(
                'Benvenut*\na Casa Lazzarini',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: CLColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              if (name.isNotEmpty) ...[
                const SizedBox(height: CLSpacing.sm),
                Text(
                  name,
                  style: CLTypography.body.copyWith(
                    color: CLColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: CLSpacing.huge),

              // ── Primary actions ───────────────────────────────────────────
              _ActionTile(
                label: 'Prenota',
                description: 'Scegli una suite e una data disponibile.',
                icon: Icons.calendar_today_outlined,
                onTap: null, // Phase 2
              ),

              const SizedBox(height: CLSpacing.base),

              _ActionTile(
                label: 'Le mie prenotazioni',
                description:
                    'Visualizza, modifica o cancella le tue prenotazioni.',
                icon: Icons.bookmark_outline_rounded,
                onTap: null, // Phase 3
              ),

              const Spacer(),

              // ── Sign out ──────────────────────────────────────────────────
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

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: const EdgeInsets.all(CLSpacing.xl),
            decoration: BoxDecoration(
              color: CLColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CLColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: CLColors.textPrimary,
                  ),
                ),
                const SizedBox(width: CLSpacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: CLTypography.label),
                      const SizedBox(height: 2),
                      Text(widget.description, style: CLTypography.caption),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: CLColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
