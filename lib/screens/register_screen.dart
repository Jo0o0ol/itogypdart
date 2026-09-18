import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../repositories/auth_repository.dart';
import '../widgets/page_frame.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  String? passwordValidator(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Минимум 8 символов';
    if (!RegExp(r'\d').hasMatch(text)) {
      return 'Добавьте хотя бы одну цифру';
    }
    if (!RegExp(r'[^A-Za-zА-Яа-я0-9]').hasMatch(text)) {
      return 'Добавьте специальный символ';
    }
    return null;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await context.read<AuthRepository>().register(
            email: email.text.trim(),
            password: password.text,
            fullName: name.text.trim(),
          );

      if (!mounted) return;
      context.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: PageFrame(
          maxWidth: 520,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Регистрация посетителя',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().length < 2
                                ? 'Укажите имя'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Некорректный e-mail'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          helperText:
                              '8+ символов, цифра и специальный символ',
                          border: OutlineInputBorder(),
                        ),
                        validator: passwordValidator,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(error!, textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: loading ? null : submit,
                        child: const Text('Зарегистрироваться'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('У меня уже есть аккаунт'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
