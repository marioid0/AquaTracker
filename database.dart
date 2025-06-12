import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

// ===========================================
// CONFIGURAÇÃO SUPABASE
// ===========================================

class SupabaseConfig {
  static const String supabaseUrl = 'https://sjrgakhvmygbhceojvvr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqcmdha2h2bXlnYmhjZW9qdnZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NDg0NjksImV4cCI6MjA2NTIyNDQ2OX0.AWhsG-aj4txYVcP-LE7G3Fp9mTArj8_fkulibwxX-tE';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

// ===========================================
// MODELOS DE DADOS
// ===========================================

class User {
  String id;
  String name;
  String email;
  String password;
  DateTime? createdAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'created_at': createdAt?.toIso8601String(),
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    password: json['password'] as String? ?? '',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String? ?? '') : null,
  );
}

class WaterRecord {
  String id;
  String userId;
  double litersUsed;
  String category;
  DateTime date;
  String description;
  DateTime? createdAt;
  
  WaterRecord({
    required this.id,
    required this.userId,
    required this.litersUsed,
    required this.category,
    required this.date,
    required this.description,
    this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'liters_used': litersUsed,
    'category': category,
    'usage_date': date.toIso8601String(),
    'description': description,
    'created_at': createdAt?.toIso8601String(),
  };
  
  factory WaterRecord.fromJson(Map<String, dynamic> json) => WaterRecord(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    litersUsed: (json['liters_used'] as num).toDouble(),
    category: json['category'] as String? ?? '',
    date: DateTime.parse(json['usage_date'] as String? ?? ''),
    description: json['description'] as String? ?? '',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String? ?? '') : null,
  );
}

// ===========================================
// SERVIÇO DE DADOS SUPABASE
// ===========================================

class SupabaseDataService {
  static final supabase = Supabase.instance.client;
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  // AUTENTICAÇÃO
  static Future<bool> register(String name, String email, String password) async {
    try {
      print('Tentando registrar usuário: $email');
      
      // 1. Criar usuário no Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      print('Resposta do auth: ${authResponse.user?.id}');
      
      if (authResponse.user != null) {
        // 2. Salvar dados do usuário na tabela users
        final userId = authResponse.user!.id;
        
        final userInsert = await supabase.from('users').insert({
          'id': userId,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        }).select();
        
        print('Usuário inserido na tabela: $userInsert');
        
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }
  
  static Future<bool> login(String email, String password) async {
    try {
      print('Tentando fazer login: $email');
      
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Resposta do login: ${authResponse.user?.id}');
      
      if (authResponse.user != null) {
        // Buscar dados completos do usuário
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', authResponse.user!.id)
            .single();
        
        print('Dados do usuário: $userData');
        
        _currentUser = User.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'password': '', // Não armazenar senha
          'created_at': userData['created_at'],
        });
        
        print('Usuário logado: ${_currentUser?.name}');
        
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }
  
  static Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      _currentUser = null;
      print('Logout realizado com sucesso');
    } catch (e) {
      print('Erro no logout: $e');
    }
  }
  
  // REGISTROS DE ÁGUA
  static Future<List<WaterRecord>> getUserWaterRecords() async {
    try {
      if (_currentUser == null) {
        print('Usuário não logado');
        return [];
      }
      
      print('Buscando registros para usuário: ${_currentUser!.id}');
      
      final data = await supabase
          .from('water_records')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('usage_date', ascending: false);
      
      print('Registros encontrados: ${data.length}');
      
      return data.map<WaterRecord>((json) => WaterRecord.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar registros: $e');
      return [];
    }
  }
  
  static Future<bool> addWaterRecord(WaterRecord record) async {
    try {
      print('Adicionando registro: ${record.toJson()}');
      
      final response = await supabase.from('water_records').insert(record.toJson()).select();
      
      print('Registro adicionado: $response');
      
      return true;
    } catch (e) {
      print('Erro ao adicionar registro: $e');
      return false;
    }
  }
  
  static Future<bool> updateWaterRecord(WaterRecord record) async {
    try {
      print('Atualizando registro: ${record.id}');
      
      await supabase
          .from('water_records')
          .update(record.toJson())
          .eq('id', record.id);
      
      print('Registro atualizado com sucesso');
      
      return true;
    } catch (e) {
      print('Erro ao atualizar registro: $e');
      return false;
    }
  }
  
  static Future<bool> deleteWaterRecord(String recordId) async {
    try {
      print('Deletando registro: $recordId');
      
      await supabase
          .from('water_records')
          .delete()
          .eq('id', recordId);
      
      print('Registro deletado com sucesso');
      
      return true;
    } catch (e) {
      print('Erro ao deletar registro: $e');
      return false;
    }
  }
  
  static Future<double> getTotalWaterUsage() async {
    try {
      if (_currentUser == null) return 0.0;
      
      final records = await getUserWaterRecords();
      final total = records.fold<double>(0.0, (sum, record) => sum + record.litersUsed);
      
      print('Total de água utilizada: $total L');
      
      return total;
    } catch (e) {
      print('Erro ao calcular total: $e');
      return 0.0;
    }
  }
  
  // ESTATÍSTICAS
  static Future<Map<String, double>> getUsageByCategory() async {
    try {
      if (_currentUser == null) return {};
      
      final records = await getUserWaterRecords();
      Map<String, double> categoryUsage = {};
      
      for (var record in records) {
        categoryUsage[record.category] = 
            (categoryUsage[record.category] ?? 0) + record.litersUsed;
      }
      
      print('Uso por categoria: $categoryUsage');
      
      return categoryUsage;
    } catch (e) {
      print('Erro ao calcular uso por categoria: $e');
      return {};
    }
  }
}

// ===========================================
// FACTORY PATTERN - PROXY PARA SUPABASE
// ===========================================

class DataService {
  // Proxy para o serviço Supabase
  
  static User? get currentUser => SupabaseDataService.currentUser;
  
  static Future<bool> register(String name, String email, String password) =>
      SupabaseDataService.register(name, email, password);
  
  static Future<bool> login(String email, String password) =>
      SupabaseDataService.login(email, password);
  
  static Future<void> logout() => SupabaseDataService.logout();
  
  static Future<List<WaterRecord>> getUserWaterRecords() =>
      SupabaseDataService.getUserWaterRecords();
  
  static Future<bool> addWaterRecord(WaterRecord record) =>
      SupabaseDataService.addWaterRecord(record);
  
  static Future<bool> updateWaterRecord(WaterRecord record) =>
      SupabaseDataService.updateWaterRecord(record);
  
  static Future<bool> deleteWaterRecord(String recordId) =>
      SupabaseDataService.deleteWaterRecord(recordId);
  
  static Future<double> getTotalWaterUsage() =>
      SupabaseDataService.getTotalWaterUsage();
      
  static Future<Map<String, double>> getUsageByCategory() =>
      SupabaseDataService.getUsageByCategory();
}