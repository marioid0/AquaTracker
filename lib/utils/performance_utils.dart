import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceUtils {
  // Image optimization and caching
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.round(),
      cacheHeight: height?.round(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? 
          Container(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? 
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.error, color: Colors.grey[600]),
          );
      },
    );
  }

  // Debounce utility for search and input fields
  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  static final Map<String, Timer> _debounceTimers = {};

  // Memory optimization - dispose timers
  static void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
}

// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return 16.0;
    if (width < tablet) return 20.0;
    if (width < desktop) return 24.0;
    return 32.0;
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return baseFontSize * 0.9;
    if (width < tablet) return baseFontSize;
    if (width < desktop) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
}

// Performance monitoring
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void startTimer(String key) {
    _stopwatches[key] = Stopwatch()..start();
  }

  static void endTimer(String key) {
    final stopwatch = _stopwatches[key];
    if (stopwatch != null) {
      stopwatch.stop();
      if (kDebugMode) {
        print('Performance [$key]: ${stopwatch.elapsedMilliseconds}ms');
      }
      _stopwatches.remove(key);
    }
  }
}

import 'dart:async';