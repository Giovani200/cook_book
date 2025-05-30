import 'package:flutter/material.dart';
import 'package:cook_book/common/color_extension.dart';
import 'package:cook_book/common_widget/round_button.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:cook_book/view/login/new_password_view.dart';
// import 'new_password_view.dart';

class OTPView extends StatefulWidget {
  const OTPView({super.key});

  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  // TextEditingController txtEmail = TextEditingController();
  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text(
                "Un code de vérification a été envoyé à votre mobile",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),

              Text(
                "Je vous prie d'entrer le code de vérification",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                height: 60,
                child: OtpPinField(
                  key: _otpPinFieldController,

                  ///in case you want to enable autoFill
                  autoFillEnable: true,

                  ///for Ios it is not needed as the SMS autofill is provided by default, but not for Android, that's where this key is useful.
                  textInputAction: TextInputAction.done,

                  ///in case you want to change the action of keyboard
                  /// to clear the Otp pin Controller
                  onSubmit: (text) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    debugPrint('Entered pin is $text');

                    /// return the entered pin
                  },
                  onChange: (text) {
                    debugPrint('Enter on change pin is $text');

                    /// return the entered pin
                  },
                  onCodeChanged: (code) {
                    debugPrint('onCodeChanged  is $code');
                  },

                  /// to decorate your Otp_Pin_Field
                  otpPinFieldStyle: const OtpPinFieldStyle(
                    /// bool to show hints in pin field or not
                    showHintText: true,

                    /// to set the color of hints in pin field or not
                    // hintTextColor: Colors.red,

                    /// to set the text  of hints in pin field
                    // hintText: '1',

                    /// border color for inactive/unfocused Otp_Pin_Field
                    defaultFieldBorderColor: Colors.grey,

                    /// border color for active/focused Otp_Pin_Field
                    activeFieldBorderColor: Colors.indigo,

                    /// Background Color for inactive/unfocused Otp_Pin_Field
                    // defaultFieldBackgroundColor: Colors.yellow,

                    /// Background Color for active/focused Otp_Pin_Field
                    // activeFieldBackgroundColor: Colors.cyanAccent,

                    /// Background Color for filled field pin box
                    // filledFieldBackgroundColor: Colors.green,

                    /// border Color for filled field pin box
                    // filledFieldBorderColor: Colors.green,
                    //
                    /// gradient border Color for field pin box
                    activeFieldBorderGradient: LinearGradient(
                      colors: [Colors.black, Colors.redAccent],
                    ),
                    filledFieldBorderGradient: LinearGradient(
                      colors: [Colors.green, Colors.tealAccent],
                    ),
                    defaultFieldBorderGradient: LinearGradient(
                      colors: [Colors.orange, Colors.brown],
                    ),
                    fieldBorderWidth: 3,
                  ),
                  maxLength: 4,

                  /// no of pin field
                  showCursor: true,

                  /// bool to show cursor in pin field or not
                  cursorColor: Colors.indigo,

                  /// to choose cursor color
                  upperChild: const Column(
                    children: [
                      SizedBox(height: 30),
                      Icon(Icons.flutter_dash_outlined, size: 150),
                      SizedBox(height: 20),
                    ],
                  ),
                  // 123456

                  ///bool which manage to show custom keyboard
                  // showCustomKeyboard: true,

                  /// Widget which help you to show your own custom keyboard in place if default custom keyboard
                  // customKeyboard: Container(),
                  ///bool which manage to show default OS keyboard
                  // showDefaultKeyboard: true,

                  /// to select cursor width
                  cursorWidth: 3,

                  /// place otp pin field according to yourself
                  mainAxisAlignment: MainAxisAlignment.center,

                  /// predefine decorate of pinField use  OtpPinFieldDecoration.defaultPinBoxDecoration||OtpPinFieldDecoration.underlinedPinBoxDecoration||OtpPinFieldDecoration.roundedPinBoxDecoration
                  ///use OtpPinFieldDecoration.custom  (by using this you can make Otp_Pin_Field according to yourself like you can give fieldBorderRadius,fieldBorderWidth and etc things)
                  otpPinFieldDecoration:
                      OtpPinFieldDecoration.defaultPinBoxDecoration,
                ),
              ),

              const SizedBox(height: 20),
              RoundButton(
                title: "Suivant",
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const SingUpView()));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Vous n'avez pas reçu de code ?",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "Renvoyer en cliquant ici",
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
