import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/session.dart';
import '../repositories/pb_repository.dart';
import '../widgets/page_frame.dart';
import '../widgets/state_views.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>>? items;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final userId = context.read<Session>().userId!;
      final result = await context.read<PbRepository>().list(
            'favorites',
            perPage: 100,
            sort: '-created',
            filter: 'user="$userId" && deleted=false',
            expand: 'menu_item',
          );

      if (!mounted) return;
      setState(() {
        items = result.items;
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items == null && error == null) return const LoadingView();
    if (error != null) {
      return ErrorView(message: error!, onRetry: load);
    }

    if (items!.isEmpty) {
      return const EmptyView(
        message: 'Избранное пока пусто.',
      );
    }

    return PageFrame(
      maxWidth: 900,
      child: ListView(
        children: [
          Text(
            'Избранное',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          for (final item in items!)
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite),
                title: Text(
                  '${(item['expand'] as Map?)?['menu_item']?['name'] ?? 'Позиция меню'}',
                ),
                trailing: IconButton(
                  tooltip: 'Удалить',
                  onPressed: () async {
                    await context.read<PbRepository>().delete(
                          'favorites',
                          '${item['id']}',
                        );
                    load();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
