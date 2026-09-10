import 'package:flutter/material.dart';

import '../screens/signin/signin_screen.dart';
import '../utils/string_constants.dart';
import 'logout_session.dart';

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
    builder: (_) => const _LogoutSheet(),
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
    final colors = Theme.of(sheetContext).colorScheme;
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
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close',
                    onPressed:
                        _loading ? null : () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: colors.surfaceContainerHighest,
                    child: Icon(Icons.logout_rounded,
                        size: 28, color: colors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  Strings.areYouSureForSignOut,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error)),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _loading ? null : _logout,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: _loading
                      ? SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onSurface,
                              semanticsLabel: 'Logging out'))
                      : const Text(Strings.logout),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed:
                      _loading ? null : () => Navigator.pop(sheetContext),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: const Text(Strings.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
