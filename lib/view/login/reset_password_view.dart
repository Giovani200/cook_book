import 'package:cook_book/common_widget/round_button.dart';
import 'package:cook_book/view/login/otp_view.dart';
import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_textfield.dart';
import 'package:cook_book/services/mongodb_service.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  TextEditingController txtEmail = TextEditingController();
  bool isLoading = false;

  Future<void> _sendResetCode() async {
    if (txtEmail.text.isEmpty) {
      _showErrorDialog('Veuillez entrer votre adresse email');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Vérifier si l'utilisateur existe
      final user = await MongoDBService.instance.findUserByEmail(
        txtEmail.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        // Utilisateur trouvé, naviguer vers la page OTP
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPView(email: txtEmail.text.trim()),
            ),
          );
        }
      } else {
        _showErrorDialog('Aucun compte associé à cet email');
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
                "Réinitialiser le mot de passe",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              Text(
                "Entrez votre email pour recevoir un code de réinitialisation",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              RoundTextfield(
                hintText: "Votre email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              RoundButton(
                title: isLoading ? "Envoi en cours..." : "Envoyer le code",
                onPressed: _sendResetCode,
                isDisabled: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
