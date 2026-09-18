import 'package:flutter/material.dart';

import '../domain/drink_builder.dart';
import '../widgets/page_frame.dart';

class DrinkCalculatorScreen extends StatefulWidget {
  const DrinkCalculatorScreen({super.key});

  @override
  State<DrinkCalculatorScreen> createState() =>
      _DrinkCalculatorScreenState();
}

class _DrinkCalculatorScreenState extends State<DrinkCalculatorScreen> {
  final basePrice = TextEditingController(text: '250');
  DrinkSize size = DrinkSize.medium;
  bool altMilk = false;
  bool extraEspresso = false;
  int syrupShots = 0;

  @override
  void dispose() {
    basePrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = DrinkBuilder.calculate(
      basePrice: double.tryParse(basePrice.text) ?? 0,
      size: size,
      alternativeMilk: altMilk,
      syrupShots: syrupShots,
      extraEspresso: extraEspresso,
    );

    return PageFrame(
      maxWidth: 720,
      child: ListView(
        children: [
          Text(
            'Конструктор напитка',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Содержательная особенность проекта: расчёт объёма, количества эспрессо и стоимости напитка с добавками.',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: basePrice,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Базовая цена',
              suffixText: '₽',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<DrinkSize>(
            segments: const [
              ButtonSegment(
                value: DrinkSize.small,
                label: Text('S'),
              ),
              ButtonSegment(
                value: DrinkSize.medium,
                label: Text('M'),
              ),
              ButtonSegment(
                value: DrinkSize.large,
                label: Text('L'),
              ),
            ],
            selected: {size},
            onSelectionChanged: (value) {
              setState(() => size = value.first);
            },
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: altMilk,
            title: const Text('Альтернативное молоко'),
            subtitle: const Text('+60 ₽'),
            onChanged: (value) => setState(() => altMilk = value),
          ),
          SwitchListTile(
            value: extraEspresso,
            title: const Text('Дополнительный шот эспрессо'),
            subtitle: const Text('+70 ₽'),
            onChanged: (value) =>
                setState(() => extraEspresso = value),
          ),
          ListTile(
            title: const Text('Сироп'),
            subtitle: Text('$syrupShots порц. × 25 ₽'),
            trailing: Wrap(
              children: [
                IconButton(
                  onPressed: syrupShots > 0
                      ? () => setState(() => syrupShots--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: syrupShots < 5
                      ? () => setState(() => syrupShots++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Объём: ${result.volumeMl} мл'),
                  Text(
                    'Шотов эспрессо: ${result.espressoShots}',
                  ),
                  Text(
                    'Добавки: ${result.extrasPrice.toStringAsFixed(2)} ₽',
                  ),
                  const Divider(),
                  Text(
                    'Итого: ${result.total.toStringAsFixed(2)} ₽',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
