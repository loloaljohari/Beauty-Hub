import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/register/register_bloc.dart';
import '../../blocs/register/register_event.dart';
import '../../blocs/register/register_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Register screen - matches Figma frame "Register" (938:1038).
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  static const AuthRepository _repository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          Navigator.of(context).pushNamed(RouteNames.verification,arguments: state.fields['email']  );
        } else if (state.status == RegisterStatus.failure &&
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
              BlocBuilder<RegisterBloc, RegisterState>(
                builder: (context, state) {
                    //  final bloc = context.read<RegisterBloc>();
                  return Center(
                    child: Container(
                      child:  _imagePickerPlaceholder()),
                  );
                }
              ),
              _TitleSection(),
              SizedBox(height: AppDimens.spaceXl.h(context)),
              const _FormSection(),
              SizedBox(height: AppDimens.spaceXl.h(context)),
              const _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}


class _imagePickerPlaceholder extends StatelessWidget {
  const _imagePickerPlaceholder({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<RegisterBloc>().add(RegisterImagePicked(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
                    onTap: () => _pickAvatar(context),
                    child: SizedBox(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40.r(context),
                            backgroundColor:
                                context.read<RegisterBloc>().state.imagePath ==
                                        null
                                    ? Color.fromARGB(255, 227, 227, 227)
                                    : Colors.transparent,
                            child:
                                context.read<RegisterBloc>().state.imagePath !=
                                        null
                                    ? ClipOval(
                                        child: Image.file(
                                          File(context
                                              .read<RegisterBloc>()
                                              .state
                                              .imagePath!),
                                          width: 80.w(context),
                                          height: 80.w(context),
                                          fit: BoxFit.cover,
                                        ),) 
                                    : const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 25,
                                height: 8,
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 30.r(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          AppStrings.register,
          style: AppTextStyles.h1.copyWith(fontSize: 32.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.haveAccountLogin,
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
    final fields = _RegisterView._repository.getRegisterFields();
    final fields2 = _RegisterView._repository.getFirstNameFields();

    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bloc = context.read<RegisterBloc>();

        return Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final field in fields2) ...[
                CustomTextField(
                  name: true,
                  label: field.label,
                  icon: field.icon,
                  keyboardType: field.keyboardType,
                  isPassword: field.isPassword,
                  isObscured: field.key == 'password'
                      ? state.isPasswordObscured
                      : field.key == 'confirmPassword'
                          ? state.isConfirmPasswordObscured
                          : true,
                  onToggleObscure: field.isPassword
                      ? () => bloc.add(
                            RegisterPasswordVisibilityToggled(field.key),
                          )
                      : null,
                  onChanged: (value) =>
                      bloc.add(RegisterFieldChanged(field.key, value)),
                ),
                SizedBox(height: AppDimens.spaceSm.h(context)),
              ],
            ]),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            for (final field in fields) ...[
              CustomTextField(
                name: false,
                label: field.label,
                icon: field.icon,
                keyboardType: field.keyboardType,
                isPassword: field.isPassword,
                isObscured: field.key == 'password'
                    ? state.isPasswordObscured
                    : field.key == 'confirmPassword'
                        ? state.isConfirmPasswordObscured
                        : true,
                onToggleObscure: field.isPassword
                    ? () => bloc.add(
                          RegisterPasswordVisibilityToggled(field.key),
                        )
                    : null,
                onChanged: (value) =>
                    bloc.add(RegisterFieldChanged(field.key, value)),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
            ],
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bloc = context.read<RegisterBloc>();
        return PrimaryButton(
          label: AppStrings.register,
          isLoading: state.status == RegisterStatus.loading,
          onPressed: () => bloc.add(const RegisterSubmitted()),
        );
      },
    );
  }
}
