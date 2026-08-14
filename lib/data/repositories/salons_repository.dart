import '../models/salon_model.dart';

/// Static data source for "Salons & Centers" browsing and the
/// "detail of salon" screen.
class SalonsRepository {
  const SalonsRepository();

  List<String> getCities() => const [
        'Damascus',
        'Assweda',
        'Homs',
        'Hamah',
        'Aleppo',
        'Latakia',
        'Tertius',
      ];

}
