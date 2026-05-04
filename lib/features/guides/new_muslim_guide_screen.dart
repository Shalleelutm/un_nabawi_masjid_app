import 'package:flutter/material.dart';

class NewMuslimGuideScreen extends StatefulWidget {
  const NewMuslimGuideScreen({super.key});

  @override
  State<NewMuslimGuideScreen> createState() => _NewMuslimGuideScreenState();
}

class _NewMuslimGuideScreenState extends State<NewMuslimGuideScreen> {
  int _selectedSection = 0;
  final List<String> _sections = ['5 Pillars', 'Prayer Guide', 'Wudu Guide', '99 Names', 'Daily Duas', 'Islamic Terms', 'Quiz'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Muslim Guide'),
        backgroundColor: Colors.green.shade700,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_sections[index]),
                    selected: _selectedSection == index,
                    onSelected: (_) => setState(() => _selectedSection = index),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.amber,
                    labelStyle: TextStyle(color: _selectedSection == index ? Colors.black : Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedSection,
        children: [
          _buildFivePillars(),
          _buildPrayerGuide(),
          _buildWuduGuide(),
          _buildNinetyNineNames(),
          _buildDailyDuas(),
          _buildIslamicTerms(),
          _buildQuizSection(),
        ],
      ),
    );
  }

  Widget _buildFivePillars() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPillarCard('🕌 Shahada', 'Declaration of Faith', 'La ilaha illallah, Muhammadur Rasulullah', 'There is no god but Allah, and Muhammad is the Messenger of Allah'),
        _buildPillarCard('🕋 Salah', 'Prayer 5 times daily', 'Fajr, Dhuhr, Asr, Maghrib, Isha', 'Connect with Allah throughout the day'),
        _buildPillarCard('💰 Zakat', 'Charity', '2.5% of savings', 'Purify your wealth by giving to those in need'),
        _buildPillarCard('🌙 Sawm', 'Fasting in Ramadan', 'Dawn to sunset', 'Develop self-discipline and empathy'),
        _buildPillarCard('🕋 Hajj', 'Pilgrimage to Mecca', 'Once in a lifetime', 'Journey of a lifetime to the House of Allah'),
      ],
    );
  }

  Widget _buildPillarCard(String icon, String title, String subtitle, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: ExpansionTile(
        leading: Text(icon, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(description, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerGuide() {
    final prayers = [
      {'name': 'Fajr', 'rakats': '2 Sunnah + 2 Fard', 'time': 'Before sunrise'},
      {'name': 'Dhuhr', 'rakats': '4 Sunnah + 4 Fard + 2 Sunnah', 'time': 'After noon'},
      {'name': 'Asr', 'rakats': '4 Fard', 'time': 'Late afternoon'},
      {'name': 'Maghrib', 'rakats': '3 Fard + 2 Sunnah', 'time': 'Just after sunset'},
      {'name': 'Isha', 'rakats': '4 Fard + 2 Sunnah + 3 Witr', 'time': 'Night'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final p = prayers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: Text(p['name']![0], style: const TextStyle(fontWeight: FontWeight.bold))),
            title: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${p['rakats']} - ${p['time']}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrayerDetails(p['name']!, p['rakats']!, p['time']!),
          ),
        );
      },
    );
  }

  void _showPrayerDetails(String name, String rakats, String time) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$name Prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🕋 Rakats: $rakats', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('⏰ Time: $time'),
            const SizedBox(height: 12),
            const Divider(),
            const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('1. Make Niyyah (intention)\n2. Takbiratul Ihram\n3. Recite Al-Fatihah\n4. Ruku\'\n5. Sujud\n6. Tashahhud\n7. Taslim'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(_), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildWuduGuide() {
    final steps = [
      {'step': '1', 'title': 'Make Niyyah', 'desc': 'Intention to perform wudu for Allah'},
      {'step': '2', 'title': 'Wash Hands', 'desc': 'Wash both hands up to wrists (3 times)'},
      {'step': '3', 'title': 'Rinse Mouth', 'desc': 'Rinse mouth thoroughly (3 times)'},
      {'step': '4', 'title': 'Clean Nose', 'desc': 'Sniff water into nostrils (3 times)'},
      {'step': '5', 'title': 'Wash Face', 'desc': 'From hairline to chin, ear to ear (3 times)'},
      {'step': '6', 'title': 'Wash Arms', 'desc': 'Right then left, up to elbows (3 times)'},
      {'step': '7', 'title': 'Wipe Head', 'desc': 'Wipe head and ears once'},
      {'step': '8', 'title': 'Wash Feet', 'desc': 'Right then left, up to ankles (3 times)'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final s = steps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(s['step']!), backgroundColor: Colors.blue.shade100),
            title: Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s['desc']!),
          ),
        );
      },
    );
  }

  Widget _buildNinetyNineNames() {
    final names = [
      {'arabic': 'الرَّحْمَـٰنُ', 'english': 'Ar-Rahman', 'meaning': 'The Most Gracious'},
      {'arabic': 'الرَّحِيمُ', 'english': 'Ar-Raheem', 'meaning': 'The Most Merciful'},
      {'arabic': 'الْمَلِكُ', 'english': 'Al-Malik', 'meaning': 'The Sovereign'},
      {'arabic': 'الْقُدُّوسُ', 'english': 'Al-Quddus', 'meaning': 'The Holy'},
      {'arabic': 'السَّلاَمُ', 'english': 'As-Salam', 'meaning': 'The Source of Peace'},
      {'arabic': 'الْمُؤْمِنُ', 'english': 'Al-Mu\'min', 'meaning': 'The Guardian of Faith'},
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final n = names[index];
        return Card(
          margin: const EdgeInsets.all(6),
          child: InkWell(
            onTap: () => _showNameMeaning(n['english']!, n['arabic']!, n['meaning']!),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(n['arabic']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(n['english']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNameMeaning(String english, String arabic, String meaning) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(english),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(arabic, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            Text(meaning, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(_), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDailyDuas() {
    final duas = [
      {'title': '😴 Before Sleeping', 'arabic': 'Allahumma bismika amutu wa ahya', 'meaning': 'O Allah, with Your name I die and live'},
      {'title': '🌅 After Waking Up', 'arabic': 'Alhamdulillah alladhi ahyana ba\'da ma amatana', 'meaning': 'All praise to Allah who gave us life after death'},
      {'title': '🕌 Entering Mosque', 'arabic': 'Allahumma iftah li abwaba rahmatik', 'meaning': 'O Allah, open for me the doors of Your mercy'},
      {'title': '🍽️ Before Eating', 'arabic': 'Bismillahi wa barakatillah', 'meaning': 'In the name of Allah and with His blessings'},
      {'title': '🏠 Entering Home', 'arabic': 'Allahumma inni as\'aluka khayral maulij', 'meaning': 'O Allah, I ask for the best entry and best exit'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final d = duas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Text(d['title']!.substring(0, 2), style: const TextStyle(fontSize: 24)),
            title: Text(d['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(d['arabic']!, style: const TextStyle(fontSize: 18, fontFamily: 'monospace')),
                    const SizedBox(height: 8),
                    Text(d['meaning']!, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIslamicTerms() {
    final terms = [
      {'term': 'Halal', 'meaning': 'Permissible in Islam'},
      {'term': 'Haram', 'meaning': 'Forbidden in Islam'},
      {'term': 'Sunnah', 'meaning': 'Practices of Prophet Muhammad (PBUH)'},
      {'term': 'Hadith', 'meaning': 'Sayings of Prophet Muhammad (PBUH)'},
      {'term': 'Fatwa', 'meaning': 'Islamic legal ruling'},
      {'term': 'Imam', 'meaning': 'Prayer leader'},
      {'term': 'Jannah', 'meaning': 'Paradise'},
      {'term': 'Jahannam', 'meaning': 'Hellfire'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final t = terms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(t['term']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(t['meaning']!),
            trailing: const Icon(Icons.help_outline),
          ),
        );
      },
    );
  }

  Widget _buildQuizSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text('Islamic Knowledge Quiz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Test your understanding of Islam', textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _startQuiz(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: const Text('More quiz questions will be added in future updates. Stay tuned!'),
        actions: [TextButton(onPressed: () => Navigator.pop(_), child: const Text('OK'))],
      ),
    );
  }
}