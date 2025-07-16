import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String pin = '';
  String confirmPin = '';
  bool isConfirming = false;

  void onNumberPress(String number) {
    setState(() {
      if (!isConfirming) {
        if (pin.length < 4) pin += number;
        if (pin.length == 4) isConfirming = true;
      } else {
        if (confirmPin.length < 4) confirmPin += number;
      }
    });
  }

  void onBackspace() {
    setState(() {
      if (!isConfirming) {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else {
        if (confirmPin.isNotEmpty) confirmPin = confirmPin.substring(0, confirmPin.length - 1);
      }
    });
  }

  Future<void> onDone() async {
    if (pin == confirmPin) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userPin', pin);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        pin = '';
        confirmPin = '';
        isConfirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entered = isConfirming ? confirmPin : pin;

    return Scaffold(
      appBar: AppBar(title: const Text('Set your PIN')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isConfirming ? 'Confirm PIN' : 'Enter new PIN'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Icon(
                index < entered.length ? Icons.circle : Icons.circle_outlined,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 40),
          buildNumberPad(),
        ],
      ),
    );
  }

  Widget buildNumberPad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['done', '0', 'back']
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((value) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (value == 'done') {
                      onDone();
                    } else if (value == 'back') {
                      onBackspace();
                    } else {
                      onNumberPress(value);
                    }
                  },
                  child: value == 'done'
                      ? const Icon(Icons.check)
                      : value == 'back'
                          ? const Icon(Icons.backspace)
                          : Text(value, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
