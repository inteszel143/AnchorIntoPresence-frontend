import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/app_back_button.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';

import '../../common/local_storage.dart';
import '../../common/widgets/button_widget.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../signin/signin_screen.dart';
import 'feelingcategory_bloc/feeling_categories_bloc.dart';
import 'feelingcategory_bloc/feeling_categories_event.dart';
import 'feelingcategory_bloc/feeling_categories_state.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  final List<String> categories = const [
    'Grounded',
    'Aligned',
    'Calm',
    'Steady',
    'Connected',
  ];

  void _goToSignin(BuildContext context) {
    LocalStorage.deleteToken();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc(),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategorySuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await LocalStorage.saveCategorySelected(true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => MainScreen(
                          initialIndex: 0,
                        )),
                (route) => false,
              );
            });
          } else if (state is CategoryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _goToSignin(context);
            },
            child: AppScaffold(
              body: Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AppBackButton(
                              onPressed: () => _goToSignin(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                            ),
                            child: Text(
                              Strings.CategoryHeader,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: Fonts.headingLetterSpacing,
                                fontFamily: Fonts.heading,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            child: Text(
                              Strings.CategoryDescription,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontFamily: Fonts.body,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: categories.map((category) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<CategoryBloc>().add(
                                              SelectCategory(mood: category),
                                            );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        child: ButtonWidget(
                                          btnTxt: category,
                                          widthFactor: 0.9,
                                          height: 52,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
