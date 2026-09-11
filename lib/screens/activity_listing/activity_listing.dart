import 'package:flutter/material.dart';
import 'category_collection.dart';

class MeditationListing extends StatelessWidget {
  const MeditationListing({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) =>
      CategoryCollection(categoryId: categoryId, isPause: true);
}
