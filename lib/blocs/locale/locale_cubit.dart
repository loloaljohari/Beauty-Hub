import 'package:beautyhup/core/localization/app_language.dart';
import 'package:beautyhup/core/storage/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the app's currently selected [AppLanguage].
///
/// Intentionally a [Cubit] rather than a full Bloc: it holds one value
/// and exposes a method to change it. [MaterialApp] listens through
/// [BlocBuilder] and rebuilds with the new [Locale] and text direction
/// app-wide.
///
/// The choice is persisted through [StorageService], so it survives a
/// restart. It is deliberately NOT cleared on logout - language is a
/// device preference, not session data, and resetting an Arabic user to
/// English every time they sign out would be hostile.
class LocaleCubit extends Cubit<AppLanguage> {
  /// Reads the saved language synchronously.
  ///
  /// This works because `StorageService.init()` runs in `main()` before
  /// `runApp`, so the value is already in memory - no async gap, and
  /// therefore no flash of the wrong language on the first frame.
  LocaleCubit() : super(_restore());

  static AppLanguage _restore() {
    final code = StorageService.localeSync;
    if (code == null || code.isEmpty) return AppLanguage.english;
    return AppLanguageX.fromLanguageCode(code);
  }

  void changeLanguage(AppLanguage language) {
    if (language == state) return;
    emit(language);
    StorageService.saveLocale(language.locale.languageCode);
  }

  void toggle() {
    changeLanguage(
      state == AppLanguage.english ? AppLanguage.arabic : AppLanguage.english,
    );
  }
}
