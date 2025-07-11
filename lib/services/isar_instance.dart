import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/settings_model.dart';


class IsarDatabase {
  static IsarDatabase? _instance;
  static Isar? _isar;

  IsarDatabase._();

  static IsarDatabase get instance {
    _instance ??= IsarDatabase._();
    return _instance!;
  }

  Future<Isar> get database async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [ProductSchema, SaleSchema,SettingsSchema], 
        directory: dir.path,
        inspector: true,
      );
      return _isar!;
    } catch (e) {
      throw Exception('Failed to initialize Isar: $e');
    }
  }

  Future<void> closeDatabase() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
