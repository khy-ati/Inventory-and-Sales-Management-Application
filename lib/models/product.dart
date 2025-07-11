import 'package:isar/isar.dart';
part 'product.g.dart';

@collection
class Product {
  
  Id? productId=Isar.autoIncrement;
  late String productName;
  late int quantity;
  late double costPrice;
  late double sellingPrice;
  String category = 'Uncategorized';
  String? imageUrl; 
  
  double get profitPerItem => sellingPrice - costPrice;
   
  
  Product({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    this.category = 'Uncategorized',
    this.imageUrl,
    
  });
}
