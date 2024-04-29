import 'package:flutter/material.dart';

class CustomDialpad extends StatefulWidget {
  final Function(String) onDigitPressed;
  final Function() onClearPressed;
  final Function() onCallPressed;
  final List<String> enteredDigits;

  const CustomDialpad({
    Key? key,
    required this.onDigitPressed,
    required this.onClearPressed,
    required this.onCallPressed,
    required this.enteredDigits,
  }) : super(key: key);

  @override
  _CustomDialpadState createState() => _CustomDialpadState();
}

class _CustomDialpadState extends State<CustomDialpad> {
  String _pressedDigit = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.enteredDigits.join(), // Display entered digits inside the tab
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClearPressed,
                    icon: Icon(Icons.backspace_outlined),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('*'),
              _buildButton('0'),
              _buildButton('#'),
            ],
          ),
          SizedBox(height: 16.0),
          Center(
            child: InkWell(
              onTap: widget.onCallPressed,
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[100], // Light purple color
                ),
                child: Icon(
                  Icons.phone,
                  size: 30.0,
                  color: Colors.blue, // Icon color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedDigit = label;
        });
        widget.onDigitPressed(label);
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            _pressedDigit = '';
          });
        });
      },
      onTapCancel: () {
        setState(() {
          _pressedDigit = '';
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 64.0,
        height: 64.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressedDigit == label ? Colors.blue[200] : Colors.white,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              color: _pressedDigit == label ? Colors.blueAccent : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}