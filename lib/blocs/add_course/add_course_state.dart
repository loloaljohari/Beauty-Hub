import 'package:equatable/equatable.dart';

enum AddCourseStatus { initial, loading, submitting, success, failure }

class AddCourseState extends Equatable {
  const AddCourseState({
    this.courseId,
    this.fields = const {},
    this.isOnline = false,
    this.coverImagePath,
    this.existingCoverUrl,
    this.status = AddCourseStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  /// Null when creating, set when editing.
  final String? courseId;

  /// Keyed by the backend's own field names, so nothing has to be
  /// translated at submit time.
  final Map<String, String> fields;

  final bool isOnline;

  /// Newly picked local file, if any.
  final String? coverImagePath;

  /// Already-uploaded cover when editing.
  final String? existingCoverUrl;

  final AddCourseStatus status;
  final String? errorMessage;

  /// Per-field validation messages returned by the server (422), so
  /// each one can sit under the input it belongs to.
  final Map<String, String> fieldErrors;

  bool get isEditing => courseId != null;

  String value(String key) => fields[key] ?? '';

  AddCourseState copyWith({
    String? courseId,
    Map<String, String>? fields,
    bool? isOnline,
    String? coverImagePath,
    String? existingCoverUrl,
    AddCourseStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return AddCourseState(
      courseId: courseId ?? this.courseId,
      fields: fields ?? this.fields,
      isOnline: isOnline ?? this.isOnline,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      existingCoverUrl: existingCoverUrl ?? this.existingCoverUrl,
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        courseId,
        fields,
        isOnline,
        coverImagePath,
        existingCoverUrl,
        status,
        errorMessage,
        fieldErrors,
      ];
}
