import 'package:equatable/equatable.dart';

abstract class NavEvent extends Equatable {
  const NavEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user taps a bottom navigation tab.
class NavTabChanged extends NavEvent {
  const NavTabChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
