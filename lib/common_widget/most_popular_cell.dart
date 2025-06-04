// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';

class MostPopularCell extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MostPopularCell({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                mObj["image"].toString(), // Image de la catégorie
                width: 220,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              mObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  mObj["type"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 10,
                    // fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  ".",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 10,
                    // fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  mObj["food_type"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 10,
                    // fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 8),

                Image.asset(
                  "assets/img/rate.png",
                  width: 10,
                  height: 10,
                  fit: BoxFit.cover,
                ),

                const SizedBox(width: 4),

                Text(
                  mObj["rate"].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 6,
                    // fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
