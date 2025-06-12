import 'package:shared_preferences/shared_preferences.dart';
import 'package:cook_book/models/user_model.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

  User? _currentUser;

  // Liste des utilisateurs enregistrés (simuler une base de données locale)
  List<Map<String, dynamic>> _users = [];

  // Initialiser le service
  Future<void> initialize() async {
    await _loadUsers();
  }

  // Charger les utilisateurs depuis SharedPreferences
  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users_list');
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users = usersList.cast<Map<String, dynamic>>();
      }
      print('Utilisateurs chargés: ${_users.length}');
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      _users = [];
    }
  }

  // Sauvegarder les utilisateurs dans SharedPreferences
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('users_list', jsonEncode(_users));
      print('Utilisateurs sauvegardés: ${_users.length}');
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  // Inscription
  Future<bool> register(String name, String email, String password) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUser = _users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        print('Email déjà utilisé: $email');
        return false;
      }

      // Créer le nouvel utilisateur
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Ajouter à la liste
      _users.add(newUser);

      // Sauvegarder
      await _saveUsers();

      // Connecter automatiquement l'utilisateur
      _currentUser = User(
        id: null,
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );

      await _saveCurrentUser();

      print('Utilisateur créé avec succès: $email');
      return true;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return false;
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        print('Identifiants incorrects');
        return false;
      }

      // Connecter l'utilisateur
      _currentUser = User(
        id: null,
        name: user['name'],
        email: user['email'],
        password: user['password'],
        createdAt: DateTime.parse(user['createdAt']),
      );

      await _saveCurrentUser();

      print('Connexion réussie: $email');
      return true;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }

  // Sauvegarder l'utilisateur actuel
  Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
    }
  }

  // Charger l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        return _currentUser;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    }
    return null;
  }

  // Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  // Vérifier si connecté
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
