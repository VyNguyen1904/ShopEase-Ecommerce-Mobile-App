import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/map_info_card.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? searchQuery;

  const MapPickerScreen({super.key, this.initialLocation, this.searchQuery});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  LatLng _currentCenter = const LatLng(
    10.762622,
    106.660172,
  ); // Default to HCM City
  String _currentAddress = AppStrings.loadingLocation;
  dynamic _rawAddress; // Store the raw address data
  bool _isLoadingAddress = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLocation != null) {
      _currentCenter = widget.initialLocation!;
      _getAddressFromLatLng(_currentCenter);
    } else if (widget.searchQuery != null &&
        widget.searchQuery!.trim().isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchAddress(widget.searchQuery!);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentCenter = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_currentCenter, 16.0);
    _getAddressFromLatLng(_currentCenter);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });
    try {
      // Use Nominatim API for reverse geocoding
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        options: Options(headers: {'User-Agent': 'ShopEaseApp/1.0'}),
        queryParameters: {
          'format': 'json',
          'lat': position.latitude,
          'lon': position.longitude,
          'addressdetails': 1,
          'accept-language': 'vi',
        },
      );
      if (response.data != null && response.data['display_name'] != null) {
        String dn = response.data['display_name'];
        dn = dn.replaceAll(
          'Thành phố Thủ Đức, Thành phố Hồ Chí Minh',
          'Thành phố Hồ Chí Minh',
        );
        response.data['display_name'] = dn;

        setState(() {
          _currentAddress = dn;
          _rawAddress = response.data;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = AppStrings.cannotGetAddress;
        _rawAddress = null;
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        options: Options(headers: {'User-Agent': 'ShopEaseApp/1.0'}),
        queryParameters: {
          'format': 'json',
          'q': query,
          'limit': 5,
          'accept-language': 'vi',
          'countrycodes': 'vn',
          'addressdetails': 1,
        },
      );
      if (response.data != null) {
        setState(() {
          _searchResults = response.data;
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  void _onSearchResultSelected(dynamic result) {
    FocusScope.of(context).unfocus();
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final newLocation = LatLng(lat, lon);

    String dn = result['display_name'];
    dn = dn.replaceAll(
      'Thành phố Thủ Đức, Thành phố Hồ Chí Minh',
      'Thành phố Hồ Chí Minh',
    );
    result['display_name'] = dn;

    setState(() {
      _searchResults = [];
      _searchController.text = dn;
      _currentCenter = newLocation;
      _currentAddress = dn;
      _rawAddress = result;
    });

    _mapController.move(newLocation, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.selectLocationTitle,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 16.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  setState(() {
                    _currentCenter = position.center!;
                  });
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(_currentCenter);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shopease.app',
              ),
            ],
          ),

          // Fixed center pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 40.0,
              ), // Offset to put the tip of the pin exactly at center
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),

          // Search Bar
          MapSearchBar(
            searchController: _searchController,
            searchResults: _searchResults,
            onChanged: (val) {
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 800), () {
                if (val.length > 3) {
                  _searchAddress(val);
                }
              });
            },
            onSubmitted: (val) {
              _debounceTimer?.cancel();
              _searchAddress(val);
            },
            onClear: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
              });
            },
            onResultSelected: _onSearchResultSelected,
          ),

          // My Location Button
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Bottom Info Card
          MapInfoCard(
            isLoadingAddress: _isLoadingAddress,
            currentAddress: _currentAddress,
            onConfirm: () {
              // Return the selected location
              Navigator.of(context).pop({
                'latitude': _currentCenter.latitude,
                'longitude': _currentCenter.longitude,
                'address': _currentAddress,
                'raw': _rawAddress,
              });
            },
          ),
        ],
      ),
    );
  }
}
