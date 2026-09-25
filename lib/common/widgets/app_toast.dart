import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

/// Shared compact, animated bottom notification for app-wide feedback.
/// Uses the app's ScaffoldMessenger so messages survive route changes.
class AppToast {
  AppToast._();

  static void show(BuildContext context, String message,
      {bool isError = false}) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalMargin = width > 348 ? (width - 300) / 2 : 24.0;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF595959),
        elevation: 6,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ColorCodes.taupe),
        ),
        content: Row(children: [
          Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4))),
        ]),
      ));
  }
}
