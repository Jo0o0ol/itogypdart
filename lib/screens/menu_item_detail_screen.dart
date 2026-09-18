import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/roles.dart';
import '../core/session.dart';
import '../models/entities.dart';
import '../repositories/menu_repository.dart';
import '../repositories/pb_repository.dart';
import '../state/cart_controller.dart';
import '../widgets/page_frame.dart';
import '../widgets/state_views.dart';

class MenuItemDetailScreen extends StatefulWidget {
  const MenuItemDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  MenuItem? item;
  List<Review> reviews = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final loaded = await context.read<MenuRepository>().byId(widget.id);
      final result = await context.read<PbRepository>().list(
            'reviews',
            perPage: 50,
            sort: '-created',
            filter: 'menu_item="${widget.id}" && deleted=false',
          );

      if (!mounted) return;
      setState(() {
        item = loaded;
        reviews = result.items.map(Review.fromJson).toList();
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && item == null) return const LoadingView();
    if (error != null) return ErrorView(message: error!, onRetry: load);

    final current = item!;
    final session = context.watch<Session>();

    return PageFrame(
      maxWidth: 1000,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 28,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: 230,
                    height: 210,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      child: const Icon(
                        Icons.coffee_outlined,
                        size: 96,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 520,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.name,
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${current.categoryName} · ${current.kind}',
                        ),
                        if (current.volumeMl > 0)
                          Text('Объём: ${current.volumeMl} мл'),
                        Text('Код: ${current.sku}'),
                        const SizedBox(height: 16),
                        Text(
                          '${current.price.toStringAsFixed(2)} ₽',
                          style:
                              Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text('Доступно: ${current.stock}'),
                        const SizedBox(height: 14),
                        if (Permissions.canBuy(session.role))
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: current.available
                                    ? () => context
                                        .read<CartController>()
                                        .add(current)
                                    : null,
                                icon:
                                    const Icon(Icons.add_shopping_cart),
                                label: const Text('В корзину'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<PbRepository>()
                                        .create(
                                      'favorites',
                                      {
                                        'user': session.userId,
                                        'menu_item': current.id,
                                        'deleted': false,
                                      },
                                    );

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Добавлено в избранное',
                                        ),
                                      ),
                                    );
                                  } on ApiException catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(e.message),
                                      ),
                                    );
                                  }
                                },
                                icon:
                                    const Icon(Icons.favorite_border),
                                label:
                                    const Text('В избранное'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Отзывы',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          if (reviews.isEmpty)
            const EmptyView(message: 'Отзывов пока нет.')
          else
            for (final review in reviews)
              Card(
                child: ListTile(
                  leading:
                      CircleAvatar(child: Text('${review.rating}')),
                  title: Text(review.text),
                  subtitle: Text('Оценка: ${review.rating}/5'),
                ),
              ),
        ],
      ),
    );
  }
}
