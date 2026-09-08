import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/socket_service.dart';

class RealtimeNotificationProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();

  Order? _latestOrder;
  bool _isBannerVisible = false;
  bool _isConnected = false;

  Order? get latestOrder => _latestOrder;
  bool get isBannerVisible => _isBannerVisible;
  bool get isConnected => _isConnected;

  void initialize(void Function(Order) onNewOrderCallback) {
    _socketService.addConnectionListener((connected) {
      _isConnected = connected;
      notifyListeners();
    });

    _socketService.addOrderListener((order) {
      _latestOrder = order;
      _isBannerVisible = true;
      notifyListeners();
      onNewOrderCallback(order);

      // Auto-hide banner after 8 seconds if not dismissed
      Future.delayed(const Duration(seconds: 8), () {
        if (_latestOrder?.id == order.id) {
          _isBannerVisible = false;
          notifyListeners();
        }
      });
    });

    _socketService.initSocket();
  }

  void dismissBanner() {
    _isBannerVisible = false;
    notifyListeners();
  }

  void triggerManualTestOrder() {
    final mockOrder = Order(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'DZ-${1000 + DateTime.now().second * 10}',
      customerName: 'محمد أمين',
      customerPhone: '0555123456',
      shippingWilaya: 'الجزائر العاصمة',
      shippingCity: 'زرالدة',
      shippingAddress: 'حي المستقبل، عمارة 4',
      deliveryType: 'home',
      shippingCost: 450,
      subtotal: 5800,
      discountAmount: 0,
      totalAmount: 6250,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        OrderItem(
          id: 'item-test',
          orderId: 'test',
          productTitle: 'ساعة ذكية Ultra Smart Watch مقاومة للماء',
          unitPrice: 5800,
          quantity: 1,
          totalPrice: 5800,
        ),
      ],
    );

    _latestOrder = mockOrder;
    _isBannerVisible = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
