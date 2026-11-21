import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';
import '../../services/firebase_service.dart';

class ProductService {
  static final ProductService instance = ProductService._internal();
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Danh sách mẫu 6 chiếc xe đạp y hệt trang 11 của giáo trình
  final List<Product> _mockProducts = [
    Product(
      id: 'mock_1',
      name: 'Instinct',
      price: 6999.99,
      imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Product(
      id: 'mock_2',
      name: 'Stumpjumper',
      price: 3178.99,
      imageUrl: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Product(
      id: 'mock_3',
      name: 'Trek Fuel',
      price: 4999.99,
      imageUrl: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Product(
      id: 'mock_4',
      name: 'Devinci Troy',
      price: 5599.00,
      imageUrl: 'https://images.unsplash.com/photo-1511994298241-608e28f14fde?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: 'mock_5',
      name: 'Slayer',
      price: 4699.99,
      imageUrl: 'https://images.unsplash.com/photo-1572111504021-46a782b9a712?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Product(
      id: 'mock_6',
      name: 'Trek Slash 8',
      price: 6999.99,
      imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final StreamController<List<Product>> _mockStreamController =
      StreamController<List<Product>>.broadcast();

  Stream<List<Product>> getProductsStream() {
    if (FirebaseService.instance.useMockMode) {
      // Bắn ngay danh sách mock
      Future.microtask(() => _mockStreamController.add(List.from(_mockProducts)));
      return _mockStreamController.stream;
    }

    try {
      return _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          // Nếu Firestore trống, có thể dùng mock
          return _mockProducts;
        }
        return snapshot.docs.map((doc) {
          return Product.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      Future.microtask(() => _mockStreamController.add(List.from(_mockProducts)));
      return _mockStreamController.stream;
    }
  }

  /// Thêm sản phẩm mới (Tải ảnh lên Firebase Storage & lưu dữ liệu vào Firestore)
  Future<void> addProduct({
    required String name,
    required double price,
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    String imageUrl =
        'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80';

    if (!FirebaseService.instance.useMockMode &&
        (imageBytes != null || imagePath != null)) {
      try {
        final refName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _storage.ref().child(refName);

        if (kIsWeb || imageBytes != null) {
          await storageRef.putData(imageBytes!);
        } else {
          await storageRef.putFile(File(imagePath!));
        }
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        if (kDebugMode) print('Lỗi upload ảnh lên Storage: $e');
      }
    }

    if (FirebaseService.instance.useMockMode) {
      final newProd = Product(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        price: price,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      _mockProducts.insert(0, newProd);
      _mockStreamController.add(List.from(_mockProducts));
      return;
    }

    try {
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fallback nếu Firestore rules chặn
      final newProd = Product(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        price: price,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      _mockProducts.insert(0, newProd);
      _mockStreamController.add(List.from(_mockProducts));
    }
  }

  /// Xóa sản phẩm (Trang 11: Thêm chức năng xóa sản phẩm)
  Future<void> deleteProduct(Product product) async {
    if (FirebaseService.instance.useMockMode) {
      _mockProducts.removeWhere((p) => p.id == product.id);
      _mockStreamController.add(List.from(_mockProducts));
      return;
    }

    try {
      await _firestore.collection('products').doc(product.id).delete();
      // Xóa ảnh trên storage nếu là ảnh lưu trên Firebase Storage
      if (product.imageUrl.contains('firebasestorage.googleapis.com')) {
        try {
          await _storage.refFromURL(product.imageUrl).delete();
        } catch (_) {}
      }
    } catch (e) {
      _mockProducts.removeWhere((p) => p.id == product.id);
      _mockStreamController.add(List.from(_mockProducts));
    }
  }
}
