import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/view/home/home_view.dart';
import 'package:cook_book/view/home/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/view/home/add_recipe_view.dart';
import 'package:cook_book/view/home/profil_view.dart';
import 'package:cook_book/view/home/settings_view.dart';

class MainTabview extends StatefulWidget {
  const MainTabview({super.key});

  @override
  State<MainTabview> createState() => _MainTabviewState();
}

class _MainTabviewState extends State<MainTabview> {
  int selectTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView =
      const HomeView(); // Changez ici pour afficher HomeView par défaut
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            if (selectTab != 2) {
              selectTab = 2;
              selectPageView = const HomeView();
              if (mounted) {
                setState(() {});
              }
            }
          },
          shape: const CircleBorder(),
          backgroundColor: selectTab == 2 ? TColor.primary : TColor.placeholder,
          child: Image.asset("assets/img/tab_home.webp", width: 35, height: 35),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: TColor.secondaryText,
        surfaceTintColor: TColor.secondaryText,
        elevation: 1,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Image.asset(
                "assets/img/tab_menu.webp", // Changé de .webp à .webp
                width: 30,
                height: 30,
              ),
              onPressed: () {
                if (selectTab != 0) {
                  selectTab = 0;
                  selectPageView = const MenuView();
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
            ),
            IconButton(
              icon: Image.asset(
                "assets/img/tab_add.webp", // Nouveau nom pour l'icône d'ajout
                width: 30,
                height: 30,
                color: selectTab == 1 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 1;
                selectPageView = const AddRecipeView();
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(width: 65), // Espace pour le FAB
            IconButton(
              icon: Image.asset(
                "assets/img/tab_profile.webp",
                width: 30,
                height: 30,
                color: selectTab == 3 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 3;
                selectPageView =
                    const ProfilView(); // CHANGEMENT: Utiliser ProfilView
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: Image.asset(
                "assets/img/tab_settings.webp",
                width: 30,
                height: 30,
                color: selectTab == 4 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 4;
                selectPageView =
                    const SettingsView(); // CHANGEMENT: Utiliser SettingsView
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
