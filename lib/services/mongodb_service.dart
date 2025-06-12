// Service permettant la connexion et les opérations avec MongoDB
import 'package:mongo_dart/mongo_dart.dart';
import 'package:cook_book/models/user_model.dart';
import 'package:cook_book/models/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MongoDBService {
  // Implémentation du pattern Singleton pour garantir une seule instance
  static final MongoDBService _instance = MongoDBService._internal();
  static MongoDBService get instance => _instance;

  // Objet de connexion à la base de données
  Db? _db;
  // CORRECTION: Spécifier explicitement la base de données
  final String _connectionString =
      "mongodb+srv://Giovani:Giovani12!@cluster0.89qzw.mongodb.net/cookbook_db?retryWrites=true&w=majority&appName=Cluster0";

  // Constructeur privé pour le Singleton
  MongoDBService._internal();

  // Getter pour accéder à la base de données
  Db? get db => _db;

  // Méthode pour établir la connexion à MongoDB
  Future<void> connect() async {
    try {
      if (_db == null || !_db!.isConnected) {
        print('Tentative de connexion à MongoDB...');

        // Encodage des caractères spéciaux dans l'URL
        final String encodedPassword = Uri.encodeComponent('Giovani12!');
        final String safeConnectionString =
            "mongodb+srv://Giovani:$encodedPassword@cluster0.89qzw.mongodb.net/cookbook_db?retryWrites=true&w=majority&appName=Cluster0";

        print('Connexion avec URL sécurisée vers cookbook_db');
        _db = await Db.create(safeConnectionString);

        print('Ouverture de la connexion...');
        await _db!.open();

        // Vérifier que la connexion est réellement établie
        if (_db!.isConnected) {
          print('✅ Connexion MongoDB établie - Base: ${_db!.databaseName}');

          // Vérifier que les collections existent ou les créer
          var collections = await _db!.getCollectionNames();
          print('Collections disponibles: $collections');

          if (!collections.contains('users')) {
            print('Création de la collection users...');
            await _db!.createCollection('users');
            print('✅ Collection users créée');
          }

          if (!collections.contains('recipes')) {
            print('Création de la collection recipes...');
            await _db!.createCollection('recipes');
            print('✅ Collection recipes créée');
          }
        }
      } else {
        print('Connexion MongoDB déjà établie - Base: ${_db!.databaseName}');
      }
    } catch (e) {
      print('ERREUR CRITIQUE lors de la connexion à MongoDB: $e');
      rethrow;
    }
  }

  // Méthode pour tester la connexion
  Future<bool> testConnection() async {
    try {
      await connect();
      final test = await _db!.collection('users').findOne();
      print('Test de connexion réussi sur ${_db!.databaseName}');
      return true;
    } catch (e) {
      print('Test de connexion échoué: $e');
      return false;
    }
  }

  // Accès à la collection 'users' dans MongoDB
  DbCollection get usersCollection => _db!.collection('users');

  // NOUVEAU: Accès à la collection 'recipes' dans MongoDB
  DbCollection get recipesCollection => _db!.collection('recipes');

  // Recherche un utilisateur par son email
  Future<User?> findUserByEmail(String email) async {
    try {
      print('🔍 RECHERCHE UTILISATEUR: $email');
      await connect();

      print('Base de données utilisée: ${_db!.databaseName}');
      final userMap = await usersCollection.findOne(where.eq('email', email));

      if (userMap != null) {
        print('✅ UTILISATEUR TROUVÉ: ${userMap['name']}');
        return User.fromJson(userMap);
      } else {
        print('❌ UTILISATEUR NON TROUVÉ pour: $email');

        // DEBUG: Lister tous les utilisateurs pour vérifier
        final allUsers = await usersCollection.find().toList();
        print('Tous les utilisateurs en BDD:');
        for (var user in allUsers) {
          print('  - ${user['email']} | ${user['name']}');
        }

        return null;
      }
    } catch (e) {
      print('❌ ERREUR recherche utilisateur: $e');
      return null;
    }
  }

  // Crée un nouvel utilisateur dans la base de données
  Future<bool> createUser(User user) async {
    try {
      print('=== DÉBUT CRÉATION UTILISATEUR ===');
      print('Email: ${user.email}');

      await connect();

      if (_db == null || !_db!.isConnected) {
        print('❌ ERREUR: DB non connectée');
        return false;
      }

      print('Base de données cible: ${_db!.databaseName}');

      // Créer le document utilisateur
      final userData = <String, dynamic>{
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'createdAt': user.createdAt.toIso8601String(),
        'mobile': user.mobile,
      };

      print('Données à insérer: $userData');

      // Insérer dans la collection 'users' de cookbook_db
      final result = await usersCollection.insertOne(userData);

      print('Résultat insertion:');
      print('- ID généré: ${result.id}');
      print('- Base utilisée: ${_db!.databaseName}');

      if (result.id != null) {
        print('✅ UTILISATEUR CRÉÉ AVEC SUCCÈS - ID: ${result.id}');

        // VÉRIFICATION IMMÉDIATE dans la même base
        print('Vérification immédiate...');
        final verification = await usersCollection.findOne(
          where.eq('email', user.email),
        );
        if (verification != null) {
          print('✅ VÉRIFICATION RÉUSSIE: Utilisateur trouvé après création');
        } else {
          print(
            '❌ VÉRIFICATION ÉCHOUÉE: Utilisateur non trouvé après création',
          );
        }

        return true;
      } else {
        print('❌ ÉCHEC: Aucun ID généré');
        return false;
      }
    } catch (e) {
      print('❌ EXCEPTION création utilisateur: $e');
      return false;
    }
  }

  // Authentifie un utilisateur avec email et mot de passe
  Future<User?> authenticateUser(String email, String password) async {
    try {
      print('🔐 AUTHENTIFICATION UTILISATEUR');
      print('Email: $email');
      print('Password: $password');

      await connect();
      print('Base de données utilisée: ${_db!.databaseName}');

      final userMap = await usersCollection.findOne(
        where.eq('email', email).eq('password', password),
      );

      if (userMap != null) {
        print('✅ AUTHENTIFICATION RÉUSSIE');
        return User.fromJson(userMap);
      } else {
        print('❌ AUTHENTIFICATION ÉCHOUÉE');

        // DEBUG: Vérifier si l'email existe avec un autre mot de passe
        final emailCheck = await usersCollection.findOne(
          where.eq('email', email),
        );
        if (emailCheck != null) {
          print('❌ Email trouvé mais mot de passe incorrect');
          print('Password en BDD: ${emailCheck['password']}');
          print('Password saisi: $password');
        } else {
          print('❌ Email non trouvé en BDD');
        }

        return null;
      }
    } catch (e) {
      print('❌ ERREUR authentification: $e');
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

  // Remplacer initialize() par une méthode qui appelle connect()
  Future<void> initialize() async {
    try {
      print('Initialisation de MongoDB...');
      await connect();
      print('MongoDB initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de MongoDB: $e');
      rethrow;
    }
  }

  // NOUVEAU: Récupère un utilisateur par son ID
  Future<User?> findUserById(ObjectId userId) async {
    try {
      await connect();
      final userMap = await usersCollection.findOne(where.eq('_id', userId));

      if (userMap != null) {
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('❌ ERREUR recherche utilisateur par ID: $e');
      return null;
    }
  }

  // MODIFICATION: Sauvegarde une recette avec authorId
  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      print('=== SAUVEGARDE RECETTE MONGODB ===');
      print('Recette: ${recipe.name} par authorId: ${recipe.authorId}');

      await connect();

      if (_db == null || !_db!.isConnected) {
        print('❌ ERREUR: DB non connectée');
        return false;
      }

      final recipeData = <String, dynamic>{
        'name': recipe.name,
        'description': recipe.description,
        'preparation': recipe.preparation,
        'prepTime': recipe.prepTime,
        'cookingTime': recipe.cookingTime,
        'category': recipe.category,
        'imagePath': recipe.imagePath,
        'createdAt': recipe.createdAt.toIso8601String(),
        'authorId': recipe.authorId, // Stockage de l'ID
        'likes': recipe.likes,
      };

      print('Données recette à insérer: $recipeData');

      final result = await recipesCollection.insertOne(recipeData);

      if (result.id != null) {
        print('✅ RECETTE SAUVEGARDÉE AVEC SUCCÈS - ID: ${result.id}');
        return true;
      } else {
        print('❌ ÉCHEC: Aucun ID généré pour la recette');
        return false;
      }
    } catch (e) {
      print('❌ EXCEPTION sauvegarde recette: $e');
      return false;
    }
  }

  // NOUVEAU: Récupère toutes les recettes depuis MongoDB
  Future<List<Recipe>> getAllRecipes() async {
    try {
      print('=== RÉCUPÉRATION TOUTES RECETTES ===');
      await connect();

      final recipesList = await recipesCollection.find().toList();
      print('Nombre de recettes trouvées: ${recipesList.length}');

      return recipesList
          .map((recipeData) => Recipe.fromJson(recipeData))
          .toList();
    } catch (e) {
      print('❌ ERREUR récupération recettes: $e');
      return [];
    }
  }

  // NOUVEAU: Récupère les recettes par catégorie depuis MongoDB
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      print('=== RÉCUPÉRATION RECETTES PAR CATÉGORIE ===');
      print('Catégorie: $category');
      await connect();

      final recipesList =
          await recipesCollection.find(where.eq('category', category)).toList();
      print(
        'Nombre de recettes trouvées pour $category: ${recipesList.length}',
      );

      return recipesList
          .map((recipeData) => Recipe.fromJson(recipeData))
          .toList();
    } catch (e) {
      print('❌ ERREUR récupération recettes par catégorie: $e');
      return [];
    }
  }

  // NOUVEAU: Récupère les recettes les plus récentes depuis MongoDB
  Future<List<Recipe>> getRecentRecipes({int limit = 3}) async {
    try {
      print('=== RÉCUPÉRATION RECETTES RÉCENTES ===');
      await connect();

      // Correction: utiliser la syntaxe correcte pour le tri et la limitation
      final recipesList = await recipesCollection.find().toList();

      // Trier par date de création (les plus récentes en premier)
      recipesList.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt']);
        final dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA); // Ordre décroissant
      });

      // Prendre seulement le nombre demandé
      final limitedList = recipesList.take(limit).toList();

      print('Nombre de recettes récentes trouvées: ${limitedList.length}');

      return limitedList
          .map((recipeData) => Recipe.fromJson(recipeData))
          .toList();
    } catch (e) {
      print('❌ ERREUR récupération recettes récentes: $e');
      return [];
    }
  }

  // NOUVEAU: Récupère les recettes les plus populaires depuis MongoDB
  Future<List<Recipe>> getMostPopularRecipes({int limit = 5}) async {
    try {
      print('=== RÉCUPÉRATION RECETTES POPULAIRES ===');
      await connect();

      // Correction: utiliser la syntaxe correcte pour le tri et la limitation
      final recipesList = await recipesCollection.find().toList();

      // Trier par nombre de likes (les plus populaires en premier)
      recipesList.sort((a, b) {
        final likesA = a['likes'] ?? 0;
        final likesB = b['likes'] ?? 0;
        return likesB.compareTo(likesA); // Ordre décroissant
      });

      // Prendre seulement le nombre demandé
      final limitedList = recipesList.take(limit).toList();

      print('Nombre de recettes populaires trouvées: ${limitedList.length}');

      return limitedList
          .map((recipeData) => Recipe.fromJson(recipeData))
          .toList();
    } catch (e) {
      print('❌ ERREUR récupération recettes populaires: $e');
      return [];
    }
  }

  // NOUVEAU: Like une recette dans MongoDB
  Future<bool> likeRecipe(ObjectId? recipeId) async {
    try {
      if (recipeId == null) {
        print('❌ ERREUR: Recipe ID est null');
        return false;
      }

      print('=== LIKE RECETTE ===');
      print('Recipe ID: $recipeId');
      await connect();

      final result = await recipesCollection.updateOne(
        where.eq('_id', recipeId),
        modify.inc('likes', 1),
      );

      print('Résultat like: ${result.isSuccess}');
      return result.isSuccess;
    } catch (e) {
      print('❌ ERREUR like recette: $e');
      return false;
    }
  }

  // NOUVEAU: Récupère les recettes d'un utilisateur spécifique
  Future<List<Recipe>> getRecipesByUserId(ObjectId userId) async {
    try {
      print('=== RÉCUPÉRATION RECETTES PAR USER ID ===');
      print('User ID: $userId');
      await connect();

      final recipesList =
          await recipesCollection.find(where.eq('authorId', userId)).toList();
      print(
        'Nombre de recettes trouvées pour l\'utilisateur $userId: ${recipesList.length}',
      );

      return recipesList
          .map((recipeData) => Recipe.fromJson(recipeData))
          .toList();
    } catch (e) {
      print('❌ ERREUR récupération recettes par user ID: $e');
      return [];
    }
  }

  // Ajouter cette méthode pour une importation optimisée en masse
  Future<int> bulkSaveRecipes(List<Recipe> recipes) async {
    try {
      await connect();

      if (_db == null || !_db!.isConnected) {
        print('❌ ERREUR: DB non connectée');
        return 0;
      }

      final collection = _db!.collection('recipes');

      // Convertir toutes les recettes en Map pour l'insertion
      final List<Map<String, dynamic>> recipesData =
          recipes.map((recipe) => recipe.toMap()).toList();

      // Utiliser insertMany pour une insertion optimisée
      final result = await collection.insertMany(recipesData);

      print(
        '✅ Insertion en masse réussie: ${result.ok} / ${result.nInserted} insérés',
      );
      return result.nInserted;
    } catch (e) {
      print('❌ EXCEPTION importation en masse: $e');
      return 0;
    }
  }
}
