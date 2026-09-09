import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object> get props => [];
}

class SelectCategory extends CategoryEvent {
  final String mood;

  const SelectCategory({required this.mood});

  @override
  List<Object> get props => [mood];
}
