import 'package:flutter_bloc/flutter_bloc.dart';
import 'nav_event.dart';
import 'nav_state.dart';

/// Controls which tab is active in the main app shell's
/// [IndexedStack] (Home / Store / Reservations / Chats / Profile).
class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(const NavState()) {
    on<NavTabChanged>((event, emit) {
    
      emit(state.copyWith(currentIndex: event.index));
    });
  }
}
