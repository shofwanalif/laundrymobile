import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:laundrymobile/app/core/theme/app_colors.dart';
import '../controllers/location_controller.dart';

/// View untuk Live Location Tracker dengan Navigation
/// Menampilkan koordinat dan OpenStreetMap dengan marker lokasi pengguna dan rute
class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Location Tracker',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryDark
          : AppColors.primaryLight,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.hasRoute ? Icons.route : Icons.navigation,
                color: controller.hasRoute ? Colors.blue : null,
              ),
              onPressed: controller.calculateRouteToDestination,
              tooltip: 'Calculate Route',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPosition,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.openAppSettings,
            tooltip: 'Open Settings',
          ),
        ],
      ),
      body: Obx(() {
        // Loading state (include route calculation)
        if (controller.isLoading || controller.isCalculatingRoute) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mendapatkan lokasi...'),
              ],
            ),
          );
        }

        // Error state
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: controller.requestPermission,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Request Permission'),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Calculate Route di error state - TAMBAHKAN INI
                      ElevatedButton.icon(
                        onPressed: controller.calculateRouteToDestination,
                        icon: const Icon(Icons.navigation),
                        label: const Text('Calculate Route'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Main content
        return Stack(
          children: [
            Column(
              children: [
                // Coordinate Display Section
                _buildCoordinateDisplay(context, controller),

                // OpenStreetMap Section
                Expanded(child: _buildOpenStreetMap(controller)),
              ],
            ),

            // Zoom controls - positioned di kanan layar
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.zoomIn();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error zoom in: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.zoomOut();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error zoom out: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'center',
                    mini: true,
                    onPressed: () {
                      try {
                        controller.moveToCurrentPosition();
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error move to position: $e');
                        }
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 16,
              bottom: 16,
              child: Obx(
                () => FloatingActionButton(
                  heroTag: 'tracking',
                  onPressed: controller.toggleTracking,
                  backgroundColor: controller.isTracking
                      ? Colors.red
                      : Colors.blue,
                  child: Icon(
                    controller.isTracking ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            if (controller.hasRoute)
              Positioned(
                left: 16,
                bottom: 80,
                child: FloatingActionButton(
                  heroTag: 'zoom_route',
                  mini: true,
                  onPressed: controller.zoomToRoute,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.zoom_out_map, color: Colors.white),
                ),
              ),
          ],
        );
      }),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCoordinateDisplay(BuildContext context,LocationController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Laundry Cemerlang',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                // GPS Toggle Switch
                Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isGpsEnabled
                            ? Icons.gps_fixed
                            : Icons.gps_not_fixed,
                        size: 16,
                        color: controller.isGpsEnabled
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        controller.isGpsEnabled ? 'GPS' : 'Net',
                        style: TextStyle(
                          fontSize: 10,
                          color: controller.isGpsEnabled
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 40,
                        height: 24,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Switch(
                            value: controller.isGpsEnabled,
                            onChanged: (value) => controller.toggleGps(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  if (controller.hasRoute) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            controller.showRoute
                                ? Icons.route
                                : Icons.route_outlined,
                            color: controller.showRoute
                                ? Colors.blue
                                : Colors.grey,
                            size: 20,
                          ),
                          onPressed: controller.toggleRouteVisibility,
                          tooltip: 'Toggle Route',
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_out_map, size: 20),
                          onPressed: controller.zoomToRoute,
                          tooltip: 'Zoom to Route',
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }),

                if (controller.isTracking)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Route Information Card - TAMBAHKAN INI
            Obx(() {
              if (controller.hasRoute && controller.showRoute) {
                return Column(
                  children: [
                    _buildRouteInfoCard(controller),
                    const SizedBox(height: 12),
                  ],
                );
              }
              return const SizedBox();
            }),

            if (controller.currentPosition != null) ...[
              _buildCoordinateRow(
                'Latitude',
                controller.latitude?.toStringAsFixed(6) ?? 'N/A',
                Icons.north,
              ),
              const SizedBox(height: 8),
              _buildCoordinateRow(
                'Longitude',
                controller.longitude?.toStringAsFixed(6) ?? 'N/A',
                Icons.east,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Akurasi',
                      '${controller.accuracy?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.my_location,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      'Altitude',
                      '${controller.altitude?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.height,
                    ),
                  ),
                ],
              ),
              if (controller.speed != null && controller.speed! > 0) ...[
                const SizedBox(height: 8),
                _buildInfoCard(
                  context,
                  'Speed',
                  '${controller.speed?.toStringAsFixed(1) ?? 'N/A'} m/s',
                  Icons.speed,
                ),
              ],
              if (controller.timestamp != null) ...[
                const SizedBox(height: 8),
                _buildInfoCard(
                  context,
                  'Waktu',
                  DateFormat('HH:mm:ss').format(controller.timestamp!),
                  Icons.access_time,
                ),
              ],
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada data lokasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build coordinate row
  Widget _buildCoordinateRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar(
              'Copied',
              '$label: $value',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfoCard(LocationController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          Icon(Icons.route, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route to Laundry Cemerlang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Distance: ${controller.formattedDistance}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
                Text(
                  'Duration: ${controller.formattedDuration}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (controller.isCalculatingRoute)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  /// Build OpenStreetMap widget menggunakan FlutterMap - DIMODIFIKASI
  Widget _buildOpenStreetMap(LocationController controller) {
    if (controller.currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Menunggu data lokasi...',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.getCurrentPosition,
              icon: const Icon(Icons.location_searching),
              label: const Text('Dapatkan Lokasi'),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      // Render map langsung, handle error dengan try-catch
      try {
        return FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            onMapReady: () {
              controller.setMapReady();
            },
            initialCenter: controller.mapCenter,
            initialZoom: controller.mapZoom,
            minZoom: 3.0,
            maxZoom: 18.0,
            onMapEvent: (MapEvent event) {
              if (event is MapEventMove) {
                try {
                  if (controller.isMapControllerReady) {
                    final camera = controller.mapController.camera;
                    controller.updateMapCenter(camera.center, camera.zoom);
                  }
                } catch (e) {
                  // Ignore error if controller is disposed
                  if (kDebugMode) {
                    print('Error updating map center: $e');
                  }
                }
              }
            },
          ),
          children: [
            // Tile Layer - OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mobile.laundrymobile',
              maxZoom: 19,
              // Retina mode untuk kualitas lebih baik
              retinaMode: MediaQuery.of(Get.context!).devicePixelRatio > 1.0,
            ),

            // Route Polyline Layer - TAMBAHKAN INI
            Obx(() {
              if (controller.showRoute && controller.routePoints.isNotEmpty) {
                return PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.routePoints,
                      color: Colors.blue.withValues(alpha: 0.7),
                      strokeWidth: 4,
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),

            // Marker Layer - Menampilkan marker lokasi pengguna dan destination
            if (controller.currentPosition != null)
              MarkerLayer(
                markers: [
                  // User Marker
                  Marker(
                    point: LatLng(controller.latitude!, controller.longitude!),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Destination Marker - TAMBAHKAN INI
                  Marker(
                    point: controller.destination,
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

            // Attribution
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              popupBackgroundColor: Colors.white,
              attributions: [
                TextSourceAttribution('OpenStreetMap', onTap: () => {}),
                TextSourceAttribution('Contributors', onTap: () => {}),
              ],
            ),
          ],
        );
      } catch (e) {
        // Jika error, tampilkan error message dan tombol retry
        if (kDebugMode) {
          print('Error rendering map: $e');
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading map', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Reset map controller dan refresh
                  controller.resetMapController();
                  controller.refreshPosition();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    });
  }
}
