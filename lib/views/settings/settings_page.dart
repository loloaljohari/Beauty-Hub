import 'dart:io';
import '../../widgets/state_views.dart';
import '../../core/utils/image_helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/locale/locale_cubit.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/bottom_sheet_wrapper.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/setting_field_row.dart';
import '../add_work_time/add_work_time_page.dart';

/// Settings screen - matches Figma frame "Setting" (1138:xxxx).
///
/// Includes the language switcher (English/Arabic) which flips the
/// whole app's text direction (RTL/LTR) via [LocaleCubit], and an
/// avatar picker using image_picker.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // NO LocaleCubit here. LocalizedApp already provides one above
        // MaterialApp; creating a second instance meant the language
        // picker updated a local copy that nothing else listened to -
        // the app's direction and strings never changed.
        BlocProvider(
          create: (_) => ProfileBloc()..add(const ProfileLoaded()),
        ),
        BlocProvider(
          create: (_) => SettingsBloc()..add(const SettingsLoaded()),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(SettingsAvatarChanged(picked.path));
      print('Picked avatar image path: ${picked.path}');
    }
  }

  Future<void> _editField(
    BuildContext context, {
    required String key,
    required String title,
    required String currentValue,
  }) async {
    final newValue = await showEditFieldDialog(
      context,
      title: title,
      initialValue: currentValue,
    );
    if (newValue != null) {
      print("updateProfile called");
      context.read<SettingsBloc>().add(SettingsFieldChanged(key, newValue));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated $title')),
        );
      }
      else {
        print("updateProfile failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $title')),
        );
      }
    }
    else {
      print("updateProfile cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            context.l10n.settingsTitle,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH.w(context),
            vertical: AppDimens.spaceMd.h(context),
          ),
          children: [
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state.status == SettingsStatus.failure) {
                  return ErrorState(
                    message: state.errorMessage,
                    onRetry: () => context
                        .read<SettingsBloc>()
                        .add(const SettingsLoaded()),
                  );
                }

                if (state.status != SettingsStatus.loaded ||
                    state.profile == null) {
                  return const LoadingState();
                }

                final profile = state.profile!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          // `avatarUrl!` used to be dereferenced before
                          // the null check two lines below it, so an
                          // expert with no photo crashed this screen.
                          CircleAvatar(
                            radius:
                                (AppDimens.avatarSizeLarge / 2).r(context),
                            backgroundColor: AppColors.avatarPlaceholder,
                            backgroundImage:
                                _avatarProvider(profile.avatarUrl),
                            child: _avatarProvider(profile.avatarUrl) == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 32.r(context),
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => _pickAvatar(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(6.r(context)),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16.r(context),
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          context.l10n.settingsPersonalInfo,
                          style: AppTextStyles.h3
                              .copyWith(fontSize: 16.sp(context)),
                        ),
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsName,
                      value: profile.name,
                      onTap: () => _editField(
                        context,
                        key: 'name',
                        title: context.l10n.settingsName,
                        currentValue: profile.name,
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsPhone,
                      value: profile.phone,
                      onTap: () => _editField(
                        context,
                        key: 'phone',
                        title: context.l10n.settingsPhone,
                        currentValue: profile.phone,
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsEmail,
                      value: profile.email,
                      onTap: () => _editField(
                        context,
                        key: 'email',
                        title: context.l10n.settingsEmail,
                        currentValue: profile.email,
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsBirthdate,
                      value: profile.birthdate.split('T')[0], // Display only the date part
                      onTap: () => _editField(
                        context,
                        key: 'birthdate',
                        title: context.l10n.settingsBirthdate,
                        currentValue: profile.birthdate.split('T')[0],
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsBio,
                      value: profile.bio,
                      onTap: () => _editField(
                        context,
                        key: 'bio',
                        title: context.l10n.settingsBio,
                        currentValue: profile.bio,
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.settingsLocation,
                      value: profile.location,
                      onTap: () => _editField(
                        context,
                        key: 'location',
                        title: context.l10n.settingsLocation,
                        currentValue: profile.location,
                      ),
                    ),
                    SettingFieldRow(
                      label: context.l10n.specialization,
                      value: profile.typeOfWork,
                      onTap: () => _editField(
                        context,
                        key: 'specialization',
                        title: context.l10n.specialization,
                        currentValue: profile.typeOfWork,
                      ),
                    ),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.settingsTimeOfWork,
                          style: AppTextStyles.h3
                              .copyWith(fontSize: 16.sp(context)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            final settingsBloc = context.read<SettingsBloc>();
                            BottomSheetWrapper.show(
                              context,
                              BlocProvider.value(
                                value: settingsBloc,
                                child: const AddWorkTimePage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(context.l10n.settingsAddTime),
                        ),
                      ],
                    ),
                    for (final schedule in state.workSchedule)
                      _WorkScheduleRow(
                        slot: schedule.slotDuration,
                        day: schedule.day,
                        range: schedule.formattedRange,
                        onRemove: () => context
                            .read<SettingsBloc>()
                            .add(WorkScheduleRemoved(schedule.id)),
                      ),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    const _LanguageSection(),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        context.l10n.settingsSecurity,
                        style:
                            AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_outline),
                      title: Text(context.l10n.settingsChangePassword),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.changePassword),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: AppDimens.spaceLg.h(context)),
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
              return PrimaryButton(
                  // isLoading: state.actionStatus == SettingsActionStatus.loading,
                  label: context.l10n.settingsLogout,
                  variant: PrimaryButtonVariant.filled,
                  onPressed: () {
                    context
                        .watch<SettingsBloc>()
                        .add(const SettingsLogoutRequested());
                    if (state.actionStatus == SettingsActionStatus.success) {
                      Navigator.of(context).pushNamed(
                        RouteNames.login,
                      );
                    } else if (state.actionStatus ==
                            SettingsActionStatus.failure &&
                        state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  });
            }),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
              return OutlinedButton(
                onPressed: () {
                  context
                      .read<SettingsBloc>()
                      .add(SettingsAccountDeletionRequested());

                  if (state.actionStatus == SettingsActionStatus.success) {
                    Navigator.of(context).pushNamed(
                      RouteNames.login,
                    );
                  } else if (state.actionStatus ==
                          SettingsActionStatus.failure &&
                      state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50.h(context)),
                ),
                child: state.actionStatus == SettingsActionStatus.loading
                    ? CircularProgressIndicator()
                    : Text(context.l10n.settingsDeleteAccount),
              );
            }),
            SizedBox(height: AppDimens.spaceXl.h(context)),
          ],
        ),
      );

  }
}

class _WorkScheduleRow extends StatelessWidget {
  const _WorkScheduleRow({
    required this.day,
    required this.range,
    required this.onRemove,
    required this.slot,
  });

  final String day;
  final String range;
  final String slot;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXs.h(context)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        day,
                        style: AppTextStyles.label
                            .copyWith(fontSize: 14.sp(context)),
                      ),
                    ),
                    Text(
                      range,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontSize: 13.sp(context)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "the slot duration : $slot",
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontSize: 13.sp(context)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 16.r(context)),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

/// Language picker section: switching here updates [LocaleCubit],
/// which flips `MaterialApp.locale` and the app's text direction
/// (RTL for Arabic, LTR for English) immediately, app-wide.
class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.watch<LocaleCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.settingsLanguage,
          style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceXs.h(context)),
        Row(
          children: [
            for (final language in AppLanguage.values) ...[
              Expanded(
                child: _LanguageOption(
                  language: language,
                  isSelected: language == currentLanguage,
                  onTap: () =>
                      context.read<LocaleCubit>().changeLanguage(language),
                ),
              ),
              if (language != AppLanguage.values.last)
                SizedBox(width: AppDimens.spaceSm.w(context)),
            ],
          ],
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Text(
              language.nativeName,
              style: AppTextStyles.label.copyWith(
                fontSize: 14.sp(context),
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              SizedBox(height: 2.h(context)),
              Icon(Icons.check_circle,
                  size: 14.r(context), color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

/// Picks the right image source for the avatar.
///
/// The value can be three different things depending on where it came
/// from: a freshly picked local file path, a relative storage path
/// returned by the API, or nothing at all. Returning `null` for the
/// last case lets [CircleAvatar] show its placeholder child instead of
/// firing a doomed network request.
ImageProvider? _avatarProvider(String? avatarUrl) {
  final value = avatarUrl?.trim();
  if (value == null || value.isEmpty || value == 'null') return null;

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return remoteImageProvider(value);
  }

  // A local file picked in this session (image_picker returns an
  // absolute device path) rather than something from the server.
  if (File(value).existsSync()) return FileImage(File(value));

  return remoteImageProvider(value);
}
