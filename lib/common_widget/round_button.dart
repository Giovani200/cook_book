// Widget bouton personnalisé avec bords arrondis et différents styles
import 'package:cook_book/common/color_extension.dart';
import 'package:flutter/material.dart';

// Types de boutons disponibles dans l'application
enum RoundButtonType { primary, textPrimary }

class RoundButton extends StatelessWidget {
  // Texte affiché sur le bouton
  final String title;
  // Action à exécuter lors du clic
  final VoidCallback onPressed;
  // Indique si le bouton est désactivé
  final bool isDisabled;
  // Style du bouton (couleur pleine ou contour)
  final RoundButtonType type;

  // Constructeur avec paramètres nommés
  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isDisabled = false,
    this.type = RoundButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    // Construction du bouton avec MaterialButton comme base
    return MaterialButton(
      onPressed: isDisabled ? null : onPressed,
      disabledColor: Colors.grey.shade300,
      color:
          type == RoundButtonType.primary ? TColor.primary : Colors.transparent,
      elevation: type == RoundButtonType.primary ? 1 : 0,
      height: 50,
      minWidth: double.maxFinite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side:
            type == RoundButtonType.textPrimary
                ? BorderSide(color: TColor.primary, width: 1)
                : BorderSide.none,
      ),
      child: Text(
        title,
        style: TextStyle(
          color:
              type == RoundButtonType.primary ? Colors.white : TColor.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
