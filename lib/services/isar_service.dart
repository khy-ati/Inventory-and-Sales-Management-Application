import 'package:isar/isar.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../services/isar_instance.dart'; 
import 'package:vendor_tracker_application/models/settings_model.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Future<Isar> get _db async => await IsarDatabase.instance.database;

  Future<void> saveProduct(Product product) async {
    try {
      final db = await _db;
      await db.writeTxn(() async {
        await db.products.put(product);
      });
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final db = await _db;
      return await db.products.where().findAll();
    } catch (e) {
      //print('Error getting products: $e');
      return [];
    }
  }

  Future<void> deleteProduct(Id id) async {
    try {
      final db = await _db;
      await db.writeTxn(() async{ 
        await db.products.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> recordSale(Sale sale, Product updatedProduct) async {
    try {
      final db = await _db;
      await db.writeTxn(() async {
        // Validate data before saving
        if (updatedProduct.productId != null) {
          await db.sales.put(sale);
          await db.products.put(updatedProduct);
        } else {
          throw Exception('Invalid product data');
        }
      });
    } catch (e) {
      throw Exception('Failed to record sale: $e');
    }
  }

  Future<List<Sale>> getAllSales() async {
    try {
      final db = await _db;
      return await db.sales.where().sortBySaleDateDesc().findAll();
    } catch (e) {
      //print('Error getting sales: $e');
      return [];
    }
  }

  Future<void> deleteSale(Id id) async {
    try {
      final db = await _db;
      await db.writeTxn(() async {
        await db.sales.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete sale: $e');
    }
  }

  // --- Settings Methods (NEW) ---
  // Retrieves the single settings document.
  Future<Settings?> getSettings() async {
    final db = await _db;
    // We use a fixed ID (0) for the single settings document
    return await db.settings.get(0);
  }

  // Saves (or updates) the single settings document.
  Future<void> saveSettings(Settings settings) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.settings.put(settings);
    });
  }
  
  Future<void> clearAllData() async {
    try {
      final db = await _db;
      await db.writeTxn(() async {
        await db.clear();
      });
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  
}