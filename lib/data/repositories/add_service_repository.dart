import 'package:beautyhup/core/network/api_client.dart';
import 'package:beautyhup/core/network/api_endpoints.dart';
import 'package:beautyhup/core/network/api_response.dart';
import 'package:beautyhup/data/models/service_model.dart';

import 'service_categories_repository.dart';

/// Static data source for the multi-step "Add service" wizard:
/// category options, the available-cities list, and the dynamic
/// required-questions sections (medical/booking questionnaire).
class AddServiceRepository {
  const AddServiceRepository();

  /// Same source as the inventory screens, so a service and a material
  /// can never be filed under two different "Hair care" ids.
  List<Map<String, dynamic>> getCategories() =>
      ServiceCategoriesRepository.all;

  // ─── API ──────────────────────────────────────────────────────────
  // Field names and types come from the FormRequest classes:
  // StoreServiceRequest, UpdateServiceRequest, SetQuestionsRequest,
  // UpdateInstructionsRequest, UpdateMinBookingsRequest.

  /// GET /expert/services -> data.services (paginated, active only).
  ///
  /// Note the backend filters `is_active = true`, so a "deleted"
  /// service (which is only deactivated, never removed) will not
  /// come back here.
  Future<List<Map<String, dynamic>>> getServices() async {
    final response = await ApiClient.get(ApiEndpoints.services);
    return ApiResponse.asMapList(ApiResponse.data(response)['services']);
  }

  /// POST /expert/services -> data.service.id
  ///
  /// Throws [ApiException] on failure rather than returning 0. The
  /// previous version returned 0 when the envelope check failed, and
  /// the wizard then happily posted instructions and questions to
  /// `services/0/...`, which 404s with no visible cause.
  Future<int> saveBasicInfo({
    required String name,
    required int id,
    required String bio,
    required String price,
    required String duration,
    double? depositPercent,
    int? cancellationDeadlineHours,
    String? genderFor,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.services,
      body: {
        'name': name,
        'category_id': id,
        'description': bio,
        // The rules are `numeric` / `integer`; sending real numbers
        // avoids relying on Laravel's string coercion.
        'price': double.tryParse(price) ?? price,
        'duration_minutes': int.tryParse(duration) ?? duration,
        if (depositPercent != null) 'deposit_percent': depositPercent,
        if (cancellationDeadlineHours != null)
          'cancellation_deadline_hrs': cancellationDeadlineHours,
        if (genderFor != null) 'gender_for': genderFor,
      },
    );

    final serviceId =
        ApiResponse.asInt(ApiResponse.object(response, 'service')['id']);

    if (serviceId == 0) {
      throw const ApiException(
        message: 'The service was not created. Please try again.',
        statusCode: 0,
      );
    }

    return serviceId;
  }

  /// POST /expert/services/{id}/instructions
  ///
  /// The column is a single TEXT field (`instructions`), not a list.
  /// The previous version sent `jsonEncode([...])`, so the customer
  /// app would have rendered a raw JSON array. The lines are joined
  /// with newlines instead.
  Future<void> saveInstructions({
    required int serviceId,
    required List<String> instructions,
  }) async {
    await ApiClient.post(
      ApiEndpoints.serviceInstructions(serviceId),
      body: {
        'instructions': instructions
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .join('\n'),
      },
    );
  }

  /// POST /expert/services/{id}/min-bookings
  ///
  /// Only `min_bookings_remote` exists on the backend. There is NO
  /// column or endpoint for "available at home" or a per-service city
  /// list, so those two arguments are accepted (the wizard collects
  /// them) but deliberately not sent - inventing query parameters the
  /// server ignores would look like it worked.
  Future<void> saveHomeServiceSettings({
    required int serviceId,
    required int minimumPeople,
    required bool availableAtHome,
    required List<String> selectedCities,
  }) async {
    await ApiClient.post(
      ApiEndpoints.serviceMinBookings(serviceId),
      body: {'min_bookings_remote': minimumPeople},
    );
  }

  /// POST /expert/services/{id}/questions
  ///
  /// Replaces the whole set: the backend deletes every existing
  /// question for this service first, so partial updates are not
  /// possible - always send the complete list.
  ///
  /// Each entry needs `question_text` and `answer_type`
  /// (`yes_no` | `multiple_choice` | `free_text`); `options_json` must
  /// be an array when present, and `sort_order` is derived server-side
  /// from the array order.
  Future<void> saveQuestions({
    required int serviceId,
    required List<Map<String, dynamic>> questions,
  }) async {
    await ApiClient.post(
      ApiEndpoints.serviceQuestions(serviceId),
      body: {'questions': questions},
    );
  }

  /// POST /expert/services/{id}
  ///
  /// Registered as POST (not PUT) on the backend. `instructions` is
  /// accepted here too, so a simple edit does not need a second call.
  Future<void> updateService({
    required int serviceId,
    String? instructions,
    String? name,
    int? id,
    String? bio,
    String? price,
    String? duration,
  }) async {
    await ApiClient.post(
      ApiEndpoints.service(serviceId),
      body: {
        if (name != null) 'name': name,
        if (id != null) 'category_id': id,
        if (bio != null) 'description': bio,
        if (price != null) 'price': double.tryParse(price) ?? price,
        if (duration != null)
          'duration_minutes': int.tryParse(duration) ?? duration,
        if (instructions != null) 'instructions': instructions,
      },
    );
  }

  /// DELETE /expert/services/{id} - deactivates rather than deletes.
  Future<void> deleteService(Object serviceId) async {
    await ApiClient.delete(ApiEndpoints.service(serviceId));
  }

  // ─── service materials ────────────────────────────────────────────
  // Links a service to the inventory items one session consumes, which
  // is what drives the "smart alert" for tomorrow's bookings.

  /// GET /expert/services/{id}/materials
  ///
  /// Returns `{service_id, service_name, materials: [...]}` where each
  /// material carries `covers_sessions` - how many sessions the current
  /// stock is good for.
  Future<ServiceMaterials> getServiceMaterials(Object serviceId) async {
    final response =
        await ApiClient.get(ApiEndpoints.serviceMaterials(serviceId));
    final payload = ApiResponse.data(response);

    return ServiceMaterials(
      serviceId: ApiResponse.asString(payload['service_id']),
      serviceName: ApiResponse.asString(payload['service_name']),
      materials: ApiResponse.asMapList(payload['materials'])
          .map((row) => ServiceMaterial(
                productId: ApiResponse.asString(row['product_id']),
                productName: ApiResponse.asString(row['product_name']),
                sku: ApiResponse.asString(row['sku']),
                quantityPerSession:
                    ApiResponse.asDouble(row['quantity_per_session']),
                unit: ApiResponse.asString(row['unit']),
                stockQuantity: ApiResponse.asDouble(row['stock_quantity']),
                coversSessions: ApiResponse.asInt(row['covers_sessions']),
              ))
          .toList(),
    );
  }

  /// POST /expert/services/{id}/materials
  ///
  /// A full sync: the backend deletes every existing link for the
  /// service and recreates it from what is sent, so always post the
  /// complete list. Sending `materials: []` clears them all.
  ///
  /// FIELD NAME WARNING - Postman and the backend disagree here.
  /// The Postman collection documents `quantity_per_booking`, but
  /// `SyncServiceMaterialsRequest` validates
  /// `materials.*.quantity_per_session` (and the `service_materials`
  /// migration defines that column). Following Postman would fail with
  /// a 422 every time, so this sends `quantity_per_session`.
  Future<ServiceMaterials> syncServiceMaterials({
    required Object serviceId,
    required List<ServiceMaterialInput> materials,
  }) async {
    await ApiClient.post(
      ApiEndpoints.serviceMaterials(serviceId),
      body: {
        'materials': materials
            .map((m) => {
                  'product_id': int.tryParse(m.productId) ?? m.productId,
                  'quantity_per_session': m.quantityPerSession,
                  if (m.unit != null && m.unit!.isNotEmpty) 'unit': m.unit,
                })
            .toList(),
      },
    );

    // The endpoint replies with the refreshed list; refetching keeps
    // `covers_sessions` accurate after the change.
    return getServiceMaterials(serviceId);
  }

  List<String> getAvailableCities() => const [
        'Damascus',
        'Homs',
        'Aleppo',
        'Latakia',
      ];

  /// Default pre-booking instructions shown in step 2.
  List<String> getDefaultInstructions() => const [];

  /// Dynamic question sections for step 4 ("Required Questions").
  /// Rendered via a generic list builder so adding/removing
  /// sections or questions never requires new widget code.
  List<RequiredQuestionSection> getRequiredQuestionSections() => const [
        RequiredQuestionSection(
          id: 'general_medical',
          title: 'General Medical History',
          questions: [
            RequiredQuestion(
              id: 'q1',
              text: 'Do you have any chronic medical conditions?',
              placeholder:
                  'Diabetes, High Blood Pressure, Heart Disease, Thyroid Disorder',
            ),
            RequiredQuestion(
              id: 'q2',
              text: 'Have you been hospitalized in the past 12 months?',
            ),
            RequiredQuestion(
              id: 'q3',
              text: 'Have you had any previous surgeries?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'allergies',
          title: 'Allergies',
          questions: [
            RequiredQuestion(
              id: 'q4',
              text: 'Are you allergic to any medications?',
            ),
            RequiredQuestion(
              id: 'q5',
              text: 'Are you allergic to skincare or cosmetic products?',
            ),
            RequiredQuestion(
              id: 'q6',
              text: 'Are you allergic to local anesthetics?',
            ),
            RequiredQuestion(
              id: 'q7',
              text: 'Do you have any food allergies?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'current_medications',
          title: 'Current Medications',
          questions: [
            RequiredQuestion(
              id: 'q8',
              text: 'Are you currently taking any medications?',
            ),
            RequiredQuestion(
              id: 'q9',
              text: 'Are you taking blood thinners?',
            ),
            RequiredQuestion(
              id: 'q10',
              text: 'Are you taking any acne medications?',
            ),
            RequiredQuestion(
              id: 'q11',
              text: 'Are you taking vitamins, supplements, or herbal products?',
            ),
            RequiredQuestion(
              id: 'q12',
              text: 'Please list all current medications',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'skin_health',
          title: 'Skin Health Assessment',
          questions: [
            RequiredQuestion(
              id: 'q13',
              text: 'What is your skin type?',
              placeholder: 'Oily, Dry, Combination, Sensitive, Normal',
            ),
            RequiredQuestion(
              id: 'q14',
              text: 'Do you currently have any of the following?',
              placeholder:
                  'Acne, Rosacea, Eczema, Psoriasis, Hyperpigmentation, Melasma',
            ),
            RequiredQuestion(
              id: 'q15',
              text: 'Do you have a history of keloid or hypertrophic scarring?',
            ),
            RequiredQuestion(
              id: 'q16',
              text:
                  'Have you recently experienced excessive sun exposure or tanning?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'previous_treatments',
          title: 'Previous Aesthetic Treatments',
          questions: [
            RequiredQuestion(
              id: 'q17',
              text: 'Have you previously received aesthetic treatments?',
            ),
            RequiredQuestion(
              id: 'q18',
              text: 'Date of your last treatment.',
              placeholder: '24/9/2024.....',
            ),
            RequiredQuestion(
              id: 'q19',
              text: 'Have you had any of the following?',
              placeholder:
                  'Botox, Dermal Fillers, Laser Treatments, Chemical Peels, Microneedling',
            ),
            RequiredQuestion(
              id: 'q20',
              text:
                  'Did you experience any complications or adverse reactions?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'womens_health',
          title: "Women's Health",
          questions: [
            RequiredQuestion(id: 'q21', text: 'Are you currently pregnant?'),
            RequiredQuestion(id: 'q22', text: 'Are you breastfeeding?'),
            RequiredQuestion(
              id: 'q23',
              text: 'Are you planning pregnancy in the near future?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'lifestyle',
          title: 'Lifestyle Information',
          questions: [
            RequiredQuestion(id: 'q24', text: 'Do you smoke?'),
            RequiredQuestion(
              id: 'q25',
              text: 'Do you use nicotine products?',
              placeholder: '24/9/2024.....',
            ),
            RequiredQuestion(id: 'q26', text: 'Do you consume alcohol?'),
            RequiredQuestion(
              id: 'q27',
              text: 'How often are you exposed to direct sunlight?',
            ),
            RequiredQuestion(
              id: 'q28',
              text: 'Do you use sunscreen regularly?',
            ),
          ],
        ),
        RequiredQuestionSection(
          id: 'treatment_goals',
          title: 'Treatment Goals',
          questions: [
            RequiredQuestion(
              id: 'q29',
              text: 'What is your primary aesthetic concern?',
            ),
            RequiredQuestion(
              id: 'q30',
              text: 'What areas would you like treated?',
              placeholder: '24/9/2024.....',
            ),
            RequiredQuestion(
              id: 'q31',
              text: 'What results are you hoping to achieve?',
            ),
            RequiredQuestion(
              id: 'q32',
              text:
                  'Have you received a professional skin consultation before?',
            ),
          ],
        ),
      ];
}

/// The materials one service consumes per session.
class ServiceMaterials {
  const ServiceMaterials({
    this.serviceId = '',
    this.serviceName = '',
    this.materials = const [],
  });

  final String serviceId;
  final String serviceName;
  final List<ServiceMaterial> materials;
}

class ServiceMaterial {
  const ServiceMaterial({
    required this.productId,
    required this.productName,
    this.sku = '',
    this.quantityPerSession = 0,
    this.unit = '',
    this.stockQuantity = 0,
    this.coversSessions = 0,
  });

  final String productId;
  final String productName;
  final String sku;
  final double quantityPerSession;
  final String unit;
  final double stockQuantity;

  /// How many more sessions the current stock covers, computed
  /// server-side.
  final int coversSessions;
}

/// What the sync endpoint accepts for one material.
class ServiceMaterialInput {
  const ServiceMaterialInput({
    required this.productId,
    required this.quantityPerSession,
    this.unit,
  });

  final String productId;

  /// Must be greater than zero - the backend rejects 0 with `gt:0`.
  final double quantityPerSession;
  final String? unit;
}
