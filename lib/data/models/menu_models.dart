import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single tappable row in the side drawer (e.g. "Material",
/// "Job Requests").
class MenuItemModel extends Equatable {
  const MenuItemModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Route name to navigate to when tapped (see [RouteNames]).
  final String routeName;

  @override
  List<Object?> get props => [id, label, icon, routeName];
}

/// A grouped section in the side drawer (Business / Growth /
/// Account), each containing several [MenuItemModel] rows.
class MenuSectionModel extends Equatable {
  const MenuSectionModel({required this.title, required this.items});

  final String title;
  final List<MenuItemModel> items;

  @override
  List<Object?> get props => [title, items];
}
