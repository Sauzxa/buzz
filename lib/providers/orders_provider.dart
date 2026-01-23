import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<dynamic> _activeOrders = [];
  List<dynamic> _archivedOrders = [];
  bool _isLoadingFn = false; // "Fn" for Fetching
  String? _error;

  List<dynamic> get activeOrders => _activeOrders;
  List<dynamic> get archivedOrders => _archivedOrders;
  bool get isLoading => _isLoadingFn;
  String? get error => _error;

  /// Fetch all active orders for a customer
  Future<void> fetchActiveOrders(String customerId) async {
    _isLoadingFn = true;
    _error = null;
    notifyListeners();

    try {
      _activeOrders = await _orderService.getActiveOrders(customerId);
    } catch (e) {
      _error = 'Failed to load active orders: $e';
      print(_error);
    } finally {
      _isLoadingFn = false;
      notifyListeners();
    }
  }

  /// Fetch all archived orders for a customer
  Future<void> fetchArchivedOrders(String customerId) async {
    _isLoadingFn = true;
    _error = null;
    notifyListeners();

    try {
      _archivedOrders = await _orderService.getArchivedOrders(customerId);
    } catch (e) {
      _error = 'Failed to load archived orders: $e';
      print(_error);
    } finally {
      _isLoadingFn = false;
      notifyListeners();
    }
  }

  /// Cancel an order and refresh list
  Future<bool> cancelOrder(String orderId, String customerId) async {
    try {
      await _orderService.cancelOrder(orderId);
      // Refresh active orders
      await fetchActiveOrders(customerId);
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  /// Refresh all data
  Future<void> refreshAll(String customerId) async {
    await Future.wait([
      fetchActiveOrders(customerId),
      fetchArchivedOrders(customerId),
    ]);
  }
}
