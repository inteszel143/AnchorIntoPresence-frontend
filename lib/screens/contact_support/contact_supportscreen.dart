import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/textfield_widget.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import 'contactsupport_bloc/contact_support_bloc.dart';
import 'contactsupport_bloc/contact_support_event.dart';
import 'contactsupport_bloc/contact_support_state.dart';

/// Screen for submitting contact support requests
class ContactSupportscreen extends StatelessWidget {
  ContactSupportscreen({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactSupportBloc(),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              // Controllers for form fields
              final titleController = TextEditingController();
              final descriptionController = TextEditingController();

              return BlocConsumer<ContactSupportBloc, ContactSupportState>(
                listener: (context, state) {
                  // Handle success state - clear form and show success message
                  if (state is ContactSupportSuccess) {
                    titleController.clear();
                    descriptionController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.response.message),
                        backgroundColor: ColorCodes.buttoncolor,
                      ),
                    );
                  }
                  // Handle failure state - show error message
                  else if (state is ContactSupportFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: ColorCodes.buttoncolor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final screenHeight = MediaQuery.of(context).size.height;

                  // Main content widget
                  final content = SizedBox(
                    height: screenHeight,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App bar with heading
                              CustomAppbar(headingTxt: Strings.contactSupport),

                              // Title field
                              _buildLabel(Strings.title),
                              TextFieldWidget(
                                label: Strings.enterTitle,
                                controller: titleController,
                                widthFactor: 0.9,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter title';
                                  }
                                  return null;
                                },
                              ),

                              // Description field
                              _buildLabel(Strings.description),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: TextFormField(
                                  controller: descriptionController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorCodes.textformfeildcolor,
                                    hintText: Strings.enterDescription,
                                    hintStyle: const TextStyle(
                                      color: ColorCodes.greyColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: ColorCodes.searchboxcolor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: ColorCodes.searchboxcolor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: ColorCodes.searchboxcolor,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter description';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Submit button
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  final title = titleController.text.trim();
                                  final description =
                                      descriptionController.text.trim();

                                  if (_formKey.currentState!.validate()) {
                                    context.read<ContactSupportBloc>().add(
                                          SubmitSupportRequest(
                                            title: title,
                                            description: description,
                                          ),
                                        );
                                  }
                                },
                                child: Center(
                                  child: const ButtonWidget(
                                    btnTxt: Strings.submit,
                                    widthFactor: 0.89,
                                    height: 52,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  // Show loading overlay when request is in progress
                  if (state is ContactSupportLoading) {
                    return Stack(
                      children: [
                        content,
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: ColorCodes.buttoncolor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return content;
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds label widget for form fields
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 20),
        child: Text(
          text,
          style: const TextStyle(
            color: ColorCodes.bellefairheadingtextcolor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: Fonts.body,
          ),
        ),
      ),
    );
  }
}
