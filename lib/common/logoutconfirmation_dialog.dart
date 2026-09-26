import 'dart:ui';
import 'package:flutter/material.dart';

import '../screens/signin/signin_screen.dart';
import '../utils/string_constants.dart';
import 'logout_session.dart';
import 'widgets/confirmation_sheet_content.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: const BoxConstraints(maxWidth: 600),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: const _LogoutSheet(),
    ),
  );
}

class _LogoutSheet extends StatefulWidget {
  const _LogoutSheet();

  @override
  State<_LogoutSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends State<_LogoutSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _logout() async {
    if (_loading) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await logoutSession();
      if (!navigator.mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SigninScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Couldn’t log out. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext sheetContext) {
    return PopScope(
      canPop: !_loading,
      child: GestureDetector(
        onVerticalDragEnd: _loading
            ? null
            : (details) {
                if ((details.primaryVelocity ?? 0) > 300) {
                  Navigator.pop(sheetContext);
                }
              },
        child: ConfirmationSheetContent(
          icon: Icons.logout_rounded,
          message: Strings.areYouSureForSignOut,
          confirmLabel: Strings.logout,
          loading: _loading,
          error: _error,
          onConfirm: _loading ? null : _logout,
          onCancel: _loading ? null : () => Navigator.pop(sheetContext),
        ),
      ),
    );
  }
}
