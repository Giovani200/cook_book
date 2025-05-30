import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/view/home/home_view.dart';
import 'package:flutter/material.dart';

class MainTabview extends StatefulWidget {
  const MainTabview({super.key});

  @override
  State<MainTabview> createState() => _MainTabviewState();
}

class _MainTabviewState extends State<MainTabview> {
  int selectTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const Center(child: Text("Home"));
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
          child: Image.asset("assets/img/tab_home.png", width: 35, height: 35),
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
                "assets/img/tab_home.png",
                width: 30,
                height: 30,
                color: selectTab == 0 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 0;
                selectPageView = const Center(child: Text("Search"));
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: Image.asset(
                "assets/img/tab_home.png",
                width: 30,
                height: 30,
                color: selectTab == 1 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 1;
                selectPageView = const Center(child: Text("Favorite"));
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(width: 65), // Espace pour le FAB
            IconButton(
              icon: Image.asset(
                "assets/img/tab_home.png",
                width: 30,
                height: 30,
                color: selectTab == 3 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 3;
                selectPageView = const Center(child: Text("Profile"));
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: Image.asset(
                "assets/img/tab_home.png",
                width: 30,
                height: 30,
                color: selectTab == 4 ? TColor.primary : TColor.placeholder,
              ),
              onPressed: () {
                selectTab = 4;
                selectPageView = const Center(child: Text("Settings"));
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
