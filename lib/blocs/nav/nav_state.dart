import 'package:equatable/equatable.dart';

class NavState extends Equatable {
  const NavState({this.currentIndex = 0});

  /// 0 = Home, 1 = Store, 2 = Reservations, 3 = Chats, 4 = Profile.
  final int currentIndex;

  NavState copyWith({int? currentIndex}) {
    return NavState(currentIndex: currentIndex ?? this.currentIndex);
  }

  @override
  List<Object?> get props => [currentIndex];
}
