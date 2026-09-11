import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/collection_page.dart';
import '../../common/widgets/profile_avatar.dart';
import '../edit_profile/edit_profile.dart';
import 'user_model.dart';
import 'userprofile_bloc/user_profile_bloc.dart';
import 'userprofile_bloc/user_profile_event.dart';
import 'userprofile_bloc/user_profile_state.dart';

class UserprofileScreen extends StatelessWidget {
  const UserprofileScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => UserProfileBloc()..add(FetchUserProfile()),
        child: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) => CollectionPage(
            title: 'Profile',
            description: 'A little about you and your account.',
            slivers: [
              if (state is UserProfileLoaded)
                SliverToBoxAdapter(
                    child: ProfileDetails(
                  user: state.user,
                  onEdit: () async {
                    final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserprofileEditScreen(
                                name: state.user.name,
                                email: state.user.email,
                                image: state.user.image)));
                    if (updated == true && context.mounted) {
                      context.read<UserProfileBloc>().add(FetchUserProfile());
                    }
                  },
                ))
              else if (state is UserProfileError)
                SliverToBoxAdapter(
                    child: CollectionMessage(
                  icon: Icons.wifi_off_rounded,
                  title: 'Your profile couldn’t load',
                  description: 'Please try again in a moment.',
                  action: OutlinedButton.icon(
                      onPressed: () => context
                          .read<UserProfileBloc>()
                          .add(FetchUserProfile()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again')),
                ))
              else
                const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: CircularProgressIndicator(
                            semanticsLabel: 'Loading profile'))),
            ],
          ),
        ),
      );
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key, required this.user, required this.onEdit});
  final UserModel user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget detail(IconData icon, String label, String value) =>
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(value.isEmpty ? 'Not provided' : value,
                    style: theme.textTheme.bodyLarge),
              ])),
        ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: ProfileAvatar(image: user.image)),
      const SizedBox(height: 18),
      Text(user.name.trim().isEmpty ? 'Your profile' : user.name,
          textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text('Your space to grow, one moment at a time.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
      const SizedBox(height: 32),
      Text('Account details', style: theme.textTheme.titleMedium),
      const SizedBox(height: 14),
      Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            detail(Icons.person_outline_rounded, 'Name', user.name),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                    height: 1, color: theme.colorScheme.outlineVariant)),
            detail(Icons.mail_outline_rounded, 'Email address', user.email),
          ])),
      const SizedBox(height: 24),
      FilledButton.icon(
          onPressed: onEdit,
          style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder()),
          icon: const Icon(Icons.edit_outlined, size: 20),
          label: const Text('Edit profile')),
    ]);
  }
}
