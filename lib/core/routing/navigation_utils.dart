import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Pops the current route when one exists in the go_router stack,
/// otherwise navigates to Home as a safe fallback.
///
/// Handles both push-navigated routes (canPop = true) and go-navigated
/// routes that replaced the stack (canPop = false), e.g. via the bottom nav.
void goBackOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}
