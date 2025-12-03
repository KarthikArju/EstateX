import 'property.dart';

class PropertyResponse {
  final String? error;
  final FiltersApplied filtersApplied;
  final bool loading;
  final int page;
  final int pageSize;
  final List<Property> properties;
  final int totalPages;
  final int totalProperties;

  PropertyResponse({
    this.error,
    required this.filtersApplied,
    required this.loading,
    required this.page,
    required this.pageSize,
    required this.properties,
    required this.totalPages,
    required this.totalProperties,
  });

  factory PropertyResponse.fromJson(Map<String, dynamic> json) {
    return PropertyResponse(
      error: json['error'] as String?,
      filtersApplied: FiltersApplied.fromJson(
        json['filtersApplied'] as Map<String, dynamic>,
      ),
      loading: json['loading'] as bool,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      properties: (json['properties'] as List)
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalProperties: json['totalProperties'] as int,
    );
  }
}

class FiltersApplied {
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final String? status;
  final List<String> tags;

  FiltersApplied({
    this.location,
    this.minPrice,
    this.maxPrice,
    this.status,
    required this.tags,
  });

  factory FiltersApplied.fromJson(Map<String, dynamic> json) {
    return FiltersApplied(
      location: json['location'] as String?,
      minPrice: json['min_price'] != null
          ? (json['min_price'] as num).toDouble()
          : null,
      maxPrice: json['max_price'] != null
          ? (json['max_price'] as num).toDouble()
          : null,
      status: json['status'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : <String>[],
    );
  }
}

