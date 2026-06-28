import 'package:flutter/foundation.dart';

/// Penyimpanan data Keranjang & Wishlist secara global (in-memory),
/// supaya semua halaman (Detail, Pencarian, Keranjang, Wishlist)
/// bisa baca & ubah data yang sama tanpa perlu tambahan package.
class AppStore {
  AppStore._internal();
  static final AppStore instance = AppStore._internal();

  final ValueNotifier<List<Map<String, dynamic>>> cartItems =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<List<Map<String, dynamic>>> wishlistItems =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // --- DATA PROFIL CUSTOMER ---
  // Disimpan di sini (bukan di State halaman) supaya nama & foto tetap
  // tersimpan walaupun customer pindah-pindah tab.
  final ValueNotifier<String> userName = ValueNotifier<String>('Abel Nayaka');
  final ValueNotifier<String?> userPhotoPath = ValueNotifier<String?>(null);

  // --- RIWAYAT PESANAN ---
  // Terisi otomatis setiap kali customer berhasil menyelesaikan Checkout.
  final ValueNotifier<List<Map<String, dynamic>>> orderHistory =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  void addOrder(Map<String, dynamic> order) {
    orderHistory.value = [order, ...orderHistory.value];
  }

  // --- ALAMAT PENGIRIMAN TERSIMPAN ---
  final ValueNotifier<List<Map<String, dynamic>>> addresses =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  void addAddress(Map<String, dynamic> address) {
    addresses.value = [...addresses.value, address];
  }

  void updateAddress(int index, Map<String, dynamic> address) {
    final list = [...addresses.value];
    if (index >= 0 && index < list.length) {
      list[index] = address;
      addresses.value = list;
    }
  }

  void removeAddress(int index) {
    final list = [...addresses.value];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      addresses.value = list;
    }
  }

  // --- PENGATURAN ---
  final ValueNotifier<bool> notificationsEnabled = ValueNotifier<bool>(true);

  bool isInCart(String name) {
    return cartItems.value.any((item) => item['name'] == name);
  }

  bool isInWishlist(String name) {
    return wishlistItems.value.any((item) => item['name'] == name);
  }

  /// Menambahkan produk ke keranjang. Kalau produk dengan nama & ukuran yang
  /// sama sudah ada, jumlahnya (quantity) akan ditambahkan, bukan dianggap
  /// barang baru. Ini yang membuat 1 produk bisa dibeli lebih dari 1 buah.
  void addToCart(Map<String, dynamic> product) {
    final name = product['name'];
    final size = product['size'];
    final qtyToAdd = (product['quantity'] as int?) ?? 1;

    final existingIndex = cartItems.value.indexWhere(
      (item) => item['name'] == name && item['size'] == size,
    );

    if (existingIndex != -1) {
      final updated = [...cartItems.value];
      final currentQty = (updated[existingIndex]['quantity'] as int?) ?? 1;
      updated[existingIndex] = {
        ...updated[existingIndex],
        'quantity': currentQty + qtyToAdd,
      };
      cartItems.value = updated;
    } else {
      cartItems.value = [
        ...cartItems.value,
        {...product, 'quantity': qtyToAdd},
      ];
    }
  }

  /// Hapus item dari keranjang. Kalau [size] diisi, hanya item dengan
  /// nama + ukuran itu yang dihapus (lebih presisi kalau ada 2 ukuran
  /// dari produk yang sama di keranjang).
  void removeFromCart(String name, [String? size]) {
    cartItems.value = cartItems.value
        .where((item) => !(item['name'] == name && (size == null || item['size'] == size)))
        .toList();
  }

  /// Mengubah jumlah (quantity) item yang sudah ada di keranjang, dipakai
  /// untuk tombol +/- langsung di halaman Keranjang. Kalau hasilnya 0 atau
  /// kurang, item otomatis dihapus.
  void updateCartQuantity(String name, String? size, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(name, size);
      return;
    }
    final list = [...cartItems.value];
    final index = list.indexWhere((item) => item['name'] == name && item['size'] == size);
    if (index != -1) {
      list[index] = {...list[index], 'quantity': newQuantity};
      cartItems.value = list;
    }
  }

  /// Menambah/menghapus produk dari wishlist (tombol love).
  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      wishlistItems.value = wishlistItems.value
          .where((item) => item['name'] != product['name'])
          .toList();
    } else {
      wishlistItems.value = [...wishlistItems.value, product];
    }
  }

  void removeFromWishlist(String name) {
    wishlistItems.value =
        wishlistItems.value.where((item) => item['name'] != name).toList();
  }

  /// Helper untuk mengubah teks harga seperti "Rp. 300.000" atau "Rp 450.000"
  /// menjadi angka bersih (300000), supaya konsisten dipakai di semua halaman
  /// dan tidak ada lagi ketidaksinkronan harga saat masuk ke Checkout.
  static int parsePrice(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }
}