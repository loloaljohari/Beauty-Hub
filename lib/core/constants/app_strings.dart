/// Centralized static strings used across the Authentication module.
/// Replace with a localization solution (e.g. easy_localization /
/// flutter_localizations) later without touching widget code.
class AppStrings {
  AppStrings._();

  // Login
  static const String welcomeBackTo = 'welcome back to';
  static const String appName = 'Beaut   Hub';
  static const String login = 'Login';
  static const String noAccountRegister = "you don't have account? Register";
  static const String emailAddress = 'Email Address';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String loginAsGuest = 'Login as guest';
  static const String or = 'or';
  static const String continueWithGoogle = 'continue with Google';

  // Register
  static const String register = 'Register';
  static const String haveAccountLogin = 'you have account? Login';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phoneNumber = 'Phone Number';
  static const String yourAddress = 'Your Address';
  static const String confirmPassword = 'Confirm Password';

  // Verification / OTP
  static const String verificationCode = 'Verification Code';
  static const String otpSentMessage =
      'We have sent the verification code to your email address';
  static const String orderAnotherAfter = 'you can order another one after:';
  static const String order = 'Order';
  static const String continueText = 'Continue';

  // Check email
  static const String checkYourEmail = 'Check your Email';

  // Forgot password
  static const String enterEmailInstructions =
      "Enter Email Address associated with your account and we'll send an "
      'email with instructions to reset your password';
  static const String send = 'Send';

  // New password
  static const String createNewPassword = 'Create new Password';
  static const String newPasswordDifferent =
      'Your new password must be different from previous used password';
  static const String newPassword = 'New Password';
  static const String resetPassword = 'Reset Password';

  // Plan
  static const String planComparison = 'Plan comparison';
  static const String upgrade = 'Upgrade';
  static const String current = 'Current';
  static const String choose = 'Choose';
  static const String starter = 'Starter';
  static const String singleSalon = 'Single salon';
  static const String luxeGrowth = 'Luxe Growth';
  static const String multiLocationSuite = 'Multi-location suite';
  static const String enterprise = 'Enterprise';
  static const String beautyGroupScale = 'Beauty group scale';
  static const String free = 'Free';
  static const String custom = 'Custom';

  // Validation messages
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
}
