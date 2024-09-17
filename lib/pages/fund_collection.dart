import 'package:flutter/material.dart';

class FundCollection extends StatefulWidget {
  static const String id = "fundCollection"; // Define a static constant identifier

  const FundCollection({Key? key}) : super(key: key);

  @override
  _FundCollectionState createState() => _FundCollectionState();
}

class _FundCollectionState extends State<FundCollection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Collection'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Fund Collection Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}