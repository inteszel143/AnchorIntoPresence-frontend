import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/signin/deleteaccount_bloc/delete_account_bloc.dart';
import '../screens/signin/deleteaccount_bloc/delete_account_event.dart';
import '../screens/signin/signin_screen.dart';
import '../utils/string_constants.dart';
import 'widgets/confirmation_sheet_content.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: const BoxConstraints(maxWidth: 600),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: ConfirmationSheetContent(
          icon: Icons.warning_rounded,
          message: Strings.areYouSureForDeleteAccount,
          detail: 'This process cannot be undone.',
          confirmLabel: Strings.delete,
          onCancel: () => Navigator.pop(sheetContext),
          onConfirm: () {
            context.read<AccountDeletionBloc>().add(AccountDeletionRequest());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SigninScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      );
    },
  );
}
