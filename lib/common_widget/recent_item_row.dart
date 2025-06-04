// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';

class RecentItemRow extends StatelessWidget {
  final Map rObj;
  final VoidCallback onTap;
  const RecentItemRow({super.key, required this.rObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                rObj["image"].toString(), // Image de la catégorie
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    rObj["name"],
                    textAlign: TextAlign.left,
                    
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          rObj["type"],
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
                        rObj["food_type"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 10,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      
                      Image.asset(
                        "assets/img/rate.png",
                        width: 10,
                        height: 10,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        rObj["rate"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 6,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),


                      const SizedBox(width: 4),

                      
                      Text(
                        "(${ rObj["rating"]} Ratings)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 10,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
