// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';

class CategoryCall extends StatelessWidget {
  final Map cObj;
  final VoidCallback onTap;
  const CategoryCall({super.key, required this.cObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                cObj["image"].toString(), // Image de la catégorie
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),
        
            const SizedBox(height: 8),
            Text(
              cObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
