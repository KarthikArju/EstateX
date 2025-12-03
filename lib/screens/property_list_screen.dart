import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/filter_sheet.dart';
import '../models/property.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _availableLocations = {
    'Cityville',
    'Hillview',
    'Metrocity',
    'Beachside',
    'Townsburg',
  };
  final Set<String> _availableTags = {
    'New',
    'Furnished',
    'Luxury',
    'Pet Friendly',
    'Available',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties(reset: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Infinite scroll - load more when 80% scrolled
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final provider = context.read<PropertyProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadProperties();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.properties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProperties(reset: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.properties.isEmpty) {
            return const Center(
              child: Text('No properties found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadProperties(reset: true);
            },
            child: Column(
              children: [
                if (provider.selectedLocation != null ||
                    provider.minPrice != null ||
                    provider.maxPrice != null ||
                    provider.selectedStatus != null ||
                    provider.selectedTags.isNotEmpty)
                  _buildActiveFilters(provider),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount:
                        provider.properties.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.properties.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final property = provider.properties[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.9 + (value * 0.1),
                              child: PropertyCard(
                                property: property,
                                onTap: () => _navigateToDetail(property),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Responsive grid columns based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4; // Large desktop
    if (width > 800) return 3; // Tablet/Desktop
    if (width > 600) return 2; // Mobile landscape
    return 1; // Mobile portrait
  }

  Widget _buildActiveFilters(PropertyProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Text('Active filters: '),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (provider.selectedLocation != null)
                  Chip(
                    label: Text('Location: ${provider.selectedLocation}'),
                    onDeleted: () {
                      provider.setFilters(
                        location: null,
                        minPrice: provider.minPrice,
                        maxPrice: provider.maxPrice,
                        status: provider.selectedStatus,
                        tags: provider.selectedTags,
                      );
                    },
                  ),
                if (provider.minPrice != null || provider.maxPrice != null)
                  Chip(
                    label: Text(
                      'Price: \$${provider.minPrice ?? 0} - \$${provider.maxPrice ?? '∞'}',
                    ),
                    onDeleted: () {
                      provider.setFilters(
                        location: provider.selectedLocation,
                        minPrice: null,
                        maxPrice: null,
                        status: provider.selectedStatus,
                        tags: provider.selectedTags,
                      );
                    },
                  ),
                if (provider.selectedStatus != null)
                  Chip(
                    label: Text('Status: ${provider.selectedStatus}'),
                    onDeleted: () {
                      provider.setFilters(
                        location: provider.selectedLocation,
                        minPrice: provider.minPrice,
                        maxPrice: provider.maxPrice,
                        status: null,
                        tags: provider.selectedTags,
                      );
                    },
                  ),
                ...provider.selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      provider.removeTag(tag);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final provider = context.read<PropertyProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterSheet(
        currentLocation: provider.selectedLocation,
        currentMinPrice: provider.minPrice,
        currentMaxPrice: provider.maxPrice,
        currentStatus: provider.selectedStatus,
        currentTags: provider.selectedTags,
        availableTags: _availableTags.toList(),
        availableLocations: _availableLocations.toList(),
        onApply: (location, minPrice, maxPrice, status, tags) {
          provider.setFilters(
            location: location,
            minPrice: minPrice,
            maxPrice: maxPrice,
            status: status,
            tags: tags,
          );
        },
      ),
    );
  }

  // Navigate to detail with slide animation
  void _navigateToDetail(Property property) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PropertyDetailScreen(property: property),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
