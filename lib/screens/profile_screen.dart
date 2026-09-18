import 'package:coffee_house_final/core/roles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/session.dart';
import '../repositories/auth_repository.dart';
import '../repositories/pb_repository.dart';
import '../widgets/page_frame.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nickname = TextEditingController();
  final favoriteDrink = TextEditingController();
  String? profileId;
  String? message;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nickname.dispose();
    favoriteDrink.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final userId = context.read<Session>().userId!;

    try {
      final result = await context.read<PbRepository>().list(
            'user_profiles',
            perPage: 1,
            filter: 'user="$userId"',
          );

      if (result.items.isNotEmpty) {
        final profile = result.items.first;
        profileId = '${profile['id']}';
        nickname.text = '${profile['nickname'] ?? ''}';
        favoriteDrink.text =
            '${profile['favorite_drink'] ?? ''}';
      }
    } catch (_) {}

    if (mounted) setState(() => loaded = true);
  }

  Future<void> save() async {
    final repo = context.read<PbRepository>();
    final data = {
      'user': context.read<Session>().userId,
      'nickname': nickname.text.trim(),
      'favorite_drink': favoriteDrink.text.trim(),
    };

    try {
      if (profileId == null) {
        final record =
            await repo.create('user_profiles', data);
        profileId = '${record['id']}';
      } else {
        await repo.update('user_profiles', profileId!, data);
      }

      setState(() => message = 'Профиль сохранён.');
    } on ApiException catch (e) {
      setState(() => message = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();

    return PageFrame(
      maxWidth: 650,
      child: !loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  'Профиль',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text('${session.fullName} · ${session.email}'),
                Text('Роль: ${session.role.title}'),
                const SizedBox(height: 18),
                TextField(
                  controller: nickname,
                  decoration: const InputDecoration(
                    labelText: 'Имя в кофейне',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: favoriteDrink,
                  decoration: const InputDecoration(
                    labelText: 'Любимый напиток',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: save,
                  child: const Text('Сохранить профиль'),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Divider(height: 28),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AuthRepository>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                ),
              ],
            ),
    );
  }
}
