import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/roles.dart';
import '../core/session.dart';
import '../models/catalog_query.dart';
import '../models/entities.dart';
import '../models/page_result.dart';
import '../repositories/menu_repository.dart';
import '../repositories/pb_repository.dart';
import '../state/cart_controller.dart';
import '../widgets/page_frame.dart';
import '../widgets/responsive.dart';
import '../widgets/state_views.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.query,
  });

  final CatalogQuery query;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final search = TextEditingController();
  final min = TextEditingController();
  final max = TextEditingController();

  Timer? debounce;
  PageResult<MenuItem>? page;
  List<CafeCategory> categories = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    sync();
    load();
    loadCategories();
  }

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query.toUrlQuery().toString() !=
        widget.query.toUrlQuery().toString()) {
      sync();
      load();
    }
  }

  void sync() {
    search.text = widget.query.search;
    min.text = widget.query.minPrice?.toString() ?? '';
    max.text = widget.query.maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    min.dispose();
    max.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final result = await context.read<PbRepository>().list(
            'categories',
            perPage: 100,
            sort: 'name',
            filter: 'deleted=false',
          );

      if (!mounted) return;
      setState(() {
        categories = result.items.map(CafeCategory.fromJson).toList();
      });
    } catch (_) {}
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await context.read<MenuRepository>().find(widget.query);
      if (!mounted) return;
      setState(() => page = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void go(CatalogQuery query) {
    final uri = Uri(
      path: '/menu',
      queryParameters:
          query.toUrlQuery().isEmpty ? null : query.toUrlQuery(),
    );
    context.go(uri.toString());
  }

  void onSearch(String value) {
    debounce?.cancel();
    debounce = Timer(
      const Duration(milliseconds: 350),
      () => go(widget.query.copyWith(search: value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();

    return PageFrame(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Меню кофейни',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (Permissions.canManageMenu(session.role))
                FilledButton.icon(
                  onPressed: () => context.go('/inventory'),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Управление'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _filters(),
          const SizedBox(height: 14),
          Expanded(child: _body(session)),
        ],
      ),
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: search,
            onChanged: onSearch,
            decoration: const InputDecoration(
              labelText: 'Поиск по названию или коду',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: 210,
          child: DropdownButtonFormField<String?>(
            value: widget.query.categoryId,
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Все категории'),
              ),
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => go(
              widget.query.copyWith(
                categoryId: value,
                clearCategory: value == null,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String?>(
            value: widget.query.kind,
            decoration: const InputDecoration(
              labelText: 'Тип',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Любой')),
              DropdownMenuItem(value: 'coffee', child: Text('Кофе')),
              DropdownMenuItem(value: 'tea', child: Text('Чай')),
              DropdownMenuItem(value: 'dessert', child: Text('Десерт')),
              DropdownMenuItem(value: 'food', child: Text('Еда')),
              DropdownMenuItem(value: 'beans', child: Text('Зёрна')),
            ],
            onChanged: (value) => go(
              widget.query.copyWith(
                kind: value,
                clearKind: value == null,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 110,
          child: TextField(
            controller: min,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Цена от',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: 110,
          child: TextField(
            controller: max,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Цена до',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () => go(
            widget.query.copyWith(
              minPrice: double.tryParse(min.text),
              maxPrice: double.tryParse(max.text),
              clearMin: min.text.isEmpty,
              clearMax: max.text.isEmpty,
            ),
          ),
          child: const Text('Применить'),
        ),
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
            value: widget.query.sort,
            decoration: const InputDecoration(
              labelText: 'Сортировка',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: '-created',
                child: Text('Сначала новые'),
              ),
              DropdownMenuItem(value: 'price', child: Text('Цена ↑')),
              DropdownMenuItem(value: '-price', child: Text('Цена ↓')),
              DropdownMenuItem(value: 'name', child: Text('Название')),
            ],
            onChanged: (value) {
              if (value != null) {
                go(widget.query.copyWith(sort: value));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _body(Session session) {
    if (loading && page == null) return const LoadingView();
    if (error != null) return ErrorView(message: error!, onRetry: load);

    final current = page;
    if (current == null || current.items.isEmpty) {
      return const EmptyView(
        message: 'По заданным условиям ничего не найдено.',
      );
    }

    final widthClass = widthClassFor(MediaQuery.sizeOf(context).width);
    final columns = switch (widthClass) {
      WidthClass.compact => 1,
      WidthClass.medium => 2,
      WidthClass.wide => 3,
      WidthClass.ultraWide => 4,
    };

    return Column(
      children: [
        if (loading) const LinearProgressIndicator(),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 2.15 : 0.95,
            ),
            itemCount: current.items.length,
            itemBuilder: (context, index) {
              final item = current.items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/menu-items/${item.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.kind == 'dessert'
                              ? Icons.cake_outlined
                              : Icons.local_cafe_outlined,
                          size: 42,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${item.categoryName} · ${_kindTitle(item.kind)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.volumeMl > 0)
                          Text('${item.volumeMl} мл'),
                        const Spacer(),
                        Text(
                          '${item.price.toStringAsFixed(2)} ₽',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('Доступно: ${item.stock}'),
                        if (Permissions.canBuy(session.role))
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'В корзину',
                              onPressed: item.available
                                  ? () => context
                                      .read<CartController>()
                                      .add(item)
                                  : null,
                              icon: const Icon(
                                Icons.add_shopping_cart,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: current.page > 1
                  ? () => go(
                        widget.query.copyWith(
                          page: current.page - 1,
                        ),
                      )
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              'Страница ${current.page} из ${current.totalPages}',
            ),
            IconButton(
              onPressed: current.page < current.totalPages
                  ? () => go(
                        widget.query.copyWith(
                          page: current.page + 1,
                        ),
                      )
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  String _kindTitle(String value) => switch (value) {
        'coffee' => 'Кофе',
        'tea' => 'Чай',
        'dessert' => 'Десерт',
        'food' => 'Еда',
        'beans' => 'Зёрна',
        _ => value,
      };
}
