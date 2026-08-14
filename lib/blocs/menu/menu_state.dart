import 'package:equatable/equatable.dart';
import '../../data/models/menu_models.dart';

class MenuState extends Equatable {
  const MenuState({this.sections = const [], this.selectedItemId});

  final List<MenuSectionModel> sections;
  final String? selectedItemId;

  MenuState copyWith({
    List<MenuSectionModel>? sections,
    String? selectedItemId,
  }) {
    return MenuState(
      sections: sections ?? this.sections,
      selectedItemId: selectedItemId ?? this.selectedItemId,
    );
  }

  @override
  List<Object?> get props => [sections, selectedItemId];
}
