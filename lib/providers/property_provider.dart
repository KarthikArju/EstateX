import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/api_service.dart';

// Property provider - manages list state, filters, pagination
class PropertyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Property> _properties = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  int _totalProperties = 0;
  int _totalPages = 0;

  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedStatus;
  List<String> _selectedTags = [];

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get totalProperties => _totalProperties;
  int get totalPages => _totalPages;

  String? get selectedLocation => _selectedLocation;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get selectedStatus => _selectedStatus;
  List<String> get selectedTags => _selectedTags;

  Future<void> loadProperties({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 1;
      _properties = [];
      _hasMore = true;
    }

    if (!_hasMore && !reset) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Fetch from API

    try {
      final response = await _apiService.getProperties(
        page: _currentPage,
        location: _selectedLocation,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        status: _selectedStatus,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
      );

      if (reset) {
        _properties = response.properties;
      } else {
        _properties.addAll(response.properties);
      }

      _totalProperties = response.totalProperties;
      _totalPages = response.totalPages;
      _hasMore = _currentPage < response.totalPages;
      _currentPage++;

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading properties: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilters({
    String? location,
    double? minPrice,
    double? maxPrice,
    String? status,
    List<String>? tags,
  }) {
    _selectedLocation = location;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _selectedStatus = status;
    _selectedTags = tags ?? [];
    loadProperties(reset: true);
  }

  void clearFilters() {
    _selectedLocation = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedStatus = null;
    _selectedTags = [];
    loadProperties(reset: true);
  }

  void addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      _selectedTags.add(tag);
      loadProperties(reset: true);
    }
  }

  void removeTag(String tag) {
    _selectedTags.remove(tag);
    loadProperties(reset: true);
  }
}

