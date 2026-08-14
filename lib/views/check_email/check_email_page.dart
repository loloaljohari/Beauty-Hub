import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../blocs/otp/otp_bloc.dart';
import '../../blocs/otp/otp_event.dart';
import '../../blocs/otp/otp_state.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/otp_input_box.dart';
import '../../widgets/primary_button.dart';

/// "Check your Email" screen - matches Figma frame "Check email" (938:1194).
///
/// Visually similar to the Verification screen except for the header
/// copy and the "Continue" button using the filled (burgundy) variant.
class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc()..add(const OtpCountdownStarted()),
      child: const _CheckEmailView(),
    );
  }
}

class _CheckEmailView extends StatefulWidget {
  const _CheckEmailView();

  @override
  State<_CheckEmailView> createState() => _CheckEmailViewState();
}

class _CheckEmailViewState extends State<_CheckEmailView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    // Length comes from the BLoC (which reads it from the repository)
    // instead of a literal - the backend issues a 6-digit OTP, and the
    // hardcoded 5 here meant the last digit was never captured.
    final length = context.read<OtpBloc>().state.digits.length;
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    context.read<OtpBloc>().add(OtpDigitChanged(index, value));
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OtpStatus.failure && state.errorMessage != null) {
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
            const AuthHeader(title: AppStrings.checkYourEmail),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              AppStrings.otpSentMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            Center(
      child: Container(
        
              child: Image.asset(
          height: 100,
          width: 100,
          'assets/images/send.jpg',
        ),
      ),
    ),
                SizedBox(height: AppDimens.spaceXl.h(context)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_controllers.length, (index) {
                return OtpInputBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  autofocus: index == 0,
                  onChanged: (value) => _onDigitChanged(index, value),
                );
              }),
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            const _ResendRow(),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            const _ContinueButton(),
          ],
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.orderAnotherAfter,
              style: AppTextStyles.timerText.copyWith(
                fontSize: 13.sp(context),
              ),
            ),
            SizedBox(width: 6.w(context)),
            Text(
              state.formattedTime,
              style: AppTextStyles.timerText.copyWith(
                fontSize: 13.sp(context),
              ),
            ),
            SizedBox(width: 6.w(context)),
            GestureDetector(
              onTap: state.canResend
                  ? () => context
                      .read<OtpBloc>()
                      .add(const OtpResendRequested())
                  : null,
              child: Text(
                AppStrings.order,
                style: AppTextStyles.orderAction.copyWith(
                  fontSize: 16.sp(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {
        return PrimaryButton(
          label: AppStrings.continueText,
          variant: PrimaryButtonVariant.filled,
          isLoading: state.status == OtpStatus.loading,
          onPressed: state.isComplete
              ? () async {
                  // Deliberately NOT calling /auth/verify_otp here.
                  // That endpoint clears `otp_code` on the server, and
                  // /auth/reset_password needs the same code to still be
                  // valid - verifying first would invalidate the reset.
                  // So the code travels to the next screen instead.
                  final email =
                      await StorageService.getPendingOtpEmail() ?? '';
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed(
                    RouteNames.newPassword,
                    arguments: ResetPasswordArgs(
                      otp: state.code,
                      email: email,
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}

/// What the "check your email" screen hands to the reset form.
class ResetPasswordArgs {
  const ResetPasswordArgs({required this.otp, required this.email});

  final String otp;
  final String email;
}
