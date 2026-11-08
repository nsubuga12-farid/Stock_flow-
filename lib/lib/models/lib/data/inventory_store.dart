import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movement.dart';
import '../models/product.dart';

/// The single source of truth for all stock data.
/// Whenever data changes we call notifyListeners() and every screen
/// that is watching rebuilds by itself.
/// Data is saved on the phone, so it works with no internet.
class InventoryStore extends ChangeNotifier {
  static const _productsKey = 'products_v1';
  static const _movesKey = 'moves_v1';

  List<Product> _products = List.of(kSeedProducts);
  List<Movement> _moves = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Movement> get moves => List.unmodifiable(_moves);

  int get lowOrOutCount => _products.where((p) => p.status != StockStatus.ok).length;
  int get pendingCount => _products.where((p) => !p.synced).length;
  int get todayMoves => _moves.where((m) => m.isToday).length;

  /// Called once in main() before the app starts.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final rawProducts = prefs.getString(_productsKey);
    if (rawProducts != null) {
      final list = jsonDecode(rawProducts) as List;
      _products = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }

    final rawMoves = prefs.getString(_movesKey);
    if (rawMoves != null) {
      final list = jsonDecode(rawMoves) as List;
      _moves = list.map((e) => Movement.fromJson(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(_products.map((p) => p.toJson()).toList()));
    await prefs.setString(_movesKey, jsonEncode(_moves.map((m) => m.toJson()).toList()));
  }

  /// Finds a product by scanned barcode / SKU (ignores capital letters).
  Product? findByCode(String code) {
    final c = code.trim().toLowerCase();
    for (final p in _products) {
      if (p.sku.toLowerCase() == c) return p;
    }
    return null;
  }

  /// Sets a product's quantity (used by the scan sheet).
  Future<void> setQuantity(String id, int newQty) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) return;
    final old = _products[i];
    final delta = newQty - old.qty;
    if (delta == 0) return;

    _products[i] = old.copyWith(qty: newQty, synced: false);
    _addMove(old.name, delta);
    notifyListeners();
    await _save();
    _scheduleSync();
  }

  /// Adds units after a purchase arrives (Reorder button).
  Future<void> receiveStock(String id, int units) async {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) return;
    await setQuantity(id, _products[i].qty + units);
  }

  /// Adds a brand-new product.
  Future<void> addProduct(Product p) async {
    _products.add(p.copyWith(synced: false));
    if (p.qty != 0) _addMove(p.name, p.qty);
    notifyListeners();
    await _save();
    _scheduleSync();
  }

  void _addMove(String name, int delta) {
    _moves.insert(0, Movement(productName: name, delta: delta, time: DateTime.now()));
    if (_moves.length > 50) _moves = _moves.sublist(0, 50);
  }

  void _scheduleSync() {
    Future.delayed(const Duration(seconds: 2), syncPending);
  }

  /// Marks every pending product as synced.
  /// TODO: PLACEHOLDER. Replace with real uploads to your backend.
  Future<void> syncPending() async {
    if (pendingCount == 0) return;
    await Future.delayed(const Duration(milliseconds: 400));
    _products = _products.map((p) => p.synced ? p : p.copyWith(synced: true)).toList();
    notifyListeners();
    await _save();
  }
}
