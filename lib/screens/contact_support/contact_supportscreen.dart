import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/information_page.dart';
import '../../utils/string_constants.dart';
import 'contactsupport_bloc/contact_support_bloc.dart';
import 'contactsupport_bloc/contact_support_event.dart';
import 'contactsupport_bloc/contact_support_state.dart';

class ContactSupportscreen extends StatefulWidget {
  const ContactSupportscreen({super.key, this.createBloc});

  final ContactSupportBloc Function()? createBloc;

  @override
  State<ContactSupportscreen> createState() => _ContactSupportscreenState();
}

class _ContactSupportscreenState extends State<ContactSupportscreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  static const _topics = [
    'Using the app',
    'Meditations & tracking',
    'Subscription & billing',
    'Account & sign-in',
    'Something else',
  ];
  String _topic = _topics.first;
  bool _sent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => widget.createBloc?.call() ?? ContactSupportBloc(),
        child: BlocConsumer<ContactSupportBloc, ContactSupportState>(
          listener: (context, state) {
            if (state is ContactSupportSuccess) {
              _titleController.clear();
              _descriptionController.clear();
              setState(() => _sent = true);
            }
          },
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            final text = Theme.of(context).textTheme;
            final loading = state is ContactSupportLoading;
            return InformationPage(
              title: Strings.contactSupport,
              slivers: [
                SliverToBoxAdapter(
                  child: _sent
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 40, color: colors.primary),
                              const SizedBox(height: 16),
                              Semantics(
                                liveRegion: true,
                                child: Text('Your message has been sent',
                                    style: text.titleLarge),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Thank you for reaching out. Your request has been shared with our support team.',
                                  style: text.bodyLarge),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  child: const Text('Done'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() {
                                  _sent = false;
                                  _topic = _topics.first;
                                }),
                                child: const Text('Send another message'),
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('How can we help?', style: text.titleLarge),
                              const SizedBox(height: 8),
                              Text(
                                  'Choose a topic and tell us what’s happening. We’re here to help.',
                                  style: text.bodyLarge?.copyWith(
                                      color: colors.onSurfaceVariant)),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('What do you need help with?',
                                        style: text.titleMedium),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        for (final topic in _topics)
                                          ChoiceChip(
                                            label: Text(topic),
                                            selected: _topic == topic,
                                            onSelected: loading
                                                ? null
                                                : (_) => setState(
                                                    () => _topic = topic),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    if (_topic == 'Something else') ...[
                                      Text('Title', style: text.titleMedium),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        key: const ValueKey('support-title'),
                                        controller: _titleController,
                                        enabled: !loading,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          hintText:
                                              'A short summary of your question',
                                          filled: true,
                                          fillColor: colors.surface,
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          errorMaxLines: 3,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                  color:
                                                      colors.outlineVariant)),
                                        ),
                                        validator: (value) => value == null ||
                                                value.trim().isEmpty
                                            ? 'Please enter a title.'
                                            : null,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    Text('Your message',
                                        style: text.titleMedium),
                                    const SizedBox(height: 8),
                                    Text(
                                        'What were you trying to do, and what happened? Include any error message you saw.',
                                        style: text.bodyMedium?.copyWith(
                                            color: colors.onSurfaceVariant)),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _descriptionController,
                                      enabled: !loading,
                                      minLines: 5,
                                      maxLines: 10,
                                      keyboardType: TextInputType.multiline,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Tell us a little about the issue…',
                                        filled: true,
                                        fillColor: colors.surface,
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        errorMaxLines: 3,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                                color: colors.outlineVariant)),
                                      ),
                                      validator: (value) => value == null ||
                                              value.trim().isEmpty
                                          ? 'Please write a message so we can help.'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                        'Please don’t include passwords or payment card details.',
                                        style: text.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant)),
                                    if (state is ContactSupportFailure) ...[
                                      const SizedBox(height: 16),
                                      Semantics(
                                        liveRegion: true,
                                        child: Text(state.error,
                                            style: text.bodyMedium?.copyWith(
                                                color: colors.error)),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: loading
                                            ? null
                                            : () {
                                                if (!_formKey.currentState!
                                                    .validate()) {
                                                  return;
                                                }
                                                FocusScope.of(context)
                                                    .unfocus();
                                                context
                                                    .read<ContactSupportBloc>()
                                                    .add(
                                                      SubmitSupportRequest(
                                                        title: _topic ==
                                                                'Something else'
                                                            ? _titleController
                                                                .text
                                                                .trim()
                                                            : _topic,
                                                        description:
                                                            _descriptionController
                                                                .text
                                                                .trim(),
                                                      ),
                                                    );
                                              },
                                        style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 16)),
                                        child: loading
                                            ? const Wrap(
                                                spacing: 12,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  SizedBox.square(
                                                    dimension: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                  Text('Sending…'),
                                                ],
                                              )
                                            : const Text('Send message'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      );
}
