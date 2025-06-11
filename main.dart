import 'package:flutter/material.dart';
import 'dart:async';
import 'database.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(AquaTrackerApp());
}

class AquaTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ===========================================
// MODELOS BÁSICOS (mantidos no main por serem essenciais)
// ===========================================

class User {
  String id;
  String name;
  String email;
  String password;
  
  User({required this.id, required this.name, required this.email, required this.password});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
  );
}

class WaterRecord {
  String id;
  String userId;
  double litersUsed;
  String category;
  DateTime date;
  String description;
  
  WaterRecord({
    required this.id,
    required this.userId,
    required this.litersUsed,
    required this.category,
    required this.date,
    required this.description,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'litersUsed': litersUsed,
    'category': category,
    'date': date.toIso8601String(),
    'description': description,
  };
  
  factory WaterRecord.fromJson(Map<String, dynamic> json) => WaterRecord(
    id: json['id'],
    userId: json['userId'],
    litersUsed: json['litersUsed'].toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    description: json['description'],
  );
}

// ===========================================
// SERVIÇO DE DADOS TEMPORÁRIO (será movido para database.dart)
// ===========================================

class DataService {
  static List<User> _users = [];
  static List<WaterRecord> _waterRecords = [];
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static Future<bool> register(String name, String email, String password) async {
    // Simula delay de rede
    await Future.delayed(Duration(milliseconds: 500));
    
    if (_users.any((user) => user.email == email)) {
      return false;
    }
    
    User newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );
    
    _users.add(newUser);
    return true;
  }
  
  static Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    try {
      User user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 200));
    _currentUser = null;
  }
  
  static Future<List<WaterRecord>> getUserWaterRecords() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (_currentUser == null) return [];
    return _waterRecords.where((record) => record.userId == _currentUser!.id).toList();
  }
  
  static Future<void> addWaterRecord(WaterRecord record) async {
    await Future.delayed(Duration(milliseconds: 400));
    _waterRecords.add(record);
  }
  
  static Future<void> updateWaterRecord(WaterRecord updatedRecord) async {
    await Future.delayed(Duration(milliseconds: 400));
    int index = _waterRecords.indexWhere((record) => record.id == updatedRecord.id);
    if (index != -1) {
      _waterRecords[index] = updatedRecord;
    }
  }
  
  static Future<void> deleteWaterRecord(String recordId) async {
    await Future.delayed(Duration(milliseconds: 300));
    _waterRecords.removeWhere((record) => record.id == recordId);
  }
  
  static Future<double> getTotalWaterUsage() async {
    final records = await getUserWaterRecords();
    return records.fold<double>(0.0, (double sum, WaterRecord record) => sum + record.litersUsed);
  }
}

// ===========================================
// LAZY LOADING - TELAS CARREGADAS SOB DEMANDA
// ===========================================

// Tela de Autenticação - LAZY LOADED
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Widgets são criados apenas quando necessários
  Widget? _loginForm;
  Widget? _registerForm;
  
  @override
  void dispose() {
    // Limpa recursos quando sai da tela
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: _buildCurrentForm(), // Lazy loading do formulário
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Lazy loading - constrói apenas o formulário necessário
  Widget _buildCurrentForm() {
    if (isLogin) {
      _loginForm ??= _buildLoginForm(); // Cria apenas se não existir
      return _loginForm!;
    } else {
      _registerForm ??= _buildRegisterForm(); // Cria apenas se não existir  
      return _registerForm!;
    }
  }
  
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Icon(Icons.water_drop, size: 80, color: Color(0xFF1E88E5)),
          SizedBox(height: 10),
          Text('AquaTracker', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          Text('Monitore e economize água', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 30),
          
          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor, insira seu email';
              if (!value.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          SizedBox(height: 15),
          
          // Senha
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor, insira sua senha';
              return null;
            },
          ),
          SizedBox(height: 25),
          
          // Botão Entrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 15),
          
          // Link para cadastro
          TextButton(
            onPressed: () {
              setState(() {
                isLogin = false;
                _registerForm = null; // Reset register form para lazy load
              });
            },
            child: Text('Não tem conta? Cadastre-se', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Icon(Icons.water_drop, size: 80, color: Color(0xFF1E88E5)),
          SizedBox(height: 10),
          Text('Criar Conta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          Text('Junte-se à comunidade sustentável', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 30),
          
          // Nome
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor, insira seu nome';
              return null;
            },
          ),
          SizedBox(height: 15),
          
          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor, insira seu email';
              if (!value.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          SizedBox(height: 15),
          
          // Senha
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Por favor, insira sua senha';
              if (value.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
              return null;
            },
          ),
          SizedBox(height: 25),
          
          // Botão Cadastrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text('Cadastrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 15),
          
          // Link para login
          TextButton(
            onPressed: () {
              setState(() {
                isLogin = true;
                _loginForm = null; // Reset login form para lazy load
              });
            },
            child: Text('Já tem conta? Faça login', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        bool success = await DataService.login(_emailController.text, _passwordController.text);
        
        if (success) {
          // Navega para home e destrói a tela de auth
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showError('Email ou senha incorretos');
        }
      } catch (e) {
        _showError('Erro ao fazer login');
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
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
        
        if (success) {
          _showSuccess('Cadastro realizado com sucesso!');
          setState(() {
            isLogin = true;
            _loginForm = null; // Reset para lazy load
          });
        } else {
          _showError('Email já cadastrado');
        }
      } catch (e) {
        _showError('Erro ao cadastrar');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}

// ===========================================
// HOME - CARREGA APENAS A ABA ATIVA
// ===========================================

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // LAZY LOADING - Telas são criadas apenas quando acessadas
  Widget? _dashboardScreen;
  Widget? _recordsScreen;
  Widget? _profileScreen;
  
  @override
  void dispose() {
    // Limpa todas as telas quando sai
    _dashboardScreen = null;
    _recordsScreen = null;
    _profileScreen = null;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(), // Carrega apenas a tela ativa
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1E88E5),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Registros'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
  
  // LAZY LOADING - Cria tela apenas quando necessário
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        _dashboardScreen ??= DashboardScreen(); // Cria apenas se não existir
        return _dashboardScreen!;
      case 1:
        _recordsScreen ??= WaterRecordsScreen();
        return _recordsScreen!;
      case 2:
        _profileScreen ??= ProfileScreen();
        return _profileScreen!;
      default:
        return Container();
    }
  }
}

// ===========================================
// TELAS SIMPLIFICADAS - LAZY LOADED
// ===========================================

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double? _totalUsage;
  List<WaterRecord>? _recentRecords;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // Carrega dados apenas quando a tela é criada
  }
  
  Future<void> _loadDashboardData() async {
    try {
      final totalUsage = await DataService.getTotalWaterUsage();
      final records = await DataService.getUserWaterRecords();
      
      if (mounted) {
        setState(() {
          _totalUsage = totalUsage;
          _recentRecords = records.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E88E5),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boas-vindas
              Text(
                'Olá, ${DataService.currentUser?.name ?? "Usuário"}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                'Vamos economizar água juntos 💧',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 30),
              
              // Card de consumo
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)]),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.water_drop, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        '${(_totalUsage ?? 0).toStringAsFixed(1)} L',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Consumo Total Registrado',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Dica do dia (carregada dinamicamente)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange),
                          SizedBox(width: 10),
                          Text('Dica do Dia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Feche a torneira enquanto escova os dentes. Você pode economizar até 12 litros de água por escovação!',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
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

class WaterRecordsScreen extends StatefulWidget {
  @override
  _WaterRecordsScreenState createState() => _WaterRecordsScreenState();
}

class _WaterRecordsScreenState extends State<WaterRecordsScreen> {
  List<WaterRecord> records = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecords(); // Carrega apenas quando a tela é criada
  }
  
  Future<void> _loadRecords() async {
    try {
      final loadedRecords = await DataService.getUserWaterRecords();
      if (mounted) {
        setState(() {
          records = loadedRecords;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Registros de Água', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E88E5),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros de Água', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Nenhum registro encontrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 10),
                  Text('Toque no + para adicionar seu primeiro registro', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: records.length,
              itemBuilder: (context, index) {
                WaterRecord record = records[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF1E88E5),
                      child: Icon(Icons.water_drop, color: Colors.white),
                    ),
                    title: Text('${record.litersUsed} L - ${record.category}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.description),
                        SizedBox(height: 5),
                        Text('${record.date.day}/${record.date.month}/${record.date.year}',
                             style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    trailing: Icon(Icons.more_vert),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar dialog de adição
        },
        backgroundColor: Color(0xFF1E88E5),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = DataService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF1E88E5),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(user?.name ?? 'Usuário', 
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '', 
                 style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 30),
            
            // Botão de logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await DataService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Sair da Conta', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}