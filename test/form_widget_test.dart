import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key});

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Пароль'),
                validator: (value) {
                  if ((value ?? '').length < 8) {
                    return 'Минимум 8 символов';
                  }
                  return null;
                },
              ),
              TextButton(
                onPressed: () =>
                    key.currentState!.validate(),
                child: const Text('Проверить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'форма показывает ошибку короткого пароля',
    (tester) async {
      await tester.pumpWidget(const PasswordForm());
      await tester.enterText(
        find.byType(TextFormField),
        '123',
      );
      await tester.tap(find.text('Проверить'));
      await tester.pump();

      expect(
        find.text('Минимум 8 символов'),
        findsOneWidget,
      );
    },
  );
}
