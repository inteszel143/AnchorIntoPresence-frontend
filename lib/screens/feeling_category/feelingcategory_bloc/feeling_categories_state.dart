import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategorySuccess extends CategoryState {}

class CategoryFailure extends CategoryState {
  final String error;

  const CategoryFailure(this.error);

  @override
  List<Object> get props => [error];
}
