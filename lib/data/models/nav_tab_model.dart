import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single tab in the main app [BottomNavBar].
class NavTabModel extends Equatable {
  const NavTabModel({
    required this.index,
    required this.icon,
    this.isProfile = false,
  });

  final int index;
  final IconData icon;

  /// True for the rightmost circular-avatar Profile tab, which is
  /// rendered differently (avatar instead of icon).
  final bool isProfile;

  @override
  List<Object?> get props => [index, icon, isProfile];
}
