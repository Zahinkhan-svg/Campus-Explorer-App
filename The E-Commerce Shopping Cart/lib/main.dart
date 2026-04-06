import 'package:flutter/material.dart';
import 'dart:core'; // For DateTime


// Abstract Product class
abstract class Product {
  final String name;
  double basePrice;
  int stockQuantity;


  Product({
    required this.name,
    required this.basePrice,
    required this.stockQuantity,
  });


  double calculateFinalPrice(); // Abstract


  void updateStock(int quantity) {
    stockQuantity += quantity;
    if (stockQuantity < 0) stockQuantity = 0;
  }


  @override
  String toString() => '$name (Stock: $stockQuantity)';
}


// ElectronicsProduct
class ElectronicsProduct extends Product {
  final int warrantyYears;


  ElectronicsProduct({
    required super.name,
    required super.basePrice,
    required super.stockQuantity,
    required this.warrantyYears,
  });


  @override
  double calculateFinalPrice() {
    return basePrice + (warrantyYears * 50.0);
  }


  String getWarrantyInfo() => 'Warranty: $warrantyYears years';
}


// ClothingProduct
class ClothingProduct extends Product {
  final String size;
  final String brand;


  ClothingProduct({
    required super.name,
    required super.basePrice,
    required super.stockQuantity,
    required this.size,
    required this.brand,
  });


  @override
  double calculateFinalPrice() {
    double markup = brand.toLowerCase() == 'premium' ? 1.30 : 1.10;
    return basePrice * markup;
  }


  String getSizeInfo() => 'Size: $size, Brand: $brand';
}


// FoodProduct
class FoodProduct extends Product {
  final DateTime expiryDate;
  final bool isOrganic;


  FoodProduct({
    required super.name,
    required super.basePrice,
    required super.stockQuantity,
    required this.expiryDate,
    required this.isOrganic,
  });


  @override
  double calculateFinalPrice() {
    double price = basePrice;
    if (isOrganic) {
      price *= 1.20;
    }
    int daysLeft = checkExpiry();
    if (daysLeft <= 3) {
      price *= 0.85; // 15% discount
    }
    return price;
  }


  int checkExpiry() {
    return expiryDate.difference(DateTime.now()).inDays;
  }


  String getExpiryInfo() => 'Expiry in ${checkExpiry()} days, Organic: $isOrganic';
}


// ShoppingCart
class ShoppingCart {
  List<Map<String, dynamic>> products = []; // List of {product: Product, quantity: int}
  final String customerName;
  double discountPercentage = 0.0;


  ShoppingCart(this.customerName);


  void addProduct(Product product, int quantity) {
    if (product.stockQuantity < quantity) {
      print('Not enough stock for ${product.name}');
      return;
    }
    product.updateStock(-quantity);
    bool found = false;
    for (var item in products) {
      if (item['product'].name == product.name) {
        item['quantity'] += quantity;
        found = true;
        break;
      }
    }
    if (!found) {
      products.add({'product': product, 'quantity': quantity});
    }
    print('Added $quantity x ${product.name} to cart');
  }


  void removeProduct(String productName) {
    products.removeWhere((item) => item['product'].name == productName);
    print('Removed $productName from cart');
  }


  double calculateTotal() {
    double total = 0.0;
    for (var item in products) {
      Product p = item['product'];
      total += p.calculateFinalPrice() * item['quantity'];
    }
    return total * (1 - discountPercentage / 100);
  }


  void applyDiscount(double percentage) {
    discountPercentage = percentage;
    print('Applied $percentage% discount');
  }


  void displayCart() {
    print('\n=== Shopping Cart for $customerName ===');
    for (var item in products) {
      Product p = item['product'];
      print('${item['quantity']} x ${p.name} - Final Price: \$${p.calculateFinalPrice().toStringAsFixed(2)} each');
      if (p is ElectronicsProduct) print('  ${p.getWarrantyInfo()}');
      if (p is ClothingProduct) print('  ${p.getSizeInfo()}');
      if (p is FoodProduct) print('  ${p.getExpiryInfo()}');
    }
    print('Total (after ${discountPercentage.toStringAsFixed(1)}% discount): \$${calculateTotal().toStringAsFixed(2)}');
    print('===============================\n');
  }
}


// Flutter App
void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DemoCartScreen(),
    );
  }
}


class DemoCartScreen extends StatefulWidget {
  @override
  _DemoCartScreenState createState() => _DemoCartScreenState();
}


class _DemoCartScreenState extends State<DemoCartScreen> {
  late ShoppingCart cart;


  @override
  void initState() {
    super.initState();
    cart = ShoppingCart('Test Customer');


    // Demo: Create polymorphic products
    Product electronics1 = ElectronicsProduct(name: 'iPhone', basePrice: 999.0, stockQuantity: 10, warrantyYears: 2);
    Product electronics2 = ElectronicsProduct(name: 'Laptop', basePrice: 1299.0, stockQuantity: 5, warrantyYears: 1);
    Product clothing = ClothingProduct(name: 'T-Shirt', basePrice: 29.99, stockQuantity: 20, size: 'M', brand: 'Premium');
    Product food = FoodProduct(name: 'Apple', basePrice: 1.99, stockQuantity: 100, expiryDate: DateTime.now().add(Duration(days: 2)), isOrganic: true);


    // Add to cart (polymorphism: List<Product>)
    cart.addProduct(electronics1, 1);
    cart.addProduct(electronics2, 1);
    cart.addProduct(clothing, 2);
    cart.addProduct(food, 3);


    cart.displayCart(); // Console output demo


    cart.applyDiscount(10.0);
    cart.displayCart(); // Final bill after discount
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart Demo')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Demo completed in console. Check Flutter console for output.\n'
              'Polymorphism: Different Product types in same cart list.\n'
              'Total bill calculated with discounts.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.products.length,
              itemBuilder: (context, index) {
                var item = cart.products[index];
                Product p = item['product'];
                return ListTile(
                  title: Text('${item['quantity']} x ${p.name}'),
                  subtitle: Text(
                    'Price: \$${p.calculateFinalPrice().toStringAsFixed(2)}\n'
                    '${p is ElectronicsProduct ? (p as ElectronicsProduct).getWarrantyInfo() : ''}'
                    '${p is ClothingProduct ? (p as ClothingProduct).getSizeInfo() : ''}'
                    '${p is FoodProduct ? (p as FoodProduct).getExpiryInfo() : ''}'
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${cart.calculateTotal().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: () {
              cart.removeProduct('iPhone');
              setState(() {});
            },
            child: Icon(Icons.remove_shopping_cart),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'discount',
            onPressed: () {
              cart.applyDiscount(5);
              setState(() {});
            },
            child: Icon(Icons.discount),
          ),
        ],
      ),
    );
  }
}


