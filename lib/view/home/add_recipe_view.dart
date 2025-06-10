import 'dart:io';
import 'package:cook_book/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Recipe {
  final String name;
  final String description;
  final String cookingTime;
  final String prepTime;
  final String category;
  final String preparation;
  final String? imagePath;

  Recipe({
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.prepTime,
    required this.category,
    required this.preparation,
    this.imagePath,
  });

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'cookingTime': cookingTime,
      'prepTime': prepTime,
      'category': category,
      'preparation': preparation,
      'imagePath': imagePath,
    };
  }
}

// Service pour gérer les recettes
class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  // Liste de toutes les recettes
  final List<Recipe> _recipes = [];

  // Ajouter une recette
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
  }

  // Obtenir toutes les recettes
  List<Recipe> getAllRecipes() {
    return _recipes;
  }

  // Obtenir les recettes par catégorie
  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  // Rechercher des recettes par nom
  List<Recipe> searchRecipes(String query) {
    return _recipes.where((recipe) => 
      recipe.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

class AddRecipeView extends StatefulWidget {
  const AddRecipeView({Key? key}) : super(key: key);

  @override
  State<AddRecipeView> createState() => _AddRecipeViewState();
}

class _AddRecipeViewState extends State<AddRecipeView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _preparationController = TextEditingController();
  
  String _selectedCategory = "Entrées";
  final List<String> _categories = ["Entrées", "Plats", "Desserts", "Boissons"];
  
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cookingTimeController.dispose();
    _prepTimeController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveRecipe() {
    // Vérifier que les champs obligatoires sont remplis
    if (_nameController.text.isEmpty || 
        _descriptionController.text.isEmpty ||
        _preparationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    // Créer une nouvelle recette
    final recipe = Recipe(
      name: _nameController.text,
      description: _descriptionController.text,
      cookingTime: _cookingTimeController.text,
      prepTime: _prepTimeController.text,
      category: _selectedCategory,
      preparation: _preparationController.text,
      imagePath: _image?.path,
    );

    // Ajouter la recette au service
    RecipeService().addRecipe(recipe);

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recette ajoutée avec succès !")),
    );

    // Retourner à l'écran précédent
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ajout de recette",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ du nom de la recette
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Nom de recette",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Champ de description
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "description",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Temps de cuisson et préparation
            Row(
              children: [
                // Temps de cuisson
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _cookingTimeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Temps de cuisson",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Temps de préparation
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _prepTimeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Temps de préparation",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Catégorie de plat
            const Text(
              "Catégorie de plat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Sélection de catégorie
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 60) / 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedCategory == category
                          ? Colors.grey[300]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category == "Entrées" ? "Entrées" : 
                        category == "Plats" ? "Plats" : 
                        category == "Desserts" ? "Desserts" : "Boissons",
                        style: TextStyle(
                          color: _selectedCategory == category
                              ? Colors.black
                              : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Instructions de préparation
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _preparationController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Préparation",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Ajouter une image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey[700]),
                    const SizedBox(width: 15),
                    Text(
                      _image != null ? "Image sélectionnée" : "add picture",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bouton d'enregistrement
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}