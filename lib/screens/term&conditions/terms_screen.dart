import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/information_page.dart';
import '../../common/widgets/legal_document.dart';
import '../../utils/string_constants.dart';
import 'term&condition_bloc/terms_bloc.dart';
import 'term&condition_bloc/terms_event.dart';
import 'term&condition_bloc/terms_state.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TermsBloc()..add(FetchTermsEvent()),
        child: InformationPage(
          title: Strings.termsAndConditions,
          slivers: [
            BlocBuilder<TermsBloc, TermsState>(
              builder: (context, state) {
                if (state is TermsLoading) {
                  return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()));
                }
                if (state is TermsLoaded) {
                  return SliverToBoxAdapter(
                      child: LegalDocument(description: state.description));
                }
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        state is TermsError
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
