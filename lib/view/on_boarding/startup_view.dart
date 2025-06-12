import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/welcome_view.dart';
import 'package:cook_book/services/user_session.dart';
import 'package:cook_book/view/main_tabview/main_tabview.dart';
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
    checkUserSession();
  }

  // CORRECTION: Vérifier la session utilisateur au lieu de rediriger automatiquement
  void checkUserSession() async {
    // Attendre un petit délai pour l'écran de démarrage
    await Future.delayed(const Duration(seconds: 2));

    // Vérifier si un utilisateur est connecté
    final isLoggedIn = await UserSession.instance.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        // Utilisateur connecté -> aller vers l'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabview()),
        );
      } else {
        // Pas d'utilisateur connecté -> aller vers welcome
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeView()),
        );
      }
    }
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
            "assets/img/background_startup.jpg", // Nom plus simple
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/img/character_3d.jpg", // Nom plus simple
            width: media.width * 0.55,
            height: media.height * 0.55,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
