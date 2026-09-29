import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/urls.dart';

/// Enrich older API responses using the existing category-filtered endpoint.
Future<Map<String, dynamic>> resolveActivityCategories(
  Map<String, dynamic> response, {
  required http.Client client,
  required String token,
  String? categoryId,
}) async {
  final items = [
    ...?response['data'] as List?,
    ...?response['recommendedActivities'] as List?,
  ];
  if (items.isEmpty ||
      items.every(
          (item) => (item['categoryName'] ?? '').toString().isNotEmpty)) {
    return response;
  }
  Future<Map<String, dynamic>> get(
      String endpoint, Map<String, String> query) async {
    final result = await client
        .get(Uri.parse(endpoint).replace(queryParameters: query), headers: {
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 30));
    if (result.statusCode != 200) {
      throw Exception('Unable to load practice categories');
    }
    final json = jsonDecode(result.body) as Map<String, dynamic>;
    if (json['status'] != true) {
      throw Exception('Unable to load practice categories');
    }
    return json;
  }

  final categories = <Map<String, dynamic>>[];
  for (var page = 1;; page++) {
    final result =
        await get(Urls.getCategories, {'page': '$page', 'limit': '100'});
    categories.addAll((result['data'] as List).cast<Map<String, dynamic>>());
    if (page >= (result['pagination']?['totalPages'] as num? ?? 1)) break;
  }
  final labels = <String, String>{};
  if (categoryId != null && categoryId.isNotEmpty) {
    final matches = categories.where((c) => c['_id'] == categoryId);
    if (matches.isNotEmpty) {
      for (final item in items) {
        labels[item['_id'].toString()] = matches.first['name'].toString();
      }
    }
  } else {
    for (final category in categories) {
      for (var page = 1;; page++) {
        final result = await get(Urls.getActivity, {
          'categoryId': category['_id'].toString(),
          'page': '$page',
          'limit': '10000',
        });
        for (final item in result['data'] as List) {
          labels[item['_id'].toString()] = category['name'].toString();
        }
        if (page >= (result['pagination']?['totalPages'] as num? ?? 1)) break;
      }
    }
  }
  List<dynamic> annotate(List<dynamic>? list) => (list ?? [])
      .map((item) => {
            ...item as Map<String, dynamic>,
            'categoryName':
                labels[item['_id'].toString()] ?? item['categoryName'] ?? '',
          })
      .toList();
  return {
    ...response,
    'data': annotate(response['data']),
    'recommendedActivities': annotate(response['recommendedActivities'])
  };
}
