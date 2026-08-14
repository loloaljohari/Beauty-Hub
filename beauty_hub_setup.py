import os

project_structure = {
    # ================= CORE =================
    "lib/core/constants/app_colors.dart": """import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF4A152B);
  static const Color primary = Color(0xFF7A1B38);
  static const Color primaryLight = Color(0xFF9E2A4B);
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textMuted = Color(0xFF8B8B8B);
  static const Color inputBg = Color(0xFFF6F6F6);
  static const Color background = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFD4AF37);
  static const Color blurYellow = Color(0xFFFBEAA0);
  static const Color blurPink = Color(0xFFF0C2C8);
}""",

    "lib/core/constants/app_text_styles.dart": """import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle logo = TextStyle(fontFamily: 'Benne', fontSize: 42, fontWeight: FontWeight.normal, color: AppColors.primaryDark);
  static const TextStyle h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textMuted);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
}""",

    "lib/core/routes/app_router.dart": """import 'package:flutter/material.dart';
import '../../views/plan/plan_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/verification_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/check_email_screen.dart';
import '../../views/auth/new_password_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/': 
        return MaterialPageRoute(builder: (_) => const PlanScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/verification':
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case '/forgot_password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/check_email':
        return MaterialPageRoute(builder: (_) => const CheckEmailScreen());
      case '/new_password':
        return MaterialPageRoute(builder: (_) => const NewPasswordScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}""",

    # ================= WIDGETS =================
    "lib/widgets/auth_scaffold.dart": """import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  const AuthScaffold({Key? key, required this.child, this.showBackButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: Container(width: 250, height: 250, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blurYellow))),
          Positioned(bottom: -50, right: -100, child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blurPink))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBackButton)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}""",

    "lib/widgets/custom_text_field.dart": """import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;

  const CustomTextField({Key? key, required this.hintText, required this.prefixIcon, this.isPassword = false}) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: _obscureText,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: Icon(widget.prefixIcon, color: AppColors.textMuted, size: 22),
          suffixIcon: widget.isPassword ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted), onPressed: () => setState(() => _obscureText = !_obscureText)) : null,
          filled: true,
          fillColor: AppColors.inputBg,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }
}""",

    "lib/widgets/primary_button.dart": """import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(text, style: AppTextStyles.button),
      ),
    );
  }
}""",

    # ================= VIEWS =================
    "lib/views/plan/plan_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/auth_scaffold.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text('Choose Your Plan', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('Unlock the full potential of your salon', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          _buildPlanCard(context, 'Free Plan', '\\$0', 'Basic features.', ['1 Location', 'Basic Booking'], 'Choose Free', false, () => Navigator.pushNamed(context, '/login')),
          const SizedBox(height: 16),
          _buildPlanCard(context, 'Luxe Growth', '\\$79/mo', 'Best for growing.', ['Up to 3 Locations', 'Advanced Analytics'], 'Go Luxe', true, () {}),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, String desc, List<String> features, String btnText, bool isPopular, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.primaryDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isPopular ? Border.all(color: AppColors.gold, width: 2) : Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)), child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: AppTextStyles.h2.copyWith(color: isPopular ? Colors.white : AppColors.textPrimary)), Text(price, style: AppTextStyles.h1.copyWith(color: isPopular ? AppColors.blurPink : AppColors.primary))]),
          const SizedBox(height: 8),
          Text(desc, style: AppTextStyles.bodyMedium.copyWith(color: isPopular ? Colors.white70 : AppColors.textMuted)),
          const Divider(height: 30),
          ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [Icon(Icons.check_circle, size: 20, color: isPopular ? AppColors.gold : AppColors.primary), const SizedBox(width: 8), Text(f, style: TextStyle(color: isPopular ? Colors.white : AppColors.textPrimary))]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: isPopular ? Colors.white : AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: Text(btnText, style: TextStyle(color: isPopular ? AppColors.primaryDark : Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/login_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Text('Beauty Hub', style: AppTextStyles.logo),
          const SizedBox(height: 8),
          const Text('Welcome back, you\\'ve been missed!', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          const CustomTextField(hintText: 'Email Address', prefixIcon: Icons.email_outlined),
          const CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, isPassword: true),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
              child: const Text('Forgot password?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(text: 'Login', onPressed: () => Navigator.pushNamed(context, '/verification')),
          const SizedBox(height: 16),
          TextButton(onPressed: () {}, child: const Text('Login as a guest', style: TextStyle(color: AppColors.textMuted, fontSize: 16))),
          const SizedBox(height: 10),
          Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or')), Expanded(child: Divider())]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
              label: const Text('Continue with Google', style: TextStyle(color: Colors.black, fontSize: 16)),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Don\\'t have an account? ', style: AppTextStyles.bodyMedium),
              GestureDetector(onTap: () => Navigator.pushNamed(context, '/register'), child: const Text('Register', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/register_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Account', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          const Text('Fill your details to get started', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 30),
          Row(children: const [
            Expanded(child: CustomTextField(hintText: 'First Name', prefixIcon: Icons.person_outline)),
            SizedBox(width: 16),
            Expanded(child: CustomTextField(hintText: 'Last Name', prefixIcon: Icons.person_outline)),
          ]),
          const CustomTextField(hintText: 'Phone Number', prefixIcon: Icons.phone_outlined),
          const CustomTextField(hintText: 'Address', prefixIcon: Icons.location_on_outlined),
          const CustomTextField(hintText: 'Email Address', prefixIcon: Icons.email_outlined),
          const CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, isPassword: true),
          const CustomTextField(hintText: 'Confirm Password', prefixIcon: Icons.lock_outline, isPassword: true),
          const SizedBox(height: 20),
          PrimaryButton(text: 'Register', onPressed: () => Navigator.pushNamed(context, '/verification')),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: AppTextStyles.bodyMedium),
                GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Log In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/forgot_password_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Forgot Password', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          const Text('Please enter your email to reset the password', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          const CustomTextField(hintText: 'Email Address', prefixIcon: Icons.email_outlined),
          const SizedBox(height: 30),
          PrimaryButton(text: 'Reset Password', onPressed: () => Navigator.pushNamed(context, '/check_email')),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/check_email_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../core/constants/app_colors.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          const Text('Check your email', style: AppTextStyles.h1),
          const SizedBox(height: 12),
          const Text('We sent a reset link to\\ncontact@dscode.com', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          PrimaryButton(text: 'Open email app', onPressed: () => Navigator.pushNamed(context, '/new_password')),
          const SizedBox(height: 20),
          TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false), child: const Text('Back to login', style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/new_password_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Create new password', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          const Text('Your new password must be different from previously used passwords.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          const CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, isPassword: true),
          const CustomTextField(hintText: 'Confirm Password', prefixIcon: Icons.lock_outline, isPassword: true),
          const SizedBox(height: 30),
          PrimaryButton(text: 'Reset Password', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)),
        ],
      ),
    );
  }
}""",

    "lib/views/auth/verification_screen.dart": """import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/primary_button.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('Verification Code', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          const Text('We sent a 4-digit code to your email', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) => _buildOtpBox()),
          ),
          const SizedBox(height: 30),
          const Text('Resend code in 00:59s', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
          PrimaryButton(text: 'Continue', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildOtpBox() {
    return SizedBox(
      width: 70, height: 70,
      child: TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    );
  }
}""",

    # ================= BLOC & MODELS =================
    "lib/blocs/auth/auth_bloc.dart": "// مساحة مخصصة لـ BLoC\\n",
    "lib/blocs/auth/auth_event.dart": "// مساحة مخصصة لـ Events\\n",
    "lib/blocs/auth/auth_state.dart": "// مساحة مخصصة لـ States\\n",

    # ================= MAIN =================
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
        fontFamily: 'SF Pro Text', // تأكدي من إضافة الخط في pubspec.yaml
      ),
      initialRoute: '/', // البداية من شاشة Plan
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}"""
}

for filepath, content in project_structure.items():
    dirname = os.path.dirname(filepath)
    if dirname and not os.path.exists(dirname):
        os.makedirs(dirname)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

print("تم بناء المشروع بالكامل مع إضافة جميع الواجهات الجديدة بنجاح!")
