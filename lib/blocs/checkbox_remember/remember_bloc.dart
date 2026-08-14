import 'package:flutter_bloc/flutter_bloc.dart';

class RememberBloc extends Cubit<RememberState> {
  RememberBloc() : super(const RememberState(remember: false));
  void toggleRemember(bool remember) {
    emit(state.copyWith(remember: remember));
  }
}

class RememberState {
  final bool remember;
  const RememberState({required this.remember});
  RememberState copyWith({bool? remember}) {
    return RememberState(
      remember: remember ?? this.remember,
    );
  }
}
