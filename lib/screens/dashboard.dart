import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vendor_tracker_application/models/product.dart';
import 'package:vendor_tracker_application/models/sale.dart';
import 'package:vendor_tracker_application/screens/inventory_list.dart';
import 'package:vendor_tracker_application/screens/add_sale.dart';
import 'package:vendor_tracker_application/screens/sales_history.dart'; 
import 'package:vendor_tracker_application/screens/settings_screen.dart'; 
import 'package:vendor_tracker_application/providers/product_provider.dart';
import 'package:vendor_tracker_application/providers/sale_provider.dart';
import 'package:vendor_tracker_application/providers/settings_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final productProvider = context.watch<ProductProvider>();
    final saleProvider = context.watch<SaleProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final List<Product> allProducts = productProvider.products;
    final List<Sale> allSales = saleProvider.sales;
    final int lowStockThreshold = settingsProvider.settings.lowStockThreshold;

    final double totalInventoryValue = allProducts.fold(
      0.0,
      (sum, product) => sum + (product.sellingPrice * product.quantity),
    );

    final double totalSalesRevenue = allSales.fold(
      0.0,
      (sum, sale) => sum + sale.totalSalePrice,
    );

    double totalProfit = 0.0;
    for (final sale in allSales) {
      final product = allProducts.firstWhere(
        (p) => p.productId == sale.productId,
        orElse: () => Product(
          productName: 'Unknown Product',
          quantity: 0,
          costPrice: 0.0,
          sellingPrice: 0.0,
          category: 'Unknown',
        ),
      );
      totalProfit += sale.calculateProfit(product.costPrice);
    }

    final int lowStockItemsCount = allProducts
        .where(
          (product) => product.quantity <= lowStockThreshold,
        )
        .length;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      // FIX: Wrap with SingleChildScrollView to prevent overflow
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.2,
            children: [
              _buildSummaryCard(
                icon: Icons.inventory_2,
                title: 'Inventory Value',
                value: currencyFormatter.format(totalInventoryValue),
                color: Colors.blue.shade100,
                iconColor: Colors.blue.shade700,
              ),
              _buildSummaryCard(
                icon: Icons.attach_money,
                title: 'Total Revenue',
                value: currencyFormatter.format(totalSalesRevenue),
                color: Colors.green.shade100,
                iconColor: Colors.green.shade700,
              ),
              _buildSummaryCard(
                icon: Icons.money_off,
                title: 'Total Profit',
                value: currencyFormatter.format(totalProfit),
                color: Colors.purple.shade100,
                iconColor: Colors.purple.shade700,
              ),
              _buildSummaryCard(
                icon: Icons.warning_amber,
                title: 'Low Stock Items',
                value: '$lowStockItemsCount Items',
                color: Colors.orange.shade100,
                iconColor: Colors.orange.shade700,
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.add_shopping_cart,
                label: 'Record New Sale',
                onTap: () {
                  // Navigate to AddSaleScreen
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                        builder: (context) => const AddSaleScreen()),
                  )
                      .then((_) {
                    // Optional: If you want to refresh dashboard data when returning from AddSaleScreen
                    // context.read<ProductProvider>().loadProducts();
                    // context.read<SaleProvider>().loadSales();
                  });
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.receipt_long,
                label: 'View Sales History',
                onTap: () {
                  // Navigate to SalesHistoryScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SalesHistoryScreen()),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.inventory,
                label: 'Manage Inventory',
                onTap: () {
                  // Navigate to InventoryListScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const InventoryListScreen()),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.bar_chart,
                label: 'View Reports',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Analytics Screen (Coming Soon)!')));
                  // setState(() {
                  //   _selectedIndex = 3;
                  // });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _buildDashboardContent(),
      const InventoryListScreen(),
      const AddSaleScreen(),
      const Center(child: Text('Analytics Screen (Coming Soon)')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory and Sales Manager'),
        centerTitle: true,
        actions: [
           IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ]
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
