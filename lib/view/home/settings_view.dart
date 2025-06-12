import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/app_colors.dart';
import '../../services/user_session.dart';
import '../../models/user_model.dart';
import '../login/welcome_view.dart';
import 'edit_profile_view.dart';
import 'about_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  User? _currentUser;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _isLoading = true;
  String _selectedLanguage = 'Français';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    final user = await UserSession.instance.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _selectedLanguage = prefs.getString('selected_language') ?? 'Français';
      });
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      await prefs.setString('selected_language', _selectedLanguage);
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await UserSession.instance.clearUserSession();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeView(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vider le cache'),
          content: Text(
            'Cette action supprimera les données temporaires. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Simuler la suppression du cache
                await Future.delayed(Duration(seconds: 1));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cache vidé avec succès'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: Text('Vider'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête utilisateur
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 30, left: 20, right: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        _currentUser?.name.isNotEmpty == true
                            ? _currentUser!.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.name ?? 'Utilisateur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currentUser?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Section Compte
            _buildSectionTitle('Compte'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Modifier le profil',
                subtitle: 'Nom, email, mot de passe',
                onTap: () async {
                  if (_currentUser != null) {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProfileView(user: _currentUser!),
                      ),
                    );
                    if (updatedUser != null) {
                      setState(() {
                        _currentUser = updatedUser;
                      });
                    }
                  }
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Confidentialité',
                subtitle: 'Paramètres de confidentialité',
                onTap: () {
                  _showComingSoonDialog('Confidentialité');
                },
              ),
            ]),

            SizedBox(height: 20),

            // Section Préférences
            _buildSectionTitle('Préférences'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Recevoir des notifications push',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                subtitle: 'Thème sombre de l\'application',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Redémarrez l\'app pour voir les changements',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Langue',
                subtitle: _selectedLanguage,
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ]),

            SizedBox(height: 20),

            // Section Données et stockage
            _buildSectionTitle('Données et stockage'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.delete_sweep,
                title: 'Vider le cache',
                subtitle: 'Libérer de l\'espace de stockage',
                onTap: _clearCache,
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.download,
                title: 'Sauvegarder mes données',
                subtitle: 'Exporter mes recettes',
                onTap: () {
                  _showComingSoonDialog('Sauvegarde');
                },
              ),
            ]),

            SizedBox(height: 20),

            // Section Support
            _buildSectionTitle('Support'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Centre d\'aide',
                subtitle: 'FAQ et support technique',
                onTap: () {
                  _showComingSoonDialog('Centre d\'aide');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.feedback,
                title: 'Envoyer un commentaire',
                subtitle: 'Aidez-nous à améliorer l\'app',
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'À propos',
                subtitle: 'Version et informations légales',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutView()),
                  );
                },
              ),
            ]),

            SizedBox(height: 30),

            // Bouton de déconnexion
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey[200],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Français'),
                value: 'Français',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  _saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  _saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('Español'),
                value: 'Español',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  _saveSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Envoyer un commentaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Votre avis nous est précieux !'),
              SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre commentaire ici...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Merci pour votre commentaire !'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bientôt disponible'),
          content: Text(
            'La fonctionnalité "$feature" sera disponible dans une future mise à jour.',
          ),
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
}
