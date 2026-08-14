import 'package:equatable/equatable.dart';

abstract class CertificatesEvent extends Equatable {
  const CertificatesEvent();

  @override
  List<Object?> get props => [];
}

class CertificatesLoaded extends CertificatesEvent {
  const CertificatesLoaded();
}

/// Switches between All / Created by me / from Salon & Center.
class CertificatesTabChanged extends CertificatesEvent {
  const CertificatesTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class CertificateDeleted extends CertificatesEvent {
  const CertificateDeleted(this.certificateId);

  final String certificateId;

  @override
  List<Object?> get props => [certificateId];
}
