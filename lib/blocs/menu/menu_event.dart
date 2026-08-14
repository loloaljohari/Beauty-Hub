import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class MenuLoaded extends MenuEvent {
  const MenuLoaded();
}

/// Tracks which menu item the user last navigated to so it can be
/// visually highlighted next time the drawer opens.
class MenuItemSelected extends MenuEvent {
  const MenuItemSelected(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}
