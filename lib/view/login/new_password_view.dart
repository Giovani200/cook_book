import 'package:cook_book/common_widget/round_button.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/services/mongodb_service.dart';
import 'package:cook_book/view/login/login_view.dart';

class NewPasswordView extends StatefulWidget {
  final String email;

  const NewPasswordView({super.key, required this.email});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  bool isLoading = false;

  Future<void> _updatePassword() async {
    if (txtPassword.text.isEmpty || txtConfirmPassword.text.isEmpty) {
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
      // Mettre à jour le mot de passe dans MongoDB
      final success = await MongoDBService.instance.updateUserPassword(
        widget.email,
        txtPassword.text,
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        // Afficher le message de succès et rediriger vers la connexion
        _showSuccessDialog();
      } else {
        _showErrorDialog('Erreur lors de la mise à jour du mot de passe');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Erreur: ${e.toString()}');
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Succès'),
          content: const Text('Votre mot de passe a été mis à jour avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text('Se connecter'),
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
                "Nouveau mot de passe",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              Text(
                "Créez un nouveau mot de passe pour votre compte",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              RoundTextfield(
                hintText: "Nouveau mot de passe",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              RoundTextfield(
                hintText: "Confirmer le mot de passe",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              RoundButton(
                type:
                    RoundButtonType
                        .primary, // Correction ici : ButtonType -> RoundButtonType
                title: isLoading ? "Mise à jour..." : "Mettre à jour",
                onPressed: _updatePassword,
                isDisabled: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
