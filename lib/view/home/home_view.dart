import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/category_call.dart';
import 'package:cook_book/common_widget/most_popular_cell.dart';
import 'package:cook_book/common_widget/recent_item_row.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/common_widget/view_all_title_row.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  //
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  // Liste des plats avec différentes informations
  final List<Map<String, dynamic>> recipes = [
    {
      "name": "Spaghetti Carbonara",
      "description":
          "Une recette italienne classique avec œufs, fromage et lardons",
      "image": "assets/img/burger.png", // Chemin vers l'image du plat 1
    },
    {
      "name": "Poulet rôti",
      "description": "Poulet doré au four avec herbes et légumes de saison",
      "image": "assets/img/burger.png", // Chemin vers l'image du plat 2
    },
    {
      "name": "Salade César",
      "description": "Laitue romaine, croûtons, parmesan et sauce crémeuse",
      "image": "assets/img/burger.png", // Chemin vers l'image du plat 3
    },
    {
      "name": "Burger maison",
      "description": "Steak haché, cheddar fondu et sauce spéciale",
      "image": "assets/img/burger.png", // Chemin vers l'image du plat 4
    },
  ];

  // catégorie de plats

  List catArr = [
    {
      "name": "Entrées",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Entrées
    },
    {
      "name": "Plats principaux",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Plats principaux
    },
    {
      "name": "Desserts",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Desserts
    },
    {
      "name": "Boissons",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Boissons
    },
  ];

  List mostPopArr = [
    {
      "name": "spaghetti",
      "image":
          "assets/img/spaghetti.jpg", // Chemin vers l'image de la catégorie Entrées
      "rate": "4", // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },
    {
      "name": "pancakes",
      "image":
          "assets/img/pancakes.jpg", // Chemin vers l'image de la catégorie Plats principaux
      "rate": 4, // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },
  ];

  List recentArr = [
    {
      "name": "Entrées",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Entrées
      "rate": 4, // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },
    {
      "name": "Plats principaux",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Plats principaux
      "rate": 4, // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },
    {
      "name": "Entrées",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Entrées
      "rate": 4, // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },

    {
      "name": "Plats principaux",
      "image":
          "assets/img/burger.png", // Chemin vers l'image de la catégorie Plats principaux
      "rate": 4, // Note de popularité
      "rating": "124",
      "type": "entree", // Type de la catégorie
      "food_type": "entree", // Type de la catégorie
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(
                    //   height: 64), // Espace à gauche
                    Text(
                      "Good Morning Mohamed!",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/img/profil.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Espace entre le texte et la liste
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Liste horizontale défilante de plats
              SizedBox(
                height: 150,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Partie gauche: description et bouton
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipes[index]["name"], // Nom du plat de la liste
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  recipes[index]["description"], // Description du plat de la liste
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text("Voir la recette"),
                                ),
                              ],
                            ),
                          ),

                          // Partie droite: image
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Image.asset(
                                  recipes[index]["image"], // Image spécifique au plat
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Titre pour la section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "Catégorie de plats",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: catArr.length,
                  itemBuilder: ((context, index) {
                    var cObj = catArr[index] as Map? ?? {};
                    return CategoryCall(cObj: cObj, onTap: () {});
                  }),
                ),
              ),

              // const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Popular Recipes", onView: () {}),
              ),




              

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Most popular", onView: () {}),
              ),

              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: mostPopArr.length,
                  itemBuilder: ((context, index) {
                    var mObj = mostPopArr[index] as Map? ?? {};
                    return MostPopularCell(mObj: mObj, onTap: () {});
                  }),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(title: "Recent Items", onView: () {}),
              ),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: recentArr.length,
                itemBuilder: ((context, index) {
                  var rObj = recentArr[index] as Map? ?? {};
                  return RecentItemRow(rObj: rObj, onTap: () {});
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
