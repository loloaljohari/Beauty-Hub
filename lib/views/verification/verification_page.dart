import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../blocs/otp/otp_bloc.dart';
import '../../blocs/otp/otp_event.dart';
import '../../blocs/otp/otp_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/otp_input_box.dart';
import '../../widgets/primary_button.dart';


/// Verification (OTP) screen - matches Figma frame "Verification" (938:1087).
class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc()..add(const OtpCountdownStarted()),
      child: _VerificationView(email: email),
    );
  }
}

class _VerificationView extends StatefulWidget {
  const _VerificationView({required this.email});

  final String email;

  @override
  State<_VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<_VerificationView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final length = context.read<OtpBloc>().state.digits.length;
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
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
        if (state.status == OtpStatus.success) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
             ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("successfully verified")),
          );
        } else if (state.status == OtpStatus.failure &&
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
            const AuthHeader(title: AppStrings.verificationCode),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            Text(
              AppStrings.otpSentMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp(context),
              ),
            ),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            const _VerificationIllustration(),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            _OtpRow(
              controllers: _controllers,
              focusNodes: _focusNodes,
              onChanged: _onDigitChanged,
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            const _ResendRow(),
            SizedBox(height: AppDimens.spaceXl.h(context)),
            _ContinueButton(email: widget.email),
          ],
        ),
      ),
    );
  }
}

/// Decorative illustration placeholder.
///
/// In the Figma design this is a complex vector illustration
/// ("confirmed/amico") with ~60 nested vector paths (device, character,
/// plants, checkmark). Exporting it as a single SVG/PNG from Figma and
/// placing it at `assets/images/verification_illustration.svg` (or .png)
/// is strongly recommended instead of rebuilding it with widgets.
class _VerificationIllustration extends StatelessWidget {
  const _VerificationIllustration();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = (214 / AppDimens.designHeight) * size.height;

    return Center(
      child: Container(
        
              child: SvgPicture.asset(
          height: 200,
          width: 200,
          'assets/icons/amico.svg',
        ),
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(controllers.length, (index) {
        print('Building OTP input box for index $index of ${controllers.length}');
        return OtpInputBox(
          controller: controllers[index],
          focusNode: focusNodes[index],
          autofocus: index == 0,
          onChanged: (value) => onChanged(index, value),
        );
      }),
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
                  color: state.canResend
                      ? AppColors.primary
                      : AppColors.textHint,
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
  const _ContinueButton({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
    
      builder: (context, state) {
        print(email);
        return PrimaryButton(
          label: AppStrings.continueText,
          isLoading: state.status == OtpStatus.loading,
          onPressed: () => context.read<OtpBloc>().add(OtpSubmitted(email: email)),
        );
      },
    );
  }
}
