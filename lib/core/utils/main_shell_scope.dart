import 'package:flutter/material.dart';

/// Exposes the main shell's [Scaffold] drawer controls to nested tab
/// pages (Home/Store/Reservations/Chats/Profile), each of which has
/// its own inner [Scaffold] for its [AppBar]. Since `Scaffold.of`
/// only resolves to the *nearest* ancestor Scaffold, nested pages
/// can't open the shell-level [endDrawer] directly - they use
/// [MainShellScope.of(context).openMenu()] instead.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.openMenu,
    required super.child,
  });

  final VoidCallback openMenu;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static MainShellScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MainShellScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      openMenu != oldWidget.openMenu;
}
