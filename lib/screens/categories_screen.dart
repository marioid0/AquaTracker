import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/performance_utils.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/optimized_widgets.dart';
import '../services/optimized_database_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();

  void showAddCategoryDialog() {
    // This will be called from the state
  }
}

class _CategoriesScreenState extends State<CategoriesScreen> 
    with AutomaticKeepAliveClientMixin {
  List<Category> categories = [];
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      PerformanceMonitor.startTimer('load_categories');
      
      final loadedCategories = await OptimizedDatabaseService.getCachedCategories(
        forceRefresh: true,
      );
      
      if (mounted) {
        setState(() {
          categories = loadedCategories;
          _isLoading = false;
        });
      }
      
      PerformanceMonitor.endTimer('load_categories');
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void showAddCategoryDialog() {
    _showAddCategoryDialog();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: ResponsiveText(
            'Categorias',
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
          'Categorias',
          baseFontSize: 20,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: ResponsiveBreakpoints.isMobile(context) ? 60 : 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  ResponsiveText(
                    'Nenhuma categoria encontrada',
                    baseFontSize: 18,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ResponsiveText(
                    'Toque no + para adicionar sua primeira categoria',
                    baseFontSize: 14,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCategories,
              color: const Color(0xFF1E88E5),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ResponsiveCard(
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveBreakpoints.getResponsivePadding(context),
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1E88E5),
                        child: const Icon(Icons.category, color: Colors.white),
                      ),
                      title: ResponsiveText(
                        category.name,
                        baseFontSize: 16,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: ResponsiveText(
                        category.description,
                        baseFontSize: 14,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                              _showEditCategoryDialog(category);
                              break;
                            case 'delete':
                              await _deleteCategory(category);
                              break;
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

  Future<void> _showAddCategoryDialog() async {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Adicionar Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OptimizedTextField(
                controller: _nameController,
                labelText: 'Nome da categoria',
              ),
              const SizedBox(height: 15),
              OptimizedTextField(
                controller: _descriptionController,
                labelText: 'Descrição',
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && 
                    _descriptionController.text.isNotEmpty) {
                  
                  final category = Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    createdAt: DateTime.now(),
                  );
                  
                  bool success = await OptimizedDatabaseService.addCategoryWithCacheUpdate(category);
                  Navigator.of(context).pop();
                  
                  if (success) {
                    _loadCategories();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Categoria adicionada com sucesso!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Erro ao adicionar categoria'),
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
  }

  void _showEditCategoryDialog(Category category) {
    // Implementation for editing category
  }

  Future<void> _deleteCategory(Category category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a categoria "${category.name}"?'),
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
      // Note: This would need to be implemented in the database service
      // bool success = await OptimizedDatabaseService.deleteCategoryWithCacheUpdate(category.id);
      
      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Funcionalidade de exclusão será implementada'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}