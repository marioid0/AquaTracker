import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

// ===========================================
// CONFIGURAÇÃO SUPABASE (RECOMENDADO)
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
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
    id: json['id'],
    userId: json['user_id'],
    litersUsed: (json['liters_used'] as num).toDouble(),
    category: json['category'],
    date: DateTime.parse(json['usage_date']),
    description: json['description'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
      // 1. Criar usuário no Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        // 2. Salvar dados do usuário na tabela users
        final userId = authResponse.user!.id;
        await supabase.from('users').insert({
          'id': userId,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
        
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
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        // Buscar dados completos do usuário
        final userData = await supabase
            .from('users')
            .select()
            .eq('id', authResponse.user!.id)
            .single();
        
        _currentUser = User.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'password': '', // Não armazenar senha
          'created_at': userData['created_at'],
        });
        
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
    } catch (e) {
      print('Erro no logout: $e');
    }
  }
  
  // REGISTROS DE ÁGUA
  static Future<List<WaterRecord>> getUserWaterRecords() async {
    try {
      if (_currentUser == null) return [];
      
      final data = await supabase
          .from('water_records')
          .select()
          .eq('user_id', _currentUser!.id)
          .order('usage_date', ascending: false);
      
      return data.map<WaterRecord>((json) => WaterRecord.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar registros: $e');
      return [];
    }
  }
  
  static Future<bool> addWaterRecord(WaterRecord record) async {
    try {
      await supabase.from('water_records').insert(record.toJson());
      return true;
    } catch (e) {
      print('Erro ao adicionar registro: $e');
      return false;
    }
  }
  
  static Future<bool> updateWaterRecord(WaterRecord record) async {
    try {
      await supabase
          .from('water_records')
          .update(record.toJson())
          .eq('id', record.id);
      return true;
    } catch (e) {
      print('Erro ao atualizar registro: $e');
      return false;
    }
  }
  
  static Future<bool> deleteWaterRecord(String recordId) async {
    try {
      await supabase
          .from('water_records')
          .delete()
          .eq('id', recordId);
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
      return records.fold<double>(0.0, (sum, record) => sum + record.litersUsed);
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
      
      return categoryUsage;
    } catch (e) {
      print('Erro ao calcular uso por categoria: $e');
      return {};
    }
  }
}

// ===========================================
// SERVIÇO DE DADOS FIREBASE (ALTERNATIVO)
// ===========================================

/*
class FirebaseDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // AUTENTICAÇÃO
  static Future<bool> register(String name, String email, String password) async {
    try {
      // 1. Criar usuário no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // 2. Salvar dados do usuário no Firestore
        final userId = credential.user!.uid;
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Buscar dados do usuário
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _currentUser = User.fromJson({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'password': '', // Não armazenar senha
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }
  
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Erro no logout: $e');
    }
  }
  
  // REGISTROS DE ÁGUA
  static Future<List<WaterRecord>> getUserWaterRecords() async {
    try {
      if (_currentUser == null) return [];
      
      final querySnapshot = await _firestore
          .collection('water_records')
          .where('userId', isEqualTo: _currentUser!.id)
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => WaterRecord.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Erro ao buscar registros: $e');
      return [];
    }
  }
  
  static Future<bool> addWaterRecord(WaterRecord record) async {
    try {
      await _firestore.collection('water_records').add({
        'userId': record.userId,
        'litersUsed': record.litersUsed,
        'category': record.category,
        'date': Timestamp.fromDate(record.date),
        'description': record.description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erro ao adicionar registro: $e');
      return false;
    }
  }
  
  static Future<double> getTotalWaterUsage() async {
    try {
      final records = await getUserWaterRecords();
      return records.fold<double>(0.0, (sum, record) => sum + record.litersUsed);
    } catch (e) {
      print('Erro ao calcular total: $e');
      return 0.0;
    }
  }
}
*/

// ===========================================
// FACTORY PATTERN - ESCOLHA O SERVIÇO
// ===========================================

class DataService {
  // Proxy para o serviço escolhido (Supabase ou Firebase)
  
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
      
  // Método adicional para estatísticas
  static Future<Map<String, double>> getUsageByCategory() =>
      SupabaseDataService.getUsageByCategory();
}