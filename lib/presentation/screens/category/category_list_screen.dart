import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../localization/localization.dart';
import 'category_list_bloc.dart';
import 'category_list_state.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryListBloc, CategoryListState>(
      builder: (context, state) {
        if (state is CategoryListLoaded) {
          return Center(
            child: Text(
              AppLocalizations.of(context).categoriesComingSoon,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
