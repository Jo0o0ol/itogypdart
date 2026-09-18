import 'package:flutter/material.dart';
class LoadingView extends StatelessWidget { const LoadingView({super.key}); @override Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())); }
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = 'Ничего не найдено.'}); final String message;
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.inventory_2_outlined, size: 52), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center)])));
}
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry}); final String message; final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_off_outlined, size: 52, color: Theme.of(context).colorScheme.error), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Повторить'))])));
}
