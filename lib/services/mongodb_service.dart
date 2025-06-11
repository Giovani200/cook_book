import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';

class MongoDBService {
  static const String connectionString = 
      'mongodb+srv://Giovani:Giovani12!@cluster0.89qzw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
  
  static const String databaseName = 'cookbook_db';
  static const String userCollection = 'users';
  
  static Db? _database;
  static DbCollection? _userCollection;

  static Future<void> connect() async {
    try {
      _database = await Db.create(connectionString);
      await _database!.open();
      _userCollection = _database!.collection(userCollection);
      print('Connected to MongoDB successfully');
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      throw e;
    }
  }

  static Future<void> disconnect() async {
    await _database?.close();
  }

  static Future<bool> createUser(User user) async {
    try {
      if (_userCollection == null) {
        await connect();
      }

      // Vérifier si l'email existe déjà
      var existingUser = await _userCollection!.findOne(where.eq('email', user.email));
      if (existingUser != null) {
        throw Exception('Un compte avec cet email existe déjà');
      }

      await _userCollection!.insertOne(user.toJson());
      print('User created successfully');
      return true;
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  static Future<User?> loginUser(String email, String password) async {
    try {
      if (_userCollection == null) {
        await connect();
      }

      var userDoc = await _userCollection!.findOne(
        where.eq('email', email).eq('password', password)
      );

      if (userDoc != null) {
        return User.fromJson(userDoc);
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      throw e;
    }
  }
}
