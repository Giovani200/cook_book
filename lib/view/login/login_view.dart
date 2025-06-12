import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/sing_up_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/services/user_session.dart';
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

  Future<void> _loginUser() async {
    if (txtEmail.text.isEmpty || txtPassword.text.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("=== TENTATIVE DE CONNEXION ===");
      print("Email: ${txtEmail.text.trim()}");

      // Authentifier avec MongoDB (corrigé)
      final user = await MongoDBService.instance.authenticateUser(
        txtEmail.text.trim().toLowerCase(),
        txtPassword.text,
      );

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        print("✅ CONNEXION RÉUSSIE pour: ${user.name}");

        // Sauvegarder la session
        await UserSession.instance.saveUserSession(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connexion réussie! Bienvenue ${user.name}'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabview()),
          );
        }
      } else {
        print("❌ CONNEXION ÉCHOUÉE");
        _showErrorDialog('Email ou mot de passe incorrect');
      }
    } catch (e) {
      print("❌ ERREUR DE CONNEXION: $e");
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  // Wrapper pour éviter les problèmes de type avec onPressed
  void _handleLogin() {
    if (!isLoading) {
      _loginUser();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Connexion",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              Text(
                "Connectez-vous à votre compte",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              RoundTextfield(
                hintText: "Votre email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              RoundTextfield(
                hintText: "Votre mot de passe",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              RoundButton(
                title: isLoading ? "Connexion en cours..." : "Se connecter",
                onPressed: _handleLogin,
                type: RoundButtonType.primary,
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SingUpView(),
                      ),
                    );
                  },
                  child: Text(
                    "Vous n'avez pas de compte ? S'inscrire",
                    style: TextStyle(
                      color: TColor.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
