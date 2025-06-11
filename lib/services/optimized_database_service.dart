import '../database.dart';
import 'cache_service.dart';
import '../utils/performance_utils.dart';

class OptimizedDatabaseService {
  // Cached database operations
  static Future<List<WaterRecord>> getCachedUserWaterRecords({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'user_water_records';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedRecords = CacheService.get<List<WaterRecord>>(cacheKey);
      if (cachedRecords != null) {
        return cachedRecords;
      }
    }

    PerformanceMonitor.startTimer('fetch_water_records');
    
    try {
      final records = await DataService.getUserWaterRecords();
      CacheService.set(cacheKey, records, duration: const Duration(minutes: 2));
      
      PerformanceMonitor.endTimer('fetch_water_records');
      return records;
    } catch (e) {
      PerformanceMonitor.endTimer('fetch_water_records');
      rethrow;
    }
  }

  static Future<double> getCachedTotalWaterUsage({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'total_water_usage';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedTotal = CacheService.get<double>(cacheKey);
      if (cachedTotal != null) {
        return cachedTotal;
      }
    }

    PerformanceMonitor.startTimer('calculate_total_usage');
    
    try {
      final total = await DataService.getTotalWaterUsage();
      CacheService.set(cacheKey, total, duration: const Duration(minutes: 1));
      
      PerformanceMonitor.endTimer('calculate_total_usage');
      return total;
    } catch (e) {
      PerformanceMonitor.endTimer('calculate_total_usage');
      rethrow;
    }
  }

  static Future<Map<String, double>> getCachedUsageByCategory({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'usage_by_category';
    
    if (!forceRefresh && CacheService.has(cacheKey)) {
      final cachedUsage = CacheService.get<Map<String, double>>(cacheKey);
      if (cachedUsage != null) {
        return cachedUsage;
      }
    }

    PerformanceMonitor.startTimer('calculate_category_usage');
    
    try {
      final usage = await DataService.getUsageByCategory();
      CacheService.set(cacheKey, usage, duration: const Duration(minutes: 2));
      
      PerformanceMonitor.endTimer('calculate_category_usage');
      return usage;
    } catch (e) {
      PerformanceMonitor.endTimer('calculate_category_usage');
      rethrow;
    }
  }

  // Batch operations for better performance
  static Future<bool> addWaterRecordWithCacheUpdate(WaterRecord record) async {
    PerformanceMonitor.startTimer('add_water_record');
    
    try {
      final success = await DataService.addWaterRecord(record);
      
      if (success) {
        // Invalidate related caches
        CacheService.remove('user_water_records');
        CacheService.remove('total_water_usage');
        CacheService.remove('usage_by_category');
      }
      
      PerformanceMonitor.endTimer('add_water_record');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('add_water_record');
      rethrow;
    }
  }

  static Future<bool> deleteWaterRecordWithCacheUpdate(String recordId) async {
    PerformanceMonitor.startTimer('delete_water_record');
    
    try {
      final success = await DataService.deleteWaterRecord(recordId);
      
      if (success) {
        // Invalidate related caches
        CacheService.remove('user_water_records');
        CacheService.remove('total_water_usage');
        CacheService.remove('usage_by_category');
      }
      
      PerformanceMonitor.endTimer('delete_water_record');
      return success;
    } catch (e) {
      PerformanceMonitor.endTimer('delete_water_record');
      rethrow;
    }
  }

  // Preload data for better UX
  static Future<void> preloadDashboardData() async {
    await Future.wait([
      getCachedTotalWaterUsage(),
      getCachedUserWaterRecords(),
      getCachedUsageByCategory(),
    ]);
  }

  // Clear all caches
  static void clearAllCaches() {
    CacheService.clear();
  }
}