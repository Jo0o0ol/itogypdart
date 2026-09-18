import 'package:coffee_house_final/models/catalog_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('условия фильтрации входят в PocketBase filter', () {
    const query = CatalogQuery(
      search: 'капучино',
      categoryId: 'cat1',
      kind: 'coffee',
      minPrice: 200,
      maxPrice: 500,
    );

    final filter = query.toPocketBaseFilter();

    expect(filter, contains('name~"капучино"'));
    expect(filter, contains('category="cat1"'));
    expect(filter, contains('kind="coffee"'));
    expect(filter, contains('price>=200'));
    expect(filter, contains('price<=500'));
  });

  test('фильтры отражаются в URL', () {
    const query = CatalogQuery(
      search: 'латте',
      kind: 'coffee',
      page: 2,
    );

    final url = query.toUrlQuery();

    expect(url['search'], 'латте');
    expect(url['kind'], 'coffee');
    expect(url['page'], '2');
  });
}
