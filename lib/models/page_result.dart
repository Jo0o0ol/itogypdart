class PageResult<T> {
  const PageResult({required this.page, required this.perPage, required this.totalItems, required this.totalPages, required this.items});
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<T> items;

  factory PageResult.fromPocketBase(Map<String, dynamic> json, T Function(Map<String, dynamic>) parser) {
    final raw = json['items'] as List? ?? const [];
    return PageResult<T>(
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['perPage'] as num?)?.toInt() ?? 20,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? raw.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      items: raw.whereType<Map>().map((e) => parser(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
