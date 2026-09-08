import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_endpoints.dart';
import '../models/order.dart';

typedef OnOrderReceived = void Function(Order order);
typedef OnConnectionChanged = void Function(bool isConnected);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final List<OnOrderReceived> _orderListeners = [];
  final List<OnConnectionChanged> _connectionListeners = [];

  void addOrderListener(OnOrderReceived listener) {
    if (!_orderListeners.contains(listener)) {
      _orderListeners.add(listener);
    }
  }

  void removeOrderListener(OnOrderReceived listener) {
    _orderListeners.remove(listener);
  }

  void addConnectionListener(OnConnectionChanged listener) {
    if (!_connectionListeners.contains(listener)) {
      _connectionListeners.add(listener);
    }
  }

  void removeConnectionListener(OnConnectionChanged listener) {
    _connectionListeners.remove(listener);
  }

  void initSocket() {
    if (_socket != null && _socket!.connected) return;

    try {
      _socket = IO.io(
        ApiEndpoints.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(999)
            .setReconnectionDelay(3000)
            .build(),
      );

      _socket!.onConnect((_) {
        // ignore: avoid_print
        print('⚡ [SocketService] Connected to real-time server: ${ApiEndpoints.socketUrl}');
        _isConnected = true;
        for (var l in _connectionListeners) {
          l(true);
        }
      });

      _socket!.onDisconnect((_) {
        // ignore: avoid_print
        print('❌ [SocketService] Disconnected from real-time server');
        _isConnected = false;
        for (var l in _connectionListeners) {
          l(false);
        }
      });

      _socket!.onConnectError((err) {
        // ignore: avoid_print
        print('⚠️ [SocketService] Connect error: $err');
      });

      // Listen for incoming order events
      _socket!.on('new_order', (data) {
        _handleIncomingOrder(data);
      });

      _socket!.on('order:created', (data) {
        _handleIncomingOrder(data);
      });
    } catch (e) {
      // ignore: avoid_print
      print('SocketService init error: $e');
    }
  }

  void _handleIncomingOrder(dynamic data) {
    if (data == null) return;
    try {
      Map<String, dynamic> jsonMap;
      if (data is Map<String, dynamic>) {
        jsonMap = data;
      } else if (data is Map) {
        jsonMap = Map<String, dynamic>.from(data);
      } else {
        return;
      }

      // If server wrapped payload in { order: {...}, message: "..." }
      if (jsonMap.containsKey('order') && jsonMap['order'] is Map) {
        jsonMap = Map<String, dynamic>.from(jsonMap['order'] as Map);
      }

      Order order = Order.fromJson(jsonMap);
      for (var listener in _orderListeners) {
        listener(order);
      }
    } catch (e) {
      // ignore: avoid_print
      print('SocketService _handleIncomingOrder error: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
