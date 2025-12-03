import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../services/analytics_service.dart';
import '../services/image_service.dart';
import '../widgets/image_picker_bottom_sheet.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final ImageService _imageService = ImageService();
  DateTime? _viewStartTime;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _viewStartTime = DateTime.now();
    _analyticsService.trackPropertyView(widget.property.id);
  }

  @override
  void dispose() {
    if (_viewStartTime != null) {
      final duration = DateTime.now().difference(_viewStartTime!);
      _analyticsService.trackTimeSpent(widget.property.id, duration);
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
            actions: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _showImagePicker,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, priceFormat),
                  const SizedBox(height: 24),
                  _buildStatusBadge(theme),
                  const SizedBox(height: 16),
                  _buildPropertyDetails(theme),
                  const SizedBox(height: 24),
                  _buildDescription(theme),
                  const SizedBox(height: 24),
                  _buildLocationInfo(theme),
                  const SizedBox(height: 24),
                  _buildAgentInfo(theme),
                  const SizedBox(height: 24),
                  _buildTags(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.property.images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.property.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.property.images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            );
          },
        ),
        if (widget.property.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.property.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, NumberFormat priceFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.property.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          priceFormat.format(widget.property.price),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.property.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.property.status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailItem(
          Icons.bed,
          '${widget.property.bedrooms}',
          'Bedrooms',
          theme,
        ),
        _buildDetailItem(
          Icons.bathtub,
          '${widget.property.bathrooms}',
          'Bathrooms',
          theme,
        ),
        _buildDetailItem(
          Icons.square_foot,
          '${widget.property.areaSqFt}',
          'Sq Ft',
          theme,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String value,
    String label,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.property.description,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocationInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(widget.property.location.address),
          subtitle: Text(
            '${widget.property.location.city}, ${widget.property.location.state} ${widget.property.location.zip}',
          ),
        ),
      ],
    );
  }

  Widget _buildAgentInfo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Agent',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  widget.property.agent.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(widget.property.agent.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.property.agent.email),
                  Text(widget.property.agent.contact),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callAgent(context),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _emailAgent(context),
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(ThemeData theme) {
    if (widget.property.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.property.tags.map((tag) {
            return Chip(label: Text(tag));
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showImagePicker() {
    final scaffoldContext = context;
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => ImagePickerBottomSheet(
        onCameraTap: () async {
          Navigator.pop(bottomSheetContext);
          final image = await _imageService.pickImageFromCamera();
          if (image != null && mounted) {
            await _imageService.uploadImage(image, widget.property.id);
            if (mounted) {
              try {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                  ),
                );
              } catch (e) {
                // Context might be invalid, ignore silently
                print('Could not show snackbar: $e');
              }
            }
          }
        },
        onGalleryTap: () async {
          Navigator.pop(bottomSheetContext);
          final image = await _imageService.pickImageFromGallery();
          if (image != null && mounted) {
            await _imageService.uploadImage(image, widget.property.id);
            if (mounted) {
              try {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                  ),
                );
              } catch (e) {
                // Context might be invalid, ignore silently
                print('Could not show snackbar: $e');
              }
            }
          }
        },
      ),
    );
  }

  Future<void> _callAgent(BuildContext context) async {
    _analyticsService.trackClickEvent(
      widget.property.id,
      'button',
      'call_agent',
    );

    final phoneNumber = widget.property.agent.contact;
    final uri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make call to $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _emailAgent(BuildContext context) async {
    _analyticsService.trackClickEvent(
      widget.property.id,
      'button',
      'email_agent',
    );

    final email = widget.property.agent.email;
    final subject = 'Inquiry about ${widget.property.title}';
    final body = 'Hello ${widget.property.agent.name},\n\n'
        'I am interested in the property: ${widget.property.title}\n'
        'Property ID: ${widget.property.id}\n\n'
        'Please provide more information.\n\n'
        'Thank you!';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot send email to $email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
