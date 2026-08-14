import 'package:equatable/equatable.dart';
import '../../data/models/training_models.dart';

enum CertificatesStatus { initial, loading, loaded, failure }

class CertificatesState extends Equatable {
  const CertificatesState({
    this.allCertificates = const [],
    this.tabIndex = 0,
    this.status = CertificatesStatus.initial,
    this.errorMessage,
  });

  final List<CertificateModel> allCertificates;

  /// 0 = All, 1 = Created by me, 2 = from Salon & Center.
  final int tabIndex;
  final CertificatesStatus status;
  final String? errorMessage;

  bool get isEmpty =>
      status == CertificatesStatus.loaded && allCertificates.isEmpty;

  List<CertificateModel> get filteredCertificates {
    if (tabIndex == 0) return allCertificates;
    final originFilter = tabIndex == 1
        ? CertificateOrigin.createdByMe
        : CertificateOrigin.fromSalonOrCenter;
    return allCertificates.where((c) => c.origin == originFilter).toList();
  }

  CertificatesState copyWith({
    List<CertificateModel>? allCertificates,
    int? tabIndex,
    CertificatesStatus? status,
    String? errorMessage,
  }) {
    return CertificatesState(
      allCertificates: allCertificates ?? this.allCertificates,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [allCertificates, tabIndex, status, errorMessage];
}
