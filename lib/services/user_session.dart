// Service gérant la session utilisateur avec stockage persistant
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cook_book/models/user_model.dart';
import 'dart:convert';

class UserSession {
  // Implémentation du pattern Singleton
  static final UserSession _instance = UserSession._internal();
  static UserSession get instance => _instance;

  // Utilisateur actuellement connecté (null si aucun)
  User? currentUser;

  // Constructeur privé pour le Singleton
  UserSession._internal();

  // Enregistre les données de l'utilisateur connecté dans SharedPreferences
  Future<void> saveUserSession(User user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Récupère les données de l'utilisateur à partir du stockage local
  Future<User?> getCurrentUser() async {
    if (currentUser != null) return currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      currentUser = User.fromJson(jsonDecode(userData));
      return currentUser;
    }
    return null;
  }

  // Supprime les données de session (déconnexion)
  Future<void> clearUserSession() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Vérifie si un utilisateur est actuellement connecté
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
