import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Analytics tracking service
// Stores data locally in SharedPreferences
class AnalyticsService {
  static const String _viewCountKey = 'property_view_counts';
  static const String _timeSpentKey = 'property_time_spent';
  static const String _clickEventsKey = 'click_events';

  Future<void> trackPropertyView(String propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewCountsJson = prefs.getString(_viewCountKey) ?? '{}';
      final viewCounts = Map<String, int>.from(
        json.decode(viewCountsJson) as Map,
      );

      viewCounts[propertyId] = (viewCounts[propertyId] ?? 0) + 1;

      await prefs.setString(_viewCountKey, json.encode(viewCounts));
      _logToConsole('Property view tracked', {'propertyId': propertyId});
    } catch (e) {
      print('Error tracking property view: $e');
    }
  }

  Future<void> trackTimeSpent(String propertyId, Duration duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeSpentJson = prefs.getString(_timeSpentKey) ?? '{}';
      final timeSpent = Map<String, int>.from(
        json.decode(timeSpentJson) as Map,
      );

      final currentTime = timeSpent[propertyId] ?? 0;
      timeSpent[propertyId] = currentTime + duration.inSeconds;

      await prefs.setString(_timeSpentKey, json.encode(timeSpent));
      _logToConsole(
        'Time spent tracked',
        {
          'propertyId': propertyId,
          'seconds': duration.inSeconds,
        },
      );
    } catch (e) {
      print('Error tracking time spent: $e');
    }
  }

  Future<void> trackClickEvent(
    String propertyId,
    String elementType,
    String elementId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clickEventsJson = prefs.getString(_clickEventsKey) ?? '[]';
      final clickEvents = List<Map<String, dynamic>>.from(
        json.decode(clickEventsJson) as List,
      );

      clickEvents.add({
        'propertyId': propertyId,
        'elementType': elementType,
        'elementId': elementId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_clickEventsKey, json.encode(clickEvents));
      _logToConsole(
        'Click event tracked',
        {
          'propertyId': propertyId,
          'elementType': elementType,
          'elementId': elementId,
        },
      );
    } catch (e) {
      print('Error tracking click event: $e');
    }
  }

  Future<Map<String, int>> getMostViewedProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewCountsJson = prefs.getString(_viewCountKey) ?? '{}';
      final viewCounts = Map<String, int>.from(
        json.decode(viewCountsJson) as Map,
      );

      final sortedEntries = viewCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sortedEntries);
    } catch (e) {
      print('Error getting most viewed properties: $e');
      return {};
    }
  }

  Future<Map<String, int>> getTimeSpentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeSpentJson = prefs.getString(_timeSpentKey) ?? '{}';
      return Map<String, int>.from(
        json.decode(timeSpentJson) as Map,
      );
    } catch (e) {
      print('Error getting time spent data: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getClickEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clickEventsJson = prefs.getString(_clickEventsKey) ?? '[]';
      return List<Map<String, dynamic>>.from(
        json.decode(clickEventsJson) as List,
      );
    } catch (e) {
      print('Error getting click events: $e');
      return [];
    }
  }

  void _logToConsole(String event, Map<String, dynamic> data) {
    print('[Analytics] $event: ${json.encode(data)}');
  }
}

