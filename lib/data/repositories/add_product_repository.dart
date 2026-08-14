/// Static data source for the "Add product" form: category options
/// and default/sample values matching the Figma mockup content.
class AddProductRepository {
  const AddProductRepository();

  List<String> getCategories() => const [
        'Hair care',
        'Skin care',
        'Nail care',
        'Makeup',
        'Tools',
      ];
}
