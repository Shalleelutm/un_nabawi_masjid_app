import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  double _totalZakat = 0;
  double _nisabGold = 0;
  double _nisabSilver = 0;
  bool _isCalculating = false;

  static const double goldPricePerGram = 4500;
  static const double silverPricePerGram = 60;
  static const int nisabGoldGrams = 87;
  static const int nisabSilverGrams = 612;

  void _calculateZakat() {
    setState(() {
      _isCalculating = true;
    });

    // Calculate Nisab values
    _nisabGold = nisabGoldGrams * goldPricePerGram;
    _nisabSilver = nisabSilverGrams * silverPricePerGram;
    final nisab = _nisabGold < _nisabSilver ? _nisabGold : _nisabSilver;

    // Calculate total wealth with null safety
    double gold = 0;
    double silver = 0;
    double cash = 0;
    double savings = 0;
    double business = 0;

    if (_goldController.text.isNotEmpty) {
      gold = double.tryParse(_goldController.text) ?? 0;
    }
    if (_silverController.text.isNotEmpty) {
      silver = double.tryParse(_silverController.text) ?? 0;
    }
    if (_cashController.text.isNotEmpty) {
      cash = double.tryParse(_cashController.text) ?? 0;
    }
    if (_savingsController.text.isNotEmpty) {
      savings = double.tryParse(_savingsController.text) ?? 0;
    }
    if (_businessController.text.isNotEmpty) {
      business = double.tryParse(_businessController.text) ?? 0;
    }

    double totalWealth = gold + silver + cash + savings + business;

    if (totalWealth >= nisab) {
      _totalZakat = totalWealth * 0.025;
    } else {
      _totalZakat = 0;
    }

    setState(() {
      _isCalculating = false;
    });
  }

  void _reset() {
    _goldController.clear();
    _silverController.clear();
    _cashController.clear();
    _savingsController.clear();
    _businessController.clear();
    setState(() {
      _totalZakat = 0;
      _nisabGold = 0;
      _nisabSilver = 0;
    });
  }

  void _shareResult() {
    if (_totalZakat == 0) return;

    final formatter = NumberFormat('#,##0.00');
    
    double gold = double.tryParse(_goldController.text) ?? 0;
    double silver = double.tryParse(_silverController.text) ?? 0;
    double cash = double.tryParse(_cashController.text) ?? 0;
    double savings = double.tryParse(_savingsController.text) ?? 0;
    double business = double.tryParse(_businessController.text) ?? 0;
    double total = gold + silver + cash + savings + business;

    Share.share(
      '📊 Zakat Calculation Result:\n\n'
      'Total Wealth: Rs ${formatter.format(total)}\n\n'
      'Zakat Due (2.5%): Rs ${formatter.format(_totalZakat)}\n\n'
      'May Allah accept your charity. 🤲',
      subject: 'My Zakat Calculation',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResult,
            tooltip: 'Share result',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.teal.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calculate, size: 50, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    'Zakat Calculator',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Calculate your Zakat accurately',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputField(_goldController, 'Gold (grams)', Icons.monetization_on, 'Enter gold weight in grams'),
                    const SizedBox(height: 12),
                    _buildInputField(_silverController, 'Silver (grams)', Icons.monetization_on, 'Enter silver weight in grams'),
                    const SizedBox(height: 12),
                    _buildInputField(_cashController, 'Cash (Rs)', Icons.attach_money, 'Enter cash amount'),
                    const SizedBox(height: 12),
                    _buildInputField(_savingsController, 'Savings (Rs)', Icons.savings, 'Enter savings amount'),
                    const SizedBox(height: 12),
                    _buildInputField(_businessController, 'Business Assets (Rs)', Icons.business, 'Enter business assets'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nisab: Gold (${nisabGoldGrams}g ~ Rs ${formatter.format(_nisabGold)}) or Silver (${nisabSilverGrams}g ~ Rs ${formatter.format(_nisabSilver)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCalculating ? null : _calculateZakat,
                    icon: _isCalculating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.calculate),
                    label: const Text('Calculate Zakat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_totalZakat > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007A3D), Color(0xFF00A86B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Zakat Due',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${formatter.format(_totalZakat)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/donation');
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Pay Zakat Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            else if (_totalZakat == 0 && (_goldController.text.isNotEmpty || _silverController.text.isNotEmpty || _cashController.text.isNotEmpty))
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Your wealth is below Nisab threshold.\nZakat is not obligatory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    _cashController.dispose();
    _savingsController.dispose();
    _businessController.dispose();
    super.dispose();
  }
}