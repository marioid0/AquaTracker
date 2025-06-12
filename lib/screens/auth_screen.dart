import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/performance_utils.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/optimized_widgets.dart';
import '../services/optimized_database_service.dart';
import 'home_screen.dart';

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
              Icons.policy, 
              size: ResponsiveBreakpoints.isMobile(context) ? 60 : 80, 
              color: const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 10),
          ResponsiveText(
            isLogin ? 'Policy Manager' : 'Criar Conta',
            baseFontSize: 28,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1E88E5),
            ),
          ),
          ResponsiveText(
            isLogin 
              ? 'Gerencie suas políticas' 
              : 'Junte-se à plataforma',
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