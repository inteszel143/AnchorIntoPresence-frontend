import 'package:flutter/material.dart';
import 'category_collection.dart';

class MeditationListingDaily extends StatelessWidget {
  const MeditationListingDaily({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) =>
      CategoryCollection(categoryId: categoryId);
}
