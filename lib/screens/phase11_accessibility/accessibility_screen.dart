// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class AccessibilityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accessibility')),
      body: Center(child: Text('Large text and simple UI settings')),
    );
  }
}
