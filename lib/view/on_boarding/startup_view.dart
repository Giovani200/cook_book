import 'package:flutter/material.dart';

/// Widget représentant l'écran de démarrage (Startup)
class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  Widget build(BuildContext context) {
    // Récupère la taille de l'écran pour adapter l'affichage de l'image
    var media = MediaQuery.of(context).size;

    return Scaffold(
      // Utilise un Stack pour placer l'image en fond d'écran
      body: Stack(
        alignment: Alignment.center, // Centre les enfants du Stack
        children: [
          // Affiche une image qui couvre tout l'écran
          Image.asset(
            "assets/img/createur-de-contenu-alimentaire-filmant-une-variete-de-plats-a-telecharger-sur-internet.jpg",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover, // L'image couvre toute la surface disponible
          ),
        ],
      ),
    );
  }
}