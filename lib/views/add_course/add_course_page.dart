import 'dart:io';
import '../../core/localization/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/add_course/add_course_bloc.dart';
import '../../blocs/add_course/add_course_event.dart';
import '../../blocs/add_course/add_course_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/image_helpers.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';

/// Create or edit a course.
///
/// New screen for `POST /expert/courses` and `POST /expert/courses/{id}`.
/// Both endpoints already had repository methods, but the "+" button on
/// My Courses was a no-op comment, so an expert could never publish a
/// course from the app at all.
///
/// Field set and limits come from `StoreCourseRequest`: only `title`
/// and `price` are required; everything else is optional, and
/// `end_date` must be on or after `start_date`.
class AddCoursePage extends StatelessWidget {
  const AddCoursePage({super.key, this.courseId});

  /// Null creates a new course; set edits an existing one.
  final String? courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AddCourseBloc()..add(AddCourseStarted(courseId: courseId)),
      child: const _AddCourseView(),
    );
  }
}

class _AddCourseView extends StatelessWidget {
  const _AddCourseView();

  Future<void> _pickCover(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null || !context.mounted) return;
    context.read<AddCourseBloc>().add(AddCourseCoverPicked(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCourseBloc, AddCourseState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddCourseStatus.success) {
          // `true` tells My Courses to refetch.
          Navigator.of(context).pop(true);
        } else if (state.status == AddCourseStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<AddCourseBloc>();

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.textPrimary),
            title: Text(
              state.isEditing ? 'Edit Course' : 'New Course',
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
            ),
          ),
          body: state.status == AddCourseStatus.loading
              ? const LoadingState()
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPaddingH.w(context),
                      vertical: AppDimens.spaceMd.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CoverPicker(
                          state: state,
                          onTap: () => _pickCover(context),
                        ),
                        SizedBox(height: AppDimens.spaceMd.h(context)),
                        CustomTextField(
                          name: false,
                          label: context.l10n.courseTitle,
                          icon: Icons.school_outlined,
                          initialValue: state.value('title'),
                          errorText: state.fieldErrors['title'],
                          onChanged: (v) =>
                              bloc.add(AddCourseFieldChanged('title', v)),
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                        CustomTextField(
                          name: false,
                          label: context.l10n.description,
                          icon: Icons.notes_outlined,
                          initialValue: state.value('description'),
                          errorText: state.fieldErrors['description'],
                          onChanged: (v) => bloc
                              .add(AddCourseFieldChanged('description', v)),
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                name: false,
                                label: context.l10n.price,
                                icon: Icons.attach_money,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                initialValue: state.value('price'),
                                errorText: state.fieldErrors['price'],
                                onChanged: (v) => bloc
                                    .add(AddCourseFieldChanged('price', v)),
                              ),
                            ),
                            SizedBox(width: AppDimens.spaceSm.w(context)),
                            Expanded(
                              child: CustomTextField(
                                name: false,
                                label: context.l10n.hours,
                                icon: Icons.schedule_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                initialValue: state.value('duration_hours'),
                                errorText:
                                    state.fieldErrors['duration_hours'],
                                onChanged: (v) => bloc.add(
                                  AddCourseFieldChanged('duration_hours', v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                        CustomTextField(
                          name: false,
                          label: context.l10n.maximumTrainees,
                          icon: Icons.groups_outlined,
                          keyboardType: TextInputType.number,
                          initialValue: state.value('max_enrollments'),
                          errorText: state.fieldErrors['max_enrollments'],
                          onChanged: (v) => bloc.add(
                            AddCourseFieldChanged('max_enrollments', v),
                          ),
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _DateField(
                                label: context.l10n.startDate,
                                value: state.value('start_date'),
                                firstDate: DateTime.now(),
                                onPicked: (v) => bloc.add(
                                  AddCourseFieldChanged('start_date', v),
                                ),
                              ),
                            ),
                            SizedBox(width: AppDimens.spaceSm.w(context)),
                            Expanded(
                              child: _DateField(
                                label: context.l10n.endDate,
                                value: state.value('end_date'),
                                // `after_or_equal:start_date`, so the
                                // same day is allowed.
                                firstDate: DateTime.tryParse(
                                      state.value('start_date'),
                                    ) ??
                                    DateTime.now(),
                                onPicked: (v) => bloc.add(
                                  AddCourseFieldChanged('end_date', v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          value: state.isOnline,
                          onChanged: (value) =>
                              bloc.add(AddCourseOnlineToggled(value)),
                          title: Text(
                            context.l10n.onlineCourse,
                            style: AppTextStyles.label
                                .copyWith(fontSize: 15.sp(context)),
                          ),
                        ),
                        // A venue only makes sense for an in-person
                        // course, so the field follows the toggle.
                        if (!state.isOnline)
                          CustomTextField(
                            name: false,
                            label: context.l10n.location,
                            icon: Icons.place_outlined,
                            initialValue: state.value('location'),
                            errorText: state.fieldErrors['location'],
                            onChanged: (v) => bloc
                                .add(AddCourseFieldChanged('location', v)),
                          ),
                        SizedBox(height: AppDimens.spaceXl.h(context)),
                        PrimaryButton(
                          label: state.isEditing ? 'Save changes' : 'Publish',
                          variant: PrimaryButtonVariant.filled,
                          isLoading:
                              state.status == AddCourseStatus.submitting,
                          onPressed: () =>
                              bloc.add(const AddCourseSubmitted()),
                        ),
                        SizedBox(height: AppDimens.spaceLg.h(context)),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({required this.state, required this.onTap});

  final AddCourseState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A freshly picked file wins over whatever is already on the server.
    final DecorationImage? image = state.coverImagePath != null
        ? DecorationImage(
            image: FileImage(File(state.coverImagePath!)),
            fit: BoxFit.cover,
          )
        : _existing(state.existingCoverUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150.h(context),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.imagePlaceholder,
          borderRadius: BorderRadius.circular(16),
          image: image,
        ),
        alignment: Alignment.center,
        child: image == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32.r(context),
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: AppDimens.spaceXxs.h(context)),
                  Text(
                    context.l10n.addCoverImage,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp(context),
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  DecorationImage? _existing(String? url) {
    final provider = remoteImageProvider(url);
    if (provider == null) return null;
    return DecorationImage(image: provider, fit: BoxFit.cover);
  }
}

/// Emits `YYYY-MM-DD`, which is what Laravel's `date` rule accepts.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.onPicked,
  });

  final String label;
  final String value;
  final DateTime firstDate;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final initial = DateTime.tryParse(value) ?? firstDate;

        final picked = await showDatePicker(
          context: context,
          initialDate: initial.isBefore(firstDate) ? firstDate : initial,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 1095)),
        );

        if (picked == null) return;

        final month = picked.month.toString().padLeft(2, '0');
        final day = picked.day.toString().padLeft(2, '0');
        onPicked('${picked.year}-$month-$day');
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textHint,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.inputRadius),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          value.isEmpty ? 'Select' : value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.sp(context),
            color: value.isEmpty ? AppColors.textHint : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
