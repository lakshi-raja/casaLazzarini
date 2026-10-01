import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_motion.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../features/auth/domain/auth_providers.dart';
import '../../../shared/models/profile.dart';
import '../../../shared/widgets/cl_action_card.dart';
import '../../../shared/widgets/cl_bottom_navigation.dart';
import '../../../shared/widgets/cl_dialog.dart';
import '../../../shared/widgets/cl_hero_section.dart';
import '../../../shared/widgets/cl_primary_button.dart';
import '../../../shared/widgets/cl_secondary_button.dart';
import '../../../shared/widgets/cl_section_header.dart';
import '../../../shared/widgets/cl_suite_preview_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: CLMotion.durationSlow,
    )..forward();

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: CLMotion.curveEntrance),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entranceCtrl, curve: CLMotion.curveEntrance),
        );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appAuthProvider).profile;

    return Scaffold(
      extendBody: true,
      backgroundColor: CLColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Hero — full-width, extends under status bar
            const CLHeroSection(),

            // B–F. Animated content below hero
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CLSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: CLSpacing.xxl),

                      // B. Welcome
                      _WelcomeSection(profile: profile),

                      const SizedBox(height: CLSpacing.xxxl),

                      // C. Primary CTA — Prenota
                      CLActionCard(
                        label: 'Prenota una suite',
                        icon: Icons.calendar_month_outlined,
                        variant: CLActionCardVariant.primary,
                        onTap: () => context.push(AppRoutes.booking),
                      ),

                      const SizedBox(height: CLSpacing.md),

                      // D. Secondary CTA — Le mie prenotazioni
                      CLActionCard(
                        label: 'Le mie prenotazioni',
                        icon: Icons.bookmark_outline_rounded,
                        variant: CLActionCardVariant.secondary,
                        onTap: () => context.push(AppRoutes.myBookings),
                      ),

                      const SizedBox(height: CLSpacing.xxxl),

                      // E. Availability — placeholder, no invented data
                      _AvailabilitySection(),

                      const SizedBox(height: CLSpacing.xxxl),

                      // F. Suites — real names only, no invented metadata
                      const _SuitesSection(),

                      // Bottom safe area for nav bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CLBottomNavigation(currentIndex: 0),
    );
  }
}

// ── B. Welcome ────────────────────────────────────────────────────────────────

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Benvenut*\na Casa Lazzarini', style: CLTypography.displayMedium),
        const SizedBox(height: CLSpacing.md),
        Text(
          'Un soggiorno pensato per rallentare.',
          style: CLTypography.body.copyWith(
            color: CLColors.textSecondary,
            height: 1.6,
          ),
        ),
        if (name.isNotEmpty) ...[
          const SizedBox(height: CLSpacing.sm),
          Text(
            name,
            style: CLTypography.caption.copyWith(color: CLColors.textMuted),
          ),
        ],
        const SizedBox(height: CLSpacing.base),
        _SignOutLink(),
      ],
    );
  }
}

class _SignOutLink extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await CLDialog.show<bool>(
          context: context,
          title: 'Esci',
          content: const Text('Sei sicuro di voler uscire?'),
          actions: [
            CLSecondaryButton(
              label: 'Annulla',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CLPrimaryButton(
              label: 'Esci',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
        if (confirmed != true) return;
        if (!context.mounted) return;
        ref.read(appAuthProvider.notifier).signOut();
      },
      child: Text(
        'Esci',
        style: CLTypography.caption.copyWith(color: CLColors.textMuted),
      ),
    );
  }
}

// ── E. Availability placeholder ───────────────────────────────────────────────

class _AvailabilitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLSectionHeader(
          title: 'Disponibilità',
          actionLabel: 'Vedi calendario',
          onAction: () => context.push(AppRoutes.booking),
        ),
        const SizedBox(height: CLSpacing.base),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CLSpacing.xl,
            vertical: CLSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: CLColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: CLColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: CLColors.textMuted,
              ),
              const SizedBox(width: CLSpacing.md),
              Expanded(
                child: Text(
                  'Disponibilità presto disponibile',
                  style: CLTypography.body.copyWith(color: CLColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── F. Suites ─────────────────────────────────────────────────────────────────

class _SuitesSection extends StatelessWidget {
  const _SuitesSection();

  static const _suiteNames = ['Suite n.1', 'Suite n.2', 'Suite n.3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CLSectionHeader(title: 'Le suite'),
        const SizedBox(height: CLSpacing.base),
        for (int i = 0; i < _suiteNames.length; i++) ...[
          CLSuitePreviewCard(name: _suiteNames[i], onTap: null),
          if (i < _suiteNames.length - 1) const SizedBox(height: CLSpacing.md),
        ],
      ],
    );
  }
}
