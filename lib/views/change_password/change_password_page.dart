import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Change password.
///
/// New screen for `POST /expert/auth/change_password`. The repository
/// method and the BLoC handler both existed, but Settings only had a
/// TODO where the navigation should be, so the endpoint was
/// unreachable.
///
/// One behaviour worth knowing: on success the backend revokes EVERY
/// token for the account (`$expert->tokens()->delete()`). The session
/// is therefore dead the moment this succeeds, which is why the screen
/// routes back to login rather than popping.
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _currentObscured = true;
  bool _nextObscured = true;
  bool _confirmObscured = true;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final current = _current.text;
    final next = _next.text;
    final confirm = _confirm.text;

    if (current.isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }

    // The backend's password rule is `min:8`; checking here avoids a
    // round trip for something the form already knows.
    if (next.length < 8) {
      setState(() => _error = 'The new password must be at least 8 characters.');
      return;
    }

    if (next != confirm) {
      setState(() => _error = 'The two passwords do not match.');
      return;
    }

    if (next == current) {
      setState(() => _error = 'Choose a password different from the current one.');
      return;
    }

    setState(() => _error = null);

    context.read<SettingsBloc>().add(
          SettingsPasswordChangeSubmitted(
            currentPassword: current,
            newPassword: next,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == SettingsActionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.passwordChangedSignInAgain),
            ),
          );

          // Every token was revoked server-side, so there is no session
          // left to go back to.
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.login,
            (route) => false,
          );
        } else if (state.actionStatus == SettingsActionStatus.failure &&
            state.errorMessage != null) {
          setState(() => _error = state.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading =
            state.actionStatus == SettingsActionStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.textPrimary),
            title: Text(
              context.l10n.changePassword,
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH.w(context),
                vertical: AppDimens.spaceLg.h(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.signedOutAfterChange??
                    'your password.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp(context),
                      color: AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLg.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.currentPassword,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscured: _currentObscured,
                    onToggleObscure: () =>
                        setState(() => _currentObscured = !_currentObscured),
                    onChanged: (value) => _current.text = value,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.newPasswordLower,
                    icon: Icons.lock_reset_outlined,
                    isPassword: true,
                    isObscured: _nextObscured,
                    onToggleObscure: () =>
                        setState(() => _nextObscured = !_nextObscured),
                    onChanged: (value) => _next.text = value,
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  CustomTextField(
                    name: false,
                    label: context.l10n.confirmNewPassword,
                    icon: Icons.lock_reset_outlined,
                    isPassword: true,
                    isObscured: _confirmObscured,
                    onToggleObscure: () =>
                        setState(() => _confirmObscured = !_confirmObscured),
                    onChanged: (value) => _confirm.text = value,
                    errorText: _error,
                  ),
                  SizedBox(height: AppDimens.spaceXl.h(context)),
                  PrimaryButton(
                    label: context.l10n.changePassword,
                    variant: PrimaryButtonVariant.filled,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
