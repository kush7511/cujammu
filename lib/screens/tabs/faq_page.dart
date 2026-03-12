import 'package:flutter/material.dart';


class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQs")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text("How to check results?"),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Go to Results tab and select semester."),
              ),
            ],
          ),
          ExpansionTile(
            title: Text("How to pay fees?"),
           children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Go to Fee Payment section and proceed."),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
