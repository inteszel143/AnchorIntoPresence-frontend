import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

/// Shared account confirmation layout, with accessible large-text actions.
class ConfirmationSheetContent extends StatelessWidget {
  const ConfirmationSheetContent({
    super.key,
    required this.icon,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.detail,
    this.loading = false,
    this.error,
  });

  final IconData icon;
  final String message;
  final String? detail;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final accent = dark ? ColorCodes.sand : ColorCodes.charcoal;
    final cancel = OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            dark ? colors.surfaceContainerHighest : ColorCodes.sand,
        foregroundColor: accent,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text('Cancel'),
    );
    final confirm = FilledButton(
      onPressed: onConfirm,
      style: FilledButton.styleFrom(
        backgroundColor: dark ? ColorCodes.sand : ColorCodes.charcoal,
        foregroundColor: dark ? ColorCodes.charcoal : ColorCodes.cream,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.onSurface,
                semanticsLabel: 'Logging out',
              ),
            )
          : Text(confirmLabel),
    );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: dark
                          ? ColorCodes.clay.withValues(alpha: .18)
                          : ColorCodes.sand,
                      child: Icon(icon, size: 30, color: accent),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Are you sure?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: accent, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant, height: 1.45)),
                  if (detail != null)
                    Text(detail!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant, height: 1.45)),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error)),
                  ],
                  const SizedBox(height: 40),
                  if (MediaQuery.textScalerOf(context).scale(16) > 24)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [cancel, const SizedBox(height: 12), confirm])
                  else
                    Row(children: [
                      Expanded(child: cancel),
                      const SizedBox(width: 12),
                      Expanded(child: confirm),
                    ]),
                ],
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                tooltip: 'Close',
                onPressed: onCancel,
                icon: Icon(Icons.close_rounded,
                    size: 20, color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
