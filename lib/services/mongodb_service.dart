// Service permettant la connexion et les opérations avec MongoDB
import 'package:mongo_dart/mongo_dart.dart';
import 'package:cook_book/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDBService {
  // Implémentation du pattern Singleton pour garantir une seule instance
  static final MongoDBService _instance = MongoDBService._internal();
  static MongoDBService get instance => _instance;

  // Objet de connexion à la base de données
  Db? _db;
  // Chaîne de connexion à MongoDB Atlas (contient les identifiants)
  final String _connectionString =
      "mongodb+srv://Giovani:Giovani12!@cluster0.89qzw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

  // Constructeur privé pour le Singleton
  MongoDBService._internal();

  // Méthode pour établir la connexion à MongoDB
  Future<void> connect() async {
    if (_db == null || !_db!.isConnected) {
      _db = await Db.create(_connectionString);
      await _db!.open();
    }
  }

  // Accès à la collection 'users' dans MongoDB
  DbCollection get usersCollection => _db!.collection('users');

  // Recherche un utilisateur par son email
  Future<User?> findUserByEmail(String email) async {
    try {
      await connect();
      final userMap = await usersCollection.findOne(where.eq('email', email));
      if (userMap != null) {
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error finding user: $e');
      return null;
    }
  }

  // Crée un nouvel utilisateur dans la base de données
  Future<bool> createUser(User user) async {
    try {
      await connect();

      // Vérifier si l'utilisateur existe déjà
      final existingUser = await findUserByEmail(user.email);
      if (existingUser != null) {
        return false;
      }

      // Créer l'utilisateur
      await usersCollection.insert(user.toJson());
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Authentifie un utilisateur avec email et mot de passe
  Future<User?> authenticateUser(String email, String password) async {
    try {
      await connect();
      final userMap = await usersCollection.findOne(
        where.eq('email', email).eq('password', password),
      );

      if (userMap != null) {
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  // Met à jour le mot de passe d'un utilisateur
  Future<bool> updateUserPassword(String email, String newPassword) async {
    try {
      await connect();
      final result = await usersCollection.updateOne(
        where.eq('email', email),
        modify.set('password', newPassword),
      );
      return result.isSuccess;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Ferme proprement la connexion à la base de données
  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }
}
