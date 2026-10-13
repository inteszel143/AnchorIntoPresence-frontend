import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/information_page.dart';
import '../../common/widgets/loading_skeleton.dart';
import '../contact_support/contact_supportscreen.dart';
import '../../helping_widgets/faqitem_tile.dart';
import 'faq_bloc/faq_bloc.dart';
import 'faq_bloc/faq_event.dart';
import 'faq_bloc/faq_state.dart';
import 'faq_model.dart';

class FrequentlyAskedQuestionsScreen extends StatelessWidget {
  const FrequentlyAskedQuestionsScreen({super.key, this.createBloc});

  final FaqBloc Function()? createBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => (createBloc?.call() ?? FaqBloc())
        ..add(
          FetchFaqs(
            searchQuery: '',
            page: 1,
            limit: 10,
          ),
        ),
      child: const _FaqScreenBody(),
    );
  }
}

class _FaqScreenBody extends StatefulWidget {
  const _FaqScreenBody();

  @override
  State<_FaqScreenBody> createState() => _FaqScreenBodyState();
}

class _FaqScreenBodyState extends State<_FaqScreenBody> {
  late final TextEditingController _searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;

        final query = value.trim();

        context.read<FaqBloc>().add(
              FetchFaqs(
                searchQuery: query,
                page: 1,
                limit: 10,
              ),
            );
      },
    );
  }

  void _clearSearch() {
    _debounce?.cancel();

    _searchController.clear();

    context.read<FaqBloc>().add(
          FetchFaqs(
            searchQuery: '',
            page: 1,
            limit: 10,
          ),
        );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InformationPage(
      title: Strings.faqs,
      slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('How can we help?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
                'Find answers about using the app and making time for yourself.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant)),
          ]),
        )),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search FAQs',
                hintText: 'Try subscriptions or reminders',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Clear search',
                          onPressed: _clearSearch),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.outlineVariant)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.outlineVariant)),
              ),
            ),
          ),
        ),
        BlocBuilder<FaqBloc, FaqState>(builder: (context, state) {
          if (state is FaqLoading) {
            return SliverToBoxAdapter(
                child: LoadingSkeleton(
              label: 'Loading questions',
              child: Column(
                  children: List.generate(
                      4,
                      (_) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: SkeletonBlock(height: 72),
                          ))),
            ));
          }
          if (state is FaqError) {
            return SliverToBoxAdapter(
                child: _notice(
              icon: Icons.wifi_off_rounded,
              title: 'Questions couldn’t load',
              message: 'Check your connection and try again.',
              action: 'Try again',
              onPressed: () => context.read<FaqBloc>().add(FetchFaqs(
                  searchQuery: _searchController.text.trim(),
                  page: 1,
                  limit: 10)),
            ));
          }
          if (state is FaqLoaded) return _buildFaqList(state.faqs);
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: .15)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.support_agent_rounded,
                  color: colors.primary, size: 28),
              const SizedBox(height: 12),
              Text('Still need a hand?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('Send us a message. We’re here to help.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactSupportscreen())),
                    child: const Text('Contact Support'),
                  )),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _notice(
      {required IconData icon,
      required String title,
      required String message,
      String? action,
      VoidCallback? onPressed}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(children: [
        Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        if (action != null) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: onPressed, child: Text(action)),
        ],
      ]),
    );
  }

  Widget _buildFaqList(List<Faq> faqs) {
    if (faqs.isEmpty) {
      final searching = _searchController.text.trim().isNotEmpty;
      return SliverToBoxAdapter(
          child: _notice(
        icon: Icons.search_off_rounded,
        title:
            searching ? 'No matching questions' : 'No questions available yet',
        message: searching
            ? 'Try a shorter phrase or a different keyword.'
            : 'You can contact our support team below.',
        action: searching ? 'Clear search' : null,
        onPressed: searching ? _clearSearch : null,
      ));
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      final faq = faqs[index];
      return FAQItemTile(
          key: ValueKey('${faq.question}:${faq.answer}'),
          question: faq.question,
          answer: faq.answer);
    }, childCount: faqs.length));
  }
}
