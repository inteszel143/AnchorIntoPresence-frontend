import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/signin/deleteaccount_bloc/delete_account_bloc.dart';
import '../screens/signin/deleteaccount_bloc/delete_account_event.dart';
import '../screens/signin/signin_screen.dart';
import '../utils/string_constants.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: const BoxConstraints(maxWidth: 600),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.errorContainer,
                  child: Icon(Icons.delete_outline_rounded,
                      size: 28, color: colors.onErrorContainer),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Strings.areYouSureForDeleteAccount,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  context
                      .read<AccountDeletionBloc>()
                      .add(AccountDeletionRequest());

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SigninScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: const Text(Strings.delete),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: const Text(Strings.cancel),
              ),
            ],
          ),
        ),
      );
    },
  );
}
