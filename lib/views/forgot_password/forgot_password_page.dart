import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/forgot_password/forgot_password_bloc.dart';
import '../../blocs/forgot_password/forgot_password_event.dart';
import '../../blocs/forgot_password/forgot_password_state.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Forgot Password screen - matches Figma frame "Forgot Password" (938:1265).
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  static const AuthRepository _repository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final fields = _repository.getForgotPasswordFields();

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.success) {
          Navigator.of(context).pushNamed(RouteNames.checkEmail);
        } else if (state.status == ForgotPasswordStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            const AuthHeader(title: AppStrings.forgotPassword),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              AppStrings.enterEmailInstructions,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                return CustomTextField(
                  name: false,
                  label: fields.first.label,
                  icon: fields.first.icon,
                  keyboardType: fields.first.keyboardType,
                  onChanged: (value) => context
                      .read<ForgotPasswordBloc>()
                      .add(ForgotPasswordEmailChanged(value)),
                );
              },
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
              builder: (context, state) {
                return PrimaryButton(
                  label: AppStrings.send,
                  variant: PrimaryButtonVariant.filled,
                  isLoading: state.status == ForgotPasswordStatus.loading,
                  onPressed: () => context
                      .read<ForgotPasswordBloc>()
                      .add(const ForgotPasswordSubmitted()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
