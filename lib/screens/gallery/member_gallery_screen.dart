import 'package:flutter/material.dart';

class MemberGalleryScreen extends StatelessWidget {
  const MemberGalleryScreen({super.key});

  final List<String> images = const [
    'assets/images/masjid/masjid_front_1.jpg',
    'assets/images/masjid/masjid_front_2.jpg',
    'assets/images/masjid/masjid_prayerhall_1.jpg',
    'assets/images/masjid/masjid_prayerhall_2.jpg',
    'assets/images/masjid/masjid_wudhu_1.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Gallery')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: images.length,
        itemBuilder: (_, i) {
          return Card(
            child: Image.asset(images[i], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}