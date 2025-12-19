import './order_status.dart';

class OrderStatusLabel {
  static String from(String status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.washing:
        return 'Dicuci';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.pickedUp:
        return 'Diambil';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'Tidak diketahui';
    }
  }
}
