import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cl_colors.dart';

/// Full-width editorial hero section.
///
/// When [imageProvider] is null renders an elegant dark placeholder
/// with the brand name in Playfair Display. Pass a real [ImageProvider]
/// to replace the placeholder — no other changes needed.
///
/// Occupies ~40% of the screen height and has a soft rounded bottom edge
/// to transition into the ivory background.
class CLHeroSection extends StatelessWidget {
  const CLHeroSection({super.key, this.imageProvider});

  /// Optional real image. When null, the editorial placeholder is shown.
  final ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.40;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imageProvider != null
            ? Image(image: imageProvider!, fit: BoxFit.cover)
            : _HeroPlaceholder(height: height),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: CLColors.charcoal,
      child: Stack(
        children: [
          // Subtle warm depth gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1917), Color(0xFF261F1A)],
                ),
              ),
            ),
          ),

          // Slot marker for future image — developer-only, barely visible
          Positioned(
            top: 16,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CLColors.warmSand.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'foto',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: CLColors.warmSand.withValues(alpha: 0.22),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Brand content — bottom-left, above safe area bottom
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Decorative warm sand hairline
                    Container(
                      width: 28,
                      height: 1,
                      color: CLColors.warmSand.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 18),

                    // Brand name — the editorial hero element
                    Text(
                      'Casa\nLazzarini',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        color: CLColors.ivory,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
