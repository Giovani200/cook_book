import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
// import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/models/user_model.dart';

class SingUpView extends StatefulWidget {
  const SingUpView({super.key});

  @override
  State<SingUpView> createState() => _SingUpViewState();
}

class _SingUpViewState extends State<SingUpView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  bool isLoading = false;

  Future<void> _registerUser() async {
    // Validation des champs
    if (txtName.text.isEmpty ||
        txtEmail.text.isEmpty ||
        txtMobile.text.isEmpty ||
        txtPassword.text.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      _showErrorDialog('Les mots de passe ne correspondent pas');
      return;
    }

    if (txtPassword.text.length < 6) {
      _showErrorDialog('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Simuler un délai d'inscription
      await Future.delayed(const Duration(seconds: 1));

      // Créer l'utilisateur (stockage temporaire en mémoire)
      User newUser = User(
        name: txtName.text.trim(),
        email: txtEmail.text.trim().toLowerCase(),
        mobile: txtMobile.text.trim(),
        password: txtPassword.text,
        createdAt: DateTime.now(),
      );

      // Pour l'instant, on simule juste le succès
      print('Utilisateur créé: ${newUser.name} - ${newUser.email}');

      setState(() {
        isLoading = false;
      });

      // Afficher message de succès
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Erreur lors de l\'inscription: ${e.toString()}');
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text('Compte créé avec succès ! Vous pouvez maintenant vous connecter.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: Text('Se connecter'),
            ),
          ],
        );
      },
    );
  }

  void _handleRegister() {
    if (!isLoading) {
      _registerUser();
    }
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
                "Inscription",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),

              Text(
                "Ajouter vos informations pour vous inscrire",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Votre nom",
                controller: txtName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Votre email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Votre Mobile",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Votre mot de passe",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Confirmer votre mot de passe",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),

              RoundButton(
                title: isLoading ? "Inscription en cours..." : "S'inscrire",
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 3),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Vous avez un compte ?",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Se connecter",
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
