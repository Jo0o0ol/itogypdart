import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/session.dart';
import '../models/entities.dart';
import '../repositories/pb_repository.dart';
import '../widgets/page_frame.dart';
import '../widgets/state_views.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<CafeTable> tables = [];
  List<Map<String, dynamic>>? reservations;
  String? selectedTableId;
  DateTime selectedAt = DateTime.now().add(const Duration(hours: 1));
  int durationMin = 90;
  int guests = 2;
  String? error;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final repo = context.read<PbRepository>();
      final userId = context.read<Session>().userId!;

      final tablesResult = await repo.list(
        'cafe_tables',
        perPage: 100,
        sort: 'code',
        filter: 'active=true && deleted=false',
      );

      final reservationResult = await repo.list(
        'reservations',
        perPage: 100,
        sort: '-reserved_at',
        filter: 'user="$userId" && deleted=false',
        expand: 'table',
      );

      if (!mounted) return;
      setState(() {
        tables = tablesResult.items.map(CafeTable.fromJson).toList();
        reservations = reservationResult.items;
        selectedTableId ??= tables.isEmpty ? null : tables.first.id;
        error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: selectedAt,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedAt),
    );

    if (time == null) return;

    setState(() {
      selectedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<bool> hasConflict() async {
    if (selectedTableId == null) return true;

    final startWindow = selectedAt.subtract(const Duration(hours: 4));
    final endWindow = selectedAt.add(const Duration(hours: 4));

    String iso(DateTime value) =>
        value.toUtc().toIso8601String().replaceFirst('T', ' ');

    final result = await context.read<PbRepository>().list(
          'reservations',
          perPage: 100,
          filter:
              'table="$selectedTableId" && status!="cancelled" && deleted=false && reserved_at>="${iso(startWindow)}" && reserved_at<="${iso(endWindow)}"',
        );

    final newStart = selectedAt;
    final newEnd = selectedAt.add(Duration(minutes: durationMin));

    for (final record in result.items) {
      final existingStart =
          DateTime.tryParse('${record['reserved_at']}')?.toLocal();
      final existingDuration =
          (record['duration_min'] as num?)?.toInt() ?? 90;

      if (existingStart == null) continue;

      final existingEnd =
          existingStart.add(Duration(minutes: existingDuration));

      if (newStart.isBefore(existingEnd) &&
          newEnd.isAfter(existingStart)) {
        return true;
      }
    }

    return false;
  }

  Future<void> createReservation() async {
    if (selectedTableId == null) return;

    final table = tables.firstWhere((t) => t.id == selectedTableId);
    if (guests > table.seats) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Столик рассчитан максимум на ${table.seats} чел.',
          ),
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      if (await hasConflict()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'На выбранное время столик уже занят.',
            ),
          ),
        );
        return;
      }

      await context.read<PbRepository>().create(
        'reservations',
        {
          'user': context.read<Session>().userId,
          'table': selectedTableId,
          'reserved_at':
              selectedAt.toUtc().toIso8601String().replaceFirst('T', ' '),
          'duration_min': durationMin,
          'guests': guests,
          'status': 'confirmed',
          'deleted': false,
        },
      );

      await load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Столик забронирован.'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reservations == null && error == null) {
      return const LoadingView();
    }

    if (error != null) {
      return ErrorView(message: error!, onRetry: load);
    }

    return PageFrame(
      maxWidth: 900,
      child: ListView(
        children: [
          Text(
            'Бронирование столика',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedTableId,
                    decoration: const InputDecoration(
                      labelText: 'Столик',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final table in tables)
                        DropdownMenuItem(
                          value: table.id,
                          child: Text(
                            '${table.code} · ${table.zone} · ${table.seats} мест',
                          ),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedTableId = value),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Дата и время'),
                    subtitle: Text(
                      '${selectedAt.day.toString().padLeft(2, '0')}.'
                      '${selectedAt.month.toString().padLeft(2, '0')}.'
                      '${selectedAt.year} '
                      '${selectedAt.hour.toString().padLeft(2, '0')}:'
                      '${selectedAt.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      onPressed: pickDateTime,
                      icon: const Icon(Icons.event),
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    value: durationMin,
                    decoration: const InputDecoration(
                      labelText: 'Длительность',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 60, child: Text('1 час')),
                      DropdownMenuItem(value: 90, child: Text('1,5 часа')),
                      DropdownMenuItem(value: 120, child: Text('2 часа')),
                    ],
                    onChanged: (value) =>
                        setState(() => durationMin = value ?? 90),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: guests,
                    decoration: const InputDecoration(
                      labelText: 'Количество гостей',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var i = 1; i <= 8; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text('$i'),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => guests = value ?? 2),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: saving || tables.isEmpty
                        ? null
                        : createReservation,
                    icon: const Icon(Icons.table_restaurant),
                    label: const Text('Забронировать'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Мои бронирования',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (reservations!.isEmpty)
            const EmptyView(
              message: 'Бронирований пока нет.',
            )
          else
            for (final reservation in reservations!)
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.table_restaurant_outlined),
                  title: Text(
                    'Столик ${(reservation['expand'] as Map?)?['table']?['code'] ?? ''}',
                  ),
                  subtitle: Text(
                    '${reservation['reserved_at']} · '
                    '${reservation['guests']} гост. · '
                    '${reservation['status']}',
                  ),
                  trailing: reservation['status'] == 'cancelled'
                      ? null
                      : TextButton(
                          onPressed: () async {
                            await context
                                .read<PbRepository>()
                                .update(
                              'reservations',
                              '${reservation['id']}',
                              {'status': 'cancelled'},
                            );
                            load();
                          },
                          child: const Text('Отменить'),
                        ),
                ),
              ),
        ],
      ),
    );
  }
}
