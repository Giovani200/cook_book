import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/login_view.dart';
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
    // Récupère la taille de l'écran pour adapter l'affichage
    var media = MediaQuery.of(context).size;

    return Scaffold(
      // Le corps de la page est une colonne verticale
      body: Column(
        children: [
          // Utilisation d'un Stack pour superposer des widgets
          Stack(
            alignment: Alignment.bottomCenter, // Aligne les enfants en bas au centre
            children: [
              // Affiche une image en largeur maximale de l'écran
              Image.asset(
                "assets/img/un-personnage-3d-emergeant-d-un-smartphone.jpg",
                width: media.width,

              ),
              Image.asset(
                "assets/img/un-personnage-3d-emergeant-d-un-smartphone.jpg",
                width: media.width * 0.55,
                height: media.height * 0.55,
                fit: BoxFit.contain,
              ),
              SizedBox(height: media.width * 0.1),

              SizedBox(height: media.width * 0.1),
              Text(
                " Bienvenue sur Cook Book decouvrez des recettes délicieuses et partagez vos créations culinaires !",
                textAlign: TextAlign.center, 
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RoundButton(title: "Se connecter", onPressed: () {
                  // Action à effectuer lors de l'appui sur le bouton
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                }),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RoundButton(
                  title: "crée un compte",
                  type: RoundButtonType.textPrimary, 
                  onPressed: () {
                    // Action à effectuer lors de l'appui sur le bouton
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}