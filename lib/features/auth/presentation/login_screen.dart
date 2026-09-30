import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/cl_colors.dart';
import '../../../core/theme/cl_spacing.dart';
import '../../../core/theme/cl_typography.dart';
import '../../../shared/widgets/cl_primary_button.dart';
import '../domain/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref
        .read(appAuthProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: CLColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CLSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Hero area ──────────────────────────────────
                            const SizedBox(height: CLSpacing.huge),
                            const SizedBox(height: CLSpacing.huge),

                            Text(
                              'Casa\nLazzarini',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: CLColors.textPrimary,
                                letterSpacing: -1.0,
                                height: 1.05,
                              ),
                            ),

                            const SizedBox(height: CLSpacing.md),

                            Text(
                              'Accesso riservato agli ospiti.',
                              style: CLTypography.body.copyWith(
                                color: CLColors.textSecondary,
                              ),
                            ),

                            const Spacer(),

                            // ── Form ───────────────────────────────────────
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enabled: !isLoading,
                                    decoration: const InputDecoration(
                                      hintText: 'Email',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Inserisci l\'indirizzo email.';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Indirizzo email non valido.';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: CLSpacing.md),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    enabled: !isLoading,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: CLColors.textMuted,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Inserisci la password.';
                                      }
                                      return null;
                                    },
                                  ),

                                  // ── Error message ──────────────────────
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    child: authState.hasError
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: CLSpacing.md,
                                            ),
                                            child: _ErrorBanner(
                                              message: authState.errorMessage!,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  const SizedBox(height: CLSpacing.xl),

                                  CLPrimaryButton(
                                    label: 'Accedi',
                                    onPressed: isLoading ? null : _submit,
                                    isLoading: isLoading,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: CLSpacing.xxxl),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CLSpacing.base,
        vertical: CLSpacing.md,
      ),
      decoration: BoxDecoration(
        color: CLColors.destructiveContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: CLColors.destructive,
          ),
          const SizedBox(width: CLSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: CLTypography.caption.copyWith(color: CLColors.destructive),
            ),
          ),
        ],
      ),
    );
  }
}
