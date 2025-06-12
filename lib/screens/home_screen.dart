import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';
import 'dashboard_screen.dart';
import 'policies_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  
  // Lazy-loaded screens
  Widget? _dashboardScreen;
  Widget? _policiesScreen;
  Widget? _categoriesScreen;
  Widget? _profileScreen;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _dashboardScreen ??= DashboardScreen(),
          _policiesScreen ??= PoliciesScreen(),
          _categoriesScreen ??= CategoriesScreen(),
          _profileScreen ??= ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.policy),
              label: 'Políticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      floatingActionButton: (_currentIndex == 1 || _currentIndex == 2)
        ? ScaleTransition(
            scale: _fabAnimationController,
            child: FloatingActionButton(
              onPressed: () => _showAddDialog(),
              backgroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        : null,
    );
  }

  void _showAddDialog() {
    if (_currentIndex == 1) {
      // Add policy
      (_policiesScreen as PoliciesScreen?)?.showAddPolicyDialog();
    } else if (_currentIndex == 2) {
      // Add category
      (_categoriesScreen as CategoriesScreen?)?.showAddCategoryDialog();
    }
  }
}