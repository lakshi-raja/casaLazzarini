import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../features/auth/domain/auth_providers.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_bookings_tab.dart';
import 'tabs/admin_suites_tab.dart';
import 'tabs/admin_profiles_tab.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appAuthProvider).profile;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: CLColors.background,
        appBar: AppBar(
          backgroundColor: CLColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: CLSpacing.base,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Casa Lazzarini',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CLColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (profile != null)
                      Text(profile.fullName, style: CLTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: CLSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: CLSpacing.sm,
                vertical: CLSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: CLColors.available.withValues(alpha: 0.12),
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
                    'Admin',
                    style: CLTypography.caption.copyWith(
                      color: CLColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined, size: 20),
              color: CLColors.textSecondary,
              tooltip: 'Esci',
              onPressed: () => ref.read(appAuthProvider.notifier).signOut(),
            ),
          ],
          bottom: TabBar(
            labelStyle: CLTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: CLColors.textPrimary,
            ),
            unselectedLabelStyle: CLTypography.caption,
            indicatorColor: CLColors.primary,
            indicatorWeight: 2,
            dividerColor: CLColors.divider,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard_outlined, size: 18),
                text: 'Dashboard',
              ),
              Tab(
                icon: Icon(Icons.calendar_month_outlined, size: 18),
                text: 'Prenotazioni',
              ),
              Tab(icon: Icon(Icons.hotel_outlined, size: 18), text: 'Suite'),
              Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Ospiti'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminDashboardTab(),
            AdminBookingsTab(),
            AdminSuitesTab(),
            AdminProfilesTab(),
          ],
        ),
      ),
    );
  }
}
