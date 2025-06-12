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

      final recipe = Recipe(
        id: null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        preparation: _preparationController.text.trim(),
        prepTime: _prepTimeController.text.trim(),
        cookingTime: _cookingTimeController.text.trim(),
        category: _selectedCategory,
        imagePath: _image?.path,
        createdAt: DateTime.now(),
        authorId: userObjectId,
      );

      await RecipeService.instance.saveRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
        title: Text(
          "Ajouter une recette",
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
              SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                hintText: "Description",
                maxLines: 3,
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _preparationController,
                hintText: "Mode de préparation et ingrédients",
                maxLines: 5,
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Ce champ est requis' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _prepTimeController,
                      hintText: "Temps de préparation (min)",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cookingTimeController,
                      hintText: "Temps de cuisson (min)",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Catégorie",
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children:
                    _categories.map((category) {
                      return Expanded(
                        child: GestureDetector(
                          onTap:
                              () =>
                                  setState(() => _selectedCategory = category),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.symmetric(vertical: 12),
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _image != null
                            ? "Image sélectionnée"
                            : "Ajouter une image (optionnel)",
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
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
      style: TextStyle(fontFamily: 'Raleway'),
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
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
