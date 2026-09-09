import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/faqitem_tile.dart';
import '../../utils/color_constants.dart';
import 'faq_bloc/faq_bloc.dart';
import 'faq_bloc/faq_event.dart';
import 'faq_bloc/faq_state.dart';
import 'faq_model.dart';

class FrequentlyAskedQuestionsScreen extends StatelessWidget {
  const FrequentlyAskedQuestionsScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar(
              headingTxt: Strings.faqs,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: Strings.searchHelp,
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      );
                    },
                  ),
                  filled: true,
                  fillColor: ColorCodes.whitecolor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FaqBloc, FaqState>(
                builder: (context, state) {
                  // Only show the loader during the initial API call.
                  if (state is FaqLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is FaqError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }

                  if (state is FaqLoaded) {
                    return _buildFaqList(state.faqs);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList(List<Faq> faqs) {
    if (faqs.isEmpty) {
      return const Center(
        child: Text(
          'No FAQs found',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];

        return FAQItemTile(
          question: faq.question,
          answer: faq.answer,
        );
      },
    );
  }
}
