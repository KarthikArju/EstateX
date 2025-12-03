import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/property_response.dart';

// API service for property listings
class ApiService {
  static const String baseUrl = 'http://147.182.207.192:8003';
  static const int defaultPageSize = 20;

  Future<PropertyResponse> getProperties({
    int page = 1,
    int pageSize = defaultPageSize,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? status,
    List<String>? tags,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/properties').replace(
        queryParameters: _buildQueryParams(
          page: page,
          pageSize: pageSize,
          location: location,
          minPrice: minPrice,
          maxPrice: maxPrice,
          status: status,
          tags: tags,
        ),
      );

      final uriWithTags = _addTagParams(uri, tags);

      // CORS issue on web - using proxy as workaround
      Uri finalUri;
      if (kIsWeb) {
        final fullUrl =
            '${uriWithTags.scheme}://${uriWithTags.host}:${uriWithTags.port}${uriWithTags.path}${uriWithTags.query.isNotEmpty ? '?${uriWithTags.query}' : ''}';
        finalUri = Uri.parse(
            'https://api.allorigins.win/raw?url=${Uri.encodeComponent(fullUrl)}');
      } else {
        finalUri = uriWithTags;
      }

      final response = await http.get(finalUri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PropertyResponse.fromJson(jsonData);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch: $e');
    }
  }

  // Build query params - only add non-null values
  Map<String, String> _buildQueryParams({
    required int page,
    required int pageSize,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? status,
    List<String>? tags,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (location != null && location.isNotEmpty) {
      params['location'] = location;
    }

    if (minPrice != null) {
      params['min_price'] = minPrice.toInt().toString();
    }

    if (maxPrice != null) {
      params['max_price'] = maxPrice.toInt().toString();
    }

    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }

    return params;
  }

  // Handle multiple tags - API needs them as separate params
  Uri _addTagParams(Uri uri, List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      return uri;
    }

    final queryParams = Map<String, dynamic>.from(uri.queryParameters);
    queryParams.remove('tags');

    final baseUri = uri.replace(queryParameters: queryParams);
    final existingQuery = baseUri.query;

    final tagParams =
        tags.map((tag) => 'tags=${Uri.encodeComponent(tag)}').join('&');
    final newQuery =
        existingQuery.isEmpty ? tagParams : '$existingQuery&$tagParams';

    return baseUri.replace(query: newQuery);
  }
}
