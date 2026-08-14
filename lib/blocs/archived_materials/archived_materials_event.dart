import 'package:equatable/equatable.dart';

abstract class ArchivedMaterialsEvent extends Equatable {
  const ArchivedMaterialsEvent();
  @override
  List<Object?> get props => [];
}

class ArchivedMaterialsLoaded extends ArchivedMaterialsEvent {
  const ArchivedMaterialsLoaded();
}

class ArchivedMaterialRestored extends ArchivedMaterialsEvent {
  const ArchivedMaterialRestored(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
