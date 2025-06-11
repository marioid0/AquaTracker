import 'dart:convert';
import 'package:flutter/foundation.dart';

class CacheService {
  static final Map<String, CacheItem> _cache = {};
  static const Duration defaultCacheDuration = Duration(minutes: 5);

  // Cache data with expiration
  static void set<T>(
    String key, 
    T data, {
    Duration? duration,
  }) {
    _cache[key] = CacheItem(
      data: data,
      timestamp: DateTime.now(),
      duration: duration ?? defaultCacheDuration,
    );
  }

  // Get cached data
  static T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (DateTime.now().difference(item.timestamp) > item.duration) {
      _cache.remove(key);
      return null;
    }

    return item.data as T?;
  }

  // Check if data exists and is valid
  static bool has(String key) {
    final item = _cache[key];
    if (item == null) return false;

    if (DateTime.now().difference(item.timestamp) > item.duration) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  // Clear specific cache
  static void remove(String key) {
    _cache.remove(key);
  }

  // Clear all cache
  static void clear() {
    _cache.clear();
  }

  // Clear expired cache items
  static void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, item) => 
      now.difference(item.timestamp) > item.duration);
  }

  // Get cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'totalItems': _cache.length,
      'memoryUsage': _calculateMemoryUsage(),
    };
  }

  static int _calculateMemoryUsage() {
    int totalSize = 0;
    for (var item in _cache.values) {
      try {
        final jsonString = jsonEncode(item.data);
        totalSize += jsonString.length;
      } catch (e) {
        // Skip items that can't be serialized
      }
    }
    return totalSize;
  }
}

class CacheItem {
  final dynamic data;
  final DateTime timestamp;
  final Duration duration;

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.duration,
  });
}