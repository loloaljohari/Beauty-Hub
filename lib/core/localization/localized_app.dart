import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../theme/app_theme.dart';
import '../../blocs/locale/locale_cubit.dart';
import 'app_language.dart';

/// Root widget that wires [LocaleCubit] into [MaterialApp] so the
/// whole app rebuilds with the new [Locale] AND text direction
/// (RTL for Arabic, LTR for English) whenever the language changes
/// in Settings.
///
/// Use this instead of building [MaterialApp] directly in `main.dart`.
class LocalizedApp extends StatelessWidget {
  final bool isLoggedIn;

  /// Lets non-widget code (the API client's 401 handler) navigate.
  final GlobalKey<NavigatorState>? navigatorKey;

  const LocalizedApp({
    super.key,
    required this.isLoggedIn,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(),
      child: BlocBuilder<LocaleCubit, AppLanguage>(
        builder: (context, language) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Beauty Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: isLoggedIn ? RouteNames.home : RouteNames.plan,
            onGenerateRoute: AppRouter.onGenerateRoute,
            locale: language.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
           
            builder: (context, child) {
              return Directionality(
                textDirection: language.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
