import 'package:flutter/material.dart';

class EmailInputFb1 extends StatelessWidget {
  final TextEditingController inputController;
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  const EmailInputFb1({
    Key? key,
    required this.inputController,
    this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blue;
    const secondaryColor = Colors.blue;
    const accentColor = Colors.white;
    const errorColor = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(12, 26),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.grey.withValues(alpha: .1),
              ),
            ],
          ),
          child: TextField(
            controller: inputController,
            obscureText: obscureText,
            onChanged: (value) {
              //Do something wi
            },
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.email),
              filled: true,
              fillColor: accentColor,
              hintText: hintText ?? 'Enter text',
              hintStyle: TextStyle(color: Colors.grey.withValues(alpha: .75)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 20.0,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: errorColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
