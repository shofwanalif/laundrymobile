import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/navigation_service.dart'; 

/// Controller untuk Live Location Tracker dengan Navigation
/// Menggunakan GetX untuk state management
/// Menggunakan OpenStreetMap dengan flutter_map
class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final NavigationService _navigationService = NavigationService(); // Tambahkan ini

  // Observables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isTracking = false.obs;
  final Rx<LocationPermission> _permissionStatus =
      LocationPermission.denied.obs;
  final RxBool _isGpsEnabled = false.obs; // GPS toggle, default: off
  final RxBool _mapReady = false.obs;
  
  // Navigation Observables - TAMBAHKAN INI
  final RxList<LatLng> _routePoints = <LatLng>[].obs;
  final RxDouble _routeDistance = 0.0.obs; // dalam meter
  final RxDouble _routeDuration = 0.0.obs; // dalam detik
  final RxBool _isCalculatingRoute = false.obs;
  final RxBool _showRoute = false.obs;

  bool get isMapReady => _mapReady.value;

  // FlutterMap Controller
  MapController? _mapController;
  bool _isDisposed = false;

  // Map center position dan zoom
  final Rx<LatLng> _mapCenter = Rx<LatLng>(
    const LatLng(-6.2088, 106.8456), // Jakarta default
  );
  final RxDouble _mapZoom = 15.0.obs;

  // Stream subscription
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  Position? get currentPosition => _currentPosition.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isTracking => _isTracking.value;
  LocationPermission get permissionStatus => _permissionStatus.value;
  bool get isGpsEnabled => _isGpsEnabled.value;
  
  // Navigation Getters - TAMBAHKAN INI
  List<LatLng> get routePoints => _routePoints;
  double get routeDistance => _routeDistance.value;
  double get routeDuration => _routeDuration.value;
  bool get isCalculatingRoute => _isCalculatingRoute.value;
  bool get showRoute => _showRoute.value;
  LatLng get destination => _navigationService.destination;

  MapController get mapController {
    // Jika null atau disposed, buat baru
    if (_mapController == null || _isDisposed) {
      try {
        _mapController?.dispose();
      } catch (e) {
        // Ignore error saat dispose
      }
      _mapController = MapController();
      _isDisposed = false;
    }
    return _mapController!;
  }

  /// Check if map controller is ready and not disposed
  bool get isMapControllerReady => _mapController != null && !_isDisposed;
  LatLng get mapCenter => _mapCenter.value;
  double get mapZoom => _mapZoom.value;

  // Computed values
  double? get latitude => _currentPosition.value?.latitude;
  double? get longitude => _currentPosition.value?.longitude;
  double? get accuracy => _currentPosition.value?.accuracy;
  double? get altitude => _currentPosition.value?.altitude;
  double? get speed => _currentPosition.value?.speed;
  DateTime? get timestamp => _currentPosition.value?.timestamp;
  
  // Navigation Computed Values - TAMBAHKAN INI
  String get formattedDistance => _navigationService.formatDistance(_routeDistance.value);
  String get formattedDuration => _navigationService.formatDuration(_routeDuration.value);
  bool get hasRoute => _routePoints.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    // Reset state dan initialize map controller
    _isDisposed = false;
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore error
    }
    _mapController = MapController();
    _initializeLocation();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _stopTracking();
    _positionSubscription?.cancel();
    _positionSubscription = null;

    // Dispose map controller dengan error handling
    try {
      _mapController?.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing map controller: $e');
      }
    } finally {
      _mapController = null;
    }

    super.onClose();
  }

  void setMapReady() {
    _mapReady.value = true;

    // Begitu map siap, dan ada posisi, langsung pindah
    if (_currentPosition.value != null) {
      moveToCurrentPosition();
    }
  }

  /// Safe method to check and use map controller
  bool _canUseMapController() {
    return !_isDisposed && _mapController != null;
  }

  /// Initialize location service
  Future<void> _initializeLocation() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Jika GPS enabled, cek apakah GPS service aktif
      // Jika GPS disabled (network only), tidak perlu cek GPS service
      if (_isGpsEnabled.value) {
        bool isEnabled = await _locationService.isLocationServiceEnabled();
        if (!isEnabled) {
          _errorMessage.value =
              'GPS tidak aktif. Silakan aktifkan GPS atau gunakan Network Provider.';
          _isLoading.value = false;
          return;
        }
      }

      // Cek permission
      _permissionStatus.value = await _locationService.checkPermission();

      // Jika permission belum granted, request
      if (_permissionStatus.value == LocationPermission.denied ||
          _permissionStatus.value == LocationPermission.deniedForever) {
        await requestPermission();
      }

      // Dapatkan posisi terakhir yang diketahui
      await getLastKnownPosition();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
      if (kDebugMode) {
        print('Location initialization error: $e');
      }
    }
  }

  /// ========== NAVIGATION METHODS - TAMBAHKAN INI ==========
  
  /// Hitung rute ke destination
  Future<void> calculateRouteToDestination() async {
    if (_currentPosition.value == null) {
      _errorMessage.value = 'Lokasi saat ini tidak tersedia';
      return;
    }

    try {
      _isCalculatingRoute.value = true;
      _errorMessage.value = '';

      // Convert Position ke LatLng
      final currentLatLng = LatLng(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      // Dapatkan rute dari OSRM
      final routeData = await _navigationService.getRoute(
        currentLatLng,
        _navigationService.destination,
      );

      // Decode polyline dan update state
      _routePoints.value = _navigationService.decodePolyline(routeData);
      
      // Update route info
      final routeInfo = _navigationService.getRouteInfo(routeData);
      _routeDistance.value = routeInfo['distance'];
      _routeDuration.value = routeInfo['duration'];

      // Auto-show route setelah dihitung
      _showRoute.value = true;
      
      _errorMessage.value = '';

      if (kDebugMode) {
        print('Route calculated: ${_routePoints.length} points');
        print('Distance: ${_routeDistance.value}m, Duration: ${_routeDuration.value}s');
      }

    } catch (e) {
      _errorMessage.value = 'Gagal menghitung rute: ${e.toString()}';
      _routePoints.clear();
      _showRoute.value = false;
      
      if (kDebugMode) {
        print('Route calculation error: $e');
      }
    } finally {
      _isCalculatingRoute.value = false;
    }
  }

  /// Toggle show/hide route di peta
  void toggleRouteVisibility() {
    _showRoute.value = !_showRoute.value;
  }

  /// Show route di peta
  void showRouteOnMap() {
    _showRoute.value = true;
  }

  /// Hide route dari peta
  void hideRouteFromMap() {
    _showRoute.value = false;
  }

  /// Clear route dari peta
  void clearRoute() {
    _routePoints.clear();
    _showRoute.value = false;
    _routeDistance.value = 0.0;
    _routeDuration.value = 0.0;
  }

  /// Refresh route dengan posisi terbaru
  Future<void> refreshRoute() async {
    if (_currentPosition.value != null) {
      await calculateRouteToDestination();
    }
  }

  /// Move map untuk menampilkan seluruh rute
  void zoomToRoute() {
    if (!isMapReady || _isDisposed || !_canUseMapController()) return;
    if (_routePoints.isEmpty) return;

    try {
      // Hitung bounds dari semua route points + current position + destination
      final allPoints = List<LatLng>.from(_routePoints)
        ..add(LatLng(_currentPosition.value!.latitude, _currentPosition.value!.longitude))
        ..add(_navigationService.destination);

      // Hitung center point
      double minLat = allPoints[0].latitude;
      double maxLat = allPoints[0].latitude;
      double minLng = allPoints[0].longitude;
      double maxLng = allPoints[0].longitude;

      for (final point in allPoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final center = LatLng(
        (minLat + maxLat) / 2,
        (minLng + maxLng) / 2,
      );

      // Adjust zoom level berdasarkan area coverage
      final latDiff = maxLat - minLat;
      final lngDiff = maxLng - minLng;
      final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
      
      double zoomLevel = 15.0;
      if (maxDiff > 0.1) zoomLevel = 12.0;
      if (maxDiff > 0.2) zoomLevel = 11.0;
      if (maxDiff > 0.5) zoomLevel = 10.0;

      _mapController?.move(center, zoomLevel);

    } catch (e) {
      if (kDebugMode) {
        print('Error zooming to route: $e');
      }
    }
  }

  /// ========== EXISTING METHODS (DIMODIFIKASI SEDIKIT) ==========

  /// Request permission untuk akses lokasi
  Future<void> requestPermission() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Request permission dengan GPS requirement sesuai toggle state
      bool granted = await _locationService.requestPermission(
        requireGps: _isGpsEnabled.value,
      );
      _permissionStatus.value = await _locationService.checkPermission();

      if (!granted) {
        _errorMessage.value =
            'Permission lokasi ditolak. Silakan aktifkan di Settings.';
      } else {
        // Jika permission granted, dapatkan posisi saat ini
        await getCurrentPosition();
      }

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  /// Buka location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Buka app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Dapatkan posisi saat ini (one-time) - DIMODIFIKASI
  Future<void> getCurrentPosition() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Gunakan GPS toggle state
      Position? position = await _locationService.getCurrentPosition(
        useGps: _isGpsEnabled.value,
      );

      if (position != null) {
        _currentPosition.value = position;
        _updateMapPosition(position);
        _errorMessage.value = '';
        
        // Auto-calculate route ketika dapat posisi baru
        await calculateRouteToDestination();
      } else {
        _errorMessage.value = 'Tidak dapat mendapatkan posisi saat ini.';
      }

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
      if (kDebugMode) {
        print('Get current position error: $e');
      }
    }
  }

  /// Dapatkan posisi terakhir yang diketahui - DIMODIFIKASI
  Future<void> getLastKnownPosition() async {
    try {
      Position? position = await _locationService.getLastKnownPosition();

      if (position != null) {
        _currentPosition.value = position;
        _updateMapPosition(position);
        // Jangan auto-calculate route untuk last known position
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get last known position error: $e');
      }
    }
  }

  /// Mulai tracking posisi real-time - DIMODIFIKASI
  Future<void> startTracking() async {
    try {
      // Cek permission dulu (dengan GPS requirement sesuai toggle state)
      bool hasPermission = await _locationService.requestPermission(
        requireGps: _isGpsEnabled.value,
      );
      if (!hasPermission) {
        _errorMessage.value = 'Permission lokasi diperlukan untuk tracking.';
        return;
      }

      _isTracking.value = true;
      _errorMessage.value = '';

      // Dapatkan stream posisi dengan GPS toggle state
      Stream<Position>? positionStream = _locationService.getPositionStream(
        useGps: _isGpsEnabled.value,
        distanceFilter: 10, // Update setiap 10 meter
      );

      if (positionStream != null) {
        _positionSubscription?.cancel();
        _positionSubscription = positionStream.listen(
          (Position position) {
            _currentPosition.value = position;
            _updateMapPosition(position);
            
            // Optional: Update route secara realtime saat tracking
            // Comment line below jika tidak ingin realtime route update
            _refreshRouteIfNeeded();
          },
          onError: (error) {
            _errorMessage.value = 'Error tracking: ${error.toString()}';
            if (kDebugMode) {
              print('Position stream error: $error');
            }
          },
        );
      } else {
        _errorMessage.value = 'Tidak dapat memulai tracking.';
        _isTracking.value = false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isTracking.value = false;
      if (kDebugMode) {
        print('Start tracking error: $e');
      }
    }
  }

  /// Helper method untuk refresh route jika diperlukan
  void _refreshRouteIfNeeded() {
    if (hasRoute && _currentPosition.value != null) {
      // Refresh route setiap 10 update atau jika significant movement
      // Implementasi bisa disesuaikan dengan kebutuhan
      refreshRoute();
    }
  }

  /// Stop tracking posisi
  void _stopTracking() {
    _isTracking.value = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationService.stopPositionStream();
  }

  /// Stop tracking (public method)
  void stopTracking() {
    _stopTracking();
  }

  /// Update map position (center dan zoom)
  void _updateMapPosition(Position position) {
    if (_isDisposed || !_canUseMapController()) return;

    final newCenter = LatLng(position.latitude, position.longitude);
    _mapCenter.value = newCenter;

    if (!isMapReady) {
      // Jangan move kalau map belum siap
      return;
    }

    try {
      _mapController?.move(newCenter, _mapZoom.value);
    } catch (e) {
      if (kDebugMode) {
        print('Map controller not ready yet: $e');
      }
    }
  }

  /// Update map center (untuk onMapMove callback)
  void updateMapCenter(LatLng center, double zoom) {
    if (_isDisposed) return;
    _mapCenter.value = center;
    _mapZoom.value = zoom;
  }

  /// Set zoom level
  void setZoom(double zoom) {
    if (!isMapReady) return;
    if (_isDisposed || !_canUseMapController()) return;

    _mapZoom.value = zoom;
    if (_currentPosition.value != null) {
      try {
        _mapController?.move(
          LatLng(
            _currentPosition.value!.latitude,
            _currentPosition.value!.longitude,
          ),
          zoom,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Map controller not ready for zoom: $e');
        }
      }
    }
  }

  /// Zoom in
  void zoomIn() {
    if (!isMapReady) return;
    final newZoom = (_mapZoom.value + 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  /// Zoom out
  void zoomOut() {
    if (!isMapReady) return;
    final newZoom = (_mapZoom.value - 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  /// Move map ke current position
  void moveToCurrentPosition() {
    if (!isMapReady || _isDisposed || !_canUseMapController()) return;

    if (_currentPosition.value != null) {
      final p = _currentPosition.value!;
      final center = LatLng(p.latitude, p.longitude);
      _mapCenter.value = center;
      _mapController!.move(center, _mapZoom.value);
    }
  }

  /// Refresh posisi - DIMODIFIKASI
  Future<void> refreshPosition() async {
    await getCurrentPosition(); // Sudah include auto-route calculation
  }

  /// Reset map controller (untuk retry setelah error)
  void resetMapController() {
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore error
    }
    _mapController = MapController();
    _isDisposed = false;
  }

  /// Toggle tracking
  Future<void> toggleTracking() async {
    if (_isTracking.value) {
      stopTracking();
    } else {
      await startTracking();
    }
  }

  /// Toggle GPS on/off - DIMODIFIKASI
  Future<void> toggleGps() async {
    _isGpsEnabled.value = !_isGpsEnabled.value;

    // Jika sedang tracking, restart dengan setting baru
    if (_isTracking.value) {
      _stopTracking();
      await startTracking();
    } else {
      // Jika tidak tracking, refresh posisi dengan setting baru
      await getCurrentPosition(); // Sudah include auto-route calculation
    }
  }

  /// Set GPS enabled/disabled - DIMODIFIKASI
  Future<void> setGpsEnabled(bool enabled) async {
    if (_isGpsEnabled.value != enabled) {
      _isGpsEnabled.value = enabled;

      // Jika sedang tracking, restart dengan setting baru
      if (_isTracking.value) {
        _stopTracking();
        await startTracking();
      } else {
        // Jika tidak tracking, refresh posisi dengan setting baru
        await getCurrentPosition(); // Sudah include auto-route calculation
      }
    }
  }
}