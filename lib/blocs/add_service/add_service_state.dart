import 'package:equatable/equatable.dart';
import '../../data/models/service_model.dart';

enum AddServiceStatus { initial, loading, success, failure }

class AddServiceState extends Equatable {
  const AddServiceState({
    this.serviceid,
    this.question = const {},
    this.currentStep = 0,
    this.totalSteps = 4,
    this.fields = const {
      'name': '',
      'category': '',
      'bio': '',
      'price': '',
      'duration': '',
    },
    this.instructions = const [],
    this.availableAtHome = false,
    this.allCities = const [],
    this.selectedCities = const [],
    this.minimumPeople = 1,
    this.questionSections = const [],
    this.answers = const {},
    this.status = AddServiceStatus.initial,
    this.errorMessage,
  });

  final int currentStep;
  final int totalSteps;
  final Map<String, bool> question;

  /// Step 1 fields.
  final Map<String, String> fields;
  final int? serviceid;

  /// Step 2 pre-booking instructions.
  final List<String> instructions;

  /// Step 3 home-service settings.
  final bool availableAtHome;
  final List<String> allCities;
  final List<String> selectedCities;
  final int minimumPeople;

  /// Step 4 dynamic question sections + free-text answers keyed by
  /// question id.
  final List<RequiredQuestionSection> questionSections;
  final Map<String, String> answers;

  final AddServiceStatus status;
  final String? errorMessage;

  String fieldValue(String key) => fields[key] ?? '';
  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;

  AddServiceState copyWith({
    int? serviceid,
    Map<String, bool>? question,
    int? currentStep,
    Map<String, String>? fields,
    List<String>? instructions,
    bool? availableAtHome,
    List<String>? allCities,
    List<String>? selectedCities,
    int? minimumPeople,
    List<RequiredQuestionSection>? questionSections,
    Map<String, String>? answers,
    AddServiceStatus? status,
    String? errorMessage,
  }) {
    return AddServiceState(
        question: question ?? this.question,
        currentStep: currentStep ?? this.currentStep,
        totalSteps: totalSteps,
        fields: fields ?? this.fields,
        instructions: instructions ?? this.instructions,
        availableAtHome: availableAtHome ?? this.availableAtHome,
        allCities: allCities ?? this.allCities,
        selectedCities: selectedCities ?? this.selectedCities,
        minimumPeople: minimumPeople ?? this.minimumPeople,
        questionSections: questionSections ?? this.questionSections,
        answers: answers ?? this.answers,
        status: status ?? this.status,
        errorMessage: errorMessage,
        serviceid: serviceid ?? this.serviceid);
  }

  @override
  List<Object?> get props => [
        currentStep,
        totalSteps,
        fields,
        instructions,
        availableAtHome,
        allCities,
        selectedCities,
        minimumPeople,
        questionSections,
        answers,
        question,
        status,
        errorMessage,
        serviceid
      ];
}
