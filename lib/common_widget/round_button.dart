
import 'package:flutter/material.dart';
import '../common/color_extension.dart';

enum RoundButtonType { bgPrimary, textPrimary }
class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final RoundButtonType type;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = RoundButtonType.bgPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: type == RoundButtonType.bgPrimary
              ? null
              : Border.all(color: TColor.primary, width: 2),
          color: type == RoundButtonType.bgPrimary ? TColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: type == RoundButtonType.bgPrimary ? Colors.white : TColor.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
