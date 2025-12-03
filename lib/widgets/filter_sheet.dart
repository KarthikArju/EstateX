import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final String? currentLocation;
  final double? currentMinPrice;
  final double? currentMaxPrice;
  final String? currentStatus;
  final List<String> currentTags;
  final List<String> availableTags;
  final List<String> availableLocations;
  final Function(String?, double?, double?, String?, List<String>) onApply;

  const FilterSheet({
    super.key,
    required this.currentLocation,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentStatus,
    required this.currentTags,
    required this.availableTags,
    required this.availableLocations,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _selectedLocation;
  late double? _minPrice;
  late double? _maxPrice;
  late String? _selectedStatus;
  late List<String> _selectedTags;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentLocation;
    _minPrice = widget.currentMinPrice;
    _maxPrice = widget.currentMaxPrice;
    _selectedStatus = widget.currentStatus;
    _selectedTags = List.from(widget.currentTags);

    if (_minPrice != null) {
      _minPriceController.text = _minPrice!.toInt().toString();
    }
    if (_maxPrice != null) {
      _maxPriceController.text = _maxPrice!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildLocationFilter(),
          const SizedBox(height: 16),
          _buildPriceFilter(),
          const SizedBox(height: 16),
          _buildStatusFilter(),
          const SizedBox(height: 16),
          _buildTagsFilter(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select location',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Locations'),
            ),
            ...widget.availableLocations.map((location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedLocation = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Min Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Max Price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStatusChip('Available'),
            _buildStatusChip('Sold'),
            _buildStatusChip('Upcoming'),
            _buildStatusChip(null),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(status ?? 'All'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedLocation = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedStatus = null;
      _selectedTags = [];
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _applyFilters() {
    final minPrice = _minPriceController.text.isNotEmpty
        ? double.tryParse(_minPriceController.text)
        : null;
    final maxPrice = _maxPriceController.text.isNotEmpty
        ? double.tryParse(_maxPriceController.text)
        : null;

    widget.onApply(
      _selectedLocation,
      minPrice,
      maxPrice,
      _selectedStatus,
      _selectedTags,
    );
    Navigator.pop(context);
  }
}

