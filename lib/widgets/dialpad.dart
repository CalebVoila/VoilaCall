import 'package:flutter/material.dart';

class CustomDialpad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final Function() onClearPressed;
  final Function() onCallPressed;

  const CustomDialpad({
    Key? key,
    required this.onDigitPressed,
    required this.onClearPressed,
    required this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Voila_Call'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your dialpad buttons here
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
