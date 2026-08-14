import 'package:flutter/material.dart';

/// The two languages supported by the app. Add new entries here and
/// to [AppStrings] (see app_localizations.dart) to support more
/// languages later.
enum AppLanguage { english, arabic }

extension AppLanguageX on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.arabic:
        return const Locale('ar');
    }
  }

  /// Native display name shown in the language picker
  /// (always shown in its own language, e.g. "العربية" not "Arabic").
  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'العربية';
    }
  }

  TextDirection get textDirection {
    switch (this) {
      case AppLanguage.english:
        return TextDirection.ltr;
      case AppLanguage.arabic:
        return TextDirection.rtl;
    }
  }

  static AppLanguage fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return AppLanguage.arabic;
      default:
        return AppLanguage.english;
    }
  }

  static AppLanguage fromLanguageCode(String code) {
    switch (code) {
      case 'ar':
        return AppLanguage.arabic;
      default:
        return AppLanguage.english;
    }
  }
}
