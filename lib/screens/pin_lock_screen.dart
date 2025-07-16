import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String enteredPin = '';

  void onNumberPress(String number) async {
    setState(() {
      if (enteredPin.length < 4) enteredPin += number;
    });

    if (enteredPin.length == 4) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPin = prefs.getString('userPin');

      if (enteredPin == savedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          enteredPin = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN. Try again.')),
        );
      }
    }
  }

  void onBackspace() {
    setState(() {
      if (enteredPin.isNotEmpty) enteredPin = enteredPin.substring(0, enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Passcode')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enter Passcode'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Icon(
                index < enteredPin.length ? Icons.circle : Icons.circle_outlined,
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
                      // not needed here — just wait for 4 digits
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
