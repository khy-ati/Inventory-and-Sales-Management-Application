import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vendor_tracker_application/models/product.dart'; // Needed to get product details for profit
import 'package:vendor_tracker_application/providers/sale_provider.dart';
import 'package:vendor_tracker_application/providers/product_provider.dart'; // Import ProductProvider

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final productProvider = context.watch<ProductProvider>();

    final sales = saleProvider.sales;
    final products = productProvider.products;
    //final int lowStockThreshold = ProductProvider.lowStockThreshold;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    Widget content;
    if (sales.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No sales recorded yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              'Start by recording a new sale.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sales.length,
        itemBuilder: (ctx, index) {
          final sale = sales[index];
          final associatedProduct = products.firstWhere(
            (p) => p.productId == sale.productId,
            orElse: () => Product(
              productName: 'Unknown Product',
              quantity: 0,
              costPrice: 0.0,
              sellingPrice: 0.0,
              category: 'Unknown',
            ),
          );

          final profit = sale.calculateProfit(associatedProduct.costPrice);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Product: ${sale.productName}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete this sale record?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          
                           if (!mounted) return;
                          final BuildContext currentContext = context;

                          if (confirm == true) {
                            try {
                              await saleProvider.deleteSale(sale.saleId!);
                              if (!currentContext.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sale deleted successfully!'),
                                    backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              if (!currentContext.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to delete sale: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Quantity Sold: ${sale.quantitySold}'),
                  Text(
                      'Total Revenue: ${currencyFormatter.format(sale.totalSalePrice)}'),
                  Text(
                    'Profit: ${currencyFormatter.format(profit)}',
                    style: TextStyle(
                      color: profit >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      'Date: ${DateFormat.yMMMd().add_jm().format(sale.saleDate)}'),
                  if (sale.imageUrl != null && sale.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset(
                        sale.imageUrl!,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        // Use theme primary color from main.dart
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: content,
    );
  }
}
