import 'package:beautyhup/widgets/feild_ser.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_work_time/add_work_time_bloc.dart';
import '../../blocs/add_work_time/add_work_time_event.dart';
import '../../blocs/add_work_time/add_work_time_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/primary_button.dart';

/// "add time to work" bottom sheet - matches Figma's modal frame.
/// Opened via [BottomSheetWrapper.show] (standard swipe/tap-outside
/// to dismiss), not a full page route.
///
/// Usage from Settings:
/// ```dart
/// final settingsBloc = context.read<SettingsBloc>();
/// BottomSheetWrapper.show(
///   context,
///   BlocProvider.value(value: settingsBloc, child: const AddWorkTimePage()),
/// );
/// ```
/// The result is reported back to [SettingsBloc] via
/// [WorkScheduleAdded] inside this widget's [BlocListener], so the
/// caller doesn't need to handle the return value.
class AddWorkTimePage extends StatelessWidget {
  const AddWorkTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddWorkTimeBloc(),
      child:  _AddWorkTimeView(),
    );
  }
}

class _AddWorkTimeView extends StatefulWidget {
   _AddWorkTimeView();

  static const SettingsRepository _repository = SettingsRepository();


  @override
  State<_AddWorkTimeView> createState() => _AddWorkTimeViewState();
}

class _AddWorkTimeViewState extends State<_AddWorkTimeView> {
    TextEditingController controller = TextEditingController();


@override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AddWorkTimeBloc, AddWorkTimeState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddWorkTimeStatus.success) {
          context.read<SettingsBloc>().add(
                WorkScheduleAdded(state.day, state.startTime, state.endTime,
                    controller.text, true),
              );
          Navigator.of(context).pop();
        } else if (state.status == AddWorkTimeStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.addTimeToWork,
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            BlocBuilder<AddWorkTimeBloc, AddWorkTimeState>(
              builder: (context, state) {
                final bloc = context.read<AddWorkTimeBloc>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.day,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 13.sp(context)),
                    ),
                    SizedBox(height: AppDimens.spaceXs.h(context)),
                    Wrap(
                      spacing: AppDimens.spaceXs.w(context),
                      runSpacing: AppDimens.spaceXs.h(context),
                      children: [
                        for (final day in _AddWorkTimeView._repository.getWeekDays())
                          ChoiceChip(
                            label: Text(day),
                            selected: state.day == day,
                            onSelected: (_) =>
                                bloc.add(AddWorkTimeDayChanged(day)),
                          ),
                      ],
                    ),
                    SizedBox(height: AppDimens.spaceMd.h(context)),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerField(
                            label: context.l10n.startTime,
                            value: state.startTime,
                            onPicked: (value) =>
                                bloc.add(AddWorkTimeStartChanged(value)),
                          ),
                        ),
                        SizedBox(width: AppDimens.spaceSm.w(context)),
                        Expanded(
                          child: _TimePickerField(
                            label: context.l10n.endTime,
                            value: state.endTime,
                            onPicked: (value) =>
                                bloc.add(AddWorkTimeEndChanged(value)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.spaceLg.w(context),
                          vertical: AppDimens.spaceSm.h(context),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius:
                              BorderRadius.circular(AppDimens.inputRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppDimens.inputIconSize.r(context),
                              color: AppColors.textPrimary.withOpacity(0.83),
                            ),
                            SizedBox(width: AppDimens.spaceSm.w(context)),
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                style: AppTextStyles.label.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp(context),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: context.l10n.slotDurationMinutes,
                                  hintStyle: AppTextStyles.label.copyWith(
                                    fontSize: 14.sp(context),
                                    color:
                                        AppColors.textPrimary.withOpacity(0.83),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // _TimePickerField(
                      //   label: context.l10n.slotDurationMinutes,
                      //   value: state.slot,
                      //   onPicked: (value) =>
                      //       bloc.add(AddWorkTimeStartChanged(value)),
                      // ),
                    ),
                    SizedBox(height: AppDimens.spaceLg.h(context)),
                    PrimaryButton(
                      label: context.l10n.save,
                      variant: PrimaryButtonVariant.filled,
                      onPressed: () => bloc.add(const AddWorkTimeSubmitted()),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  final String label;
  final String value;
  final ValueChanged<String> onPicked;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onPicked('$hour:$minute');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.spaceMd.w(context),
          vertical: AppDimens.spaceSm.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18.r(context)),
            SizedBox(width: AppDimens.spaceXs.w(context)),
            Text(
              value.isEmpty ? label : value,
              style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
            ),
          ],
        ),
      ),
    );
  }
}
