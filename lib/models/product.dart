import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The three states a product can be in.
enum StockStatus { ok, low, out }

/// One product in the inventory.
class Product {
  final String id;
  final String name;
  final String sku; // also used as the barcode value
  final String category;
  final int qty; // units currently in stock
  final int reorderLevel; // at or below this we warn "low stock"
  final double cost; // cost per unit
  final bool synced; // false = saved on the phone, waiting to upload

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.qty,
    required this.reorderLevel,
    required this.cost,
    required this.synced,
  });

  /// Out of stock, low stock, or fine.
  StockStatus get status {
    if (qty == 0) return StockStatus.out;
    if (qty <= reorderLevel) return StockStatus.low;
    return StockStatus.ok;
  }

  /// Units to buy to get back to double the reorder level.
  int get suggestedOrderQty => math.max(0, reorderLevel * 2 - qty);

  /// Money needed for that suggested purchase.
  double get suggestedOrderCost => suggestedOrderQty * cost;

  /// Icon is picked from the category.
  IconData get icon => iconForCategory(category);

  /// Returns a copy of this product with some fields changed.
  Product copyWith({int? qty, int? reorderLevel, double? cost, bool? synced}) {
    return Product(
      id: id,
      name: name,
      sku: sku,
      category: category,
      qty: qty ?? this.qty,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      cost: cost ?? this.cost,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'category': category,
        'qty': qty,
        'reorderLevel': reorderLevel,
        'cost': cost,
        'synced': synced,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        sku: j['sku'] as String,
        category: j['category'] as String,
        qty: j['qty'] as int,
        reorderLevel: j['reorderLevel'] as int,
        cost: (j['cost'] as num).toDouble(),
        synced: j['synced'] as bool,
      );
}

/// The categories shown in the "add product" form.
const kCategories = ['Beverages', 'Snacks', 'Electronics', 'Stationery', 'Other'];

/// Maps a category name to an icon.
IconData iconForCategory(String category) {
  switch (category) {
    case 'Beverages':
      return Icons.local_drink;
    case 'Snacks':
      return Icons.lunch_dining;
    case 'Electronics':
      return Icons.devices_other;
    case 'Stationery':
      return Icons.menu_book;
    default:
      return Icons.inventory_2;
  }
}

/// Starting data, used only the first time the app opens.
const kSeedProducts = <Product>[
  Product(id: 'p1', name: 'Coca-Cola 500ml', sku: 'BEV-001', category: 'Beverages', qty: 48, reorderLevel: 20, cost: 0.75, synced: true),
  Product(id: 'p2', name: 'Lays Chips 100g', sku: 'SNC-014', category: 'Snacks', qty: 6, reorderLevel: 10, cost: 0.90, synced: true),
  Product(id: 'p3', name: 'Wireless Mouse', sku: 'ELC-220', category: 'Electronics', qty: 0, reorderLevel: 5, cost: 8.50, synced: false),
  Product(id: 'p4', name: 'A4 Notebook', sku: 'STA-088', category: 'Stationery', qty: 120, reorderLevel: 30, cost: 1.20, synced: true),
  Product(id: 'p5', name: 'USB-C Cable', sku: 'ELC-105', category: 'Electronics', qty: 3, reorderLevel: 15, cost: 2.40, synced: false),
  Product(id: 'p6', name: 'Bottled Water 1L', sku: 'BEV-045', category: 'Beverages', qty: 75, reorderLevel: 25, cost: 0.40, synced: true),
];
