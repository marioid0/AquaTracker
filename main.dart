import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'database.dart';
import 'lib/utils/performance_utils.dart';
import 'lib/widgets/responsive_layout.dart';
import 'lib/widgets/optimized_widgets.dart';
import 'lib/services/optimized_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(AquaTrackerApp());
}

class AquaTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        // Optimize theme for performance
        visualDensity: VisualDensity.adaptivePlatformDensity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}

// ===========================================
// OPTIMIZED AUTH SCREEN
// ===========================================

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    PerformanceUtils.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveBreakpoints.getResponsivePadding(context)),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveCard(
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(ResponsiveBreakpoints.getResponsivePadding(context)),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveCard(
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(ResponsiveBreakpoints.getResponsivePadding(context)),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveCard(
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with hero animation
          Hero(
            tag: 'app_logo',
            child: Icon(
              Icons.water_drop, 
              size: ResponsiveBreakpoints.isMobile(context) ? 60 : 80, 
              color: const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 10),
          ResponsiveText(
            isLogin ? 'AquaTracker' : 'Criar Conta',
            baseFontSize: 28,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1E88E5),
            ),
          ),
          ResponsiveText(
            isLogin 
              ? 'Monitore e economize água' 
              : 'Junte-se à comunidade sustentável',
            baseFontSize: 16,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          
          // Form fields
          if (!isLogin) ...[
            OptimizedTextField(
              controller: _nameController,
              labelText: 'Nome',
              prefixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
          ],
          
          OptimizedTextField(
            controller: _emailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          
          OptimizedTextField(
            controller: _passwordController,
            labelText: 'Senha',
            obscureText: true,
            prefixIcon: const Icon(Icons.lock),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira sua senha';
              }
              if (!isLogin && value.length < 6) {
                return 'Senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (isLogin ? _handleLogin : _handleRegister),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, 
                      strokeWidth: 2,
                    ),
                  )
                : ResponsiveText(
                    isLogin ? 'Entrar' : 'Cadastrar',
                    baseFontSize: 16,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Toggle button
          TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                isLogin = !isLogin;
                _formKey.currentState?.reset();
              });
            },
            child: ResponsiveText(
              isLogin 
                ? 'Não tem conta? Cadastre-se' 
                : 'Já tem conta? Faça login',
              baseFontSize: 14,
              style: const TextStyle(color: Color(0xFF1E88E5)),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        bool success = await DataService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success) {
          // Preload dashboard data
          OptimizedDatabaseService.preloadDashboardData();
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        } else {
          _showError('Email ou senha incorretos');
        }
      } catch (e) {
        _showError('Erro ao fazer login: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        bool success = await DataService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (success) {
          _showSuccess('Cadastro realizado com sucesso!');
          setState(() {
            isLogin = true;
          });
          // Clear form fields
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        } else {
          _showError('Email já cadastrado ou erro no servidor');
        }
      } catch (e) {
        _showError('Erro ao cadastrar: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
  
  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

// ===========================================
// OPTIMIZED HOME SCREEN
// ===========================================

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
  Widget? _recordsScreen;
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
          _recordsScreen ??= WaterRecordsScreen(),
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
              icon: Icon(Icons.water_drop),
              label: 'Registros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1 
        ? ScaleTransition(
            scale: _fabAnimationController,
            child: FloatingActionButton(
              onPressed: () => _showAddRecordDialog(),
              backgroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        : null,
    );
  }

  Future<void> _showAddRecordDialog() async {
    final _litersController = TextEditingController();
    final _descriptionController = TextEditingController();
    String selectedCategory = 'Banho';
    final categories = ['Banho', 'Cozinha', 'Limpeza', 'Jardim', 'Outros'];
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Adicionar Registro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OptimizedTextField(
                      controller: _litersController,
                      labelText: 'Litros utilizados',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    OptimizedTextField(
                      controller: _descriptionController,
                      labelText: 'Descrição',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_litersController.text.isNotEmpty && 
                        _descriptionController.text.isNotEmpty) {
                      
                      final record = WaterRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: DataService.currentUser!.id,
                        litersUsed: double.parse(_litersController.text),
                        category: selectedCategory,
                        date: DateTime.now(),
                        description: _descriptionController.text,
                      );
                      
                      bool success = await OptimizedDatabaseService.addWaterRecordWithCacheUpdate(record);
                      Navigator.of(context).pop();
                      
                      if (success) {
                        // Refresh the records screen
                        if (_recordsScreen is WaterRecordsScreen) {
                          (_recordsScreen as WaterRecordsScreen).refreshData();
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Registro adicionado com sucesso!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Erro ao adicionar registro'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ===========================================
// OPTIMIZED DASHBOARD SCREEN
// ===========================================

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with AutomaticKeepAliveClientMixin {
  double? _totalUsage;
  List<WaterRecord>? _recentRecords;
  Map<String, double>? _categoryUsage;
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      PerformanceMonitor.startTimer('dashboard_load');
      
      final results = await Future.wait([
        OptimizedDatabaseService.getCachedTotalWaterUsage(),
        OptimizedDatabaseService.getCachedUserWaterRecords(),
        OptimizedDatabaseService.getCachedUsageByCategory(),
      ]);
      
      if (mounted) {
        setState(() {
          _totalUsage = results[0] as double;
          final allRecords = results[1] as List<WaterRecord>;
          _recentRecords = allRecords.take(3).toList();
          _categoryUsage = results[2] as Map<String, double>;
          _isLoading = false;
        });
      }
      
      PerformanceMonitor.endTimer('dashboard_load');
    } catch (e) {
      print('Erro ao carregar dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            'Dashboard',
            baseFontSize: 20,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E88E5),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E88E5),
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _loadDashboardData();
              },
              color: const Color(0xFF1E88E5),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Welcome section
                    ResponsiveText(
                      'Olá, ${DataService.currentUser?.name ?? "Usuário"}!',
                      baseFontSize: 24,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ResponsiveText(
                      'Vamos economizar água juntos 💧',
                      baseFontSize: 16,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    
                    // Total usage card
                    ResponsiveCard(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.water_drop,
                                size: 50,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 10),
                              ResponsiveText(
                                '${(_totalUsage ?? 0).toStringAsFixed(1)} L',
                                baseFontSize: 32,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              ResponsiveText(
                                'Consumo Total Registrado',
                                baseFontSize: 16,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Category usage
                    if (_categoryUsage != null && _categoryUsage!.isNotEmpty) ...[
                      ResponsiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.pie_chart, color: Color(0xFF1E88E5)),
                                const SizedBox(width: 10),
                                ResponsiveText(
                                  'Uso por Categoria',
                                  baseFontSize: 18,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ..._categoryUsage!.entries.map((entry) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ResponsiveText(
                                      entry.key,
                                      baseFontSize: 14,
                                    ),
                                    ResponsiveText(
                                      '${entry.value.toStringAsFixed(1)} L',
                                      baseFontSize: 14,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Tip of the day
                    ResponsiveCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.orange),
                              const SizedBox(width: 10),
                              ResponsiveText(
                                'Dica do Dia',
                                baseFontSize: 18,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ResponsiveText(
                            'Feche a torneira enquanto escova os dentes. Você pode economizar até 12 litros de água por escovação!',
                            baseFontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================
// OPTIMIZED WATER RECORDS SCREEN
// ===========================================

class WaterRecordsScreen extends StatefulWidget {
  @override
  _WaterRecordsScreenState createState() => _WaterRecordsScreenState();

  // Method to refresh data from parent
  void refreshData() {
    // This will be called from the state
  }
}

class _WaterRecordsScreenState extends State<WaterRecordsScreen> 
    with AutomaticKeepAliveClientMixin {
  List<WaterRecord> records = [];
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }
  
  Future<void> _loadRecords() async {
    try {
      PerformanceMonitor.startTimer('load_records');
      
      final loadedRecords = await OptimizedDatabaseService.getCachedUserWaterRecords(
        forceRefresh: true,
      );
      
      if (mounted) {
        setState(() {
          records = loadedRecords;
          _isLoading = false;
        });
      }
      
      PerformanceMonitor.endTimer('load_records');
    } catch (e) {
      print('Erro ao carregar registros: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Public method to refresh data
  void refreshData() {
    _loadRecords();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            'Registros de Água',
            baseFontSize: 20,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E88E5),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E88E5),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Registros de Água',
          baseFontSize: 20,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: ResponsiveBreakpoints.isMobile(context) ? 60 : 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  ResponsiveText(
                    'Nenhum registro encontrado',
                    baseFontSize: 18,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ResponsiveText(
                    'Toque no + para adicionar seu primeiro registro',
                    baseFontSize: 14,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecords,
              color: const Color(0xFF1E88E5),
              child: OptimizedListView(
                items: records,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ResponsiveCard(
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveBreakpoints.getResponsivePadding(context),
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E88E5),
                        child: const Icon(Icons.water_drop, color: Colors.white),
                      ),
                      title: ResponsiveText(
                        '${record.litersUsed} L - ${record.category}',
                        baseFontSize: 16,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            record.description,
                            baseFontSize: 14,
                          ),
                          const SizedBox(height: 5),
                          ResponsiveText(
                            '${record.date.day}/${record.date.month}/${record.date.year}',
                            baseFontSize: 12,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            bool success = await OptimizedDatabaseService
                                .deleteWaterRecordWithCacheUpdate(record.id);
                            if (success) {
                              _loadRecords();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Registro excluído com sucesso!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ===========================================
// OPTIMIZED PROFILE SCREEN
// ===========================================

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