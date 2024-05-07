import 'package:flutter/material.dart';

class FareMatrixPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const FareMatrixPage({Key? key}) : super(key: key);

  @override
  _FareMatrixPageState createState() => _FareMatrixPageState();
}

class _FareMatrixPageState extends State<FareMatrixPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fare matrix"),
      ),
      body: const Center(),
    );
  }
}


