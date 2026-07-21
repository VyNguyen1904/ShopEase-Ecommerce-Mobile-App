import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/providers/auth_provider.dart';

class StoreMapScreen extends ConsumerStatefulWidget {
  const StoreMapScreen({super.key});

  @override
  ConsumerState<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends ConsumerState<StoreMapScreen> {
  LatLng? _userLocation;
  LatLng _storeLocation = const LatLng(10.7769, 106.7009); // Default fallback
  String _storeName = 'Cửa hàng';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchUserLocation(), _fetchStoreLocation()]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStoreLocation() async {
    try {
      final authService = ref.read(authServiceProvider);
      final data = await authService.getStoreInfo();
      if (data['latitude'] != null && data['longitude'] != null) {
        _storeLocation = LatLng(data['latitude'], data['longitude']);
      }
      if (data['storeName'] != null) {
        _storeName = data['storeName'];
      }
    } catch (e) {
      // Fallback to default if API fails
      debugPrint('Could not fetch store location: $e');
    }
  }

  Future<void> _fetchUserLocation() async {
    final locationService = ref.read(locationServiceProvider);
    Position? position = await locationService.getCurrentLocation();

    if (mounted) {
      if (position != null) {
        _userLocation = LatLng(position.latitude, position.longitude);
      }

      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể lấy được vị trí hiện tại. Vui lòng cấp quyền vị trí.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    final double destLat = _storeLocation.latitude;
    final double destLng = _storeLocation.longitude;

    final String googleMapsUrl = _userLocation != null
        ? 'https://www.google.com/maps/dir/?api=1&origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=$destLat,$destLng'
        : 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng';

    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể mở bản đồ.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bản đồ $_storeName')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _storeLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.shopease.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Store Marker
                        Marker(
                          point: _storeLocation,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.store,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // User Marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGoogleMaps,
        icon: const Icon(Icons.directions),
        label: const Text('Chỉ đường'),
      ),
    );
  }
}
