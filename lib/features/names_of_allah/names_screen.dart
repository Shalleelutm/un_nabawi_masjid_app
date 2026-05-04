import 'package:flutter/material.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _allNames = const [
    {'ar': 'الله', 'en': 'Allah', 'meaning': 'The God', 'transliteration': 'Allah'},
    {'ar': 'الرحمن', 'en': 'Ar-Rahman', 'meaning': 'The Most Gracious', 'transliteration': 'The Beneficent'},
    {'ar': 'الرحيم', 'en': 'Ar-Raheem', 'meaning': 'The Most Merciful', 'transliteration': 'The Merciful'},
    {'ar': 'الملك', 'en': 'Al-Malik', 'meaning': 'The Sovereign', 'transliteration': 'The King'},
    {'ar': 'القدوس', 'en': 'Al-Quddus', 'meaning': 'The Holy', 'transliteration': 'The Pure'},
    {'ar': 'السلام', 'en': 'As-Salam', 'meaning': 'The Source of Peace', 'transliteration': 'The Peace'},
    {'ar': 'المؤمن', 'en': 'Al-Mu\'min', 'meaning': 'The Guardian of Faith', 'transliteration': 'The Faithful'},
    {'ar': 'المهيمن', 'en': 'Al-Muhaymin', 'meaning': 'The Protector', 'transliteration': 'The Guardian'},
    {'ar': 'العزيز', 'en': 'Al-Aziz', 'meaning': 'The Almighty', 'transliteration': 'The Mighty'},
    {'ar': 'الجبار', 'en': 'Al-Jabbar', 'meaning': 'The Compeller', 'transliteration': 'The Irresistible'},
    {'ar': 'المتكبر', 'en': 'Al-Mutakabbir', 'meaning': 'The Supreme', 'transliteration': 'The Proud'},
    {'ar': 'الخالق', 'en': 'Al-Khaliq', 'meaning': 'The Creator', 'transliteration': 'The Creator'},
    {'ar': 'البارئ', 'en': 'Al-Bari', 'meaning': 'The Evolver', 'transliteration': 'The Maker'},
    {'ar': 'المصور', 'en': 'Al-Musawwir', 'meaning': 'The Fashioner', 'transliteration': 'The Shaper'},
    {'ar': 'الغفار', 'en': 'Al-Ghaffar', 'meaning': 'The Forgiver', 'transliteration': 'The Forgiving'},
    {'ar': 'القهار', 'en': 'Al-Qahhar', 'meaning': 'The Subduer', 'transliteration': 'The Dominant'},
    {'ar': 'الوهاب', 'en': 'Al-Wahhab', 'meaning': 'The Bestower', 'transliteration': 'The Giver'},
    {'ar': 'الرزاق', 'en': 'Ar-Razzaq', 'meaning': 'The Provider', 'transliteration': 'The Sustainer'},
    {'ar': 'الفتاح', 'en': 'Al-Fattah', 'meaning': 'The Opener', 'transliteration': 'The Judge'},
    {'ar': 'العليم', 'en': 'Al-Alim', 'meaning': 'The All-Knowing', 'transliteration': 'The Knower'},
  ];

  List<Map<String, String>> get _filteredNames {
    if (_searchQuery.isEmpty) return _allNames;
    return _allNames.where((name) {
      return name['en']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          name['ar']!.contains(_searchQuery) ||
          name['meaning']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showNameDetails(Map<String, String> name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name['ar']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(name['en']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green)),
            const SizedBox(height: 12),
            Text(name['meaning']!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(name['transliteration']!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
        backgroundColor: Colors.green.shade700,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or meaning...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final name = filtered[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () => _showNameDetails(name),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name['ar']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(name['en']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(name['meaning']!, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}