import 'package:cook_book/common/color_extension.dart';
import 'package:flutter/material.dart';

class RoundTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Color? bgColor;
  final Widget? left;

  const RoundTextfield({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.bgColor,
    this.left,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? TColor.texfield,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (left != null)
            Padding(padding: const EdgeInsets.only(left: 10), child: left!),
          Expanded(
            child: TextField(
              autocorrect: false,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,

                hintText: hintText,
                hintStyle: TextStyle(
                  color: TColor.placeholder,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                // prefixIcon: Icon(Icons.email, color: TColor.primary),
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}
