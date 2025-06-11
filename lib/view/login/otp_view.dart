import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:cook_book/view/login/new_password_view.dart';

class OTPView extends StatefulWidget {
  final String email;

  const OTPView({super.key, required this.email});

  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();
  String _enteredOTP = '';
  bool _isVerifying = false;

  // Simuler l'envoi d'un code OTP par email
  final String _mockOTP =
      '1234'; // Dans une vraie application, ce serait envoyé par email

  void _verifyOTP() async {
    if (_enteredOTP.length != 4) {
      _showErrorDialog('Veuillez entrer un code à 4 chiffres');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simuler une vérification (dans une vraie app, cela serait vérifié côté serveur)
    await Future.delayed(const Duration(seconds: 1));

    if (_enteredOTP == _mockOTP) {
      setState(() {
        _isVerifying = false;
      });

      // Rediriger vers la page de nouveau mot de passe
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordView(email: widget.email),
          ),
        );
      }
    } else {
      setState(() {
        _isVerifying = false;
      });
      _showErrorDialog('Code de vérification incorrect');
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

  void _resendOTP() {
    // Simuler l'envoi d'un nouveau code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Un nouveau code a été envoyé à ${widget.email}'),
        backgroundColor: TColor.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primary),
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
                "Vérification par code",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                "Un code de vérification a été envoyé à",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.email,
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 60,
                child: OtpPinField(
                  key: _otpPinFieldController,
                  autoFillEnable: true,
                  textInputAction: TextInputAction.done,
                  onSubmit: (text) {
                    _enteredOTP = text;
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  onChange: (text) {
                    _enteredOTP = text;
                  },
                  otpPinFieldStyle: OtpPinFieldStyle(
                    showHintText: true,
                    defaultFieldBorderColor: Colors.grey,
                    activeFieldBorderColor: TColor.primary,
                    fieldBorderWidth: 2,
                  ),
                  maxLength: 4,
                  showCursor: true,
                  cursorColor: TColor.primary,
                  upperChild: Column(
                    children: [
                      SizedBox(height: 30),
                      Icon(Icons.mail_outline, size: 80, color: TColor.primary),
                      SizedBox(height: 20),
                    ],
                  ),
                  cursorWidth: 2,
                  mainAxisAlignment: MainAxisAlignment.center,
                  otpPinFieldDecoration:
                      OtpPinFieldDecoration.defaultPinBoxDecoration,
                ),
              ),
              const SizedBox(height: 40),
              RoundButton(
                title: _isVerifying ? "Vérification..." : "Vérifier",
                onPressed: _verifyOTP,
                isDisabled: _isVerifying,
                type: RoundButtonType.primary, // Ajout du type correct
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _resendOTP,
                  child: Text(
                    "Vous n'avez pas reçu de code ? Renvoyer",
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
