import 'package:flutter/material.dart';

import '../../core/ui_feedback.dart';
import '../../services/daily_corner_service.dart';

class DailyCornerScreen extends StatefulWidget {
  const DailyCornerScreen({super.key});

  @override
  State<DailyCornerScreen> createState() => _DailyCornerScreenState();
}

class _DailyCornerScreenState extends State<DailyCornerScreen> {
  late final pack = DailyCornerService.todayPack();
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Women & Children — Daily Corner')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                pack.kidsQuestion,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ✅ Modern API for your Flutter: RadioGroup(groupValue:)
          RadioGroup<int>(
            groupValue: selected,
            onChanged: (v) => setState(() => selected = v),
            child: Column(
              children: List.generate(pack.kidsChoices.length, (i) {
                return RadioListTile<int>(
                  value: i,
                  title: Text(pack.kidsChoices[i]),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (selected == null) {
                UIFeedback.errorSnack(context, 'Pick an answer first.');
                return;
              }

              if (selected == pack.kidsAnswer) {
                UIFeedback.successSnack(context, 'Correct! MashaAllah 🤍');
                UIFeedback.showConfetti(context);
              } else {
                UIFeedback.errorSnack(context, 'Not correct yet — try again.');
              }
            },
            child: const Text('Check Answer'),
          ),

          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded),
              title: const Text('Dua of the Day'),
              subtitle: Text(pack.duaText),
            ),
          ),
        ],
      ),
    );
  }
}
