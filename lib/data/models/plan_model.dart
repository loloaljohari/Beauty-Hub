import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a single subscription plan tier shown on the
/// "Plan comparison" screen.
class PlanModel extends Equatable {
  const PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.priceColor,
    required this.ctaLabel,
    this.badgeLabel,
    this.isCurrent = false,
  });

  /// Unique identifier, e.g. 'starter', 'luxe_growth', 'enterprise'.
  final String id;

  /// Plan name, e.g. 'Starter', 'Luxe Growth', 'Enterprise'.
  final String name;

  /// Display price string, e.g. '\$99', '\$249', 'Custom'.
  final String price;

  /// Short description of who the plan is for.
  final String description;

  /// Color used for the price text (varies per plan in the design).
  final Color priceColor;

  /// Call-to-action button label, e.g. 'Choose', 'Current'.
  final String ctaLabel;

  /// Optional badge text shown above the plan (e.g. 'Upgrade').
  final String? badgeLabel;

  /// Whether this is the user's currently active plan.
  final bool isCurrent;

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        description,
        priceColor,
        ctaLabel,
        badgeLabel,
        isCurrent,
      ];
}
