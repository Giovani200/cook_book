import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/reset_password_view.dart';
import 'package:cook_book/view/login/sing_up_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/view/main_tabview/main_tabview.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/services/user_session.dart';

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
      // Authentifier l'utilisateur avec MongoDB
      final user = await MongoDBService.instance.authenticateUser(
        txtEmail.text.trim(),
        txtPassword.text,
      );

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        // Sauvegarder la session utilisateur
        await UserSession.instance.saveUserSession(user);

        // Rediriger vers l'accueil
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabview()),
          );
        }
      } else {
        _showErrorDialog('Email ou mot de passe incorrect');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Erreur de connexion: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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
              const Text(
                "Connexion",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              Text(
                "Entrez vos identifiants pour vous connecter",
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
                title: isLoading ? "Connexion..." : "Se connecter",
                onPressed: _handleLogin,
                isDisabled: isLoading,
                type:
                    RoundButtonType
                        .primary, // Correction ici : ButtonType -> RoundButtonType
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
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
