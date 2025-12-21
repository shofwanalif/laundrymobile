import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/report_provider.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ReportProvider _reportProvider = Get.find();

  late TabController tabController;

  // Summary cards
  final activeOrdersCount = 0.obs;
  final completedOrdersCount = 0.obs;

  // Daily report
  final dailyRevenue = 0.obs;
  final dailyOrders = 0.obs;
  final dailyWeight = 0.0.obs;

  // Monthly report
  final monthlyRevenue = 0.obs;
  final monthlyOrders = 0.obs;
  final monthlyWeight = 0.0.obs;
  final dailyRevenueChart = <int, int>{}.obs;
  final servicePopularity = <Map<String, dynamic>>[].obs;

  // Loading states
  final isLoadingSummary = false.obs;
  final isLoadingDaily = false.obs;
  final isLoadingMonthly = false.obs;

  // Current date for reports
  final selectedDate = DateTime.now().obs;

  final tabs = [
    {'label': 'Harian', 'index': 0},
    {'label': 'Bulanan', 'index': 1},
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(_onTabChanged);
    _loadAllData();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      if (tabController.index == 0) {
        fetchDailyReport();
      } else {
        fetchMonthlyReport();
      }
    }
  }

  Future<void> _loadAllData() async {
    await fetchSummary();
    await fetchDailyReport();
    await fetchMonthlyReport();
  }

  Future<void> fetchSummary() async {
    try {
      isLoadingSummary.value = true;
      activeOrdersCount.value = await _reportProvider.getActiveOrdersCount();
      completedOrdersCount.value = await _reportProvider
          .getCompletedOrdersCount();
    } catch (e) {
      rethrow;
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> fetchDailyReport() async {
    try {
      isLoadingDaily.value = true;
      final report = await _reportProvider.getDailyReport(selectedDate.value);
      dailyRevenue.value = report['totalRevenue'] as int;
      dailyOrders.value = report['totalOrders'] as int;
      dailyWeight.value = report['totalWeight'] as double;
    } catch (e) {
      rethrow;
    } finally {
      isLoadingDaily.value = false;
    }
  }

  Future<void> fetchMonthlyReport() async {
    try {
      isLoadingMonthly.value = true;

      final year = selectedDate.value.year;
      final month = selectedDate.value.month;

      final report = await _reportProvider.getMonthlyReport(year, month);
      monthlyRevenue.value = report['totalRevenue'] as int;
      monthlyOrders.value = report['totalOrders'] as int;
      monthlyWeight.value = report['totalWeight'] as double;
      dailyRevenueChart.value = Map<int, int>.from(
        report['dailyRevenue'] as Map,
      );

      // Fetch service popularity
      final popularity = await _reportProvider.getServicePopularity(
        year,
        month,
      );
      servicePopularity.value = popularity;
    } catch (e) {
      rethrow;
    } finally {
      isLoadingMonthly.value = false;
    }
  }

  Future<void> refresh() async {
    await _loadAllData();
  }
}
