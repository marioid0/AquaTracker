import '../database.dart';
import 'cache_service.dart';
import '../utils/performance_utils.dart';

class OptimizedDatabaseService {
  // Cached database operations for policies
  static Future<List<Policy>> getCachedPolicies({
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'policies_${limit ?? 'all'}_${offset ?? 0}';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedPolicies = CacheService.get<List<Policy>>(cacheKey);
      if (cachedPolicies != null) {
        return cachedPolicies;
      }
    }

    PerformanceMonitor.startTimer('fetch_policies');
    
    try {
      final policies = await DataService.getPolicies(limit: limit, offset: offset);
      CacheService.set(cacheKey, policies, duration: const Duration(minutes: 2));
      
      PerformanceMonitor.endTimer('fetch_policies');
      return policies;
    } catch (e) {
      PerformanceMonitor.endTimer('fetch_policies');
      rethrow;
    }
  }

  static Future<List<Category>> getCachedCategories({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'categories';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedCategories = CacheService.get<List<Category>>(cacheKey);
      if (cachedCategories != null) {
        return cachedCategories;
      }
    }

    PerformanceMonitor.startTimer('fetch_categories');
    
    try {
      final categories = await DataService.getCategories();
      CacheService.set(cacheKey, categories, duration: const Duration(minutes: 5));
      
      PerformanceMonitor.endTimer('fetch_categories');
      return categories;
    } catch (e) {
      PerformanceMonitor.endTimer('fetch_categories');
      rethrow;
    }
  }

  static Future<Map<String, int>> getCachedStatistics({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'statistics';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedStats = CacheService.get<Map<String, int>>(cacheKey);
      if (cachedStats != null) {
        return cachedStats;
      }
    }

    PerformanceMonitor.startTimer('calculate_statistics');
    
    try {
      final stats = await DataService.getStatistics();
      CacheService.set(cacheKey, stats, duration: const Duration(minutes: 1));
      
      PerformanceMonitor.endTimer('calculate_statistics');
      return stats;
    } catch (e) {
      PerformanceMonitor.endTimer('calculate_statistics');
      rethrow;
    }
  }

  // Batch operations for better performance
  static Future<bool> addPolicyWithCacheUpdate(Policy policy) async {
    PerformanceMonitor.startTimer('add_policy');
    
    try {
      final success = await DataService.addPolicy(policy);
      
      if (success) {
        // Invalidate related caches
        _invalidatePolicyCaches();
      }
      
      PerformanceMonitor.endTimer('add_policy');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('add_policy');
      rethrow;
    }
  }

  static Future<bool> updatePolicyWithCacheUpdate(Policy policy) async {
    PerformanceMonitor.startTimer('update_policy');
    
    try {
      final success = await DataService.updatePolicy(policy);
      
      if (success) {
        // Invalidate related caches
        _invalidatePolicyCaches();
      }
      
      PerformanceMonitor.endTimer('update_policy');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('update_policy');
      rethrow;
    }
  }

  static Future<bool> deletePolicyWithCacheUpdate(String policyId) async {
    PerformanceMonitor.startTimer('delete_policy');
    
    try {
      final success = await DataService.deletePolicy(policyId);
      
      if (success) {
        // Invalidate related caches
        _invalidatePolicyCaches();
      }
      
      PerformanceMonitor.endTimer('delete_policy');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('delete_policy');
      rethrow;
    }
  }

  static Future<bool> addCategoryWithCacheUpdate(Category category) async {
    PerformanceMonitor.startTimer('add_category');
    
    try {
      final success = await DataService.addCategory(category);
      
      if (success) {
        // Invalidate related caches
        CacheService.remove('categories');
        CacheService.remove('statistics');
      }
      
      PerformanceMonitor.endTimer('add_category');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('add_category');
      rethrow;
    }
  }

  // Preload data for better UX
  static Future<void> preloadDashboardData() async {
    await Future.wait([
      getCachedStatistics(),
      getCachedPolicies(limit: 5),
      getCachedCategories(),
    ]);
  }

  // Clear all caches
  static void clearAllCaches() {
    CacheService.clear();
  }

  // Helper method to invalidate policy-related caches
  static void _invalidatePolicyCaches() {
    // Remove all policy-related cache entries
    final cacheStats = CacheService.getStats();
    final allKeys = cacheStats['keys'] as List<String>? ?? [];
    
    for (final key in allKeys) {
      if (key.startsWith('policies_')) {
        CacheService.remove(key);
      }
    }
    
    CacheService.remove('statistics');
  }
}