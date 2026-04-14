import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/prayer_provider.dart';
import '../../services/prayer_time_service.dart';
import '../../widgets/kaaba_loader.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late DateTime _selectedMonth;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().load();
    });
  }

  Future<void> _pickMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(_selectedMonth.year - 2, 1, 1),
      lastDate: DateTime(_selectedMonth.year + 2, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (result == null) return;

    setState(() {
      _selectedMonth = DateTime(result.year, result.month, 1);
      _selectedDay = result.day;
    });
  }

  Widget _monthHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _selectedMonth.year && now.month == _selectedMonth.month;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _pickMonth,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_selectedDay != null)
                      Text(
                        'Selected day: ${_selectedDay.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (isCurrentMonth)
                      Text(
                        'Today: ${DateFormat('EEEE, dd MMM yyyy').format(now)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: _pickMonth,
                child: const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _forbiddenRow(String title, String range) {
    if (range.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$title: $range',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _dayCard(PrayerDay p) {
    final isToday = DateUtils.isSameDay(p.date, DateTime.now());
    final isSelected = _selectedDay != null && p.date.day == _selectedDay;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: isToday || isSelected ? 2 : 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : isToday
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      '${p.date.day}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, dd MMM yyyy').format(p.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Prayer',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Adhan',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Iqama',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                _tableRow('Fajr', p.fajrAdhan, p.fajrIqama),
                _tableRow('Dhuhr', p.zohrAdhan, p.zohrIqama),
                _tableRow('Asr', p.asrAdhan, p.asrIqama),
                _tableRow('Maghrib', p.maghribAdhan, p.maghribIqama),
                _tableRow('Isha', p.eshaAdhan, p.eshaIqama),
                if (p.sehriLast.trim().isNotEmpty)
                  _tableRow('Sehri Ends', p.sehriLast, '-'),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _forbiddenRow('Sunrise forbidden', p.forbiddenSunrise),
                  _forbiddenRow('Zawwaal forbidden', p.forbiddenZawwaal),
                  _forbiddenRow('Sunset forbidden', p.forbiddenSunset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _tableRow(String name, String adhan, String iqama) {
    const pad = EdgeInsets.symmetric(vertical: 6);
    return TableRow(
      children: [
        Padding(
          padding: pad,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(padding: pad, child: Text(adhan)),
        Padding(padding: pad, child: Text(iqama)),
      ],
    );
  }

  List<PrayerDay> _sortedMonthRows(List<PrayerDay> monthRows) {
    if (monthRows.isEmpty) return monthRows;

    if (_selectedDay != null) {
      final selectedIndex =
          monthRows.indexWhere((row) => row.date.day == _selectedDay);
      if (selectedIndex > 0) {
        return [
          ...monthRows.sublist(selectedIndex),
          ...monthRows.sublist(0, selectedIndex),
        ];
      }
    }

    final now = DateTime.now();
    final isCurrentMonth =
        now.year == _selectedMonth.year && now.month == _selectedMonth.month;

    if (!isCurrentMonth) return monthRows;

    final todayIndex = monthRows.indexWhere(
      (row) => DateUtils.isSameDay(row.date, now),
    );

    if (todayIndex <= 0) return monthRows;

    return [
      ...monthRows.sublist(todayIndex),
      ...monthRows.sublist(0, todayIndex),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return Scaffold(
            body: Center(
              child: KaabaLoader(
                size: 110,
                message: 'Patience comes from Allah. Please wait...',
              ),
            ),
          );
        }

        final monthRows =
            provider.month(_selectedMonth.year, _selectedMonth.month);
        final sortedRows = _sortedMonthRows(monthRows);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prayer Times'),
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<PrayerProvider>().reloadAndResync(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _monthHeader(context),
              const SizedBox(height: 12),
              if (sortedRows.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No prayer timetable found for this month.'),
                  ),
                )
              else
                ...sortedRows.map(_dayCard),
            ],
          ),
        );
      },
    );
  }
}