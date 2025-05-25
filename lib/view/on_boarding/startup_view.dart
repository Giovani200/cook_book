import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/welcome_view.dart';
import 'package:flutter/material.dart';

/// Widget représentant l'écran de démarrage (Startup)
class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomPage();
  }

  void goWelcomPage() async {
    // Simule un délai de 2 secondes avant de naviguer vers la page d'accueil
    await Future.delayed(const Duration(seconds: 2));
  }

  void welcomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupère la taille de l'écran pour adapter l'affichage de l'image
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Image de fond
          Image.asset(
            "assets/img/createur-de-contenu-alimentaire-filmant-une-variete-de-plats-a-telecharger-sur-internet.jpg",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/img/un-personnage-3d-emergeant-d-un-smartphone.jpg",
            width: media.width * 0.55,
            height: media.height * 0.55,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
