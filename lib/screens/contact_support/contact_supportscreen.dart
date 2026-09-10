import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/information_page.dart';
import '../../utils/string_constants.dart';
import 'contactsupport_bloc/contact_support_bloc.dart';
import 'contactsupport_bloc/contact_support_event.dart';
import 'contactsupport_bloc/contact_support_state.dart';

class ContactSupportscreen extends StatefulWidget {
  const ContactSupportscreen({super.key});

  @override
  State<ContactSupportscreen> createState() => _ContactSupportscreenState();
}

class _ContactSupportscreenState extends State<ContactSupportscreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ContactSupportBloc(),
        child: BlocConsumer<ContactSupportBloc, ContactSupportState>(
          listener: (context, state) {
            if (state is ContactSupportSuccess) {
              _titleController.clear();
              _descriptionController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.response.message)));
            } else if (state is ContactSupportFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            final loading = state is ContactSupportLoading;
            InputDecoration decoration(String hint) => InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.outlineVariant)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: colors.primary, width: 1.5)),
                );
            return InformationPage(
              title: Strings.contactSupport,
              slivers: [
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24)),
                      child: AbsorbPointer(
                        absorbing: loading,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Strings.title,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _titleController,
                                decoration: decoration(Strings.enterTitle),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter title'
                                        : null,
                              ),
                              const SizedBox(height: 24),
                              Text(Strings.description,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration:
                                    decoration(Strings.enterDescription),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Please enter description'
                                        : null,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          FocusScope.of(context).unfocus();
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<ContactSupportBloc>()
                                                .add(SubmitSupportRequest(
                                                  title: _titleController.text
                                                      .trim(),
                                                  description:
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                ));
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16)),
                                  child: loading
                                      ? const SizedBox.square(
                                          dimension: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text(Strings.submit),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}
