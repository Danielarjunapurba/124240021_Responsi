class ExtraItemModel {
  const ExtraItemModel({required this.id, required this.name});

  final String id;
  final String name;

  factory ExtraItemModel.fromJson(dynamic json) {
    if (json is String) {
      return ExtraItemModel(id: json, name: _label(json));
    }

    if (json is Map<String, dynamic>) {
      final id = (json['slug'] ?? json['name'] ?? '').toString();
      return ExtraItemModel(
        id: id,
        name: (json['name'] ?? _label(id)).toString(),
      );
    }

    return const ExtraItemModel(id: '', name: '');
  }

  static String _label(String slug) => slug
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
