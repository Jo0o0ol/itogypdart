import 'package:flutter/material.dart';
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child, this.maxWidth = 1280});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: Padding(padding: const EdgeInsets.all(20), child: child)));
}
