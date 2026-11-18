class SavedCard {
  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final bool isDefault;

  String get label {
    final name = brand.isEmpty ? 'Card' : brand;
    final tail = last4.isEmpty ? '' : ' •••• $last4';
    return '$name$tail';
  }

  static SavedCard? tryParse(Object? data) {
    if (data is! Map) return null;
    final id = data['id'];
    if (id is! String || id.isEmpty) return null;
    final brand = data['brand'];
    final last4 = data['last4'];
    return SavedCard(
      id: id,
      brand: brand is String ? brand : '',
      last4: last4 is String ? last4 : '',
      isDefault: data['isDefault'] == true,
    );
  }

  static List<SavedCard> parseList(Object? data) {
    final rows = data is Map && data['data'] is List ? data['data'] : data;
    if (rows is! List) return const [];
    return rows.map(tryParse).whereType<SavedCard>().toList();
  }
}
