import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/menu/menu_bloc.dart';
import '../blocs/menu/menu_event.dart';
import '../blocs/menu/menu_state.dart';
import '../blocs/nav/nav_bloc.dart';
import '../blocs/nav/nav_event.dart';
import '../blocs/nav/nav_state.dart';
import '../blocs/notifications/notifications_bloc.dart';
import '../blocs/notifications/notifications_event.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../blocs/settings/settings_bloc.dart';
import '../core/utils/main_shell_scope.dart';
import '../data/models/menu_models.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/side_menu.dart';
import 'chats/chats_page.dart';
import 'home/home_page.dart';
import 'my_store/my_store_page.dart';
import 'profile/profile_page.dart';
import 'reservations/reservations_page.dart';

/// Hosts the 5 main tabs (Home / Store / Reservations / Chats /
/// Profile) inside an [IndexedStack] so each tab's scroll position
/// and BLoC state survive switching tabs, paired with the shared
/// [BottomNavBar] AND the side [SideMenu] (opened via [endDrawer]).
///
/// Nested tab pages open the menu via
/// `MainShellScope.of(context).openMenu()` - see
/// core/utils/main_shell_scope.dart for why this indirection is
/// needed instead of a plain `Scaffold.of(context).openEndDrawer()`.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavBloc()),
        BlocProvider(create: (_) => MenuBloc()..add(const MenuLoaded())),
        // Profile data is also needed for the SideMenu header summary;
        // shared here so both the Profile tab and the drawer reuse the
        // same loaded user without duplicate repository calls.
        BlocProvider(create: (_) => ProfileBloc()..add(const ProfileLoaded())),
        BlocProvider(
          create: (_) => SettingsBloc(),
        ),
        BlocProvider(
          create: (_) => NotificationsBloc()..add(const NotificationsLoaded()),
        ),
      ],
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatefulWidget {
  const _MainShellView();

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _pages = [
    HomePage(),
    MyStorePage(),
    ReservationsPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  void _openMenu() {
    print('Opening menu from MainShellScope callback');
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onMenuItemTap(MenuItemModel item) async {
    Navigator.of(context).pop(); // close drawer
    context.read<MenuBloc>().add(MenuItemSelected(item.id));
    final update = await Navigator.of(context).pushNamed(item.routeName);
    if (update == true || context.mounted) {
      // If the user updated their profile, refresh the profile data
      context.read<ProfileBloc>().add(const ProfileLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      openMenu: _openMenu,
      child: BlocBuilder<NavBloc, NavState>(
        builder: (context, navState) {
          return Scaffold(
            key: _scaffoldKey,
            endDrawer: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, menuState) {
                return BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    return SideMenu(
                      sections: menuState.sections,
                      user: profileState.user,
                      onItemTap: _onMenuItemTap,
                    );
                  },
                );
              },
            ),
            body: IndexedStack(
              index: navState.currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavBar(
                currentIndex: navState.currentIndex,
                onTap: (index) {
                  context.read<NavBloc>().add(NavTabChanged(index));
                }),
          );
        },
      ),
    );
  }
}
