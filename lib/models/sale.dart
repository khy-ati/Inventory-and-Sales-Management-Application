import 'package:isar/isar.dart';
part 'sale.g.dart';

@collection
class Sale {
  
  Id? saleId = Isar.autoIncrement;
  late int productId;
  late String productName;
  late int quantitySold;
  late double totalSalePrice;
  @Index()
  late DateTime saleDate;
  String? imageUrl;

  Sale({
    this.saleId,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalSalePrice,
    required this.saleDate,
    this.imageUrl,
  });
  
  double calculateProfit(double costPrice) {
    return totalSalePrice - (costPrice * quantitySold);
  }
}
