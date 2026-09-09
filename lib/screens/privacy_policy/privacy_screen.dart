import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_event.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_state.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/html_utils.dart';
import '../../utils/string_constants.dart';
import 'privacy_bloc/privacy_bloc.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          CustomAppbar(headingTxt: Strings.privacyPolicy),
          BlocProvider(
            create: (context) => PrivacyBloc()..add(FetchPrivacyPolicyEvent()),
            child: BlocBuilder<PrivacyBloc, PrivacyState>(
              builder: (context, state) {
                if (state is PrivacyLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is PrivacyError) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (state is PrivacyLoaded) {
                  final cleanText = sanitizeHtmlText(state.description);

                  return Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Html(
                              data: cleanText,
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
