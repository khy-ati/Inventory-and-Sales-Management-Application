import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:intl/intl.dart'; 
import 'package:isar/isar.dart'; import 'package:vendor_tracker_application/models/product.dart';
import 'package:vendor_tracker_application/models/sale.dart';
import 'package:vendor_tracker_application/screens/sales_history.dart'; // Import SalesHistoryScreen
import 'package:vendor_tracker_application/providers/product_provider.dart';
import 'package:vendor_tracker_application/providers/sale_provider.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  Product? _selectedProduct;
  double _totalSalePrice = 0.0;
  DateTime _selectedDate = DateTime.now();

  late TabController _tabController; // Re-add TabController

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
    _tabController =
        TabController(length: 2, vsync: this); // Initialize TabController
  }

  void _calculateTotal() {
    if (_selectedProduct != null) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalSalePrice = quantity * _selectedProduct!.sellingPrice;
      });
    } else {
      setState(() {
        _totalSalePrice = 0.0;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;
    final BuildContext currentContext = context;
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: currentContext,
        initialTime: TimeOfDay.now(),
      );

      if (!currentContext.mounted) return;

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _recordSale() async {
    if (!mounted) return; 
    final BuildContext currentContext = context;
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Please select a product and fill quantity.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);

    if (quantity > _selectedProduct!.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Only ${_selectedProduct!.quantity} in stock for ${_selectedProduct!.productName}.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final newSale = Sale(
        saleId: null,
        productId: _selectedProduct!.productId!,
        productName: _selectedProduct!.productName,
        quantitySold: quantity,
        totalSalePrice: _totalSalePrice,
        saleDate: _selectedDate,
        imageUrl: _selectedProduct!.imageUrl,
      );

      final updatedProduct = _selectedProduct!.copyWith(
        quantity: _selectedProduct!.quantity - quantity,
      );

      final saleProvider = context.read<SaleProvider>();
      final productProvider = context.read<ProductProvider>();

      await saleProvider.recordSale(newSale, updatedProduct);
      await productProvider.loadProducts(); // Ensure products list is refreshed

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale Recorded!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedProduct = null;
        _quantityController.clear();
        _totalSalePrice = 0.0;
        _selectedDate = DateTime.now();
      });

      // Optionally switch to the History tab after recording a sale
      // _tabController.animateTo(1);
    } catch (e) {
      //print('Error recording sale: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording sale: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final availableProducts = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales"), // General title for the Sales section
        bottom: TabBar(
          // Re-add TabBar
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: "Record Sale"),
            Tab(icon: Icon(Icons.history), text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        // Re-add TabBarView
        controller: _tabController,
        children: [
          _buildRecordSaleForm(
              availableProducts), // First tab: Record Sale Form
          const SalesHistoryScreen(), // Second tab: Sales History Screen (now a StatelessWidget)
        ],
      ),
    );
  }

  Widget _buildRecordSaleForm(List<Product> availableProducts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              items: availableProducts.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child:
                      Text('${product.productName} (Qty: ${product.quantity})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                  _calculateTotal();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null ? 'Select a product' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final val = int.tryParse(value ?? '');
                if (val == null || val <= 0) return 'Enter valid quantity';
                if (_selectedProduct != null &&
                    val > _selectedProduct!.quantity) {
                  return 'Not enough stock. Only ${_selectedProduct!.quantity} available.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ₹${_totalSalePrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Sale Date & Time'),
              subtitle: Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _recordSale,
              icon: const Icon(Icons.save),
              label: const Text('Record Sale'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.removeListener(_calculateTotal);
    _quantityController.dispose();
    _tabController.dispose(); 
    super.dispose();
  }
}

extension ProductCopyWith on Product {
  Product copyWith({
    Id? productId,
    String? productName,
    int? quantity,
    double? costPrice,
    double? sellingPrice,
    String? category,
    String? imageUrl,
     
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
