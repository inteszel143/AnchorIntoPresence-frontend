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
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post created successfully!')));
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
                child: Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: ScrollTitlePage(
                      title: 'Create post',
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(children: [
                                IgnorePointer(
                                    ignoring: busy,
                                    child: CustomAppbar(
                                        headingTxt: '',
                                        onTap: () => Navigator.pop(context))),
                                Expanded(
                                    child: ListView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        padding: const EdgeInsets.only(
                                            top: 24, bottom: 24),
                                        children: [
                                      Text('Create post',
                                          style: text.headlineLarge?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Share a moment with your community.',
                                          style: text.bodyLarge?.copyWith(
                                              color: colors.onSurfaceVariant)),
                                      const SizedBox(height: 28),
                                      Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              color: colors
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  ClipOval(
                                                      child: avatar != null &&
                                                              avatar.isNotEmpty
                                                          ? Image.network(
                                                              avatar.startsWith(
                                                                      'http')
                                                                  ? avatar
                                                                  : '${Urls.baseUrlimages}$avatar',
                                                              width: 48,
                                                              height: 48,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_,
                                                                      __,
                                                                      ___) =>
                                                                  _avatar(
                                                                      colors))
                                                          : _avatar(colors)),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                      child: Text(userName,
                                                          style: text
                                                              .titleMedium
                                                              ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700))),
                                                ]),
                                                const SizedBox(height: 24),
                                                Text('Your message',
                                                    style: text.titleSmall
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                const SizedBox(height: 12),
                                                TextField(
                                                    controller: _message,
                                                    enabled: !busy,
                                                    minLines: 6,
                                                    maxLines: 12,
                                                    maxLength: 500,
                                                    style: text.bodyLarge
                                                        ?.copyWith(height: 1.6),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Share your thoughts, reflections, or questions with the community…',
                                                      hintStyle: text.bodyLarge
                                                          ?.copyWith(
                                                              color: colors
                                                                  .onSurfaceVariant,
                                                              height: 1.6),
                                                      filled: true,
                                                      fillColor: Theme.of(
                                                              context)
                                                          .scaffoldBackgroundColor,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18),
                                                              borderSide: BorderSide(
                                                                  color: colors
                                                                      .primary)),
                                                    )),
                                              ])),
                                      const SizedBox(height: 16),
                                      Material(
                                          color: colors.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: ListTile(
                                              enabled: !busy,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24)),
                                              leading:
                                                  Icon(Icons.add_photo_alternate_outlined,
                                                      color: colors.primary),
                                              title: Text('Add photo',
                                                  style: text.titleMedium?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              subtitle: const Text(
                                                  'Share an image with your post'),
                                              trailing: const Icon(Icons.chevron_right_rounded),
                                              onTap: _choosePhoto)),
                                      if (_photo != null) ...[
                                        const SizedBox(height: 16),
                                        Stack(children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: Image.file(File(_photo!),
                                                  width: double.infinity,
                                                  height: 220,
                                                  fit: BoxFit.cover)),
                                          Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IconButton.filled(
                                                  tooltip: 'Remove photo',
                                                  onPressed: busy
                                                      ? null
                                                      : () => setState(
                                                          () => _photo = null),
                                                  icon: const Icon(
                                                      Icons.close_rounded))),
                                        ]),
                                      ],
                                    ])),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, bottom: 16),
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                              backgroundColor: colors.primary,
                                              foregroundColor: colors.onPrimary,
                                              minimumSize: const Size(0, 56),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18))),
                                          onPressed: busy
                                              ? null
                                              : () => _submit(context),
                                          child: busy
                                              ? SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: colors
                                                              .onSurfaceVariant,
                                                          semanticsLabel:
                                                              'Posting'))
                                              : const Text('Post'),
                                        ))),
                              ])),
                        ),
                      )),
                ));
          },
        ),
      );

  Widget _avatar(ColorScheme colors) => Container(
      width: 48,
      height: 48,
      color: colors.surfaceContainerLow,
      child: Icon(Icons.person_outline_rounded, color: colors.primary));
}
