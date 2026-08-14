import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/storage_service.dart';
import '../models/settings_models.dart';

/// Profile and weekly-schedule settings.
///
/// Two backend behaviours drive the shape of this file:
///
///  1. `PUT /expert/calendar` REPLACES the entire schedule. The service
///     deletes every row for the expert and inserts what it was sent.
///     Posting a single day therefore wipes the rest of the week -
///     which is exactly what the old `addSchedule` did. Every write
///     here now sends the complete week.
///
///  2. `day_of_week` is 0-6 on the server (`between:0,6`), where 0 is
///     Sunday. The old mapping used 1-7, so every day was stored one
///     slot late and Saturday failed validation outright.
class SettingsRepository {
  const SettingsRepository();

  /// Index in this list IS the backend's `day_of_week` value.
  static const List<String> weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  List<String> getWeekDays() => weekDays;

  String getNameofDay(dynamic dayOfWeek) {
    final index = ApiResponse.asInt(dayOfWeek, fallback: -1);
    if (index < 0 || index >= weekDays.length) return '';
    return weekDays[index];
  }

  /// Returns -1 for an unknown name so a bad value fails loudly at the
  /// call site instead of silently becoming Sunday.
  int getnumofDay(String day) => weekDays.indexOf(day);

  // ── profile ─────────────────────────────────────────────────────

  /// GET /expert/auth/profile -> data.expert
  Future<SettingsProfileModel> getProfile() async {
    final response = await ApiClient.get(ApiEndpoints.profile);
    final expert = ApiResponse.object(response, 'expert');

    await StorageService.saveUserSummary(
      id: ApiResponse.asInt(expert['id']),
      name: ApiResponse.asStringOrNull(expert['full_name']),
      email: ApiResponse.asStringOrNull(expert['email']),
      photo: ApiResponse.asStringOrNull(expert['profile_photo']),
      specialization: ApiResponse.asStringOrNull(expert['specialization']),
    );

    return _toProfile(expert);
  }

  /// POST /expert/auth/update_profile (multipart, accepts both photos).
  ///
  /// The endpoint responds with `{success, message}` and NO `data` key -
  /// `ApiResponseTrait` strips it when the payload is empty. Reading
  /// `response['data']['full_name']` there was a guaranteed crash, so
  /// the fresh profile is re-fetched instead of parsed from the reply.
  Future<SettingsProfileModel> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? bio,
    String? specialization,
    String? profilePhoto,
    String? coverPhoto,
    String? birthdate,
    String? governorate,
    int? experienceYears,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.updateProfile,
      fields: {
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (governorate != null) 'governorate': governorate,
        if (bio != null) 'bio': bio,
        if (birthdate != null && birthdate.isNotEmpty)
          'birth_date': birthdate,
        if (specialization != null) 'specialization': specialization,
        if (experienceYears != null)
          'experience_years': experienceYears.toString(),
      },
      files: {
        if (profilePhoto != null && profilePhoto.isNotEmpty)
          'profile_photo': profilePhoto,
        if (coverPhoto != null && coverPhoto.isNotEmpty)
          'cover_photo': coverPhoto,
      },
    );

    return getProfile();
  }

  // ── weekly schedule ─────────────────────────────────────────────

  /// GET /expert/calendar -> data.schedule
  Future<List<WorkScheduleModel>> getWorkSchedule() async {
    final response = await ApiClient.get(ApiEndpoints.calendar);

    return ApiResponse.asMapList(ApiResponse.data(response)['schedule'])
        .map((row) => WorkScheduleModel(
              id: ApiResponse.asString(row['id']),
              day: getNameofDay(row['day_of_week']),
              startTime: ApiResponse.asTime(row['start_time']),
              endTime: ApiResponse.asTime(row['end_time']),
              isActive: ApiResponse.asBool(row['is_active'], fallback: true),
              slotDuration:
                  ApiResponse.asString(row['slot_duration_minutes']),
            ))
        .toList();
  }

  /// Adds one working day WITHOUT losing the others.
  ///
  /// Reads the current week, merges the new entry in, and sends the
  /// whole thing back - the only safe way to use a replace-style
  /// endpoint. Adding a day that already exists overwrites that day
  /// rather than creating a duplicate the server would then reject.
  Future<List<WorkScheduleModel>> addSchedule(
    String day,
    String start,
    String end,
    String slot,
    bool active,
  ) async {
    final current = await getWorkSchedule();

    final merged = <String, WorkScheduleModel>{
      for (final entry in current) entry.day: entry,
      day: WorkScheduleModel(
        id: '',
        day: day,
        startTime: start,
        endTime: end,
        isActive: active,
        slotDuration: slot,
      ),
    };

    return replaceSchedule(merged.values.toList());
  }

  /// Removes one day, again by sending the remaining week back.
  Future<List<WorkScheduleModel>> removeScheduleDay(String day) async {
    final current = await getWorkSchedule();
    return replaceSchedule(
      current.where((entry) => entry.day != day).toList(),
    );
  }

  /// PUT /expert/calendar with the complete week.
  ///
  /// The backend requires at least one row (`array|min:1`), so clearing
  /// the schedule entirely is not possible through this endpoint - the
  /// last day is deactivated instead of deleted.
  Future<List<WorkScheduleModel>> replaceSchedule(
    List<WorkScheduleModel> schedule,
  ) async {
    final rows = schedule
        .where((entry) => getnumofDay(entry.day) >= 0)
        .map((entry) => {
              'day_of_week': getnumofDay(entry.day),
              'start_time': _hhmm(entry.startTime),
              'end_time': _hhmm(entry.endTime),
              'slot_duration_minutes':
                  int.tryParse(entry.slotDuration) ?? 30,
              'is_active': entry.isActive,
            })
        .toList();

    if (rows.isEmpty) {
      throw const ApiException(
        message: 'Your schedule must keep at least one working day.',
        statusCode: 422,
      );
    }

    final response =
        await ApiClient.put(ApiEndpoints.calendar, body: {'schedule': rows});

    return ApiResponse.asMapList(ApiResponse.data(response)['schedule'])
        .map((row) => WorkScheduleModel(
              id: ApiResponse.asString(row['id']),
              day: getNameofDay(row['day_of_week']),
              startTime: ApiResponse.asTime(row['start_time']),
              endTime: ApiResponse.asTime(row['end_time']),
              isActive: ApiResponse.asBool(row['is_active'], fallback: true),
              slotDuration:
                  ApiResponse.asString(row['slot_duration_minutes']),
            ))
        .toList();
  }

  // ── account actions ─────────────────────────────────────────────

  /// The server validates `date_format:H:i`, so `09:00:00` is rejected.
  String _hhmm(String time) =>
      time.length >= 5 ? time.substring(0, 5) : time;

  /// POST /expert/auth/logout, then clear local session state.
  Future<void> logout() async {
    try {
      await ApiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Signing out must work offline too.
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

  /// POST /expert/auth/change_password.
  /// Revokes every token server-side - the caller must route to login.
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

    await ApiClient.clearToken();
    await StorageService.clearUserData();
  }

  SettingsProfileModel _toProfile(Map<String, dynamic> expert) {
    return SettingsProfileModel(
      name: ApiResponse.asString(expert['full_name']),
      phone: ApiResponse.asString(expert['phone']),
      email: ApiResponse.asString(expert['email']),
      birthdate: ApiResponse.asDate(expert['birth_date']),
      bio: ApiResponse.asString(expert['bio']),
      location: ApiResponse.asString(expert['city']),
      // No social columns exist on `experts`; left blank rather than
      // invented so the fields simply render empty.
      instagramHandle: '',
      facebookHandle: '',
      typeOfWork: ApiResponse.asString(expert['specialization']),
      experienceYears: ApiResponse.asInt(expert['experience_years']),
      avatarUrl:
          AppConfig.mediaUrl(ApiResponse.asStringOrNull(expert['profile_photo'])),
      followersCount: ApiResponse.asInt(expert['followers_count']),
      // `following_count` is not a column on experts - an expert
      // follows nobody in this data model. Previously hardcoded to 500.
      followingCount: 0,
    );
  }
}
