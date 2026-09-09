import 'package:flutter/material.dart';

/// Base class for all home page events
abstract class HomePageEvent {}

/// Event triggered to fetch home page data
class FetchHomePageDataEvent extends HomePageEvent {
  final String searchQuery;
  final String sortOrder;
  final BuildContext context;
  final bool? isSearch;

  FetchHomePageDataEvent({
    this.searchQuery = '',
    this.sortOrder = 'desc',
    required this.context,
    this.isSearch,
  });
}
