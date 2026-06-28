import 'package:flutter/material.dart';
import 'package:kiwkiw_mobile_app/checkout.screen.dart'; // Pastikan nama file checkout Anda benar
// MENYAMBUNGKAN KE STORE KERANJANG & WISHLIST
import 'app.store.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String selectedSize = 'L'; // Ukuran default yang terpilih
  bool _isFavorite = false; // Status tombol love di kanan atas
  int _quantity = 1; // Jumlah barang yang mau dimasukkan ke keranjang

  // Data produk dalam bentuk Map, dipakai untuk dikirim ke AppStore
  Map<String, dynamic> get _productData => {
        'name': widget.product['name'],
        'price': widget.product['price'],
        'image': widget.product['image'],
        'size': selectedSize,
        'quantity': _quantity,
      };

  @override
  void initState() {
    super.initState();
    // Cek status awal love sesuai isi wishlist saat ini
    _isFavorite = AppStore.instance.isInWishlist(widget.product['name']!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              // TAMBAH / HAPUS DARI WISHLIST SECARA OTOMATIS
              AppStore.instance.toggleWishlist(_productData);
              setState(() {
                _isFavorite = AppStore.instance.isInWishlist(widget.product['name']!);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk Dinamis
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.product['image']!,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Info Kategori & Nama & Harga Dinamis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pakaian Laki-laki',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product['name']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.product['price']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Bagian Pemilihan Ukuran (Size)
                  const Text(
                    'Ukuran Tersedia',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      final isSelected = selectedSize == size;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade200,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // Pemilih Kuantitas (-/+)
                  const Text(
                    'Kuantitas',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildQtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      _buildQtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Deskripsi Statis Pendukung Estetika
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terbuat dari Bahan Cotton Fleece 100% premium yang tebal namun tetap adem, lembut, dan sangat nyaman digunakan untuk aktivitas sehari-hari.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          // Bar Bagian Bawah: Tombol Keranjang & Beli Sekarang
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TAMBAHKAN PRODUK INI KE KERANJANG SECARA OTOMATIS (SESUAI KUANTITAS YANG DIPILIH)
                      AppStore.instance.addToCart(_productData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil dimasukkan ke keranjang!')),
                      );
                      setState(() => _quantity = 1); // reset kuantitas setelah ditambahkan
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () {
                          // Klik "Beli Sekarang" langsung lempar ke halaman Checkout Anda!
                          // SAMBIL MEMBAWA HARGA PRODUK INI YANG SEBENARNYA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                subTotal: AppStore.parsePrice(widget.product['price']!) * _quantity,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Beli Sekarang',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}