class Urls {
  static const String logout = '$baseUrl/api/auth/logout';
  static const String baseUrl = 'https://admin.anchorintopresence.net';
  static const String baseUrlimages = 'https://d1ckq51qwp5orx.cloudfront.net';
  static const String postActivity = '$baseUrl/api/users/activities/';
  static const String getActivity = '$baseUrl/api/users/activities';
  static const String contactSupport = '$baseUrl/api/users/contact-support';
  static const String editProfile = '$baseUrl/api/users/profile/update';
  static const String getFaqs = '$baseUrl/api/users/faqs';
  static const String getCategories = '$baseUrl/api/users/categories';
  static const String otpVerify = '$baseUrl/api/auth/verify-otp';
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String getUserProfile = '$baseUrl/api/users/profile';
  static const String socialLogin = '$baseUrl/api/auth/socialLogin';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  static const String getSelectCategory =
      '$baseUrl/api/users/select-categories';
  static const String addRemoveFavorite = '$baseUrl/api/users/favorite';
  static const String homePageData = '$baseUrl/api/users/home';
  static const String getTerms = '$baseUrl/api/users/content/terms';
  static const String getPrivacyPolicy = '$baseUrl/api/users/content/privacy';
  static const String userTrack = '$baseUrl/api/users/user-track';
  static const String setReminder = '$baseUrl/api/users/set-reminder';
  static const String selectCategories = '$baseUrl/api/users/select-categories';
  static const String fetchNotification =
      '$baseUrl/api/users/notifications?page=';
  static const String verifyOtp = '$baseUrl/api/auth/verify-otp';
  static const String resendOtp = '$baseUrl/api/auth/resend-otp';
  static const String totalMeditation = '$baseUrl/api/users/total-meditation';
  static const String postPurchase = '$baseUrl/api/users/purchase';
  static const String fetchPurchase = '$baseUrl/api/users/purchase';
  static const String fetchPosts = '$baseUrl/api/users/community/posts';
  static const String deleteAccount = '$baseUrl/api/users';
  static const String updateNotification =
      '$baseUrl/api/users/notifications/update';
  static const String getActivityById = '$baseUrl/api/users/activities';
  static const String recentlyPlayed = '$baseUrl/api/users/activities/recent';
}
