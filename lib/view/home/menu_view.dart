import 'package:cook_book/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/view/home/category_recettes_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  TextEditingController txtSearch = TextEditingController();

  // Liste des catégories de menu (liste originale)
  final List<Map<String, dynamic>> menuCategories = [
    {
      "name": "Entrées",
      "image": "assets/img/entrees.webp",
      "items": "56 items",
    },
    {"name": "Plats", "image": "assets/img/plat.webp", "items": "45 items"},
    {
      "name": "Desserts",
      "image": "assets/img/dessert.webp",
      "items": "34 items",
    },
  ];

  // Liste filtrée qui sera affichée
  List<Map<String, dynamic>> filteredCategories = [];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser la liste filtrée avec toutes les catégories
    filteredCategories = List.from(menuCategories);

    // Ajouter un écouteur sur le champ de recherche
    txtSearch.addListener(() {
      filterCategories();
    });
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  // Fonction pour filtrer les catégories selon le texte saisi
  void filterCategories() {
    final query = txtSearch.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // Si le champ est vide, afficher toutes les catégories
        filteredCategories = List.from(menuCategories);
      } else {
        // Sinon filtrer selon le nom
        filteredCategories =
            menuCategories
                .where(
                  (category) =>
                      category["name"].toString().toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
          ),
        ],
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
                decoration: InputDecoration(
                  hintText: "Search food",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  // Pas besoin de code ici, le listener s'en charge
                },
              ),
            ),
          ),

          // Message quand aucun résultat n'est trouvé
          if (filteredCategories.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun résultat trouvé",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Liste des catégories filtrées
          if (filteredCategories.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CategoryRecipesView(
                                  category: category["name"],
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
