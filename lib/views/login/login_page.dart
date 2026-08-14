import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/login/login_event.dart';
import '../../blocs/login/login_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_login_button.dart';

/// Login screen - matches Figma frame "Login" (938:994).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  static const AuthRepository _repository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacementNamed(RouteNames.home);
        } else if (state.status == LoginStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: AuthScaffold(
        showDecorativeShapes: true,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceSm.w(context),
            vertical: AppDimens.spaceXl.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.50),
            borderRadius:
                BorderRadius.circular(AppDimens.cardRadiusLarge.r(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(),
              SizedBox(height: AppDimens.spaceXl.h(context)),
              _TitleSection(),
              SizedBox(height: AppDimens.spaceXl.h(context)),
              const _FormSection(),
              SizedBox(height: AppDimens.spaceXl.h(context)),
              const _ActionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.welcomeBackTo,
          style: AppTextStyles.welcome.copyWith(fontSize: 24.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceXs.h(context)),
        Row(
          children: [
           Image.asset(
              'assets/images/logo.png',
              width: 200.w(context),
              height: 60.h(context),
            ),
          
          ],
        ),
      ],
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.login,
          style: AppTextStyles.h1.copyWith(fontSize: 32.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(RouteNames.register),
          child: Text(
            AppStrings.noAccountRegister,
            style: AppTextStyles.linkUnderline.copyWith(
              fontSize: 15.sp(context),
              color: AppColors.black.withOpacity(0.74),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection();

  @override
  Widget build(BuildContext context) {
    final fields = _LoginView._repository.getLoginFields();

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();

        return Column(
          children: [
            CustomTextField(
                              name: false,

              label: fields[0].label,
              icon: fields[0].icon,
              keyboardType: fields[0].keyboardType,
              onChanged: (value) =>
                  bloc.add(LoginEmailChanged(value)),
            ),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            CustomTextField(
                              name: false,

              label: fields[1].label,
              icon: fields[1].icon,
              isPassword: true,
              isObscured: state.isPasswordObscured,
              onToggleObscure: () =>
                  bloc.add(const LoginPasswordVisibilityToggled()),
              onChanged: (value) =>
                  bloc.add(LoginPasswordChanged(value)),
            ),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(RouteNames.forgotPassword),
                  child: Text(
                    AppStrings.forgotPassword,
                    style:
                        AppTextStyles.link.copyWith(fontSize: 16.sp(context)),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      bloc.add(const LoginAsGuestRequested()),
                  child: Text(
                    AppStrings.loginAsGuest,
                    style:
                        AppTextStyles.link.copyWith(fontSize: 16.sp(context)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection();

  @override
  Widget build(BuildContext context) {
    final socialOptions = _LoginView._repository.getSocialLoginOptions();

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();

        return Column(
          children: [
            PrimaryButton(
              label: AppStrings.login,
              isLoading: state.status == LoginStatus.loading,
              onPressed: () => bloc.add(const LoginSubmitted()),
            ),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            const OrDivider(label: AppStrings.or),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            SocialLoginButton(
              label: socialOptions.first.label,
              onPressed: () =>
                  bloc.add(const LoginWithGoogleRequested()),
            ),
          ],
        );
      },
    );
  }
}
