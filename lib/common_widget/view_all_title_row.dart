import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class ViewAllTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  const ViewAllTitleRow({super.key, required this.title, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // const SizedBox(
        //   height: 64), // Espace à gauche
        Text(
          title,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        TextButton(
          onPressed: onView,
          child: Text(
            "See All",
            style: TextStyle(
              color: TColor.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
