import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFC9C6CE))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFC9C6CE))),
      ],
    );
  }
}
