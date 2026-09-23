import '../common/auth/social_login_exception.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mindfully_evolve_app/utils/status_codes.dart';

import '../common/local_storage.dart';
import '../screens/activity_details/activityresponse_model.dart';
import '../screens/activity_listing/getactivity_model.dart';
import '../screens/comment/comment_model.dart';
import '../screens/community/community_model.dart';
import '../screens/contact_support/contact_support_model.dart';
import '../screens/dashboard/dashboard_bloc/recently_played_model.dart';
import '../screens/dashboard/home_model.dart';
import '../screens/edit_profile/edit_profile_model.dart';
import '../screens/notification/notification_model.dart';
import '../screens/privacy_policy/privacy_model.dart';
import '../screens/reset_password/reset_password_model.dart';
import '../screens/signin/signin_model.dart';
import '../screens/signup/signup_model.dart';
import '../screens/subscriptionmanagement/user_purchase_model.dart';
import '../screens/term&conditions/terms_model.dart';
import '../screens/totalmedication/total_meditation_model.dart';
import '../screens/user_profile/user_model.dart';
import 'urls.dart';

class ApiService {
  static Future<Map<String, dynamic>> setReminder(
      Map<String, dynamic> reminderData) async {
    final url = Urls.setReminder;
    final token = await LocalStorage.getToken() ?? '';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(reminderData),
      );

      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'body': json.decode(response.body),
        };
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to set reminder');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> updateReminder(
      Map<String, dynamic> reminderData) async {
    final String id = reminderData['id'].toString();
    final token = await LocalStorage.getToken() ?? '';
    final Map<String, dynamic> bodyData = {
      'time': reminderData['time'],
    };

    if (reminderData['date'] != null &&
        reminderData['date'].toString().isNotEmpty) {
      bodyData['date'] = reminderData['date'];
    } else if (reminderData['weekday'] != null &&
        (reminderData['weekday'] as List).isNotEmpty) {
      bodyData['weekday'] = reminderData['weekday'];
    }

    final url = Uri.parse("${Urls.setReminder}/$id");

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyData),
      );
      if (response.statusCode == 200) {
        return {
          'statusCode': response.statusCode,
          'body': jsonDecode(response.body),
        };
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<bool> deleteReminder(String id) async {
    final url = Uri.parse("${Urls.setReminder}/$id");
    final token = await LocalStorage.getToken() ?? '';
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  static Future<PostActivityResponseModel> markActivityComplete({
    required String activityId,
    required String videoTimestamp,
    required String totalVideoTime,
    required bool isCompleted,
  }) async {
    final token = await LocalStorage.getToken() ?? '';
    final url = Uri.parse('${Urls.postActivity}$activityId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "videoTimestamp": videoTimestamp,
          "totalVideoTime": totalVideoTime,
          "isCompleted": isCompleted,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PostActivityResponseModel.fromJson(responseData);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception(
            'Failed to mark activity complete with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<RecentlyPlayedResponse> fetchRecentlyPlayed({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await LocalStorage.getToken() ?? '';
    final url = Uri.parse('${Urls.recentlyPlayed}?page=$page&limit=$limit');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecentlyPlayedResponse.fromJson(data);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to fetch recently played activities');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<Activity> fetchActivity(String? activityId) async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final url = Uri.parse(
        '${Urls.getActivityById}/$activityId',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return Activity.fromJson(data['data']);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to load activities: ${data['message']}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<ActivityResponse> fetchActivities(
    int page,
    int limit,
    String search,
    String sortOrder,
    String? categoryId,
    String? date, // 👈 add this
  ) async {
    try {
      final token = await LocalStorage.getToken() ?? '';

      final queryParams = <String, String>{
        'page': '$page',
        'limit': '10000',
        'search': search,
        'sort': sortOrder,
      };

      // only add if not null/empty
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final url = Uri.parse(Urls.getActivity).replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, Uri.encodeComponent(value)),
        ),
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return ActivityResponse.fromJson(data);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to load activities: ${data['message']}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<String> toggleFavorite(String activityId) async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final url = Uri.parse(Urls.addRemoveFavorite);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'activityId': activityId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return data['message'];
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('API call failed: ${data['message']}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<ContactSupportResponseModel> submitSupportRequest({
    required String title,
    required String description,
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse(Urls.contactSupport);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == StatusCode.ok &&
          responseData['status'] == true) {
        return ContactSupportResponseModel.fromJson(responseData);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        final errorMsg = responseData['message'] ?? 'Failed to send message';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<ProfileDataModel> fetchProfileData(String token) async {
    try {
      final response = await http.get(
        Uri.parse(Urls.getUserProfile),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProfileDataModel.fromJson(data['data']);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<HomePageDataModel> fetchHomeData(
    String token,
    String searchQuery,
    String sortOrder,
  ) async {
    try {
      final queryParams = <String, String>{
        'search': searchQuery,
        'sort': sortOrder,
      };

      if (searchQuery.trim().isEmpty) {
        final todayDate = DateTime.now().toIso8601String().split('T')[0];
        queryParams['date'] = todayDate;
      }

      final url = Uri.parse(Urls.homePageData).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HomePageDataModel.fromJson(data);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
          'Client Error: ${response.statusCode} - ${response.body}',
        );
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server Error: ${response.statusCode} - ${response.body}',
        );
      } else {
        throw Exception('Failed to load home page data');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      } else if (e is FormatException) {
        throw Exception(
          'Invalid response format: Unable to parse the response.',
        );
      } else if (e is TimeoutException) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<EditProfileResponseModel> updateProfile({
    required String name,
    File? image,
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse(Urls.editProfile);

      final request = http.MultipartRequest('PATCH', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

      request.fields['name'] = name;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == StatusCode.ok && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          return EditProfileResponseModel.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Profile update failed');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Unexpected server response: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> fetchFAQ(
    int page,
    int limit,
    String searchQuery,
  ) async {
    final token = await LocalStorage.getToken();

    final baseUri = Uri.parse(Urls.getFaqs);

    final url = baseUri.replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': searchQuery.trim(),
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load FAQs: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> selectCategory(String mood) async {
    final url = Uri.parse(Urls.selectCategories);

    try {
      final token = await LocalStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mood': mood.toLowerCase()}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client Error: ${response.statusCode} - ${response.body}');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server Error: ${response.statusCode} - ${response.body}');
      } else {
        throw Exception('Failed to select category: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
            'Network Error: Please check your internet connection.');
      } else if (e is FormatException) {
        throw Exception(
            'Invalid response format: Unable to parse the response.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Request timeout: The server took too long to respond.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> submitForgotPassword(String email) async {
    try {
      final cleanedEmail = email.replaceAll(' ', '');

      final response = await http.post(
        Uri.parse(Urls.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': cleanedEmail,
        }),
      );

      final responseBody = json.decode(response.body);

      // Return the API response for both success and
      // expected client-side validation/account errors.
      if (response.statusCode == StatusCode.ok ||
          (response.statusCode >= 400 && response.statusCode < 500)) {
        return responseBody;
      }

      if (response.statusCode >= 500) {
        throw Exception('Server Error');
      }

      throw Exception(
        responseBody['message'] ?? 'Unknown error',
      );
    } on SocketException {
      throw Exception('Please check your internet connection');
    } on FormatException {
      throw Exception(
        'Invalid response format: Unable to parse the response.',
      );
    } on TimeoutException {
      throw Exception(
        'Request timeout: The server took too long to respond.',
      );
    } on http.ClientException {
      throw Exception(
        'Network Error: Please check your internet connection.',
      );
    }
  }

  static Future<List<Notification>> fetchNotifications() async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final response = await http.get(
        Uri.parse(Urls.fetchNotification),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);
      final notificationResponse = NotificationResponse.fromMap(responseBody);
      return notificationResponse.data;
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<String> fetchPrivacyPolicy() async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final response = await http.get(
        Uri.parse(Urls.getPrivacyPolicy),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      final privacyPolicyResponse = PrivacyPolicyResponse.fromJson(data);
      final description = privacyPolicyResponse.data.description;
      return description;
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<ResetPasswordResponseModel> resetPassword(
      String email, String password) async {
    final url = Uri.parse(Urls.resetPassword);

    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      final resetPasswordResponse =
          ResetPasswordResponseModel.fromJson(jsonResponse);

      return resetPasswordResponse; // Return the response model if successful
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<String> fetchTerms() async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final response = await http.get(
        Uri.parse(Urls.getTerms),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      final termResponse = TermsResponse.fromJson(data);
      final description = termResponse.data.description;
      return description;
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      {required String email, required String otp}) async {
    final uri = Uri.parse(Urls.verifyOtp);
    bool? forPurchase = await LocalStorage.getBool();
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': email, 'otp': otp, 'forPurchase': forPurchase}),
      );

      final data = jsonDecode(response.body);
      return {'statusCode': response.statusCode, 'body': data};
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final uri = Uri.parse(Urls.resendOtp);
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final body = jsonDecode(response.body);
      return {'statusCode': response.statusCode, 'body': body};
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  static Future<SigninResponseModel> login({
    required String email,
    required String password,
    required String? fcmToken,
  }) async {
    final url = Uri.parse(Urls.login);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
          "fcmToken": fcmToken,
        }),
      );

      final json = jsonDecode(response.body);
      final data = SigninResponseModel.fromJson(json);
      return data;
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('Please check your internet connection');
    }
  }

  static Future<SocialSigninResponseModel> socialLogin({
    required String email,
    required String socialId,
    required String loginMedium,
    required String? fcmToken,
  }) async {
    final url = Uri.parse(Urls.socialLogin);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "login_medium": loginMedium,
          "email": email,
          "social_id": socialId,
          "fcmToken": fcmToken,
        }),
      ).timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a response object');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded['message'];
        throw SocialLoginException(response.statusCode < 500 && message is String
            ? message
            : 'The sign-in server is unavailable. Please try again later.');
      }
      return SocialSigninResponseModel.fromJson(decoded);
    } on SocialLoginException {
      rethrow;
    } on SocketException {
      throw const SocialLoginException('Unable to reach the sign-in server. Please check your connection.');
    } on http.ClientException {
      throw const SocialLoginException('Unable to connect securely to the sign-in server. Please try again.');
    } on TimeoutException {
      throw const SocialLoginException('The sign-in server took too long to respond. Please try again.');
    } catch (error) {
      throw const SocialLoginException('The sign-in server returned an unexpected response. Please try again later.');
    }
  }

  static Future<SignupResponseModel> signup({
    String? name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Urls.register);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (name != null && name.trim().isNotEmpty)
            'name': name.replaceAll(' ', ''),
          'email': email.replaceAll(' ', ''),
          'password': password,
        }),
      );

      final jsonResponse = json.decode(response.body);
      final data = SignupResponseModel.fromJson(jsonResponse);
      return data;
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('Please check your internet connection');
    }
  }

  static Future<SignupResponseModel> socialSignup({
    required String name,
    required String email,
    required String socialId,
    required String loginMedium,
  }) async {
    final url = Uri.parse(Urls.register);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name.replaceAll(' ', ''),
          'email': email.replaceAll(' ', ''),
          'social_id': socialId,
          'login_medium': loginMedium,
        }),
      );

      final jsonResponse = json.decode(response.body);
      return SignupResponseModel.fromJson(jsonResponse);
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('Please check your internet connection');
    }
  }

  static Future<TotalMeditationDataResponse> fetchTotalMeditationData() async {
    final url = Uri.parse(Urls.totalMeditation);
    final token = await LocalStorage.getToken() ?? '';
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TotalMeditationDataResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load data (Status code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Please check your internet connection');
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<UserModel> fetchUserProfile() async {
    final token = await LocalStorage.getToken() ?? '';

    final response = await http.get(
      Uri.parse(Urls.getUserProfile),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == StatusCode.ok) {
      final jsonData = json.decode(response.body);
      return UserModel.fromJson(jsonData['data']);
    } else {
      throw HttpException(
          'Failed to load user profile: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getReminder() async {
    final token = await LocalStorage.getToken() ?? '';
    final url = Urls.setReminder;
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedBody = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }

  static Future<void> sendPurchase({
    required String productId,
    required String purchaseId,
    required int amount,
    required String purchaseDate,
    required String planType,
    required String currencySymbol,
    String? extraToken,
  }) async {
    final url = Urls.postPurchase;

    final Map<String, dynamic> data = {
      'productId': productId,
      'purchaseId': purchaseId,
      'amount': amount,
      'purchaseDate': purchaseDate,
      'planType': planType,
      'currencySymbol': currencySymbol
    };

    try {
      final token = await LocalStorage.getToken() ?? extraToken;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to send purchase: ${response.statusCode}");
      }
    } catch (e) {}
  }

  static Future<List<UserPurchase>> fetchUserPurchases() async {
    final url = Urls.fetchPurchase;
    final token = await LocalStorage.getToken() ?? '';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> data = jsonBody['data'];
        return data.map((item) => UserPurchase.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch user purchases');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } catch (e) {
      throw Exception('Failed to fetch user purchases');
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await LocalStorage.getToken() ?? '';
      final response = await http.delete(
        Uri.parse(Urls.deleteAccount),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': false,
          'message': 'Failed to delete account. Please try again later.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  static Future<List<Post>> fetchPosts() async {
    final apiUrl = Urls.fetchPosts;
    final token = await LocalStorage.getToken() ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((post) => Post.fromJson(post)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> likePost(String postId) async {
    final url = '${Urls.fetchPosts}/$postId';
    final token = await LocalStorage.getToken() ?? '';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  static Future<PostLikesPage> fetchPostLikes(String postId, int page) async {
    final apiUrl = '${Urls.fetchPosts}/$postId/likes?page=$page';
    final token = await LocalStorage.getToken() ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PostLikesPage.fromJson(data);
      } else {
        throw Exception(
            'Failed to load post likes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching post likes: $e');
    }
  }

  static Future<List<Comment>> fetchComments(String postId) async {
    final apiUrl = '${Urls.fetchPosts}/$postId/comments';
    final token = await LocalStorage.getToken() ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data
            .map((commentJson) => Comment.fromJson(commentJson))
            .toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error fetching comments');
    }
  }

  static Future<void> postComment(
      String postId, String parentCommentId, String message) async {
    final url = '${Urls.fetchPosts}/$postId/comments';
    final token = await LocalStorage.getToken() ?? '';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body:
          jsonEncode({'message': message, 'parentCommentId': parentCommentId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post comment');
    }
  }

  static Future<void> likeComment(String postId, String commentId) async {
    final url = '${Urls.fetchPosts}/$postId/comments/$commentId/like';
    final token = await LocalStorage.getToken() ?? '';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like comment');
    }
  }

  static Future<void> createPost({
    required String message,
    required String postType,
    required bool postAnonymously,
    List<String>? imagePaths,
  }) async {
    final token = await LocalStorage.getToken() ?? '';
    final url = Urls.fetchPosts;
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['message'] = message;
    request.fields['postType'] = postType;
    request.fields['postAnonymously'] = postAnonymously.toString();

    if (imagePaths != null) {
      for (String path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to create post');
    }
  }

  static Future<bool> deletePost(String postId) async {
    final token = await LocalStorage.getToken() ?? '';
    final baseUrl = Urls.fetchPosts;
    final url = Uri.parse('$baseUrl/$postId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> deleteComment(String postId, String commentId) async {
    final token = await LocalStorage.getToken() ?? '';
    final baseUrl = Urls.fetchPosts;
    final url = Uri.parse('$baseUrl/ $postId/comments/$commentId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Post> fetchCommunityPost(String shareId) async {
    final url = Uri.parse('${Urls.fetchPosts}/share/$shareId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var decodedJson = json.decode(response.body);

        return Post.fromPostDetail(decodedJson['data']);
      } else {
        throw Exception("Failed to load community post");
      }
    } catch (e) {
      throw Exception("Failed to load community post: $e");
    }
  }
}
