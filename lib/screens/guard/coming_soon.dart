import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommingSoonScreen extends StatelessWidget {
  const CommingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          'Comming Soon...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
