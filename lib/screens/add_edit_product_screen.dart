import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_tracker_application/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:vendor_tracker_application/providers/product_provider.dart'; // ADDED: Import ProductProvider

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  String _selectedCategory = 'Uncategorized';
  String? _imageUrl;
  final List<String> _categories = [
    'Uncategorized',
    'Clothing',
    'Electronics',
    'Home Goods',
    'Food & Beverage',
    'Books',
    'Beauty',
    'Other',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.product != null) {
      _nameController.text = widget.product!.productName;
      _quantityController.text = widget.product!.quantity.toString();
      _costPriceController.text = widget.product!.costPrice.toStringAsFixed(2);
      _sellingPriceController.text =
          widget.product!.sellingPrice.toStringAsFixed(2);
      _selectedCategory = widget.product!.category;
      _imageUrl = widget.product!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String productName = _nameController.text;
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final double costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    final double sellingPrice =
        double.tryParse(_sellingPriceController.text) ?? 0.0;

    final productToSave = Product(
      productId: widget.product?.productId,
      productName: productName,
      quantity: quantity,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      category: _selectedCategory,
      imageUrl: _imageUrl,
    );

    try {
      await context.read<ProductProvider>().saveProduct(productToSave);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null ? 'Product Added!' : 'Product Updated!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      //print('Error saving product: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) {
      return;
    }

    if (image != null) {
      setState(() {
        _imageUrl = image.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picking cancelled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _imageUrl != null && _imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _imageUrl!.startsWith('assets/')
                                ? Image.asset(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(_imageUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  ),
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Product Name',
                icon: Icons.label,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: _quantityController,
                labelText: 'Quantity',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return 'Please enter a valid positive quantity.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: _costPriceController,
                labelText: 'Cost Price (₹)',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Please enter a valid cost price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: _sellingPriceController,
                labelText: 'Selling Price (₹)',
                icon: Icons.money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Please enter a valid selling price.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isEditing ? 'Update Product' : 'Add Product'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
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
    int? lowStockThreshold,
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
