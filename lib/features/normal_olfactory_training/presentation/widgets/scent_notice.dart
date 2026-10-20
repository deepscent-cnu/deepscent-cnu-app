import 'package:flutter/material.dart';

class ScentNotice extends StatelessWidget {
  final String message;

  const ScentNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Color(0xFF72B357).withAlpha(50),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
