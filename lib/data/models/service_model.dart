import 'package:equatable/equatable.dart';

/// A single service offered by the expert/salon (e.g. "Nail
/// Extension"), shown on the Profile "Services" tab and managed via
/// the "Add service" wizard.
class ServiceModel extends Equatable {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
    this.category = '',
    this.imageUrl,
    this.instructions = const [],
    this.availableAtHome = false,
    this.availableCities = const [],
    this.minimumPeople = 1,
  });

  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final double price;
  final String category;
  final String? imageUrl;

  /// Pre-booking instructions the customer must follow
  /// (e.g. "Don't wash your hair 24-48 hours before dyeing").
  final List<String> instructions;

  final bool availableAtHome;
  final List<String> availableCities;
  final int minimumPeople;

  String get formattedDuration => '$durationMinutes min';
  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  ServiceModel copyWith({
    List<String>? instructions,
    bool? availableAtHome,
    List<String>? availableCities,
    int? minimumPeople,
  }) {
    return ServiceModel(
      id: id,
      name: name,
      description: description,
      durationMinutes: durationMinutes,
      price: price,
      category: category,
      imageUrl: imageUrl,
      instructions: instructions ?? this.instructions,
      availableAtHome: availableAtHome ?? this.availableAtHome,
      availableCities: availableCities ?? this.availableCities,
      minimumPeople: minimumPeople ?? this.minimumPeople,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        durationMinutes,
        price,
        category,
        imageUrl,
        instructions,
        availableAtHome,
        availableCities,
        minimumPeople,
      ];
}

/// A single question within a [RequiredQuestionSection], used by the
/// dynamic "Required Questions" step of the Add Service wizard.
class RequiredQuestion extends Equatable {
  const RequiredQuestion({
    required this.id,
    required this.text,
    this.placeholder = 'type.....',
  });

  final String id;
  final String text;
  final String placeholder;

  @override
  List<Object?> get props => [id, text, placeholder];
}

/// A grouped section of medical/required questions
/// (e.g. "Allergies", "Women's Health") shown in the booking
/// questionnaire step. Built as static data so new sections/questions
/// can be added without writing new widgets.
class RequiredQuestionSection extends Equatable {
  const RequiredQuestionSection({
    required this.id,
    required this.title,
    required this.questions,
  });

  final String id;
  final String title;
  final List<RequiredQuestion> questions;

  @override
  List<Object?> get props => [id, title, questions];
}
