import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/term&condition_bloc/terms_bloc.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/term&condition_bloc/terms_event.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/term&condition_bloc/terms_state.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/html_utils.dart';
import '../../utils/string_constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          CustomAppbar(headingTxt: Strings.termsAndConditions),
          BlocProvider(
            create: (context) => TermsBloc()..add(FetchTermsEvent()),
            child: BlocBuilder<TermsBloc, TermsState>(
              builder: (context, state) {
                if (state is TermsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is TermsError) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (state is TermsLoaded) {
                  final cleanHtml = sanitizeHtmlText(state.description);

                  return Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Html(
                              data: cleanHtml,
                              style: getCommonHtmlStyles(
                                fontFamily: Fonts.body,
                                textColor: ColorCodes.mainheadingcolor,
                                fontSize: 14,
                              ),
                              shrinkWrap: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Something went wrong.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
