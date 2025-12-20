import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';
import '../../../data/providers/address_provider.dart';
import '../../../data/providers/auth_provider.dart';

class AddAddressController extends GetxController {
  final LocationService _locationService = Get.find();
  final AddressProvider _addressProvider = Get.find();
  final AuthProvider _authProvider = Get.find();
  
  final MapController mapController = MapController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final Rx<LatLng?> selectedLatLng = Rx<LatLng?>(null);

  final label = ''.obs;
  final address = ''.obs;

  // --- EDIT MODE STATE ---
  final isEditMode = false.obs;
  String? editAddressId;

  // Tambahkan TextEditingController agar saat EDIT, teks langsung muncul di kolom input
  final labelTextController = TextEditingController();
  final addressTextController = TextEditingController();

  String get userId {
    final user = _authProvider.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  @override
  void onInit() {
    super.onInit();
    
    // --- CEK APAKAH ADA ARGUMEN (MODE EDIT) ---
    if (Get.arguments != null) {
      _setupEditMode(Get.arguments);
    } else {
      _initLocation(); // Jika tidak ada argumen, ambil lokasi GPS sekarang
    }
  }

  // --- FUNGSI SETUP EDIT MODE ---
  void _setupEditMode(dynamic data) {
    isEditMode.value = true;
    editAddressId = data.id;
    
    // Isi nilai reaktif
    label.value = data.label;
    address.value = data.address;
    
    // Isi nilai ke Text Controller agar muncul di UI
    labelTextController.text = data.label;
    addressTextController.text = data.address;

    // Set posisi peta ke koordinat lama
    selectedLatLng.value = LatLng(data.latitude, data.longitude);

    // Gerakkan kamera peta setelah map ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (selectedLatLng.value != null) {
        mapController.move(selectedLatLng.value!, 16);
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      isLoading.value = true;
      final position = await _locationService.getCurrentPosition(useGps: true);
      if (position != null) {
        selectedLatLng.value = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi device');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveToCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition(useGps: true);
      if (position != null) {
        final newLatLng = LatLng(position.latitude, position.longitude);
        selectedLatLng.value = newLatLng;
        mapController.move(newLatLng, 16); 
      }
    } catch (e) {
      Get.snackbar('Info', 'Pastikan GPS Anda aktif');
    }
  }

  void updateMarkerPosition(LatLng latLng) {
    selectedLatLng.value = latLng;
  }

  Future<void> saveAddress() async {
    if (selectedLatLng.value == null || label.value.isEmpty || address.value.isEmpty) {
      Get.snackbar('Peringatan', 'Lengkapi data dan pilih lokasi di peta',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final payload = {
      'user_id': userId,
      'label': label.value.trim(),
      'address': address.value.trim(),
      'latitude': selectedLatLng.value!.latitude,
      'longitude': selectedLatLng.value!.longitude,
    };

    try {
      isSaving.value = true;

      // --- LOGIKA SIMPAN VS UPDATE ---
      if (isEditMode.value) {
        await _addressProvider.updateAddress(editAddressId!, payload);
      } else {
        payload['created_at'] = DateTime.now().toIso8601String();
        await _addressProvider.createAddress(payload);
      }

      Get.back(result: true);
      Get.snackbar('Berhasil', isEditMode.value ? 'Alamat diperbarui' : 'Alamat disimpan', 
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat memproses data');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    labelTextController.dispose();
    addressTextController.dispose();
    super.onClose();
  }
}