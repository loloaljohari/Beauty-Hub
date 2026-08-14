import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({MenuRepository? repository})
      : _repository = repository ?? const MenuRepository(),
        super(const MenuState()) {
    on<MenuLoaded>(_onLoaded);
    on<MenuItemSelected>(_onItemSelected);
  }

  final MenuRepository _repository;

  void _onLoaded(MenuLoaded event, Emitter<MenuState> emit) async{
    emit(state.copyWith(sections:await _repository.getSections( )));
  }

  void _onItemSelected(MenuItemSelected event, Emitter<MenuState> emit) {
    emit(state.copyWith(selectedItemId: event.itemId));
  }
}
