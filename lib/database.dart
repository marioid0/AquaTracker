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
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'] ?? '',
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );
}

class Category {
  String id;
  String name;
  String description;
  DateTime? createdAt;
  
  Category({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
  };
  
  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );
}

class Policy {
  String id;
  String title;
  String description;
  String categoryId;
  bool status;
  DateTime? createdAt;
  DateTime? updatedAt;
  Category? category;
  List<PolicyAttachment>? attachments;
  List<PolicyVersion>? versions;
  
  Policy({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.attachments,
    this.versions,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category_id': categoryId,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
  
  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    categoryId: json['category_id'],
    status: json['status'] ?? true,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
  );
}

class PolicyAttachment {
  String id;
  String policyId;
  String fileUrl;
  String fileName;
  DateTime? createdAt;
  
  PolicyAttachment({
    required this.id,
    required this.policyId,
    required this.fileUrl,
    required this.fileName,
    this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'policy_id': policyId,
    'file_url': fileUrl,
    'file_name': fileName,
    'created_at': createdAt?.toIso8601String(),
  };
  
  factory PolicyAttachment.fromJson(Map<String, dynamic> json) => PolicyAttachment(
    id: json['id'],
    policyId: json['policy_id'],
    fileUrl: json['file_url'],
    fileName: json['file_name'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );
}

class PolicyVersion {
  String id;
  String policyId;
  int versionNumber;
  String changes;
  DateTime? createdAt;
  
  PolicyVersion({
    required this.id,
    required this.policyId,
    required this.versionNumber,
    required this.changes,
    this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'policy_id': policyId,
    'version_number': versionNumber,
    'changes': changes,
    'created_at': createdAt?.toIso8601String(),
  };
  
  factory PolicyVersion.fromJson(Map<String, dynamic> json) => PolicyVersion(
    id: json['id'],
    policyId: json['policy_id'],
    versionNumber: json['version_number'],
    changes: json['changes'],
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
      print('Tentando registrar usuário: $email');
      
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      print('Resposta do auth: ${authResponse.user?.id}');
      
      if (authResponse.user != null) {
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
          'password': '',
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
  
  // CATEGORIAS
  static Future<List<Category>> getCategories() async {
    try {
      print('Buscando categorias');
      
      final data = await supabase
          .from('categories')
          .select()
          .order('name', ascending: true);
      
      print('Categorias encontradas: ${data.length}');
      
      return data.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar categorias: $e');
      return [];
    }
  }
  
  static Future<bool> addCategory(Category category) async {
    try {
      print('Adicionando categoria: ${category.toJson()}');
      
      final response = await supabase.from('categories').insert(category.toJson()).select();
      
      print('Categoria adicionada: $response');
      
      return true;
    } catch (e) {
      print('Erro ao adicionar categoria: $e');
      return false;
    }
  }
  
  // POLÍTICAS
  static Future<List<Policy>> getPolicies({int? limit, int? offset}) async {
    try {
      print('Buscando políticas');
      
      var query = supabase
          .from('policies')
          .select('*, categories(*)')
          .order('created_at', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final data = await query;
      
      print('Políticas encontradas: ${data.length}');
      
      return data.map<Policy>((json) => Policy.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar políticas: $e');
      return [];
    }
  }
  
  static Future<Policy?> getPolicyById(String policyId) async {
    try {
      print('Buscando política: $policyId');
      
      final data = await supabase
          .from('policies')
          .select('*, categories(*)')
          .eq('id', policyId)
          .single();
      
      print('Política encontrada: $data');
      
      return Policy.fromJson(data);
    } catch (e) {
      print('Erro ao buscar política: $e');
      return null;
    }
  }
  
  static Future<bool> addPolicy(Policy policy) async {
    try {
      print('Adicionando política: ${policy.toJson()}');
      
      final response = await supabase.from('policies').insert(policy.toJson()).select();
      
      print('Política adicionada: $response');
      
      return true;
    } catch (e) {
      print('Erro ao adicionar política: $e');
      return false;
    }
  }
  
  static Future<bool> updatePolicy(Policy policy) async {
    try {
      print('Atualizando política: ${policy.id}');
      
      await supabase
          .from('policies')
          .update({
            ...policy.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', policy.id);
      
      print('Política atualizada com sucesso');
      
      return true;
    } catch (e) {
      print('Erro ao atualizar política: $e');
      return false;
    }
  }
  
  static Future<bool> deletePolicy(String policyId) async {
    try {
      print('Deletando política: $policyId');
      
      await supabase
          .from('policies')
          .delete()
          .eq('id', policyId);
      
      print('Política deletada com sucesso');
      
      return true;
    } catch (e) {
      print('Erro ao deletar política: $e');
      return false;
    }
  }
  
  // ANEXOS DE POLÍTICAS
  static Future<List<PolicyAttachment>> getPolicyAttachments(String policyId) async {
    try {
      print('Buscando anexos da política: $policyId');
      
      final data = await supabase
          .from('policy_attachments')
          .select()
          .eq('policy_id', policyId)
          .order('created_at', ascending: false);
      
      print('Anexos encontrados: ${data.length}');
      
      return data.map<PolicyAttachment>((json) => PolicyAttachment.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar anexos: $e');
      return [];
    }
  }
  
  static Future<bool> addPolicyAttachment(PolicyAttachment attachment) async {
    try {
      print('Adicionando anexo: ${attachment.toJson()}');
      
      final response = await supabase.from('policy_attachments').insert(attachment.toJson()).select();
      
      print('Anexo adicionado: $response');
      
      return true;
    } catch (e) {
      print('Erro ao adicionar anexo: $e');
      return false;
    }
  }
  
  // VERSÕES DE POLÍTICAS
  static Future<List<PolicyVersion>> getPolicyVersions(String policyId) async {
    try {
      print('Buscando versões da política: $policyId');
      
      final data = await supabase
          .from('policy_versions')
          .select()
          .eq('policy_id', policyId)
          .order('version_number', ascending: false);
      
      print('Versões encontradas: ${data.length}');
      
      return data.map<PolicyVersion>((json) => PolicyVersion.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar versões: $e');
      return [];
    }
  }
  
  static Future<bool> addPolicyVersion(PolicyVersion version) async {
    try {
      print('Adicionando versão: ${version.toJson()}');
      
      final response = await supabase.from('policy_versions').insert(version.toJson()).select();
      
      print('Versão adicionada: $response');
      
      return true;
    } catch (e) {
      print('Erro ao adicionar versão: $e');
      return false;
    }
  }
  
  // ESTATÍSTICAS
  static Future<Map<String, int>> getStatistics() async {
    try {
      final policies = await supabase.from('policies').select('id, status');
      final categories = await supabase.from('categories').select('id');
      
      final activePolicies = policies.where((p) => p['status'] == true).length;
      final inactivePolicies = policies.where((p) => p['status'] == false).length;
      
      return {
        'totalPolicies': policies.length,
        'activePolicies': activePolicies,
        'inactivePolicies': inactivePolicies,
        'totalCategories': categories.length,
      };
    } catch (e) {
      print('Erro ao calcular estatísticas: $e');
      return {};
    }
  }
}

// ===========================================
// FACTORY PATTERN - PROXY PARA SUPABASE
// ===========================================

class DataService {
  static User? get currentUser => SupabaseDataService.currentUser;
  
  static Future<bool> register(String name, String email, String password) =>
      SupabaseDataService.register(name, email, password);
  
  static Future<bool> login(String email, String password) =>
      SupabaseDataService.login(email, password);
  
  static Future<void> logout() => SupabaseDataService.logout();
  
  static Future<List<Category>> getCategories() =>
      SupabaseDataService.getCategories();
  
  static Future<bool> addCategory(Category category) =>
      SupabaseDataService.addCategory(category);
  
  static Future<List<Policy>> getPolicies({int? limit, int? offset}) =>
      SupabaseDataService.getPolicies(limit: limit, offset: offset);
  
  static Future<Policy?> getPolicyById(String policyId) =>
      SupabaseDataService.getPolicyById(policyId);
  
  static Future<bool> addPolicy(Policy policy) =>
      SupabaseDataService.addPolicy(policy);
  
  static Future<bool> updatePolicy(Policy policy) =>
      SupabaseDataService.updatePolicy(policy);
  
  static Future<bool> deletePolicy(String policyId) =>
      SupabaseDataService.deletePolicy(policyId);
  
  static Future<List<PolicyAttachment>> getPolicyAttachments(String policyId) =>
      SupabaseDataService.getPolicyAttachments(policyId);
  
  static Future<bool> addPolicyAttachment(PolicyAttachment attachment) =>
      SupabaseDataService.addPolicyAttachment(attachment);
  
  static Future<List<PolicyVersion>> getPolicyVersions(String policyId) =>
      SupabaseDataService.getPolicyVersions(policyId);
  
  static Future<bool> addPolicyVersion(PolicyVersion version) =>
      SupabaseDataService.addPolicyVersion(version);
  
  static Future<Map<String, int>> getStatistics() =>
      SupabaseDataService.getStatistics();
}