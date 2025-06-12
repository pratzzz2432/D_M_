import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:d_m/services/translation_service.dart';

class UserMarketplacePage extends StatefulWidget {
  const UserMarketplacePage({super.key});

  @override
  State<UserMarketplacePage> createState() => _UserMarketplacePageState();
}

class _UserMarketplacePageState extends State<UserMarketplacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'government_marketplace_items';

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Water & Food',
    'Medical',
    'Electronics',
    'Shelter',
    'Tools',
    'Clothing',
    'Communication'
  ];

  Map<String, Map<String, dynamic>> _cart = {};
  bool _isLoading = false;

  void _addToCart(String itemId, Map<String, dynamic> item) {
    setState(() {
      if (_cart.containsKey(itemId)) {
        _cart[itemId]!['cartQuantity'] =
            (_cart[itemId]!['cartQuantity'] as int) + 1;
      } else {
        _cart[itemId] = {
          ...item,
          'cartQuantity': 1,
          'itemId': itemId,
        };
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TranslatableText('${item['name']} added to cart'),
        backgroundColor: const Color(0xFF5F6898),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(String itemId) {
    setState(() {
      if (_cart.containsKey(itemId)) {
        if (_cart[itemId]!['cartQuantity'] > 1) {
          _cart[itemId]!['cartQuantity'] =
              (_cart[itemId]!['cartQuantity'] as int) - 1;
        } else {
          _cart.remove(itemId);
        }
      }
    });
  }

  double _getTotalAmount() {
    double total = 0;
    _cart.forEach((key, item) {
      double price = (item['price'] is int)
          ? (item['price'] as int).toDouble()
          : (item['price'] as double? ?? 0.0);
      total += price * (item['cartQuantity'] as int);
    });
    return total;
  }

  int _getTotalCartItems() {
    int total = 0;
    _cart.forEach((key, item) {
      total += item['cartQuantity'] as int;
    });
    return total;
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TranslatableText(
                        'Your Cart',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (_cart.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 64, color: Color(0xFF5F6898)),
                            SizedBox(height: 16),
                            TranslatableText(
                              'Your cart is empty',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final itemId = _cart.keys.elementAt(index);
                          final item = _cart[itemId]!;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF5F6898),
                                child: Text(
                                  (item['name'] ?? 'N')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: TranslatableText(
                                  item['name'] ?? 'Unknown Item'),
                              subtitle: TranslatableText(
                                  '₹${_getPriceAsString(item['price'] ?? 0)} each'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _removeFromCart(itemId);
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                  ),
                                  TranslatableText('${item['cartQuantity']}'),
                                  IconButton(
                                    onPressed: () {
                                      _addToCart(itemId, item);
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add_circle,
                                        color: Color(0xFF5F6898)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_cart.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TranslatableText(
                            'Total Amount:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TranslatableText(
                            '₹${_getTotalAmount().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5F6898)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F6898),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const TranslatableText(
                          'Proceed to Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _proceedToCheckout() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatableText('Order Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TranslatableText('Your order has been placed successfully!'),
            const SizedBox(height: 10),
            TranslatableText('Total Items: ${_getTotalCartItems()}'),
            TranslatableText(
                'Total Amount: ₹${_getTotalAmount().toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            const TranslatableText(
              'You will receive a confirmation message shortly.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cart.clear();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatableText("Government Marketplace"),
        backgroundColor: const Color(0xFF5F6898),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _showCart,
                icon: const Icon(Icons.shopping_cart),
              ),
              if (_getTotalCartItems() > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_getTotalCartItems()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: TranslatableText(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF5F6898),
                    checkmarkColor: Colors.white, // Changed checkmark color for better visibility
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == 'All'
                  ? _firestore.collection(_collectionName).snapshots()
                  : _firestore
                  .collection(_collectionName)
                  .where('category', isEqualTo: _selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        TranslatableText('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        TranslatableText(
                          'No items available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        TranslatableText(
                          'Check back later for new items',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!.docs;

                final availableItems = items.where((doc) {
                  final item = doc.data() as Map<String, dynamic>;
                  return (item['quantity'] ?? 0) > 0;
                }).toList();

                if (availableItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        TranslatableText(
                          'No items available in stock',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        TranslatableText(
                          'Check back later for new items',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    // Adjusted childAspectRatio to be more accommodating for taller cards
                    // A smaller ratio means the item is taller relative to its width.
                    childAspectRatio: 0.65, // Adjust this value as needed
                  ),
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final doc = availableItems[index];
                    final item = doc.data() as Map<String, dynamic>;
                    final itemId = doc.id;

                    return Card(
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Image Placeholder
                          // Using Expanded here to allow the image placeholder to fill available space
                          // within its flex constraints. This will help if images were real.
                          Expanded(
                            flex: 3, // Give more flex to the image placeholder
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(
                                _getCategoryIcon(item['category']),
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          // Item Details
                          Expanded(
                            flex: 5, // Give more flex to the text details
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                                children: [
                                  TranslatableText(
                                    item['name'] ?? 'Unknown Item',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  TranslatableText(
                                    '₹${_getPriceAsString(item['price'] ?? 0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5F6898),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TranslatableText(
                                    'Stock: ${item['quantity'] ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if ((item['description'] ?? '').isNotEmpty &&
                                      item['description'] !=
                                          'No description available') ...[
                                    const SizedBox(height: 4),
                                    TranslatableText(
                                      item['description'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const Spacer(), // Pushes the button to the bottom
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: (item['quantity'] ?? 0) > 0
                                          ? () => _addToCart(itemId, item)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF5F6898),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                      child: TranslatableText(
                                        (item['quantity'] ?? 0) > 0
                                            ? 'Add to Cart'
                                            : 'Out of Stock',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPriceAsString(dynamic price) {
    if (price is int) {
      return price.toString();
    } else if (price is double) {
      return price.toStringAsFixed(2);
    }
    return '0';
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Water & Food':
        return Icons.restaurant;
      case 'Medical':
        return Icons.medical_services;
      case 'Electronics':
        return Icons.electrical_services;
      case 'Shelter':
        return Icons.home;
      case 'Tools':
        return Icons.build;
      case 'Clothing':
        return Icons.checkroom;
      case 'Communication':
        return Icons.phone;
      default:
        return Icons.shopping_bag;
    }
  }
}