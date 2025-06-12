import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/performance_utils.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/optimized_widgets.dart';
import '../services/optimized_database_service.dart';

class PoliciesScreen extends StatefulWidget {
  @override
  _PoliciesScreenState createState() => _PoliciesScreenState();

  void showAddPolicyDialog() {
    // This will be called from the state
  }
}

class _PoliciesScreenState extends State<PoliciesScreen> 
    with AutomaticKeepAliveClientMixin {
  List<Policy> policies = [];
  List<Category> categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      PerformanceMonitor.startTimer('load_policies_initial');
      
      final results = await Future.wait([
        OptimizedDatabaseService.getCachedPolicies(limit: _pageSize, offset: 0),
        OptimizedDatabaseService.getCachedCategories(),
      ]);
      
      if (mounted) {
        setState(() {
          policies = results[0] as List<Policy>;
          categories = results[1] as List<Category>;
          _isLoading = false;
          _hasMore = policies.length == _pageSize;
        });
      }
      
      PerformanceMonitor.endTimer('load_policies_initial');
    } catch (e) {
      print('Erro ao carregar dados iniciais: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMorePolicies() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final nextPage = _currentPage + 1;
      final morePolicies = await OptimizedDatabaseService.getCachedPolicies(
        limit: _pageSize,
        offset: nextPage * _pageSize,
        forceRefresh: true,
      );
      
      if (mounted) {
        setState(() {
          policies.addAll(morePolicies);
          _currentPage = nextPage;
          _hasMore = morePolicies.length == _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar mais políticas: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void showAddPolicyDialog() {
    _showAddPolicyDialog();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            'Políticas',
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
          'Políticas',
          baseFontSize: 20,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: policies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.policy_outlined,
                    size: ResponsiveBreakpoints.isMobile(context) ? 60 : 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  ResponsiveText(
                    'Nenhuma política encontrada',
                    baseFontSize: 18,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ResponsiveText(
                    'Toque no + para adicionar sua primeira política',
                    baseFontSize: 14,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                  _currentPage = 0;
                  policies.clear();
                });
                await _loadInitialData();
              },
              color: const Color(0xFF1E88E5),
              child: OptimizedListView(
                items: policies,
                hasMore: _hasMore,
                onLoadMore: _loadMorePolicies,
                loadingWidget: _isLoadingMore 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : null,
                itemBuilder: (context, index) {
                  final policy = policies[index];
                  return ResponsiveCard(
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveBreakpoints.getResponsivePadding(context),
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: policy.status ? Colors.green : Colors.orange,
                        child: Icon(
                          policy.status ? Icons.check : Icons.pause,
                          color: Colors.white,
                        ),
                      ),
                      title: ResponsiveText(
                        policy.title,
                        baseFontSize: 16,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            policy.description,
                            baseFontSize: 14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          ResponsiveText(
                            policy.category?.name ?? 'Sem categoria',
                            baseFontSize: 12,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  policy.status ? Icons.pause : Icons.play_arrow,
                                  color: policy.status ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(policy.status ? 'Desativar' : 'Ativar'),
                              ],
                            ),
                          ),
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
                          switch (value) {
                            case 'edit':
                              _showEditPolicyDialog(policy);
                              break;
                            case 'toggle':
                              await _togglePolicyStatus(policy);
                              break;
                            case 'delete':
                              await _deletePolicy(policy);
                              break;
                          }
                        },
                      ),
                      onTap: () {
                        _showPolicyDetails(policy);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showAddPolicyDialog() async {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    String? selectedCategoryId;
    bool isActive = true;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Adicionar Política'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OptimizedTextField(
                      controller: _titleController,
                      labelText: 'Título da política',
                    ),
                    const SizedBox(height: 15),
                    OptimizedTextField(
                      controller: _descriptionController,
                      labelText: 'Descrição',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    SwitchListTile(
                      title: const Text('Política ativa'),
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                      },
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
                    if (_titleController.text.isNotEmpty && 
                        _descriptionController.text.isNotEmpty &&
                        selectedCategoryId != null) {
                      
                      final policy = Policy(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        description: _descriptionController.text,
                        categoryId: selectedCategoryId!,
                        status: isActive,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      
                      bool success = await OptimizedDatabaseService.addPolicyWithCacheUpdate(policy);
                      Navigator.of(context).pop();
                      
                      if (success) {
                        await _loadInitialData();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Política adicionada com sucesso!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Erro ao adicionar política'),
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

  void _showEditPolicyDialog(Policy policy) {
    // Implementation for editing policy
  }

  Future<void> _togglePolicyStatus(Policy policy) async {
    final updatedPolicy = Policy(
      id: policy.id,
      title: policy.title,
      description: policy.description,
      categoryId: policy.categoryId,
      status: !policy.status,
      createdAt: policy.createdAt,
      updatedAt: DateTime.now(),
    );

    bool success = await OptimizedDatabaseService.updatePolicyWithCacheUpdate(updatedPolicy);
    
    if (success) {
      await _loadInitialData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Política ${updatedPolicy.status ? 'ativada' : 'desativada'} com sucesso!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _deletePolicy(Policy policy) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a política "${policy.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      bool success = await OptimizedDatabaseService.deletePolicyWithCacheUpdate(policy.id);
      
      if (success) {
        await _loadInitialData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Política excluída com sucesso!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showPolicyDetails(Policy policy) {
    // Implementation for showing policy details
  }
}