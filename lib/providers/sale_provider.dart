import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../services/isar_service.dart';

class SaleProvider with ChangeNotifier {
  final IsarService _isarService = IsarService();

  List<Sale> _sales = [];

  List<Sale> get sales => _sales;

  SaleProvider() {
    loadSales();
  }

  Future<void> loadSales() async {
    _sales = await _isarService.getAllSales();
    notifyListeners();
  }

  Future<void> recordSale(Sale sale, Product updatedProduct) async {
    await _isarService.recordSale(sale, updatedProduct);
    await loadSales();
  }

   Future<void> deleteSale(int id) async {
    await _isarService.deleteSale(id); // Use the IsarService to delete
    await loadSales(); // Reload sales to reflect changes in the UI
  }
  
}
