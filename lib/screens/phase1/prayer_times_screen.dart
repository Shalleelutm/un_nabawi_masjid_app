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
  String _searchQuery = '';
  String _selectedPrayer = 'All';

  final List<String> _prayerFilters = ['All', 'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

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

  void _scrollToToday() {
    setState(() => _selectedDay = DateTime.now().day);
  }

  Widget _monthHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedMonth.year && now.month == _selectedMonth.month;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _pickMonth,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer]), borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.calendar_month_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMMM yyyy').format(_selectedMonth), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        if (_selectedDay != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                            child: Text('Day ${_selectedDay.toString().padLeft(2, '0')}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSecondaryContainer)),
                          )
                        else if (isCurrentMonth)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                            child: Text('Today: ${DateFormat('dd MMM').format(now)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onPrimaryContainer)),
                          ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(onPressed: _pickMonth, child: const Text('Change')),
                ],
              ),
              const SizedBox(height: 16),
              Hero(
                tag: 'search_bar',
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search prayer times...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _searchQuery = '')) : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _prayerFilters.map((prayer) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(prayer),
                      selected: _selectedPrayer == prayer,
                      onSelected: (selected) => setState(() => _selectedPrayer = prayer),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(color: _selectedPrayer == prayer ? Theme.of(context).colorScheme.onPrimary : null),
                    ),
                  )).toList(),
                ),
              ),
              if (isCurrentMonth) const SizedBox(height: 12),
              if (isCurrentMonth)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _scrollToToday,
                    icon: const Icon(Icons.today),
                    label: const Text('Jump to Today'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
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
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Expanded(child: Text('$title: $range', style: const TextStyle(fontSize: 12, color: Colors.orange))),
        ],
      ),
    );
  }

  Widget _buildDuaCard(String title, String arabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(arabic, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
        ],
      ),
    );
  }

  Widget _prayerGuideSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.secondaryContainer]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Prayer Guide', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRakatInfo('Sunnah', '2', Colors.green),
                _buildRakatInfo('Fard', '2', Colors.blue),
                _buildRakatInfo('Witr', '3', Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _guideButton(context, icon: Icons.mosque, label: 'How to Pray', color: Colors.teal, onTap: () => _navigateToGuide(context, 'prayer'))),
              const SizedBox(width: 12),
              Expanded(child: _guideButton(context, icon: Icons.water_drop, label: 'Wudu Guide', color: Colors.cyan, onTap: () => _navigateToGuide(context, 'wudu'))),
              const SizedBox(width: 12),
              Expanded(child: _guideButton(context, icon: Icons.timer, label: 'Du\'as', color: Colors.orange, onTap: () => _navigateToGuide(context, 'duas'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRakatInfo(String name, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
          child: Text('$count Rak\'ah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _guideButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGuide(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type == 'prayer' ? 'How to Perform Prayer' : type == 'wudu' ? 'Steps of Wudu' : 'Daily Du\'as', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          if (type == 'prayer') ...[
                            _buildGuideStep('1', 'Make Niyyah (Intention)', 'Set your intention to pray for Allah'),
                            _buildGuideStep('2', 'Takbiratul Ihram', 'Say "Allahu Akbar" to begin'),
                            _buildGuideStep('3', 'Recite Al-Fatihah', 'Recite Surah Al-Fatihah and another surah'),
                            _buildGuideStep('4', 'Ruku\'', 'Bow down with hands on knees'),
                            _buildGuideStep('5', 'Sujud', 'Prostrate with forehead, nose, hands, knees touching ground'),
                            _buildGuideStep('6', 'Tashahhud', 'Sit and recite the testimony'),
                            _buildGuideStep('7', 'Taslim', 'Turn head right and left saying "Assalamu alaikum"'),
                          ] else if (type == 'wudu') ...[
                            _buildGuideStep('1', 'Niyyah', 'Make intention for wudu'),
                            _buildGuideStep('2', 'Wash Hands', 'Wash both hands up to wrists (3 times)'),
                            _buildGuideStep('3', 'Rinse Mouth', 'Rinse mouth thoroughly (3 times)'),
                            _buildGuideStep('4', 'Clean Nose', 'Sniff water into nostrils (3 times)'),
                            _buildGuideStep('5', 'Wash Face', 'Wash face from hairline to chin (3 times)'),
                            _buildGuideStep('6', 'Wash Arms', 'Wash right then left arm up to elbows (3 times)'),
                            _buildGuideStep('7', 'Wipe Head', 'Wipe head and ears once'),
                            _buildGuideStep('8', 'Wash Feet', 'Wash right then left foot up to ankles (3 times)'),
                          ] else ...[
                            _buildDuasList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle), child: Center(child: Text(number, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuasList() {
    final duas = [
      '🤲 Dua before sleeping',
      '🌅 Dua after waking up',
      '🕌 Dua for entering mosque',
      '🚶 Dua for leaving mosque',
      '👨‍👩‍👧 Dua for parents',
      '🍽️ Dua before eating',
      '🙏 Dua after eating',
      '🏠 Dua for entering home',
      '🚪 Dua for leaving home',
    ];
    return Column(
      children: duas.map((dua) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
          child: Text(dua, style: const TextStyle(fontSize: 14)),
        ),
      )).toList(),
    );
  }

  Widget _dayCard(PrayerDay p) {
    final isToday = DateUtils.isSameDay(p.date, DateTime.now());
    final isSelected = _selectedDay != null && p.date.day == _selectedDay;
    final matchesSearch = _searchQuery.isEmpty || p.fajrAdhan.toLowerCase().contains(_searchQuery) || p.zohrAdhan.toLowerCase().contains(_searchQuery) || p.asrAdhan.toLowerCase().contains(_searchQuery) || p.maghribAdhan.toLowerCase().contains(_searchQuery) || p.eshaAdhan.toLowerCase().contains(_searchQuery);
    if (!matchesSearch) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: isToday || isSelected ? 6 : 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: isSelected ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 2) : null),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: isSelected ? LinearGradient(colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondaryContainer]) : isToday ? LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer]) : null,
                      color: !isSelected && !isToday ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${p.date.day}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isSelected || isToday ? Theme.of(context).colorScheme.onPrimary : null)),
                          Text(DateFormat('MMM').format(p.date), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected || isToday ? Theme.of(context).colorScheme.onPrimary : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE').format(p.date), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(DateFormat('dd MMM yyyy').format(p.date), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Theme.of(context).colorScheme.secondary), child: Text('Selected', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w700, fontSize: 12)))
                  else if (isToday)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Theme.of(context).colorScheme.primary), child: Text('Today', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700, fontSize: 12))),
                ],
              ),
              const SizedBox(height: 14),
              Table(
                columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
                children: [
                  const TableRow(children: [Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Prayer', style: TextStyle(fontWeight: FontWeight.w800))), Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Adhan', style: TextStyle(fontWeight: FontWeight.w800))), Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Iqama', style: TextStyle(fontWeight: FontWeight.w800)))]),
                  if (_selectedPrayer == 'All' || _selectedPrayer == 'Fajr') _tableRow('Fajr', p.fajrAdhan, p.fajrIqama, Colors.green),
                  if (_selectedPrayer == 'All' || _selectedPrayer == 'Dhuhr') _tableRow('Dhuhr', p.zohrAdhan, p.zohrIqama, Colors.blue),
                  if (_selectedPrayer == 'All' || _selectedPrayer == 'Asr') _tableRow('Asr', p.asrAdhan, p.asrIqama, Colors.orange),
                  if (_selectedPrayer == 'All' || _selectedPrayer == 'Maghrib') _tableRow('Maghrib', p.maghribAdhan, p.maghribIqama, Colors.red),
                  if (_selectedPrayer == 'All' || _selectedPrayer == 'Isha') _tableRow('Isha', p.eshaAdhan, p.eshaIqama, Colors.purple),
                  if (p.sehriLast.trim().isNotEmpty && _selectedPrayer == 'All') _tableRow('Sehri Ends', p.sehriLast, '-', Colors.brown),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedPrayer == 'All')
                Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _forbiddenRow('Sunrise forbidden', p.forbiddenSunrise),
                  _forbiddenRow('Zawwaal forbidden', p.forbiddenZawwaal),
                  _forbiddenRow('Sunset forbidden', p.forbiddenSunset),
                ])),
              _prayerGuideSection(context),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(String name, String adhan, String iqama, Color color) {
    const pad = EdgeInsets.symmetric(vertical: 8);
    return TableRow(children: [
      Padding(padding: pad, child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.w600))])),
      Padding(padding: pad, child: Text(adhan, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500))),
      Padding(padding: pad, child: Text(iqama, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500))),
    ]);
  }

  List<PrayerDay> _sortedMonthRows(List<PrayerDay> monthRows) {
    if (monthRows.isEmpty) return monthRows;
    if (_selectedDay != null) {
      final selectedIndex = monthRows.indexWhere((row) => row.date.day == _selectedDay);
      if (selectedIndex > 0) return [...monthRows.sublist(selectedIndex), ...monthRows.sublist(0, selectedIndex)];
    }
    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedMonth.year && now.month == _selectedMonth.month;
    if (!isCurrentMonth) return monthRows;
    final todayIndex = monthRows.indexWhere((row) => DateUtils.isSameDay(row.date, now));
    if (todayIndex <= 0) return monthRows;
    return [...monthRows.sublist(todayIndex), ...monthRows.sublist(0, todayIndex)];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return Scaffold(body: Center(child: KaabaLoader(size: 110, message: 'Loading prayer times...')));
        }

        final monthRows = provider.month(_selectedMonth.year, _selectedMonth.month);
        final sortedRows = _sortedMonthRows(monthRows);
        final filteredRows = _searchQuery.isEmpty ? sortedRows : sortedRows.where((p) => p.fajrAdhan.toLowerCase().contains(_searchQuery) || p.zohrAdhan.toLowerCase().contains(_searchQuery) || p.asrAdhan.toLowerCase().contains(_searchQuery) || p.maghribAdhan.toLowerCase().contains(_searchQuery) || p.eshaAdhan.toLowerCase().contains(_searchQuery)).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prayer Times'),
            elevation: 0,
            actions: [
              IconButton(onPressed: () => context.read<PrayerProvider>().reloadAndResync(), icon: const Icon(Icons.refresh_rounded), tooltip: 'Refresh'),
              IconButton(onPressed: () => showAboutDialog(context: context, applicationName: 'Prayer Times Pro', applicationVersion: '3.0.0', applicationIcon: const Icon(Icons.mosque, size: 40), children: const [Text('Accurate prayer times based on your location.'), SizedBox(height: 12), Text('✨ Premium Features:', style: TextStyle(fontWeight: FontWeight.bold)), Text('• Daily prayer times with Iqama'), Text('• Interactive prayer guide'), Text('• Step-by-step Wudu instructions'), Text('• Daily Du\'as collection'), Text('• Smart search and filters'), SizedBox(height: 12), Text('May Allah accept our prayers! 🤲')]), icon: const Icon(Icons.info_outline_rounded), tooltip: 'About'),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _monthHeader(context),
              const SizedBox(height: 16),
              if (filteredRows.isEmpty)
                Card(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No prayer times found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (_searchQuery.isNotEmpty) Text('for "$_searchQuery"', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(onPressed: () => setState(() { _searchQuery = ''; _selectedPrayer = 'All'; }), icon: const Icon(Icons.clear_all), label: const Text('Clear Filters')),
                ])))
              else
                ...filteredRows.map(_dayCard).toList(),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('Timings may vary slightly based on your location. Please verify locally.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic), textAlign: TextAlign.center)),
              ])),
              const SizedBox(height: 16),

              // 🔥 DUAS SECTION
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50]), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.mosque, color: Colors.purple), SizedBox(width: 8), Text('Daily Du\'as', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                    const SizedBox(height: 12),
                    _buildDuaCard('🤲 Dua before sleeping', 'Allahumma bismika amutu wa ahya'),
                    _buildDuaCard('🌅 Dua after waking up', 'Alhamdulillah alladhi ahyana ba\'da ma amatana'),
                    _buildDuaCard('🕌 Dua for entering mosque', 'Allahumma iftah li abwaba rahmatik'),
                    _buildDuaCard('🚶 Dua for leaving mosque', 'Allahumma inni as\'aluka min fadlik'),
                    _buildDuaCard('👨‍👩‍👧 Dua for parents', 'Rabbirhamhuma kama rabbayani saghira'),
                    _buildDuaCard('🍽️ Dua before eating', 'Bismillahi wa barakatillah'),
                    _buildDuaCard('🙏 Dua after eating', 'Alhamdulillah alladhi at\'amana wa saqana'),
                    _buildDuaCard('🏠 Dua for entering home', 'Allahumma inni as\'aluka khayral maulij'),
                    _buildDuaCard('🚪 Dua for leaving home', 'Bismillahi tawakkaltu alallah'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}