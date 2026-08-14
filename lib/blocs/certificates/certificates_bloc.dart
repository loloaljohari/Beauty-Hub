import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/training_models.dart';
import '../../data/repositories/training_repository.dart';
import 'certificates_event.dart';
import 'certificates_state.dart';

class CertificatesBloc extends Bloc<CertificatesEvent, CertificatesState> {
  CertificatesBloc({TrainingRepository? repository})
      : _repository = repository ?? const TrainingRepository(),
        super(const CertificatesState()) {
    on<CertificatesLoaded>(_onLoaded);
    on<CertificatesTabChanged>(_onTabChanged);
    on<CertificateDeleted>(_onDeleted);
  }

  final TrainingRepository _repository;

  /// Two genuinely different endpoints feed the tabs:
  ///   "Created by me"       -> `GET /expert/certificates`
  ///                            (course certificates the expert granted)
  ///   "from Salon & Center" -> `GET /expert/certificates-profile`
  ///                            (the expert's own professional credentials)
  ///
  /// They are fetched together and merged, so the "All" tab is real
  /// rather than one list duplicated.
  Future<void> _onLoaded(
    CertificatesLoaded event,
    Emitter<CertificatesState> emit,
  ) async {
    emit(state.copyWith(
      status: CertificatesStatus.loading,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        _repository.getCertificates(),
        _repository.getProfileCertificates(),
      ]);

      emit(
        state.copyWith(
          allCertificates: <CertificateModel>[...results[0], ...results[1]],
          status: CertificatesStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CertificatesStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CertificatesStatus.failure,
        errorMessage: 'Could not load your certificates.',
      ));
    }
  }

  void _onTabChanged(
    CertificatesTabChanged event,
    Emitter<CertificatesState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  /// Only profile credentials can be deleted - a course certificate the
  /// expert issued to a trainee has no DELETE route, by design.
  Future<void> _onDeleted(
    CertificateDeleted event,
    Emitter<CertificatesState> emit,
  ) async {
    final target = state.allCertificates
        .where((c) => c.id == event.certificateId)
        .cast<CertificateModel?>()
        .firstWhere((c) => true, orElse: () => null);

    if (target == null) return;

    if (target.origin == CertificateOrigin.createdByMe) {
      emit(state.copyWith(
        errorMessage:
            'Certificates you granted to trainees cannot be removed.',
      ));
      return;
    }

    final previous = state.allCertificates;

    emit(state.copyWith(
      allCertificates:
          previous.where((c) => c.id != event.certificateId).toList(),
    ));

    try {
      await _repository.deleteProfileCertificate(event.certificateId);
    } on ApiException catch (e) {
      emit(state.copyWith(
        allCertificates: previous,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        allCertificates: previous,
        errorMessage: 'Could not delete this certificate.',
      ));
    }
  }
}
