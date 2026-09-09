import 'package:equatable/equatable.dart';

abstract class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object?> get props => [];
}

class FetchFaqs extends FaqEvent {
  final String searchQuery;
  final int page;
  final int limit;

  const FetchFaqs({
    this.searchQuery = '',
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchQuery, page, limit];
}
