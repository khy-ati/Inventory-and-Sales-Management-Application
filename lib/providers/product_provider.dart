import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/isar_service.dart';

class ProductProvider with ChangeNotifier {
  final IsarService isarService = IsarService();
  List<Product> _products = [];
  
  List<Product> get products => _products;

  static const int lowStockThreshold = 10;
  
  ProductProvider() {
    loadProducts(); 
    }

  Future<void> loadProducts() async {
    _products = await isarService.getAllProducts();
    notifyListeners();
  }

  Future<void> saveProduct(Product product) async {
    await isarService.saveProduct(product); // Use the IsarService to save
    await loadProducts(); // Reload products to reflect changes in the UI
  }
  

  Future<void> deleteProduct(int id) async {
    await isarService.deleteProduct(id);
    await loadProducts();
  }

   List<Product> getProductsFiltered(String query) {
    if (query.isEmpty) {
      return _products;
    }
    final lowerCaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.productName.toLowerCase().contains(lowerCaseQuery) ||
          product.category.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  


}
