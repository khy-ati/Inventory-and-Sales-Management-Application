import 'package:isar/isar.dart';
part 'settings_model.g.dart';

@collection
class Settings {
   Id id = 0; 
    bool isDarkMode = false; 
    int lowStockThreshold = 10;

  Settings({
    this.id = 0, 
    this.isDarkMode = false,
    this.lowStockThreshold = 10,
  });

  Settings copyWith({
    bool? isDarkMode,
    int? lowStockThreshold,
  }) {
    return Settings(
      id: id, 
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}
