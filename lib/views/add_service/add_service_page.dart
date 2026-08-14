import 'package:beautyhup/widgets/feild_ser.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_service/add_service_bloc.dart';
import '../../blocs/add_service/add_service_event.dart';
import '../../blocs/add_service/add_service_state.dart';
import '../../blocs/checkbox_remember/remember_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/add_service_repository.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/step_indicator.dart';
import '../chat_detail/chat_detail_page.dart';

/// Multi-step "Add service" wizard - matches Figma frames
/// "Add service" (4 steps: 995:5123, 995:5xxx, 995:5xxx, 995:5xxx):
/// 1) Basic info, 2) Pre-booking instructions, 3) Home service
/// settings, 4) Required questions (dynamic list).
class AddServicePage extends StatelessWidget {
  const AddServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddServiceBloc>(
          create: (_) => AddServiceBloc()..add(const AddServiceStarted()),
        ),
      ],
      child: const _AddServiceView(),
    );
  }
}

class _AddServiceView extends StatelessWidget {
  const _AddServiceView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddServiceBloc, AddServiceState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddServiceStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == AddServiceStatus.failure &&
            state.errorMessage != null) {
          print(" the error is ${state.errorMessage}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            context.l10n.addService,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
        ),
        body: BlocBuilder<AddServiceBloc, AddServiceState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                    vertical: AppDimens.spaceSm.h(context),
                  ),
                  child: StepIndicator(
                    totalSteps: state.totalSteps,
                    currentStep: state.currentStep,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPaddingH.w(context),
                    ),
                    child: switch (state.currentStep) {
                      0 => const StepBasicInfo(),
                      1 => const StepInstructions(),
                      2 => const _StepHomeService(),
                      _ => const _StepRequiredQuestions(),
                    },
                  ),
                ),
                _WizardNavigationBar(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WizardNavigationBar extends StatelessWidget {
  const _WizardNavigationBar({required this.state});

  final AddServiceState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AddServiceBloc>();
    return Padding(
      padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
      child: Row(
        children: [
          if (!state.isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    bloc.add(const AddServicePreviousStepRequested()),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimens.spaceSm.h(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                  ),
                ),
                child: Text(context.l10n.back),
              ),
            ),
          if (!state.isFirstStep) SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: state.isLastStep ? 'Submit' : 'Next',
              variant: PrimaryButtonVariant.filled,
              isLoading: state.status == AddServiceStatus.loading,
              onPressed: () async {
                if (state.isLastStep) {
                  await bloc
                    ..add(const AddServiceSubmitted());
                  if (state.status == AddServiceStatus.success)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("success ")),
                    );
                } else {
                  bloc.add(const AddServiceNextStepRequested());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 1: Basic info.
class StepBasicInfo extends StatelessWidget {
  const StepBasicInfo();

  static const AddServiceRepository _repository = AddServiceRepository();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddServiceBloc>().state;
    final bloc = context.read<AddServiceBloc>();
    final categories = _repository.getCategories();
    final rawCategoryId = state.fieldValue('id').isEmpty
        ? null
        : int.tryParse(state.fieldValue('id'));

    // DropdownButton asserts if its value matches no item. That can
    // happen when a service was saved under a category that has since
    // been removed, or while the real list is still loading and only
    // the fallback ids are present.
    final selectedCategoryId =
        categories.any((c) => c['id'] == rawCategoryId)
            ? rawCategoryId
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.basicInformation,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        FeildSer(
          label: context.l10n.serviceName,
          icon: Icons.label_outline,
          initialValue: state.fieldValue('name'),
          onChanged: (v) => bloc.add(AddServiceFieldChanged('name', v)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimens.spaceLg.w(context)),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              // <--- أصبح يتعامل مع int (ID)
              isExpanded: true,
              value: selectedCategoryId,
              hint: Text(context.l10n.category),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'], // قيمة العنصر هي الـ ID
                  child:
                      Text(category['name']), // النص المعروض للمستخدم هو الاسم
                );
              }).toList(),
              onChanged: (selectedId) {
                if (selectedId != null) {
                  // حفظ الـ id كـ String داخل الـ state
                  bloc.add(AddServiceFieldChanged('id', selectedId.toString()));
                }
              },
            ),
          ),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        FeildSer(
          label: context.l10n.bioDescription,
          icon: Icons.notes_outlined,
          initialValue: state.fieldValue('bio'),
          onChanged: (v) => bloc.add(AddServiceFieldChanged('bio', v)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        FeildSer(
          label: context.l10n.price,
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          initialValue: state.fieldValue('price'),
          onChanged: (v) => bloc.add(AddServiceFieldChanged('price', v)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        FeildSer(
          label: context.l10n.durationMinutes,
          icon: Icons.timer_outlined,
          keyboardType: TextInputType.number,
          initialValue: state.fieldValue('duration'),
          onChanged: (v) => bloc.add(AddServiceFieldChanged('duration', v)),
        ),
        SizedBox(height: AppDimens.spaceLg.h(context)),
      ],
    );
  }
}

/// Step 2: Pre-booking instructions (add/remove dynamic list).
class StepInstructions extends StatefulWidget {
  const StepInstructions();

  @override
  State<StepInstructions> createState() => _StepInstructionsState();
}

class _StepInstructionsState extends State<StepInstructions> {
  final TextEditingController _controller = TextEditingController();
  String _draftText = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddServiceBloc>().state;
    final bloc = context.read<AddServiceBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.preBookingInstructions,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.instructionsHelp,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        for (var i = 0; i < state.instructions.length; i++)
          Container(
            margin: EdgeInsets.only(bottom: AppDimens.spaceXs.h(context)),
            padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.instructions[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.sp(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => bloc.add(AddServiceInstructionRemoved(i)),
                ),
              ],
            ),
          ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FeildSer(
                controller: _controller,
                label: context.l10n.addAnInstruction,
                icon: Icons.add_circle_outline,
                onChanged: (value) => _draftText = value,
              ),
            ),
            SizedBox(width: AppDimens.spaceXs.w(context)),
            IconButton(
              icon: Icon(Icons.add_circle,
                  color: AppColors.primary, size: 28.r(context)),
              onPressed: () {
                bloc.add(AddServiceInstructionAdded('\'' + _draftText + '\''));
                _controller.clear();
                _draftText = '';
              },
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceLg.h(context)),
      ],
    );
  }
}

/// Step 3: Home service availability + cities + minimum people.
class _StepHomeService extends StatelessWidget {
  const _StepHomeService();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddServiceBloc>().state;
    final bloc = context.read<AddServiceBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.homeServiceSettings,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Available at customer\'s home',
            style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
          ),
          value: state.availableAtHome,
          activeColor: AppColors.primary,
          onChanged: (_) => bloc.add(const AddServiceHomeAvailabilityToggled()),
        ),
        if (state.availableAtHome) ...[
          SizedBox(height: AppDimens.spaceSm.h(context)),
          Text(
            context.l10n.availableCities,
            style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Wrap(
            spacing: AppDimens.spaceXs.w(context),
            runSpacing: AppDimens.spaceXs.h(context),
            children: [
              for (final city in state.allCities)
                FilterChip(
                  label: Text(city),
                  selected: state.selectedCities.contains(city),
                  onSelected: (_) => bloc.add(AddServiceCityToggled(city)),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimens.spaceMd.h(context)),
              Text(
                context.l10n.other,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16.sp(context),
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              MessageInputBar(
                controller: TextEditingController(text: 'Other Place: '),
                onSend: null,
                text: 'Other Place: ',
                service: true,
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
            ],
          )
        ],
        SizedBox(height: AppDimens.spaceMd.h(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.minimumNumberOfPeople,
              style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
            ),
            QuantityStepper(
              quantity: state.minimumPeople,
              onIncrement: () =>
                  bloc.add(const AddServiceMinimumPeopleChanged(1)),
              onDecrement: () =>
                  bloc.add(const AddServiceMinimumPeopleChanged(-1)),
            ),
          ],
        ),
        SizedBox(height: AppDimens.spaceLg.h(context)),
      ],
    );
  }
}

/// Step 4: Dynamic required-questions sections (medical/booking
/// questionnaire). Rendered entirely from the static
/// [RequiredQuestionSection] list so adding/removing
/// sections/questions never requires new widget code.
class _StepRequiredQuestions extends StatelessWidget {
  const _StepRequiredQuestions();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddServiceBloc>().state;
    final bloc = context.read<AddServiceBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.requiredQuestions,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        Text(
          context.l10n.questionsHelp,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
        ),
        SizedBox(height: AppDimens.spaceMd.h(context)),
        for (final section in state.questionSections) ...[
          Text(
            section.title,
            style: AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          for (final question in section.questions) ...[
            Container(
              child: Row(
                children: [
                  BlocSelector<AddServiceBloc, AddServiceState, bool>(
                    selector: (state) => state.question[question.id] ?? false,
                    builder: (context, isChecked) {
                      return Transform.scale(
                        scale: 1.3.r(context),
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (_) {
                            context.read<AddServiceBloc>().add(
                                  ToggleQuestionEvent(question.id),
                                );
                          },
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppDimens.spaceXs.w(context),
                            bottom: AppDimens.spaceXs.h(context),
                          ),
                          child: Text(
                            question.text,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12.sp(context),
                              color: AppColors.textSecondaryGrey,
                            ),
                          ),
                        ),
                        FeildSer(
                          label: question.placeholder,
                          icon: Icons.help_outline,
                          initialValue: state.answers[question.id],
                          onChanged: (v) => bloc.add(
                              AddServiceQuestionAnswerChanged(question.id, v)),
                        ),
                        SizedBox(height: AppDimens.spaceSm.h(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppDimens.spaceMd.h(context)),
        ],
        SizedBox(height: AppDimens.spaceLg.h(context)),
      ],
    );
  }
}
