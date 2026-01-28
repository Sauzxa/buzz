import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  InvoiceModel? _invoice;
  bool _isLoading = false;
  String? _error;

  InvoiceModel? get invoice => _invoice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInvoiceByOrderId(String orderId) async {
    _isLoading = true;
    _error = null;
    _invoice = null;
    notifyListeners();

    try {
      _invoice = await _invoiceService.getInvoiceByOrderId(orderId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _invoice = null;
      print('⚠️ [INVOICE_PROVIDER] Error fetching invoice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearInvoice() {
    _invoice = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
