import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/responsive_layout.dart';
import '../services/optimized_database_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final user = DataService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Perfil',
          baseFontSize: 20,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Avatar
            Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: ResponsiveBreakpoints.isMobile(context) ? 50 : 60,
                backgroundColor: const Color(0xFF1E88E5),
                child: Icon(
                  Icons.person,
                  size: ResponsiveBreakpoints.isMobile(context) ? 50 : 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            ResponsiveText(
              user?.name ?? 'Usuário',
              baseFontSize: 24,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ResponsiveText(
              user?.email ?? '',
              baseFontSize: 16,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Profile options
            ResponsiveCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Color(0xFF1E88E5)),
                    title: const Text('Configurações'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFF1E88E5)),
                    title: const Text('Ajuda'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFF1E88E5)),
                    title: const Text('Sobre'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show about dialog
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar Logout'),
                      content: const Text('Tem certeza que deseja sair da sua conta?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Sair', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await DataService.logout();
                    OptimizedDatabaseService.clearAllCaches();
                    
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: ResponsiveText(
                  'Sair da Conta',
                  baseFontSize: 16,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}