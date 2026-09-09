class Strings {
  static const String signInWelcome = 'Welcome back! Please enter your details';
  static const String signUpWelcome = 'Welcome! Please enter your details';
  static const String forgotPasswordHeader =
      "Forget your password? Enter your email, and we'll send you a reset link";
  static const String welcomeHeader = "Welcome to your daily sanctuary.";
  static const String welcomeNote1 =
      "For the next few moments, you are guided through grounding and meditation designed to calm your nervous system, steady your breath, and bring you back to yourself.";
  static const String welcomeNote3 = "\n\nFeel your body soften.\n"
      "Feel your breath deepen.\n"
      "Feel the quiet strength within you rise.\n\n"
      "This is where your day truly begins…\nanchored, aligned, and intentional.\n"
      "\nStep into your ritual.";
  static const String CategoryHeader =
      "What would feel most supportive for you in this moment?";
  static const String CategoryDescription =
      "Allow this to guide your practice.";
  static const String signUp = "Sign Up";
  static const String signIn = "Sign In";
  static const String login = "Login";
  static const String name = "Name";
  static const String enterYourName = "Enter your name";
  static const String emailAddress = "Email Address";
  static const String enterYourEmailAddress = "Enter your email address";
  static const String password = "Password";
  static const String enterYourPassword = "Enter your password";
  static const String orSignUpWith = "or Sign up with";
  static const String google = "Google";
  static const String apple = "Apple";
  static const String forgotPassword = "Forgot password";
  static const String forgotPasswordquestion = "Forgot password?";
  static const String orSignInWith = "or Sign In with";
  static const String otpVerification = "OTP Verification";
  static const String enterVerificationCode =
      "Enter the verification code we just sent to your email address";
  static const String dontGetCode = "Didn't get a code? ";
  static const String resendOtp = "Resend OTP";
  static const String resetPassword = "Reset Password";
  static const String newUniquePassword =
      "Your new password must be unique from previously used.";
  static const String newPassword = "New password";
  static const String enterNewPassword = "Enter new password";
  static const String confirmPassword = "Confirm password";
  static const String enterConfirmPassword = "Enter confirm password";
  static const String submit = "Submit";
  static const String areYouSureForSignOut =
      "Are you sure you want to sign out?";
  static const String areYouSureForDeleteAccount =
      "Are you sure you want to delete your account?";
  static const String areYouSureForDeletePost =
      "Are you sure you want to delete this post?";
  static const String areYouSureForDeleteComment =
      "Are you sure you want to delete this comment?";
  static const String logout = "Logout";
  static const String delete = "Delete";
  static const String cancel = "Cancel";
  static const String successfullyRegistered =
      "You have successfully registered.";
  static const String otpVerifiedSuccessfully = "OTP verified successfully";
  static const String pleaseEnterOTP = "Please enter the OTP";
  static const String verifying = "Verifying...";
  static const String verifyOTP = "Verify OTP";
  static const String markedAsComplete = "Marked as complete";
  static const String markAsComplete = "Mark as complete";
  static const String searchMeditation = "Search meditation...";
  static const String noActivityfound = "No activities found.";
  static const String recentActivities = "Recent Activities";
  static const String favouriteActivities = "Favorite Meditations";
  static const String contactSupport = "Contact Support";
  static const String title = "Title";
  static const String enterTitle = "Enter title";
  static const String description = "Description";
  static const String enterDescription = "Enter Description";
  static const String allFieldsRequired = "All fields are required";
  static const String searchSomething = "Search something...";
  static const String editProfile = "Edit Profile";
  static const String update = "Update";
  static const String updating = "Updating...";
  static const String faqs = "FAQs";
  static const String deleteAccount = "Delete Account";
  static const String searchHelp = "Search help...";
  static const String notifications = "Notifications";
  static const String privacyPolicy = "Privacy Policy";
  static const String setReminderTime = "Set Reminder Time";
  static const String getReminderTime = "Reminders";
  static const String sun = "Sun";
  static const String mon = "Mon";
  static const String tue = "Tue";
  static const String wed = "Wed";
  static const String thu = "Thu";
  static const String fri = "Fri";
  static const String sat = "Sat";
  static const String selectDate = "Select Date";
  static const String setReminder = "Set Reminder";
  static const String notificationAlert = "Notification Alert";
  static const String recentActivity = "Recent Activities";
  static const String subscriptionAndBilling = "Subscription and Billing";
  static const String termsAndConditions = "Terms of Use";
  static const String settings = "Settings";
  static const String subscriptionManagement = "Subscription";
  static const String plans = "Plans";
  static const String billingHistory = "Billing History";
  static const String termsConditions = "Terms & Conditions";
  static const String totalMeditation = "Total Meditation";
  static const String track = "Track";
  static const String todaySummary = "Today's Summary";
  static const String summary = "Summary";
  static const String january = "January";
  static const String february = "February";
  static const String march = "March";
  static const String april = "April";
  static const String may = "May";
  static const String june = "June";
  static const String july = "July";
  static const String august = "August";
  static const String september = "September";
  static const String october = "October";
  static const String november = "November";
  static const String december = "December";
  static const String profile = "Profile";
  static const String accountDetails = "Account Details";
  static const String somethingWentWrong = "Something went wrong";
  static const String begin = "Begin";
  static const String pleaseEnterYourEmail = "Please enter your email";
  static const String sendCode = "Send code";
  static const String community = "Community";
  static const String communityDetail = "Community Detail";
  static const String comments = "Comments";
  static const String writeYourMessage = "write your message";

  static const List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String getFirstName(String? displayName, String? email) {
    // Case 1: displayName available
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim().split(' ').first;
    }

    // Case 2: fallback to email
    if (email != null && email.contains('@')) {
      final emailName = email.split('@').first;

      // remove dots, numbers, special chars if needed
      final cleaned = emailName.replaceAll(RegExp(r'[0-9._-]'), ' ');

      final parts = cleaned.trim().split(' ');

      return parts.isNotEmpty
          ? parts.first[0].toUpperCase() + parts.first.substring(1)
          : '';
    }

    return '';
  }
}
