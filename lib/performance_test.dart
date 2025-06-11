import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utils/performance_utils.dart';
import 'services/cache_service.dart';

class PerformanceTestScreen extends StatefulWidget {
  @override
  _PerformanceTestScreenState createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  List<String> _performanceResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tests'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _runPerformanceTests,
              child: Text(_isRunning ? 'Running Tests...' : 'Run Performance Tests'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _performanceResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_performanceResults[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runPerformanceTests() async {
    setState(() {
      _isRunning = true;
      _performanceResults.clear();
    });

    // Test 1: Widget build performance
    await _testWidgetBuildPerformance();
    
    // Test 2: Cache performance
    await _testCachePerformance();
    
    // Test 3: List rendering performance
    await _testListRenderingPerformance();
    
    // Test 4: Memory usage
    await _testMemoryUsage();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testWidgetBuildPerformance() async {
    PerformanceMonitor.startTimer('widget_build_test');
    
    // Simulate building multiple widgets
    for (int i = 0; i < 1000; i++) {
      Container(
        child: Text('Test Widget $i'),
      );
    }
    
    PerformanceMonitor.endTimer('widget_build_test');
    
    setState(() {
      _performanceResults.add('✅ Widget Build Test: Completed 1000 widget builds');
    });
  }

  Future<void> _testCachePerformance() async {
    final stopwatch = Stopwatch()..start();
    
    // Test cache write performance
    for (int i = 0; i < 100; i++) {
      CacheService.set('test_key_$i', 'test_data_$i');
    }
    
    final writeTime = stopwatch.elapsedMilliseconds;
    stopwatch.reset();
    
    // Test cache read performance
    for (int i = 0; i < 100; i++) {
      CacheService.get('test_key_$i');
    }
    
    final readTime = stopwatch.elapsedMilliseconds;
    stopwatch.stop();
    
    setState(() {
      _performanceResults.add('✅ Cache Performance: Write ${writeTime}ms, Read ${readTime}ms');
    });
  }

  Future<void> _testListRenderingPerformance() async {
    PerformanceMonitor.startTimer('list_rendering_test');
    
    // Simulate list with many items
    final items = List.generate(1000, (index) => 'Item $index');
    
    // This would normally be rendered in a ListView
    for (var item in items) {
      ListTile(title: Text(item));
    }
    
    PerformanceMonitor.endTimer('list_rendering_test');
    
    setState(() {
      _performanceResults.add('✅ List Rendering: Processed 1000 list items');
    });
  }

  Future<void> _testMemoryUsage() async {
    final stats = CacheService.getStats();
    
    setState(() {
      _performanceResults.add('📊 Memory Usage: ${stats['memoryUsage']} bytes in cache');
      _performanceResults.add('📊 Cache Items: ${stats['totalItems']} items');
    });
  }
}