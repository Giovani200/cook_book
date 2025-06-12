import 'package:cook_book/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/view/home/category_recettes_view.dart';
import 'package:cook_book/services/recipe_service.dart';
import 'package:cook_book/models/recipe_model.dart';
import 'package:cook_book/view/home/recipe_detail_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  TextEditingController txtSearch = TextEditingController();

  // Liste des catégories de menu (pour l'affichage par défaut)
  final List<Map<String, dynamic>> menuCategories = [
    {
      "name": "Entrées",
      "image": "assets/img/entrees.webp",
      "items": "0 items", // Sera mis à jour dynamiquement
    },
    {
      "name": "Plats",
      "image": "assets/img/plat.webp",
      "items": "0 items", // Sera mis à jour dynamiquement
    },
    {
      "name": "Desserts",
      "image": "assets/img/dessert.webp",
      "items": "0 items", // Sera mis à jour dynamiquement
    },
  ];

  // Liste filtrée qui sera affichée
  List<Map<String, dynamic>> filteredCategories = [];

  // NOUVEAU: Liste des vraies recettes trouvées lors de la recherche
  List<Recipe> foundRecipes = [];

  // Mode d'affichage: 'categories' ou 'recipes'
  String displayMode = 'categories';

  // NOUVEAU: Toutes les recettes chargées
  List<Recipe> allRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllRecipes();

    // Ajouter un écouteur sur le champ de recherche
    txtSearch.addListener(() {
      _performSearch();
    });
  }

  // NOUVEAU: Charger toutes les recettes au démarrage
  Future<void> _loadAllRecipes() async {
    try {
      final recipes = await RecipeService.instance.getAllRecipes();
      setState(() {
        allRecipes = recipes;
        _updateCategoryItemCounts();
        filteredCategories = List.from(menuCategories);
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des recettes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // NOUVEAU: Mettre à jour le nombre d'items par catégorie
  void _updateCategoryItemCounts() {
    for (var category in menuCategories) {
      final count =
          allRecipes
              .where((recipe) => recipe.category == category['name'])
              .length;
      category['items'] = '$count items';
    }
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  // NOUVEAU: Fonction de recherche améliorée
  void _performSearch() {
    final query = txtSearch.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        // Si le champ est vide, afficher toutes les catégories
        filteredCategories = List.from(menuCategories);
        foundRecipes = [];
        displayMode = 'categories';
      } else {
        // Rechercher dans les noms de catégories
        filteredCategories =
            menuCategories
                .where(
                  (category) =>
                      category["name"].toString().toLowerCase().contains(query),
                )
                .toList();

        // CORRECTION: Rechercher dans les VRAIES recettes
        foundRecipes =
            allRecipes.where((recipe) {
              final name = recipe.name.toLowerCase();
              final description = recipe.description.toLowerCase();

              // Chercher dans le nom et la description
              return name.contains(query) || description.contains(query);
            }).toList();

        // Définir le mode d'affichage
        if (foundRecipes.isNotEmpty) {
          displayMode = 'recipes';
        } else if (filteredCategories.isNotEmpty) {
          displayMode = 'categories';
        } else {
          displayMode = 'empty';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Menu",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Menu",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: txtSearch,
                decoration: const InputDecoration(
                  hintText: "Rechercher une recette ou une catégorie",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Affichage selon le mode
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (displayMode) {
      case 'recipes':
        return _buildRecipesList();
      case 'categories':
        return _buildCategoriesList();
      case 'empty':
        return _buildEmptyState();
      default:
        return _buildCategoriesList();
    }
  }

  // NOUVEAU: Affichage des recettes trouvées
  Widget _buildRecipesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Recettes trouvées (${foundRecipes.length})",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: foundRecipes.length,
            itemBuilder: (context, index) {
              final recipe = foundRecipes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.orange,
                        size: 30,
                      ),
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.description,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Catégorie: ${recipe.category}",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 16, color: TColor.primary),
                      Text(
                        "${recipe.prepTime}min",
                        style: TextStyle(
                          fontSize: 10,
                          color: TColor.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // NOUVEAU: Navigation vers les détails de la recette
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailView(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Affichage des catégories (existant mais amélioré)
  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                ),
                child: Image.asset(
                  category["image"],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.restaurant, color: Colors.orange);
                  },
                ),
              ),
            ),
            title: Text(
              category["name"],
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              category["items"],
              style: TextStyle(color: TColor.secondaryText, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CategoryRecipesView(category: category["name"]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Aucun résultat trouvé",
            style: TextStyle(color: TColor.secondaryText, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
