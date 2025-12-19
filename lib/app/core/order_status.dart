class OrderStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const washing = 'washing';
  static const completed = 'completed';
  static const pickedUp = 'picked_up';
  static const cancelled = 'cancelled';

  static const activeStatuses = [
    pending,
    processing,
    washing,
    completed,
  ];

  static const historyStatuses = [
    pickedUp,
    cancelled,
  ];
}
