import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/app_scaffold.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/profile_avatar.dart';
import '../../common/widgets/app_toast.dart';
import '../../utils/api_service.dart';
import '../edit_profile/edit_profile.dart';
import '../user_profile/user_model.dart';
import '../../helping_widgets/user_provider/user_provider.dart';

/// A preview of upcoming profile features; no achievements or totals are implied.
class MyProfilePreview extends StatefulWidget {
  const MyProfilePreview({super.key, this.loadProfile});

  final Future<UserModel> Function()? loadProfile;

  @override
  State<MyProfilePreview> createState() => _MyProfilePreviewState();
}

class _MyProfilePreviewState extends State<MyProfilePreview> {
  bool _openingEditor = false;
  UserModel? _profile;
  bool _loadingProfile = true;
  bool _profileError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<UserModel> _fetchProfile() =>
      (widget.loadProfile ?? ApiService.fetchUserProfile)();

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = false;
    });
    try {
      final profile = await _fetchProfile();
      if (!mounted) return;
      context.read<UserProvider?>()?.setUser(profile.name, profile.image ?? '');
      setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _profileError = true);
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _editProfile() async {
    setState(() => _openingEditor = true);
    try {
      final user = _profile ?? await _fetchProfile();
      if (!mounted) return;
      final updated = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => UserprofileEditScreen(
            name: user.name, email: user.email, image: user.image),
      ));
      if (updated == true && mounted) await _loadProfile();
    } catch (_) {
      if (mounted) {
        AppToast.show(context, 'Couldn’t load your profile. Please try again.',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _openingEditor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = context.watch<UserProvider?>();
    final name = (user?.name ?? _profile?.name ?? '').trim();
    final profileImage = user?.image ?? _profile?.image;
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppbar(
                  headingTxt: 'My profile',
                  topPadding: 8,
                  onOkTap: _openingEditor ? null : _editProfile,
                  okimage: Tooltip(
                    message: 'Edit profile',
                    child: _openingEditor
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.edit_outlined,
                            semanticLabel: 'Edit profile'),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Semantics(
                                button: true,
                                label: 'Edit profile photo',
                                child: InkWell(
                                  onTap: _openingEditor ? null : _editProfile,
                                  customBorder: const CircleBorder(),
                                  child: ProfileAvatar(
                                      image: profileImage, size: 80),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        name.isEmpty
                                            ? 'Your mindful journey'
                                            : name,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    Text('Grow at your own pace.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color:
                                                    colors.onSurfaceVariant)),
                                  ])),
                            ]),
                        if (_loadingProfile)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: LinearProgressIndicator(
                                semanticsLabel: 'Loading profile'),
                          ),
                        if (_profileError)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton.icon(
                              onPressed: _loadProfile,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text(
                                  'Couldn’t refresh profile. Try again'),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                            'A preview of your personal journey. These features are coming soon; your activity isn’t shown yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5, color: colors.onSurfaceVariant)),
                        const SizedBox(height: 24),
                        const _FeatureCard(
                          title: 'Personal stats',
                          icon: Icons.insights_rounded,
                          description: 'Last 30 days · Preview',
                          child: _MetricPair(
                            firstLabel: 'Total minutes',
                            firstIcon: Icons.schedule_rounded,
                            secondLabel: 'Active days',
                            secondIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const _FeatureCard(
                          title: 'Streak',
                          icon: Icons.local_fire_department_outlined,
                          description: 'A little consistency goes a long way.',
                          child: Column(children: [
                            _MetricPair(
                              firstLabel: 'Current streak',
                              firstIcon: Icons.bolt_rounded,
                              secondLabel: 'Longest streak',
                              secondIcon: Icons.local_fire_department_outlined,
                            ),
                            SizedBox(height: 24),
                            _StreakWeek(),
                          ]),
                        ),
                        _FeatureCard(
                          title: 'Skills',
                          icon: Icons.spa_outlined,
                          description:
                              'Explore the qualities you’ll nurture through practice.',
                          child: const Column(children: [
                            _SkillRow(
                                title: 'Awareness', icon: Icons.spa_rounded),
                            SizedBox(height: 24),
                            _SkillRow(
                                title: 'Focus', icon: Icons.diamond_outlined),
                            SizedBox(height: 24),
                            _SkillRow(
                                title: 'Self-compassion',
                                icon: Icons.favorite_outline),
                          ]),
                        ),
                        const _FeatureCard(
                          title: 'Badges',
                          icon: Icons.workspace_premium_outlined,
                          description:
                              'Milestones to look forward to. Not earned yet.',
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 20,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              _Milestone(
                                  title: 'First practice',
                                  icon: Icons.spa_rounded),
                              _Milestone(
                                  title: '5 meditations',
                                  icon: Icons.filter_5_rounded),
                              _Milestone(
                                  title: '10 meditations',
                                  icon: Icons.workspace_premium_rounded),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.title,
      required this.icon,
      required this.description,
      required this.child});
  final String title;
  final IconData icon;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: colors.outlineVariant.withValues(alpha: .4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 22, color: colors.onSurface),
              const SizedBox(width: 8),
              Flexible(
                  child: Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600))),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Coming soon',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(description,
            style: theme.textTheme.bodyMedium
                ?.copyWith(height: 1.5, color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }
}

class _MetricPair extends StatelessWidget {
  const _MetricPair(
      {required this.firstLabel,
      required this.firstIcon,
      required this.secondLabel,
      required this.secondIcon});
  final String firstLabel;
  final IconData firstIcon;
  final String secondLabel;
  final IconData secondIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget metric(String label, IconData icon) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Text('—',
                  semanticsLabel: 'Not available yet',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        );
    return LayoutBuilder(builder: (context, constraints) {
      final first = metric(firstLabel, firstIcon);
      final second = metric(secondLabel, secondIcon);
      if (constraints.maxWidth < 260 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [first, const Divider(height: 32), second]);
      }
      return IntrinsicHeight(
          child: Row(children: [
        Expanded(child: first),
        const VerticalDivider(width: 32),
        Expanded(child: second),
      ]));
    });
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 52,
        height: 60,
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant, width: 2),
        ),
        child: Icon(icon, size: 30, color: colors.onSurface),
      ),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Progress coming soon',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: 14),
        ExcludeSemantics(
            child: LinearProgressIndicator(
          value: 0,
          minHeight: 5,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: colors.outlineVariant.withValues(alpha: .45),
        )),
      ])),
    ]);
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
        width: 92,
        child: Column(children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colors.outlineVariant, width: 4),
            ),
            child: Icon(icon, size: 40, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text('Locked',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant)),
        ]));
  }
}

class _StreakWeek extends StatelessWidget {
  const _StreakWeek();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Weekly streak preview. Activity is not available yet.',
      child: ExcludeSemantics(
          child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
            SizedBox(
                width: 30,
                child: Column(children: [
                  Icon(Icons.circle_outlined,
                      size: 28, color: colors.outlineVariant),
                  const SizedBox(height: 8),
                  Text(day, style: Theme.of(context).textTheme.labelSmall),
                ])),
        ],
      )),
    );
  }
}
