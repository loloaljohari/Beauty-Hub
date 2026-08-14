import os

project_structure = {
    # ================= CORE (تحديث المسارات) =================
    "lib/core/routes/app_router.dart": """import 'package:flutter/material.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/plan/plan_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash': // الشاشة الأولى
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/': // شاشة الخطط
        return MaterialPageRoute(builder: (_) => const PlanScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}""",

    # ================= SPLASH VIEW (شاشة الأنيميشن) =================
    "lib/views/splash/splash_screen.dart": """import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentFrame = 1;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _navigateToHome();
  }

  void _startAnimation() {
    // محاكاة الأنيميشن من خلال التنقل بين الصور الست
    _animationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_currentFrame < 6) {
        setState(() {
          _currentFrame++;
        });
      } else {
        _animationTimer?.cancel();
      }
    });
  }

  void _navigateToHome() {
    // الانتقال إلى شاشة الخطط بعد 3 ثوانٍ
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Image.asset(
            'assets/images/splash$_currentFrame.png',
            key: ValueKey(_currentFrame),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover, // لتغطية الشاشة بالكامل كما في الصور
          ),
        ),
      ),
    );
  }
}""",

    # ================= MAIN (تحديث البداية) =================
    "lib/main.dart": """import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const BeautyHubApp());
}

class BeautyHubApp extends StatelessWidget {
  const BeautyHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Benne', 
      ),
      initialRoute: '/splash', // البداية من الـ Splash
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}""",

    # ================= ASSETS CONFIG (إضافة لملف pubspec) =================
    "assets_guide.txt": """تأكدي من إضافة الصور في مجلد assets/images وتحديث ملف pubspec.yaml كالتالي:
assets:
  - assets/images/splash1.png
  - assets/images/splash2.png
  - assets/images/splash3.png
  - assets/images/splash4.png
  - assets/images/splash5.png
  - assets/images/splash6.png
"""
}

# كود الإنشاء التلقائي للمجلدات والملفات
for filepath, content in project_structure.items():
    dirname = os.path.dirname(filepath)
    if dirname and not os.path.exists(dirname):
        os.makedirs(dirname)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

print("✅ تم تحديث المشروع! شاشة الـ Splash مبرمجة الآن للتحرك عبر الصور الست ثم الانتقال لشاشة الخطط.")