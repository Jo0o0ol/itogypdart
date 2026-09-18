import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/menu_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/pb_repository.dart';
import 'router.dart';
import 'state/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final services = await AppServices.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: services.session),
        ChangeNotifierProvider(create: (_) => CartController()),
        Provider<AuthRepository>.value(value: services.auth),
        Provider<PbRepository>.value(value: services.pb),
        Provider<MenuRepository>.value(value: services.menu),
        Provider<OrderRepository>.value(value: services.orders),
        Provider<AnalyticsRepository>.value(value: services.analytics),
      ],
      child: CoffeeHouseApp(services: services),
    ),
  );
}

class CoffeeHouseApp extends StatefulWidget {
  const CoffeeHouseApp({
    super.key,
    required this.services,
  });

  final AppServices services;

  @override
  State<CoffeeHouseApp> createState() => _CoffeeHouseAppState();
}

class _CoffeeHouseAppState extends State<CoffeeHouseApp> {
  late final router = buildRouter(widget.services);

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7A4E32),
      brightness: Brightness.light,
    );

    return MaterialApp.router(
      title: 'BeanHouse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF8F3ED),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 1,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFBF7),
        ),
      ),
      routerConfig: router,
    );
  }
}
