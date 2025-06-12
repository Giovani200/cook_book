import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart'
    as mongo; // CORRECTION: Ajout du préfixe
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../services/user_session.dart';
import '../../common/app_colors.dart';

class AddRecipeView extends StatefulWidget {
  const AddRecipeView({Key? key}) : super(key: key);

  @override
  State<AddRecipeView> createState() => _AddRecipeViewState();
}

class _AddRecipeViewState extends State<AddRecipeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _preparationController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();

  String _selectedCategory = "Entrées";
  final List<String> _categories = ["Entrées", "Plats", "Desserts"];
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await UserSession.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      mongo.ObjectId? userObjectId;
      if (currentUser.id != null) {
        userObjectId = currentUser.id;
      } else {
        print('⚠️ Utilisateur sans ObjectId, création d\'un ID temporaire');
        userObjectId = mongo.ObjectId();
      }

      // Conversion des chaînes en entiers avec valeurs par défaut
      final int prepTimeValue =
          int.tryParse(_prepTimeController.text.trim()) ?? 30;
      final int cookingTimeValue =
          int.tryParse(_cookingTimeController.text.trim()) ?? 20;

      // Extraction des ingrédients et instructions à partir du texte de préparation
      final String prepText = _preparationController.text.trim();
      final List<String> extractedLines =
          prepText.split('\n').where((line) => line.trim().isNotEmpty).toList();

      // Séparation des ingrédients et instructions (hypothèse : les 1/3 premières lignes sont des ingrédients)
      int ingredientEndIndex = extractedLines.length ~/ 3;
      List<String> ingredients =
          extractedLines.take(ingredientEndIndex).toList();
      List<String> instructions =
          extractedLines.skip(ingredientEndIndex).toList();

      // Si pas d'ingrédients détectés, fournir une liste vide (mais non null)
      if (ingredients.isEmpty) ingredients = ['Ingrédients non spécifiés'];
      if (instructions.isEmpty) instructions = ['Instructions non spécifiées'];

      final recipe = Recipe(
        id: null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        preparation: _preparationController.text.trim(),
        prepTime: prepTimeValue,
        cookingTime: cookingTimeValue,
        category: _selectedCategory,
        imagePath: _image?.path,
        createdAt: DateTime.now(),
        authorId: userObjectId,
        // Ajouter les champs requis correctement
        ingredients: ingredients,
        instructions: instructions.join(
          '\n',
        ), // Joindre les instructions en une seule chaîne
        servings: 4, // Valeur par défaut
        likes: 0, // Valeur par défaut
      );

      await RecipeService.instance.saveRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recette ajoutée avec succès !'),
            backgroundColor: AppColors.secondary,
          ),
        );

        // CORRECTION: Retourner un résultat pour indiquer le succès
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Ajouter une recette",
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                hintText: "Nom de la recette",
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                hintText: "Description",
                maxLines: 3,
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _preparationController,
                hintText: "Mode de préparation et ingrédients",
                maxLines: 5,
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _prepTimeController,
                      hintText: "Temps de préparation (min)",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cookingTimeController,
                      hintText: "Temps de cuisson (min)",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Catégorie",
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children:
                    _categories.map((category) {
                      return Expanded(
                        child: GestureDetector(
                          onTap:
                              () =>
                                  setState(() => _selectedCategory = category),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  _selectedCategory == category
                                      ? AppColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                color:
                                    _selectedCategory == category
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _image != null
                            ? "Image sélectionnée"
                            : "Ajouter une image (optionnel)",
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Enregistrer",
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontFamily: 'Raleway'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Raleway',
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
