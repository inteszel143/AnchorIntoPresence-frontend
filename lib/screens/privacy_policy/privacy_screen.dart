import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/information_page.dart';
import '../../common/widgets/legal_document.dart';
import '../../utils/string_constants.dart';
import 'privacy_bloc/privacy_bloc.dart';
import 'privacy_bloc/privacy_event.dart';
import 'privacy_bloc/privacy_state.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => PrivacyBloc()..add(FetchPrivacyPolicyEvent()),
        child: InformationPage(
          title: Strings.privacyPolicy,
          slivers: [
            BlocBuilder<PrivacyBloc, PrivacyState>(
              builder: (context, state) {
                if (state is PrivacyLoading) {
                  return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()));
                }
                if (state is PrivacyLoaded) {
                  return SliverToBoxAdapter(
                      child: LegalDocument(description: state.description));
                }
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        state is PrivacyError
                            ? state.errorMessage
                            : 'Something went wrong.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            height: 1.5)),
                  )),
                );
              },
            ),
          ],
        ),
      );
}
