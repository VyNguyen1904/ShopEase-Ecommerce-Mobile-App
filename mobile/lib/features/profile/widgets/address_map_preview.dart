import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../screens/map_picker_screen.dart';

class AddressMapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final dynamic selectedProvince;
  final dynamic selectedWard;
  final String streetAddress;
  final List<dynamic> provinces;
  final List<dynamic> wards;
  final Function(double lat, double lng, dynamic province, dynamic ward, List<dynamic> wards, String street) onLocationUpdated;

  const AddressMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.selectedProvince,
    required this.selectedWard,
    required this.streetAddress,
    required this.provinces,
    required this.wards,
    required this.onLocationUpdated,
  });

  Future<void> _handleMapTap(BuildContext context) async {
    String? query;
    if (selectedProvince != null && streetAddress.isNotEmpty) {
      final districtPart = selectedWard != null ? '${selectedWard['district_name']}, ' : '';
      final wardPart = selectedWard != null ? '${selectedWard['name']}, ' : '';
      query = '$streetAddress, $wardPart$districtPart${selectedProvince['name']}';
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: latitude != null && longitude != null
              ? LatLng(latitude!, longitude!)
              : null,
          searchQuery: query,
        ),
      ),
    );

    if (result != null) {
      final lat = result['latitude'];
      final lng = result['longitude'];
      dynamic matchedProvince = selectedProvince;
      dynamic matchedWard = selectedWard;
      List<dynamic> updatedWards = List.from(wards);
      String street = streetAddress;

      if (result['raw'] != null && result['raw']['address'] != null) {
        final addr = result['raw']['address'] ?? {};
        final displayName = (result['raw']['display_name']?.toString() ?? '').toLowerCase();

        // Province Mapping
        matchedProvince = _findProvince(displayName);

        if (matchedProvince != null) {
           if (selectedProvince != matchedProvince) {
               matchedWard = null;
               updatedWards = [];
           }
        }
        street = addr['road'] ?? '';
        if (addr['house_number'] != null) street = '${addr['house_number']} $street';
      } else if (result['address'] != null) {
        street = result['address'];
      }

      onLocationUpdated(lat, lng, matchedProvince, matchedWard, updatedWards, street);
    }
  }

  dynamic _findProvince(String displayName) {
    final displayNameParts = displayName.split(',').map((e) => e.trim()).toList();
    for (var p in provinces) {
      final pName = p['name'].toString().toLowerCase();
      final pShort = pName.replaceFirst(RegExp(r'^(thành phố|tỉnh)\s+'), '').trim();
      if (displayNameParts.contains(pName) || displayNameParts.contains(pShort)) {
        return p;
      }
    }
    final tail = displayNameParts.reversed.take(4).join(', ');
    for (var p in provinces) {
      final pName = p['name'].toString().toLowerCase();
      final pShort = pName.replaceFirst(RegExp(r'^(thành phố|tỉnh)\s+'), '').trim();
      if (tail.contains(pName) || tail.contains(pShort)) {
        return p;
      }
    }
    return selectedProvince;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleMapTap(context),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latitude != null && longitude != null
                      ? LatLng(latitude!, longitude!)
                      : const LatLng(10.762622, 106.660172),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.shopease.app',
                  ),
                  if (latitude != null && longitude != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude!, longitude!),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                        )
                      ],
                    )
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      latitude != null ? AppStrings.tapToEditLocation : AppStrings.tapToPinLocation,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
