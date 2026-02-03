import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'category_list_event.dart';
import 'category_list_state.dart';

class CategoryListLoaded extends CategoryListState {}

class CategoryListBloc extends Bloc<CategoryListEvent, CategoryListState> {
  CategoryListBloc() : super(CategoryListLoaded()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryListState> emit,
  ) async {
    emit(CategoryListLoaded());
  }
}