import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/performance_utils.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/optimized_widgets.dart';
import '../services/optimized_database_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with AutomaticKeepAliveClientMixin {
  Map<String, int>? _statistics;
  List<Policy>? _recentPolicies;
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
        OptimizedDatabaseService.getCachedStatistics(),
        OptimizedDatabaseService.getCachedPolicies(limit: 5),
      ]);
      
      if (mounted) {
        setState(() {
          _statistics = results[0] as Map<String, int>;
          _recentPolicies = results[1] as List<Policy>;
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
                      'Gerencie suas políticas com eficiência 📋',
                      baseFontSize: 16,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 30),
                    
                    // Statistics cards
                    if (_statistics != null) ...[
                      _buildStatisticsGrid(),
                      const SizedBox(height: 20),
                    ],
                    
                    // Recent policies
                    if (_recentPolicies != null && _recentPolicies!.isNotEmpty) ...[
                      ResponsiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.policy, color: Color(0xFF1E88E5)),
                                const SizedBox(width: 10),
                                ResponsiveText(
                                  'Políticas Recentes',
                                  baseFontSize: 18,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ..._recentPolicies!.take(3).map((policy) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: policy.status ? Colors.green : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ResponsiveText(
                                            policy.title,
                                            baseFontSize: 14,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          ResponsiveText(
                                            policy.category?.name ?? 'Sem categoria',
                                            baseFontSize: 12,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
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
                    
                    // Quick actions
                    ResponsiveCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flash_on, color: Colors.orange),
                              const SizedBox(width: 10),
                              ResponsiveText(
                                'Ações Rápidas',
                                baseFontSize: 18,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to add policy
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Nova Política'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to add category
                                  },
                                  icon: const Icon(Icons.category),
                                  label: const Text('Nova Categoria'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildStatisticsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > ResponsiveBreakpoints.tablet;
        
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('Total de Políticas', _statistics!['totalPolicies'] ?? 0, Icons.policy, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Políticas Ativas', _statistics!['activePolicies'] ?? 0, Icons.check_circle, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Políticas Inativas', _statistics!['inactivePolicies'] ?? 0, Icons.pause_circle, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Categorias', _statistics!['totalCategories'] ?? 0, Icons.category, Colors.purple)),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total de Políticas', _statistics!['totalPolicies'] ?? 0, Icons.policy, Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('Políticas Ativas', _statistics!['activePolicies'] ?? 0, Icons.check_circle, Colors.green)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Políticas Inativas', _statistics!['inactivePolicies'] ?? 0, Icons.pause_circle, Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard('Categorias', _statistics!['totalCategories'] ?? 0, Icons.category, Colors.purple)),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return ResponsiveCard(
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          ResponsiveText(
            value.toString(),
            baseFontSize: 24,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          ResponsiveText(
            title,
            baseFontSize: 12,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}