import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/reset_password_view.dart';
import 'package:cook_book/view/login/sing_up_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/view/main_tabview/main_tabview.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (txtEmail.text.isEmpty || txtPassword.text.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Simuler une vérification de connexion
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        isLoading = false;
      });

      // Rediriger vers l'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainTabview(),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Erreur de connexion');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
              RoundTextfield(
                hintText: "your mail",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              RoundTextfield(
                hintText: "your password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(
                title: isLoading ? "Connexion..." : "Login", 
                onPressed: isLoading ? () {} : _handleLogin,
              ),
              const SizedBox(height: 3),

              //forgot
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SingUpView()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ?",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
