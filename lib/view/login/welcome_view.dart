import 'package:flutter/material.dart';

/// Widget principal représentant la page d'accueil (Welcome)
class WelcomView extends StatefulWidget {
  const WelcomView({super.key});

  @override
  State<WelcomView> createState() => _WelcomViewState();
}

class _WelcomViewState extends State<WelcomView> {
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
            ],
          ),
        ],
      ),
    );
  }
}