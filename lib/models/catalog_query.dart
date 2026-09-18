class CatalogQuery {
  const CatalogQuery({
    this.search = '',
    this.categoryId,
    this.kind,
    this.minPrice,
    this.maxPrice,
    this.sort = '-created',
    this.page = 1,
    this.perPage = 12,
  });

  final String search;
  final String? categoryId;
  final String? kind;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int page;
  final int perPage;

  factory CatalogQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;
    return CatalogQuery(
      search: q['search'] ?? '',
      categoryId: _nullIfEmpty(q['category']),
      kind: _nullIfEmpty(q['kind']),
      minPrice: double.tryParse(q['min'] ?? ''),
      maxPrice: double.tryParse(q['max'] ?? ''),
      sort: q['sort'] ?? '-created',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      perPage: int.tryParse(q['perPage'] ?? '') ?? 12,
    );
  }

  CatalogQuery copyWith({
    String? search,
    String? categoryId,
    String? kind,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? perPage,
    bool clearCategory = false,
    bool clearKind = false,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return CatalogQuery(
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      kind: clearKind ? null : (kind ?? this.kind),
      minPrice: clearMin ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMax ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
      page: page ?? 1,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, String> toUrlQuery() => {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (categoryId != null) 'category': categoryId!,
        if (kind != null) 'kind': kind!,
        if (minPrice != null) 'min': '$minPrice',
        if (maxPrice != null) 'max': '$maxPrice',
        if (sort != '-created') 'sort': sort,
        if (page != 1) 'page': '$page',
        if (perPage != 12) 'perPage': '$perPage',
      };

  String toPocketBaseFilter() {
    final filters = <String>['deleted=false'];

    String esc(String value) =>
        value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

    if (search.trim().isNotEmpty) {
      filters.add(
        '(name~"${esc(search.trim())}" || sku~"${esc(search.trim())}")',
      );
    }
    if (categoryId != null) filters.add('category="$categoryId"');
    if (kind != null) filters.add('kind="$kind"');
    if (minPrice != null) filters.add('price>=$minPrice');
    if (maxPrice != null) filters.add('price<=$maxPrice');

    return filters.join(' && ');
  }

  static String? _nullIfEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;
}
