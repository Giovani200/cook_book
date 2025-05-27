import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/login_view.dart';
import 'package:cook_book/view/login/sing_up_view.dart';
import 'package:flutter/material.dart';

/// Widget principal représentant la page d'accueil (Welcome)
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Image.asset(
            "assets/img/un-personnage-3d-emergeant-d-un-smartphone.jpg",
            width: media.width,
            height: media.height * 0.55,
            fit: BoxFit.cover,
          ),
          // Contenu principal centré
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: media.height * 0.08,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texte de bienvenue
                  Text(
                    "Bienvenue sur Cook Book\nDécouvrez des recettes délicieuses et partagez vos créations culinaires !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Bouton Se connecter
                  RoundButton(
                    title: "Se connecter",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Bouton Créer un compte
                  RoundButton(
                    title: "Créer un compte",
                    type: RoundButtonType.textPrimary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SingUpView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
