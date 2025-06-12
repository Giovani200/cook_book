import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/services/user_session.dart';
import 'package:cook_book/models/user_model.dart';
import 'package:cook_book/view/main_tabview/main_tabview.dart';

class SingUpView extends StatefulWidget {
  const SingUpView({super.key});

  @override
  State<SingUpView> createState() => _SingUpViewState();
}

class _SingUpViewState extends State<SingUpView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  bool isLoading = false;

  Future<void> _registerUser() async {
    // Validation des champs
    if (txtName.text.isEmpty ||
        txtEmail.text.isEmpty ||
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
      print("Tentative d'inscription avec MongoDB: ${txtEmail.text}");

      // Vérifier si l'utilisateur existe déjà dans MongoDB
      final existingUser = await MongoDBService.instance.findUserByEmail(
        txtEmail.text.trim().toLowerCase(),
      );

      if (existingUser != null) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Un compte avec cet email existe déjà');
        return;
      }

      // Créer l'utilisateur pour MongoDB
      User newUser = User(
        id: null,
        name: txtName.text.trim(),
        email: txtEmail.text.trim().toLowerCase(),
        password: txtPassword.text,
        createdAt: DateTime.now(),
      );

      // Enregistrer dans MongoDB
      final success = await MongoDBService.instance.createUser(newUser);

      setState(() {
        isLoading = false;
      });

      if (success) {
        // SUPPRESSION de la vérification qui pose problème
        // L'inscription a réussi, rediriger directement vers login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Inscription réussie! Vous pouvez maintenant vous connecter.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Rediriger vers la page de connexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        }
      } else {
        _showErrorDialog('Erreur lors de l\'enregistrement en base de données');
      }
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

  void _handleRegister() {
    if (!isLoading) {
      _registerUser();
    }
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
                "Inscription",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              Text(
                "Ajoutez vos informations pour vous inscrire",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              RoundTextfield(
                hintText: "Votre nom",
                controller: txtName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 15),
              RoundTextfield(
                hintText: "Confirmer votre mot de passe",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              RoundButton(
                title: isLoading ? "Inscription en cours..." : "S'inscrire",
                onPressed: _handleRegister,
                isDisabled: isLoading,
                type: RoundButtonType.primary, // Ajout du type correct
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                  child: Text(
                    "Vous avez déjà un compte ? Se connecter",
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
