import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text(
                "Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),

              Text(
                "Ajouter vos informations de connexion pour continuer",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              // Titre et sous-titre
              Container(
                decoration: BoxDecoration(
                  color: TColor.texfield,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  autocorrect: false,
                  controller: txtEmail,
                  decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Votre Email",
                    hintStyle: TextStyle(
                      color: TColor.placeholder,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    // prefixIcon: Icon(Icons.email, color: TColor.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
