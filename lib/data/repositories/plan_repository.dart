import '../models/plan_model.dart';
import '../../core/constants/app_colors.dart';

/// Static data source for the "Plan comparison" screen.
///
/// Replace [getPlans] with an API call later; the BLoC already wraps
/// this in an async event handler so the migration only touches this
/// repository method.
class PlanRepository {
  const PlanRepository();

  List<PlanModel> getPlans() => const [
        PlanModel(
          id: 'starter',
          name: 'Starter',
          price: '\$99',
          description: 'Single salon',
          priceColor: AppColors.decorativeRose,
          ctaLabel: 'Choose',
          badgeLabel: null,
        ),
        PlanModel(
          id: 'luxe_growth',
          name: 'Luxe Growth',
          price: '\$249',
          description: 'Multi-location suite',
          priceColor: AppColors.primaryDark,
          ctaLabel: 'Current',
          badgeLabel: 'Upgrade',
          isCurrent: true,
        ),
        PlanModel(
          id: 'enterprise',
          name: 'Enterprise',
          price: 'Custom',
          description: 'Beauty group scale',
          priceColor: AppColors.decorativeGold,
          ctaLabel: 'Choose',
          badgeLabel: null,
        ),
      ];
}
