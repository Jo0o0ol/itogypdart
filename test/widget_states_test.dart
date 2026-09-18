import 'package:coffee_house_final/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loading показывает индикатор', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingView()),
      ),
    );

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );
  });

  testWidgets('empty показывает заданное сообщение', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyView(message: 'Меню пусто'),
        ),
      ),
    );

    expect(find.text('Меню пусто'), findsOneWidget);
  });

  testWidgets('error показывает кнопку повторения', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Сервер недоступен',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.text('Повторить'), findsOneWidget);
  });
}
