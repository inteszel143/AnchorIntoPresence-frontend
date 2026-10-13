import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/scroll_title_page.dart';
import '../../utils/global.dart';
import '../../utils/urls.dart';
import 'add_post_bloc/add_post_bloc.dart';
import 'add_post_bloc/add_post_event.dart';
import 'add_post_bloc/add_post_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _message = TextEditingController();
  final _picker = ImagePicker();
  String? _photo;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a photo',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera)),
                ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery)),
              ])),
    );
    if (source == null || !mounted) return;
    try {
      final photo = await _picker.pickImage(source: source);
      if (photo != null && mounted) setState(() => _photo = photo.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unable to open photos. Please try again.')));
      }
    }
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final message = _message.text.trim();
    if (message.isEmpty && _photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a message or photo')));
      return;
    }
    context.read<PostBloc>().add(CreatePostEvent(
        message: message,
        postType: 'Reflection',
        postAnonymously: false,
        imagePaths: _photo == null ? null : [_photo!]));
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => PostBloc(),
        child: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state is PostCreated) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Your post has been shared with the community.')));
              Navigator.pop(context, true);
            } else if (state is PostError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            final text = Theme.of(context).textTheme;
            final busy = state is PostCreating;
            final avatar = userImage;
            return PopScope(
              canPop: !busy,
              child: AppScaffold(
                body: ScrollTitlePage(
                  title: 'Create post',
                  child: Center(
                      child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        IgnorePointer(
                            ignoring: busy,
                            child: CustomAppbar(
                                headingTxt: '',
                                onTap: () => Navigator.pop(context))),
                        Expanded(
                            child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          children: [
                            Text('Create post',
                                style: text.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                                'A small moment can start a meaningful connection.',
                                style: text.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant)),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      ClipOval(
                                          child: avatar != null &&
                                                  avatar.isNotEmpty
                                              ? Image.network(
                                                  avatar.startsWith('http')
                                                      ? avatar
                                                      : '${Urls.baseUrlimages}$avatar',
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _avatar(colors))
                                              : _avatar(colors)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(
                                                userName.trim().isEmpty
                                                    ? 'You'
                                                    : userName,
                                                style: text.titleMedium),
                                            const SizedBox(height: 3),
                                            Text('Sharing with the community',
                                                style: text.bodySmall?.copyWith(
                                                    color: colors
                                                        .onSurfaceVariant)),
                                          ])),
                                    ]),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _message,
                                      enabled: !busy,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardType: TextInputType.multiline,
                                      minLines: 5,
                                      maxLines: 10,
                                      maxLength: 500,
                                      style:
                                          text.bodyLarge?.copyWith(height: 1.5),
                                      decoration: InputDecoration(
                                        labelText: 'Your message',
                                        alignLabelWithHint: true,
                                        hintText: 'What’s on your mind today?',
                                        filled: true,
                                        fillColor: colors.surface,
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                                color: colors.outlineVariant)),
                                      ),
                                    ),
                                    ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: _message,
                                      builder: (context, value, _) => value
                                              .text.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Need a starting point?',
                                                      style: text.bodySmall
                                                          ?.copyWith(
                                                              color: colors
                                                                  .onSurfaceVariant)),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        for (final prompt
                                                            in const [
                                                          (
                                                            'A small win',
                                                            'A small win for me today was '
                                                          ),
                                                          (
                                                            'Feeling grateful',
                                                            'Today I’m grateful for '
                                                          ),
                                                          (
                                                            'Say hello',
                                                            'Hello everyone! '
                                                          ),
                                                        ])
                                                          ActionChip(
                                                              label: Text(
                                                                  prompt.$1),
                                                              onPressed: busy
                                                                  ? null
                                                                  : () {
                                                                      _message.value = TextEditingValue(
                                                                          text: prompt
                                                                              .$2,
                                                                          selection:
                                                                              TextSelection.collapsed(offset: prompt.$2.length));
                                                                    }),
                                                      ]),
                                                ],
                                              ))
                                          : const SizedBox.shrink(),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_photo != null) ...[
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.file(File(_photo!),
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      child: Text(
                                                          'Photo preview unavailable. Try choosing another photo.')))),
                                      const SizedBox(height: 8),
                                      Wrap(spacing: 8, children: [
                                        TextButton.icon(
                                            onPressed:
                                                busy ? null : _choosePhoto,
                                            icon: const Icon(
                                                Icons.photo_library_outlined),
                                            label: const Text('Change photo')),
                                        TextButton.icon(
                                            onPressed: busy
                                                ? null
                                                : () => setState(
                                                    () => _photo = null),
                                            icon:
                                                const Icon(Icons.close_rounded),
                                            label: const Text('Remove photo')),
                                      ]),
                                    ] else
                                      OutlinedButton.icon(
                                          onPressed: busy ? null : _choosePhoto,
                                          icon: const Icon(Icons
                                              .add_photo_alternate_outlined),
                                          label: const Text('Add photo')),
                                    if (_photo == null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                          'Optional · A message, a photo, or both.',
                                          style: text.bodySmall?.copyWith(
                                              color: colors.onSurfaceVariant)),
                                    ],
                                  ]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                                'Share with kindness. There’s no perfect way to begin.',
                                style: text.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant)),
                            if (state is PostError) ...[
                              const SizedBox(height: 12),
                              Semantics(
                                  liveRegion: true,
                                  child: Text(
                                      'Your post couldn’t be shared. Your draft is still here—please try again.',
                                      style: text.bodyMedium
                                          ?.copyWith(color: colors.error))),
                            ],
                          ],
                        )),
                        Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      minimumSize: const Size(0, 52)),
                                  onPressed:
                                      busy ? null : () => _submit(context),
                                  child: busy
                                      ? const Wrap(
                                          spacing: 12,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                              SizedBox.square(
                                                  dimension: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2)),
                                              Text('Sharing…'),
                                            ])
                                      : const Text('Share post'),
                                ))),
                      ]),
                    ),
                  )),
                ),
              ),
            );
          },
        ),
      );

  Widget _avatar(ColorScheme colors) => Container(
      width: 48,
      height: 48,
      color: colors.surfaceContainerLow,
      child: Icon(Icons.person_outline_rounded, color: colors.primary));
}
