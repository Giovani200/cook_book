import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_session.dart';
import '../../services/mongodb_service.dart';
import '../../common/app_colors.dart';

class EditProfileView extends StatefulWidget {
  final User user;

  const EditProfileView({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer un utilisateur mis à jour
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: widget.user.password,
        mobile: widget.user.mobile,
        createdAt: widget.user.createdAt,
      );

      // Mettre à jour la session
      await UserSession.instance.saveUserSession(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Modifier le profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.user.name.isNotEmpty
                        ? widget.user.name[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Champ nom
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Champ email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'L\'email est requis';
                  }
                  if (!value!.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Sauvegarder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
