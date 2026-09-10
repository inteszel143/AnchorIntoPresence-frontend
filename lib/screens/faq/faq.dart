import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/information_page.dart';
import '../../helping_widgets/faqitem_tile.dart';
import 'faq_bloc/faq_bloc.dart';
import 'faq_bloc/faq_event.dart';
import 'faq_bloc/faq_state.dart';
import 'faq_model.dart';

class FrequentlyAskedQuestionsScreen extends StatelessWidget {
  const FrequentlyAskedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaqBloc()
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
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: Strings.searchHelp,
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
            return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()));
          }
          if (state is FaqError) {
            return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                    child: Text(state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error, height: 1.5))));
          }
          if (state is FaqLoaded) return _buildFaqList(state.faqs);
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
      ],
    );
  }

  Widget _buildFaqList(List<Faq> faqs) {
    if (faqs.isEmpty) {
      return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
              child: Text('No FAQs found', textAlign: TextAlign.center)));
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
