import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/plan/plan_bloc.dart';
import '../../blocs/plan/plan_event.dart';
import '../../blocs/plan/plan_state.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/plan_card.dart';

/// Plan comparison screen - matches Figma frame "Plan" (938:1219).
///
/// Displays the Starter / Luxe Growth / Enterprise subscription tiers.
/// On phones the cards stack vertically; on tablets/wide screens they
/// are arranged in a responsive grid/row.
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlanBloc()..add(const PlanLoaded()),
      child: const _PlanView(),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showDecorativeShapes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthHeader(title: AppStrings.planComparison),
          SizedBox(height: AppDimens.spaceXl.h(context)),
          BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              if (state.status != PlanStatus.loaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final isWide = MediaQuery.of(context).size.width >= 600;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final plan in state.plans)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimens.spaceXs.w(context),
                          ),
                          child: PlanCard(
                            plan: plan,
                            isSelected: plan.id == state.selectedPlanId,
                            onSelect: () => context
                                .read<PlanBloc>()
                                .add(PlanSelected(plan.id)),
                          ),
                        ),
                      ),
                  ],
                );
              }

              return Column(
                children: [
                  for (final plan in state.plans) ...[
                    PlanCard(
                      plan: plan,
                      isSelected: plan.id == state.selectedPlanId,
                      onSelect: () => context
                          .read<PlanBloc>()
                          .add(PlanSelected(plan.id)),
                    ),
                    SizedBox(height: AppDimens.spaceMd.h(context)),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: AppDimens.spaceMd.h(context)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              ),
              child: Text(
                AppStrings.continueText,
                style: AppTextStyles.link.copyWith(fontSize: 16.sp(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
