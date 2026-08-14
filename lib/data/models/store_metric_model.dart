import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single KPI metric card on the "My Store" dashboard
/// (Cart value / Conversion / Payments, etc).
class StoreMetricModel extends Equatable {
  const StoreMetricModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  List<Object?> get props => [label, value, icon, accentColor];
}
