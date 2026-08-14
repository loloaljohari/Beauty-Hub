import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/reset_password/reset_password_bloc.dart';
import '../../blocs/reset_password/reset_password_event.dart';
import '../../blocs/reset_password/reset_password_state.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/auth_repository.dart';
import '../check_email/check_email_page.dart' show ResetPasswordArgs;
import '../../widgets/auth_header.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// New Password screen - matches Figma frame "new Password" (938:1326).
class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({super.key, this.args});

  /// Carries the OTP the user just typed on the previous screen. The
  /// backend validates it as part of the reset request, so it has to
  /// reach the BLoC before submit.
  final ResetPasswordArgs? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = ResetPasswordBloc();
        if (args != null) {
          bloc.add(
            ResetPasswordOtpReceived(otp: args!.otp, email: args!.email),
          );
        }
        return bloc;
      },
      child: const _NewPasswordView(),
    );
  }
}

class _NewPasswordView extends StatelessWidget {
  const _NewPasswordView();

  static const AuthRepository _repository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final fields = _repository.getNewPasswordFields();

    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.success) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.login,
            (route) => false,
          );
        } else if (state.status == ResetPasswordStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthHeader(title: AppStrings.createNewPassword),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              AppStrings.newPasswordDifferent,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
              builder: (context, state) {
                final bloc = context.read<ResetPasswordBloc>();
                return Column(
                  children: [
                    CustomTextField(
                                      name: false,

                      label: fields[0].label,
                      icon: fields[0].icon,
                      isPassword: true,
                      isObscured: state.isNewObscured,
                      onToggleObscure: () => bloc.add(
                        const ResetPasswordVisibilityToggled('new'),
                      ),
                      onChanged: (value) =>
                          bloc.add(ResetPasswordNewChanged(value)),
                    ),
                    SizedBox(height: AppDimens.spaceSm.h(context)),
                    CustomTextField(
                                      name: false,

                      label: fields[1].label,
                      icon: fields[1].icon,
                      isPassword: true,
                      isObscured: state.isConfirmObscured,
                      onToggleObscure: () => bloc.add(
                        const ResetPasswordVisibilityToggled('confirm'),
                      ),
                      onChanged: (value) =>
                          bloc.add(ResetPasswordConfirmChanged(value)),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
              builder: (context, state) {
                return PrimaryButton(
                  label: AppStrings.resetPassword,
                  variant: PrimaryButtonVariant.filled,
                  isLoading: state.status == ResetPasswordStatus.loading,
                  onPressed: () => context
                      .read<ResetPasswordBloc>()
                      .add(const ResetPasswordSubmitted()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
