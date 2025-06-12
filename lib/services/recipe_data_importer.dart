import 'package:mongo_dart/mongo_dart.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDataImporter {
  static final RecipeDataImporter _instance = RecipeDataImporter._internal();
  factory RecipeDataImporter() => _instance;
  RecipeDataImporter._internal();

  static RecipeDataImporter get instance => _instance;

  // Clé pour vérifier si les recettes ont déjà été importées
  static const String _importedKey = 'predefined_recipes_imported';

  // Vérifier si les données ont déjà été importées
  Future<bool> hasBeenImported() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_importedKey) ?? false;
  }

  // Marquer l'importation comme terminée
  Future<void> markAsImported() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_importedKey, true);
  }

  // Importer les recettes depuis les données prédéfinies
  Future<void> importRecipes() async {
    try {
      // Vérifier si les recettes ont déjà été importées
      if (await hasBeenImported()) {
        print('📝 Les recettes prédéfinies ont déjà été importées');
        return;
      }

      print('📝 Début d\'importation des recettes prédéfinies...');

      // Convertir les recettes JSON en objets Recipe
      final List<Recipe> recipes = _createRecipesFromData();

      // Sauvegarder les recettes dans la base de données
      final savedCount = await RecipeService.instance.saveRecipes(recipes);

      print('✅ $savedCount recettes prédéfinies importées avec succès');

      // Marquer l'importation comme terminée
      await markAsImported();
    } catch (e) {
      print('❌ Erreur lors de l\'importation des recettes prédéfinies: $e');
    }
  }

  // Convertir les données JSON en objets Recipe
  List<Recipe> _createRecipesFromData() {
    final List<Recipe> recipes = [];
    final recipeData = _getRecipesData();

    // ID système fictif pour les recettes prédéfinies
    final systemAuthorId = ObjectId();

    for (final data in recipeData) {
      try {
        // Extraire les ingrédients
        final List<String> ingredients =
            (data['ingredients'] as List)
                .map((ingredient) => ingredient['nom'].toString())
                .toList();

        // Joindre les étapes de préparation en une seule chaîne
        final String instructions = (data['etapes_preparation'] as List)
            .map((step) => step.toString())
            .join('\n');

        // Adapter la catégorie au format de l'application
        String category = data['categorie'].toString();
        category = category[0].toUpperCase() + category.substring(1);

        // Mapper "entrée" à "Entrées", "plat" à "Plats", "dessert" à "Desserts"
        switch (category) {
          case "Entrée":
            category = "Entrées";
            break;
          case "Plat":
            category = "Plats";
            break;
          case "Dessert":
            category = "Desserts";
            break;
        }

        // Créer l'objet Recipe
        final recipe = Recipe(
          name: data['nom'],
          description: data['description'],
          ingredients: ingredients,
          instructions: instructions,
          preparation:
              instructions, // Utiliser les mêmes instructions comme préparation
          prepTime: data['temps_preparation_minutes'],
          cookingTime: data['temps_cuisson_minutes'],
          servings: 4, // Valeur par défaut
          category: category,
          imageUrl: data['image'],
          complexity:
              ingredients.length > 8
                  ? 3
                  : ingredients.length > 5
                  ? 2
                  : 1,
          authorId: systemAuthorId,
          likes: 0,
        );

        recipes.add(recipe);
      } catch (e) {
        print(
          '❌ Erreur lors de la conversion de la recette "${data['nom']}": $e',
        );
      }
    }

    return recipes;
  }

  // Données JSON des recettes (liste complète)
  List<Map<String, dynamic>> _getRecipesData() {
    return [
      {
        "id": 1,
        "nom": "Salade de chèvre chaud",
        "description":
            "Salade verte agrémentée de toasts de fromage de chèvre fondant, noix et miel.",
        "categorie": "entrée",
        "ingredients": [
          {"id": 1, "nom": "Salade verte (laitue, roquette)"},
          {"id": 2, "nom": "Fromage de chèvre"},
          {"id": 3, "nom": "Pain de campagne"},
          {"id": 4, "nom": "Noix concassées"},
          {"id": 5, "nom": "Miel"},
          {"id": 6, "nom": "Huile d'olive"},
          {"id": 7, "nom": "Vinaigre balsamique"},
        ],
        "etapes_preparation": [
          "Préchauffer le four à 180 °C.",
          "Couper le pain en tranches, déposer une rondelle de chèvre sur chaque toast et arroser de miel.",
          "Enfourner 10 minutes.",
          "Dresser la salade dans les assiettes, déposer les toasts chauds dessus.",
          "Parsemer de noix, arroser d'huile d'olive et de vinaigre balsamique.",
        ],
        "temps_preparation_minutes": 15,
        "temps_cuisson_minutes": 10,
        "image": "https://via.placeholder.com/150?text=Salade+de+chevre+chaud",
      },
      {
        "id": 2,
        "nom": "Bruschetta aux tomates",
        "description":
            "Petites tranches de pain grillé garnies d'un mélange de tomates, ail et basilic.",
        "categorie": "entrée",
        "ingredients": [
          {"id": 1, "nom": "Pain italien"},
          {"id": 2, "nom": "Tomates mûres"},
          {"id": 3, "nom": "Gousse d'ail"},
          {"id": 4, "nom": "Basilic frais"},
          {"id": 5, "nom": "Huile d'olive"},
          {"id": 6, "nom": "Sel et poivre"},
        ],
        "etapes_preparation": [
          "Couper le pain en tranches et les griller légèrement.",
          "Frotter l'ail sur les tranches grillées.",
          "Mélanger tomates coupées en dés, basilic ciselé, huile d'olive, sel et poivre.",
          "Déposer le mélange sur les toasts juste avant de servir.",
        ],
        "temps_preparation_minutes": 10,
        "temps_cuisson_minutes": 5,
        "image": "https://via.placeholder.com/150?text=Bruschetta+aux+tomates",
      },
      {
        "id": 3,
        "nom": "Soupe à l'oignon gratinée",
        "description":
            "Soupe d'oignons caramélisés, gratinée au four avec du fromage et des croûtons.",
        "categorie": "entrée",
        "ingredients": [
          {"id": 1, "nom": "Oignons"},
          {"id": 2, "nom": "Beurre"},
          {"id": 3, "nom": "Bouillon de bœuf"},
          {"id": 4, "nom": "Pain"},
          {"id": 5, "nom": "Gruyère râpé"},
          {"id": 6, "nom": "Thym"},
          {"id": 7, "nom": "Laurier"},
        ],
        "etapes_preparation": [
          "Émincer les oignons et les faire revenir dans le beurre jusqu'à caramélisation.",
          "Ajouter le bouillon, le thym et le laurier. Laisser mijoter 20 minutes.",
          "Verser la soupe dans des bols, déposer une tranche de pain sur chaque bol, parsemer de gruyère.",
          "Passer sous le gril du four 5 minutes jusqu'à gratin.",
        ],
        "temps_preparation_minutes": 15,
        "temps_cuisson_minutes": 25,
        "image":
            "https://via.placeholder.com/150?text=Soupe+a+l%27oignon+gratinée",
      },
      // Restant des recettes d'entrées...
      {
        "id": 4,
        "nom": "Gazpacho andalou",
        "description":
            "Soupe froide de légumes méditerranéens mixés, idéale par temps chaud.",
        "categorie": "entrée",
        "ingredients": [
          {"id": 1, "nom": "Tomates"},
          {"id": 2, "nom": "Concombre"},
          {"id": 3, "nom": "Poivron rouge"},
          {"id": 4, "nom": "Oignon"},
          {"id": 5, "nom": "Gousse d'ail"},
          {"id": 6, "nom": "Huile d'olive"},
          {"id": 7, "nom": "Vinaigre de xérès"},
          {"id": 8, "nom": "Sel"},
        ],
        "etapes_preparation": [
          "Couper tous les légumes en gros morceaux.",
          "Mixer avec l'ail, l'huile, le vinaigre et le sel jusqu'à obtenir une consistance lisse.",
          "Réfrigérer au moins 2 heures avant de servir.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 0,
        "image": "https://via.placeholder.com/150?text=Gazpacho+andalou",
      },
      {
        "id": 5,
        "nom": "Œufs mimosa",
        "description":
            "Œufs durs garnis d'une mousse à base de jaune d'œuf et mayonnaise.",
        "categorie": "entrée",
        "ingredients": [
          {"id": 1, "nom": "Œufs"},
          {"id": 2, "nom": "Mayonnaise"},
          {"id": 3, "nom": "Ciboulette"},
          {"id": 4, "nom": "Sel et poivre"},
        ],
        "etapes_preparation": [
          "Cuire les œufs 10 minutes dans l'eau bouillante.",
          "Écaler, couper en deux et extraire délicatement les jaunes.",
          "Écraser les jaunes, mélanger avec la mayonnaise, sel, poivre et ciboulette ciselée.",
          "Farcir les blancs avec ce mélange et saupoudrer d'un peu de ciboulette.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 10,
        "image": "https://via.placeholder.com/150?text=Oeufs+mimosa",
      },
      // Plats principaux
      {
        "id": 6,
        "nom": "Bœuf bourguignon",
        "description":
            "Ragoût de bœuf mijoté au vin rouge, lardons et champignons.",
        "categorie": "plat",
        "ingredients": [
          {"id": 1, "nom": "Bœuf (macreuse ou paleron)"},
          {"id": 2, "nom": "Vin rouge"},
          {"id": 3, "nom": "Carottes"},
          {"id": 4, "nom": "Oignons"},
          {"id": 5, "nom": "Lardons"},
          {"id": 6, "nom": "Champignons de Paris"},
          {"id": 7, "nom": "Ail"},
          {"id": 8, "nom": "Bouquet garni"},
        ],
        "etapes_preparation": [
          "Couper le bœuf en gros cubes, les saisir à la cocotte puis réserver.",
          "Faire revenir les lardons, oignons et carottes.",
          "Remettre la viande, ajouter l'ail, le bouquet garni et recouvrir de vin.",
          "Laisser mijoter à feu très doux 3 heures.",
        ],
        "temps_preparation_minutes": 30,
        "temps_cuisson_minutes": 180,
        "image": "https://via.placeholder.com/150?text=Boeuf+bourguignon",
      },
      // ... tous les plats principaux
      {
        "id": 7,
        "nom": "Poulet rôti au thym et citron",
        "description":
            "Poulet fermier rôti, parfumé au thym frais et quartiers de citron.",
        "categorie": "plat",
        "ingredients": [
          {"id": 1, "nom": "Poulet entier"},
          {"id": 2, "nom": "Thym frais"},
          {"id": 3, "nom": "Citrons"},
          {"id": 4, "nom": "Beurre"},
          {"id": 5, "nom": "Sel et poivre"},
        ],
        "etapes_preparation": [
          "Préchauffer le four à 200 °C.",
          "Enduire le poulet de beurre, saler, poivrer, glisser du thym et des quartiers de citron à l'intérieur.",
          "Rôtir 1 heure en arrosant régulièrement.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 60,
        "image": "https://via.placeholder.com/150?text=Poulet+roti+au+thym",
      },
      {
        "id": 8,
        "nom": "Ratatouille provençale",
        "description":
            "Mélange mijoté d'aubergines, courgettes, poivrons et tomates.",
        "categorie": "plat",
        "ingredients": [
          {"id": 1, "nom": "Aubergines"},
          {"id": 2, "nom": "Courgettes"},
          {"id": 3, "nom": "Poivrons (rouge, jaune)"},
          {"id": 4, "nom": "Tomates"},
          {"id": 5, "nom": "Oignon"},
          {"id": 6, "nom": "Ail"},
          {"id": 7, "nom": "Herbes de Provence"},
          {"id": 8, "nom": "Huile d'olive"},
        ],
        "etapes_preparation": [
          "Couper tous les légumes en cubes.",
          "Faire revenir aubergines et courgettes séparément, réserver.",
          "Dans la même poêle, revenir oignon, poivrons et ail, ajouter tomates.",
          "Remettre aubergines et courgettes, assaisonner et laisser mijoter 30 minutes.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 40,
        "image": "https://via.placeholder.com/150?text=Ratatouille+provencale",
      },
      {
        "id": 9,
        "nom": "Quiche lorraine",
        "description":
            "Tarte salée garnie de lardons et d'une crème œufs-fromage.",
        "categorie": "plat",
        "ingredients": [
          {"id": 1, "nom": "Pâte brisée"},
          {"id": 2, "nom": "Lardons"},
          {"id": 3, "nom": "Crème fraîche"},
          {"id": 4, "nom": "Œufs"},
          {"id": 5, "nom": "Gruyère râpé"},
          {"id": 6, "nom": "Noix de muscade"},
        ],
        "etapes_preparation": [
          "Préchauffer le four à 180 °C.",
          "Faire revenir les lardons, laisser refroidir.",
          "Battre œufs, crème et muscade, incorporer les lardons et le gruyère.",
          "Verser sur la pâte, cuire 35 minutes.",
        ],
        "temps_preparation_minutes": 15,
        "temps_cuisson_minutes": 35,
        "image": "https://via.placeholder.com/150?text=Quiche+lorraine",
      },
      {
        "id": 10,
        "nom": "Curry de légumes",
        "description": "Mélange épicé de légumes mijotés au lait de coco.",
        "categorie": "plat",
        "ingredients": [
          {"id": 1, "nom": "Carottes"},
          {"id": 2, "nom": "Pommes de terre"},
          {"id": 3, "nom": "Pois chiches"},
          {"id": 4, "nom": "Poivron"},
          {"id": 5, "nom": "Oignon"},
          {"id": 6, "nom": "Pâte de curry"},
          {"id": 7, "nom": "Lait de coco"},
          {"id": 8, "nom": "Huile"},
        ],
        "etapes_preparation": [
          "Faire revenir l'oignon dans l'huile, ajouter la pâte de curry.",
          "Incorporer les légumes coupés, mijoter 5 minutes.",
          "Ajouter les pois chiches et le lait de coco, cuire 20 minutes.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 30,
        "image": "https://via.placeholder.com/150?text=Curry+de+legumes",
      },
      // ... desserts
      {
        "id": 16,
        "nom": "Tarte aux pommes",
        "description":
            "Pâte brisée croustillante garnie de fines tranches de pommes et sucre vanillé.",
        "categorie": "dessert",
        "ingredients": [
          {"id": 1, "nom": "Pâte brisée"},
          {"id": 2, "nom": "Pommes"},
          {"id": 3, "nom": "Sucre"},
          {"id": 4, "nom": "Beurre"},
          {"id": 5, "nom": "Sucre vanillé"},
        ],
        "etapes_preparation": [
          "Préchauffer le four à 180 °C.",
          "Étaler la pâte dans un moule, piquer le fond.",
          "Disposer les pommes en fines tranches, saupoudrer de sucre et déposer quelques noisettes de beurre.",
          "Cuire 35 minutes.",
        ],
        "temps_preparation_minutes": 15,
        "temps_cuisson_minutes": 35,
        "image": "https://via.placeholder.com/150?text=Tarte+aux+pommes",
      },
      {
        "id": 17,
        "nom": "Mousse au chocolat",
        "description":
            "Mousse légère et aérienne à base de chocolat noir et œufs.",
        "categorie": "dessert",
        "ingredients": [
          {"id": 1, "nom": "Chocolat noir"},
          {"id": 2, "nom": "Œufs"},
          {"id": 3, "nom": "Sucre"},
          {"id": 4, "nom": "Beurre"},
        ],
        "etapes_preparation": [
          "Faire fondre le chocolat et le beurre au bain-marie.",
          "Séparer les blancs des jaunes, incorporer les jaunes au chocolat.",
          "Monter les blancs en neige avec le sucre, incorporer délicatement.",
          "Réfrigérer 3 heures.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 0,
        "image": "https://via.placeholder.com/150?text=Mousse+au+chocolat",
      },
      {
        "id": 18,
        "nom": "Crème brûlée",
        "description":
            "Crème onctueuse parfumée à la vanille, surface caramélisée au sucre.",
        "categorie": "dessert",
        "ingredients": [
          {"id": 1, "nom": "Crème liquide"},
          {"id": 2, "nom": "Jaunes d'œufs"},
          {"id": 3, "nom": "Sucre"},
          {"id": 4, "nom": "Gousse de vanille"},
        ],
        "etapes_preparation": [
          "Préchauffer le four à 150 °C.",
          "Fendre et gratter la vanille dans la crème, porter presque à ébullition.",
          "Blanchir jaunes et sucre, verser la crème, répartir en ramequins.",
          "Cuire au bain-marie 40 minutes, réfrigérer 2 heures.",
          "Parsemer de sucre et caraméliser au chalumeau.",
        ],
        "temps_preparation_minutes": 20,
        "temps_cuisson_minutes": 40,
        "image": "https://via.placeholder.com/150?text=Creme+brulee",
      },
      {
        "id": 19,
        "nom": "Tiramisu",
        "description":
            "Dessert italien composé de biscuits imbibés de café et crème au mascarpone.",
        "categorie": "dessert",
        "ingredients": [
          {"id": 1, "nom": "Mascarpone"},
          {"id": 2, "nom": "Œufs"},
          {"id": 3, "nom": "Sucre"},
          {"id": 4, "nom": "Biscuits à la cuillère"},
          {"id": 5, "nom": "Café"},
          {"id": 6, "nom": "Cacao en poudre"},
        ],
        "etapes_preparation": [
          "Séparer blancs et jaunes, blanchir jaunes avec le sucre, incorporer le mascarpone.",
          "Monter les blancs en neige, les incorporer délicatement.",
          "Tremper rapidement les biscuits dans le café, disposer une couche au fond d'un plat, couvrir de crème.",
          "Renouveler l'opération, saupoudrer de cacao et réfrigérer 4 heures.",
        ],
        "temps_preparation_minutes": 25,
        "temps_cuisson_minutes": 0,
        "image": "https://via.placeholder.com/150?text=Tiramisu",
      },
      {
        "id": 20,
        "nom": "Panna cotta à la vanille",
        "description":
            "Crème cuite italienne légère, parfumée à la vanille et servie avec un coulis de fruits.",
        "categorie": "dessert",
        "ingredients": [
          {"id": 1, "nom": "Crème liquide"},
          {"id": 2, "nom": "Gousse de vanille"},
          {"id": 3, "nom": "Sucre"},
          {"id": 4, "nom": "Gélatine"},
        ],
        "etapes_preparation": [
          "Faire ramollir la gélatine dans de l'eau froide.",
          "Faire chauffer la crème, le sucre et la vanille sans bouillir.",
          "Hors du feu, ajouter la gélatine essorée, mélanger et verser en moules.",
          "Réfrigérer 4 heures et démouler avant de servir avec un coulis.",
        ],
        "temps_preparation_minutes": 15,
        "temps_cuisson_minutes": 5,
        "image": "https://via.placeholder.com/150?text=Panna+cotta+vanille",
      },
    ];
  }
}
