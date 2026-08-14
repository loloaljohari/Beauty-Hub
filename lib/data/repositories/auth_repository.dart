import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/notification/device_token_sync.dart';
import '../../core/storage/storage_service.dart';
import '../models/auth_field_config.dart';
import '../models/social_login_option.dart';

/// Authentication against `POST /api/expert/auth/*`.
///
/// The form-field getters below stay local on purpose: they describe
/// the *shape of the UI*, not data the server owns, and the backend
/// has no remote-config endpoint to serve them from.
class AuthRepository {
  const AuthRepository();

  /// Fields for the Login screen.
  List<AuthFieldConfig> getLoginFields() => const [
        AuthFieldConfig(
          key: 'email',
          label: 'Email Address',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        AuthFieldConfig(
          key: 'password',
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ];
 List<AuthFieldConfig> getFirstNameFields() => const [
       
        AuthFieldConfig(
          key: 'firstName',
          label: 'First Name',
          icon: Icons.person_outline,
        ),
        AuthFieldConfig(
          key: 'lastName',
          label: 'Last Name',
          icon: Icons.person_outline,
        ),
      ];


  /// Fields for the Register screen.
  List<AuthFieldConfig> getRegisterFields() => const [
       
        AuthFieldConfig(
          key: 'phoneNumber',
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        AuthFieldConfig(
          key: 'address',
          label: 'Your Address',
          icon: Icons.location_on_outlined,
        ),
        AuthFieldConfig(
          key: 'email',
          label: 'Email Address',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        AuthFieldConfig(
          key: 'password',
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        AuthFieldConfig(
          key: 'confirmPassword',
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ];

  /// Field for the Forgot Password screen.
  List<AuthFieldConfig> getForgotPasswordFields() => const [
        AuthFieldConfig(
          key: 'email',
          label: 'Email Address',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
      ];

  /// Fields for the New Password screen.
  List<AuthFieldConfig> getNewPasswordFields() => const [
        AuthFieldConfig(
          key: 'newPassword',
          label: 'New Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        AuthFieldConfig(
          key: 'confirmPassword',
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ];

  /// Social login providers shown on the Login screen.
  List<SocialLoginOption> getSocialLoginOptions() => const [
        SocialLoginOption(
          id: 'google',
          label: 'continue with Google',
          iconAsset: 'assets/icons/google.svg',
        ),
      ];

  // ─── API ──────────────────────────────────────────────────────────
  // Every method below hits `routes/api.php` under the `expert` prefix.
  // Field names are copied from the Postman collection and the
  // FormRequest classes, not guessed from the Flutter form keys.

  /// POST /expert/auth/login -> {data: {token}}
  ///
  /// Persists the token and, best-effort, a small profile summary so
  /// the drawer/app bar have something to show before the first
  /// `GET /auth/profile` returns.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await ApiClient.postMultipart(
      ApiEndpoints.login,
      fields: {'email': email, 'password': password},
    );

    final token = ApiResponse.data(response)['token'];
    if (token is String && token.isNotEmpty) {
      await ApiClient.setToken(token);
    }

    await StorageService.saveRememberMe(rememberMe, email: email);

    // Not fatal if either fails - login already succeeded.
    try {
      await cacheProfileSummary();
    } catch (_) {}

    // Register this device for push RIGHT HERE, not only in `main()`.
    //
    // `DeviceTokenSync.start()` bails out when no session exists, and
    // `main()` runs before the user has one. On a first-ever login, and
    // after any logout-then-login in the same session, the token was
    // therefore never sent - push only started working from the SECOND
    // cold start onward, which reads as an intermittent bug.
    //
    // Must come after `setToken`: the sync checks `ApiClient.hasToken`
    // and exits silently without it.
    try {
      await DeviceTokenSync.start();
    } catch (_) {
      // A failed push registration is never a reason to block login.
    }

    return ApiResponse.asMap(response);
  }

  /// GET /expert/auth/profile, stored via [StorageService] so the shell
  /// can render instantly on the next cold start.
  Future<void> cacheProfileSummary() async {
    final response = await ApiClient.get(ApiEndpoints.profile);
    final expert = ApiResponse.object(response, 'expert');
    if (expert.isEmpty) return;

    await StorageService.saveUserSummary(
      id: ApiResponse.asInt(expert['id']),
      name: ApiResponse.asStringOrNull(expert['full_name']),
      email: ApiResponse.asStringOrNull(expert['email']),
      photo: ApiResponse.asStringOrNull(expert['profile_photo']),
      specialization: ApiResponse.asStringOrNull(expert['specialization']),
    );
  }

  /// POST /expert/auth/register (multipart - it accepts photos).
  ///
  /// `specialization` is a real backend column and is required; the
  /// registration form's "address" field is mapped onto it because
  /// that is what the existing UI collects.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required String email,
    required String password,
    required String confirmPassword,
    String? profilePhotoPath,
    String? experienceYears,
    String? governorate,
    String? city,
    String? birthDate,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.register,
      fields: {
        'full_name': '$firstName $lastName'.trim(),
        'phone': phone,
        'specialization': address,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        if (experienceYears != null && experienceYears.isNotEmpty)
          'experience_years': experienceYears,
        if (governorate != null && governorate.isNotEmpty)
          'governorate': governorate,
        if (city != null && city.isNotEmpty) 'city': city,
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
      },
      files: {
        if (profilePhotoPath != null && profilePhotoPath.isNotEmpty)
          'profile_photo': profilePhotoPath,
      },
    );

    // The OTP screen may be reached after an app restart.
    await StorageService.savePendingOtpEmail(email);
  }

  /// POST /expert/auth/verify_otp
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.verifyOtp,
      fields: {'email': email, 'otp': otp},
    );

    await StorageService.clearPendingOtpEmail();
  }

  /// POST /expert/auth/resend_otp
  Future<void> resendOtp({required String email}) async {
    await ApiClient.postMultipart(
      ApiEndpoints.resendOtp,
      fields: {'email': email},
    );
  }

  /// POST /expert/auth/forget_password - sends an OTP to the address.
  Future<void> forgetPassword({required String email}) async {
    await ApiClient.postMultipart(
      ApiEndpoints.forgetPassword,
      fields: {'email': email},
    );

    // The reset screen is two navigations away and needs this.
    await StorageService.savePendingOtpEmail(email);
  }

  /// POST /expert/auth/reset_password
  ///
  /// The backend validates the OTP inside the FormRequest, so it has to
  /// travel with the new password - hence the stored [email] and the
  /// [otp] captured on the "check email" screen.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.resetPassword,
      fields: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );

    await StorageService.clearPendingOtpEmail();
  }

  /// POST /expert/auth/change_password (authenticated).
  ///
  /// The backend revokes every token afterwards, so the caller must
  /// send the user back to login.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.changePassword,
      fields: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );

    await StorageService.clearUserData();
    await ApiClient.clearToken();
  }

  /// POST /expert/auth/logout.
  ///
  /// Local state is cleared even when the network call fails - a user
  /// tapping "log out" offline must still end up logged out.
  Future<void> logout() async {
    try {
      await ApiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Intentionally swallowed: see above.
    } finally {
      await ApiClient.clearToken();
      await StorageService.clearUserData();
    }
  }

  /// DELETE /expert/auth/delete_account
  Future<void> deleteAccount() async {
    await ApiClient.delete(ApiEndpoints.deleteAccount);
    await ApiClient.clearToken();
    await StorageService.clearUserData();
  }

  /// The backend generates a 6-digit OTP (`OTPNotification`).
  int getOtpLength() => 6;

  /// Countdown before "resend" becomes tappable again.
  int getResendCountdownSeconds() => 60;
}
