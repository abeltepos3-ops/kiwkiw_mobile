import 'package:flutter/material.dart';
import 'app.store.dart';
import 'checkout.screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  int _calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (final item in items) {
      final price = AppStore.parsePrice(item['price'].toString());
      final qty = (item['quantity'] as int?) ?? 1;
      total += price * qty;
    }
    return total;
  }

  int _calculateTotalQty(List<Map<String, dynamic>> items) {
    int total = 0;
    for (final item in items) {
      total += (item['quantity'] as int?) ?? 1;
    }
    return total;
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      result = s[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              children: [
                Text(
                  'Keranjang',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // LIST ITEM KERANJANG (otomatis update saat ada produk masuk/keluar/berubah jumlah)
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppStore.instance.cartItems,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'Keranjang kamu masih kosong',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final String? size = item['size'] as String?;
                    final int qty = (item['quantity'] as int?) ?? 1;
                    final int unitPrice = AppStore.parsePrice(item['price'].toString());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item['image'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => AppStore.instance.removeFromCart(item['name'], size),
                                      child: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
                                    ),
                                  ],
                                ),
                                if (size != null && size.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text('Ukuran: $size', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  item['price'],
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ===== TOMBOL KUANTITAS (-/+) =====
                                    Row(
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          onTap: () => AppStore.instance.updateCartQuantity(item['name'], size, qty - 1),
                                        ),
                                        Container(
                                          width: 32,
                                          alignment: Alignment.center,
                                          child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          onTap: () => AppStore.instance.updateCartQuantity(item['name'], size, qty + 1),
                                        ),
                                      ],
                                    ),
                                    // SUBTOTAL PER ITEM (harga satuan x kuantitas)
                                    Text(
                                      'Rp ${_formatRupiah(unitPrice * qty)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
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

          // RINGKASAN TOTAL + TOMBOL CHECKOUT (tanpa kode promo)
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: AppStore.instance.cartItems,
            builder: (context, items, _) {
              if (items.isEmpty) return const SizedBox.shrink();
              final total = _calculateTotal(items);
              final totalQty = _calculateTotalQty(items);
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalQty barang',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        Text(
                          'Rp. ${_formatRupiah(total)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // KLIK CHECKOUT -> LANGSUNG KE HALAMAN CHECKOUT
                          // SAMBIL MEMBAWA TOTAL HARGA YANG SESUAI ISI KERANJANG (SUDAH IKUT KUANTITAS)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(subTotal: total),
                            ),
                          );
                        },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 14, color: Colors.black),
      ),
    );
  }
}