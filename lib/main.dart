import 'package:cook_book/view/on_boarding/startup_view.dart';
import 'package:cook_book/view/login/welcome_view.dart';
import 'package:cook_book/view/main_tabview/main_tabview.dart';
import 'package:cook_book/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/app_colors.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/services/recipe_importer_service.dart';
import 'package:cook_book/services/recipe_data_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la connexion à MongoDB
  await MongoDBService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cook Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Roboto", // Utilisation d'une police système
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            // fontFamily: 'Playfair Display', // Commenté pour éviter l'erreur
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            // fontFamily: 'Playfair Display', // Commenté pour éviter l'erreur
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            // fontFamily: 'Raleway', // Commenté pour éviter l'erreur
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            // fontFamily: 'Raleway', // Commenté pour éviter l'erreur
            color: AppColors.textSecondary,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            // fontFamily: 'Playfair Display', // Commenté pour éviter l'erreur
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              // fontFamily: 'Raleway', // Commenté pour éviter l'erreur
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Utiliser WelcomeView au lieu de SplashScreen
      home: const WelcomeView(),
    );
  }
}
