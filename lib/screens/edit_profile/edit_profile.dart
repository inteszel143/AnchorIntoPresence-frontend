import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/widgets/collection_page.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/profile_avatar.dart';
import '../../helping_widgets/user_provider/user_provider.dart';
import 'editprofile_bloc/edit_profile_bloc.dart';
import 'editprofile_bloc/edit_profile_event.dart';
import 'editprofile_bloc/edit_profile_state.dart';

class UserprofileEditScreen extends StatelessWidget {
  const UserprofileEditScreen(
      {super.key, required this.name, required this.email, this.image});
  final String name, email;
  final String? image;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => EditProfileBloc(),
        child: ProfileEditForm(
            initialName: name, email: email, initialImage: image),
      );
}

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm(
      {super.key,
      required this.initialName,
      required this.email,
      this.initialImage});
  final String initialName, email;
  final String? initialImage;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  final _formKey = GlobalKey<FormState>();
  bool _picking = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      final source = await showModalBottomSheet<ImageSource>(
          context: context,
          showDragHandle: true,
          useSafeArea: true,
          builder: (context) => SafeArea(
                top: false,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Change profile photo',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              leading: const Icon(Icons.photo_camera_outlined),
                              title: const Text('Take a photo'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.camera)),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              leading: const Icon(Icons.photo_library_outlined),
                              title: const Text('Choose from gallery'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.gallery)),
                        ])),
              ));
      if (source == null || !mounted) return;
      final photo = await ImagePicker().pickImage(source: source);
      if (photo != null && mounted) {
        context.read<EditProfileBloc>().add(ImagePicked(File(photo.path)));
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context,
            'Couldn’t open your photos. Please check permissions and try again.',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<EditProfileBloc, EditProfileState>(
        listenWhen: (previous, current) =>
            previous.successMessage != current.successMessage ||
            previous.error != current.error,
        listener: (context, state) {
          if (state.successMessage != null) {
            final provider = context.read<UserProvider?>();
            provider?.updateUserProfile(
                _name.text.trim(),
                state.pickedImage?.path ??
                    widget.initialImage ??
                    provider.image);
            AppToast.show(context, 'Profile updated.');
            Navigator.pop(context, true);
          } else if (state.error != null) {
            AppToast.show(context, state.error!, isError: true);
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final busy = state.isLoading || _picking;
          return CollectionPage(
            title: 'Edit profile',
            description: 'Make this space feel a little more like you.',
            slivers: [
              SliverToBoxAdapter(
                  child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                          child: ProfileAvatar(
                              image: widget.initialImage,
                              file: state.pickedImage)),
                      const SizedBox(height: 12),
                      Center(
                          child: TextButton.icon(
                              onPressed: busy ? null : _pickPhoto,
                              icon: const Icon(Icons.add_a_photo_outlined,
                                  size: 20),
                              label: const Text('Change photo'))),
                      const SizedBox(height: 24),
                      Text('Account details',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),
                      Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Name', style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _name,
                                  enabled: !state.isLoading,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.name],
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Please enter your name.'
                                          : null,
                                  onChanged: (value) => context
                                      .read<EditProfileBloc>()
                                      .add(NameChanged(value)),
                                  decoration: InputDecoration(
                                      hintText: 'Your name',
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 14),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          borderSide: BorderSide.none)),
                                ),
                                const SizedBox(height: 22),
                                Text('Email address',
                                    style: theme.textTheme.labelLarge),
                                const SizedBox(height: 8),
                                Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.lock_outline_rounded,
                                              size: 18,
                                              color: theme.colorScheme
                                                  .onSurfaceVariant),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: SelectableText(
                                                  widget.email,
                                                  style: theme
                                                      .textTheme.bodyMedium)),
                                        ])),
                                const SizedBox(height: 8),
                                Text(
                                    'Your sign-in email can’t be changed here.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ])),
                      if (state.error != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                            liveRegion: true,
                            child: Text(state.error!,
                                style:
                                    TextStyle(color: theme.colorScheme.error))),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                          onPressed: busy
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  FocusScope.of(context).unfocus();
                                  context.read<EditProfileBloc>().add(
                                      UpdateProfile(
                                          name: _name.text.trim(),
                                          image: state.pickedImage));
                                },
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: const StadiumBorder()),
                          child: state.isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      semanticsLabel: 'Saving profile'))
                              : const Text('Save changes')),
                    ]),
              ))
            ],
          );
        },
      );
}
