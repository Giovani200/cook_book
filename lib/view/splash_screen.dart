import 'package:flutter/material.dart';
import 'package:cook_book/services/recipe_data_importer.dart';
import 'package:cook_book/services/mongodb_service.dart';
import '../common/app_colors.dart';
import 'main_tab_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _statusMessage = "Initialisation...";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Connecter à MongoDB
      setState(() => _statusMessage = "Connexion à la base de données...");
      await MongoDBService.instance.initialize();

      // Importer les recettes
      setState(() => _statusMessage = "Importation des recettes...");
      await RecipeDataImporter.instance.importRecipes();

      // Attendre pour montrer le splash screen un moment
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainTabView()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Erreur d'initialisation: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Cook Book",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ] else ...[
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initialize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text("Réessayer"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
