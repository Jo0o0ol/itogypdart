import 'package:coffee_house_final/core/roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RolePanel extends StatelessWidget {
  const RolePanel({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Text('Меню'),
            if (Permissions.canReserve(role))
              const Text('Бронирование столика'),
            if (Permissions.canProcessOrders(role))
              const Text('Рабочее место бариста'),
            if (Permissions.canManageUsers(role))
              const Text('Управление пользователями'),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'у посетителя видно бронирование и скрыта админка',
    (tester) async {
      await tester.pumpWidget(
        const RolePanel(role: AppRole.customer),
      );

      expect(
        find.text('Бронирование столика'),
        findsOneWidget,
      );
      expect(
        find.text('Управление пользователями'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'бариста видит рабочее место',
    (tester) async {
      await tester.pumpWidget(
        const RolePanel(role: AppRole.barista),
      );

      expect(
        find.text('Рабочее место бариста'),
        findsOneWidget,
      );
      expect(
        find.text('Бронирование столика'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'администратор видит управление пользователями',
    (tester) async {
      await tester.pumpWidget(
        const RolePanel(role: AppRole.admin),
      );

      expect(
        find.text('Управление пользователями'),
        findsOneWidget,
      );
    },
  );
}
