// Modèle de données représentant un utilisateur dans l'application
import 'package:mongo_dart/mongo_dart.dart';

class User {
  // Identifiant MongoDB unique
  final ObjectId? id;
  // Nom complet de l'utilisateur
  final String name;
  // Email (utilisé pour l'authentification)
  final String email;
  // Mot de passe (devrait idéalement être hashé)
  final String password;
  // Numéro de téléphone optionnel
  final String? mobile;
  // Date de création du compte
  final DateTime createdAt;

  // Constructeur principal
  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.mobile,
    required this.createdAt,
  });

  // Création d'un objet User à partir d'un JSON (pour la désérialisation)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:
          json['_id'] is ObjectId
              ? json['_id']
              : json['_id'] != null
              ? ObjectId.parse(json['_id'].toString())
              : null,
      name: json['name'],
      email: json['email'],
      password: json['password'],
      mobile: json['mobile'],
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']),
    );
  }

  // Conversion de l'objet User en JSON (pour la sérialisation)
  Map<String, dynamic> toJson() {
    return {
      // Suppression conditionnelle de l'ID pour éviter les problèmes de typage
      // L'ID sera généré automatiquement par MongoDB lors de l'insertion
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Conversion de l'objet User en Map (pour d'autres utilisations)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      // Ajouter d'autres champs selon la structure de votre classe User
    };
  }

  // Méthode utilitaire pour créer une copie modifiée de l'utilisateur
  User copyWith({
    ObjectId? id,
    String? name,
    String? email,
    String? password,
    String? mobile,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
