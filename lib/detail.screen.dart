import 'package:flutter/material.dart';
// MENYAMBUNGKAN KE HALAMAN CHECKOUT YANG BARU
import 'checkout.screen.dart';
// MENYAMBUNGKAN KE STORE KERANJANG & WISHLIST
import 'app.store.dart';

class DetailScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String imageUrl;

  const DetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.imageUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Daftar ukuran lengkap (S dan M permintaanmu + L dan XL bawaan desain)
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];
  String _selectedSize = 'L'; // Default pilihan langsung aktif di ukuran L
  bool _isFavorite = false; // Status tombol love di kanan atas
  int _quantity = 1; // Jumlah barang yang mau dimasukkan ke keranjang

  // Data produk dalam bentuk Map, dipakai untuk dikirim ke AppStore
  Map<String, dynamic> get _productData => {
        'name': widget.productName,
        'price': widget.productPrice,
        'image': widget.imageUrl,
        'size': _selectedSize,
        'quantity': _quantity,
      };

  @override
  void initState() {
    super.initState();
    // Cek status awal love sesuai isi wishlist saat ini
    _isFavorite = AppStore.instance.isInWishlist(widget.productName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
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
                _isFavorite = AppStore.instance.isInWishlist(widget.productName);
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // KONTEN UTAMA DENGAN SCROLL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. GAMBAR BESAR PRODUK
                  Center(
                    child: Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. KATEGORI, NAMA PRODUK & HARGA
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
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.productName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.productPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 3. PILIHAN UKURAN TERSEDIA (S, M, L, XL)
                  const Text(
                    'Ukuran Tersedia',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // 3b. PEMILIH KUANTITAS (-/+)
                  const Text(
                    'Kuantitas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
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

                  // 4. DESKRIPSI PRODUK
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terbuat Dari Bahan Cotton Fleece 100% dan bahan adem saat digunakan.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 5. BOTTOM ACTION BAR (Keranjang & Beli Sekarang)
          Container(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30, top: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Tombol Icon Keranjang Kecil
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    onPressed: () {
                      // TAMBAHKAN PRODUK INI KE KERANJANG SECARA OTOMATIS (SESUAI KUANTITAS YANG DIPILIH)
                      AppStore.instance.addToCart(_productData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil dimasukkan ke keranjang!')),
                      );
                      setState(() => _quantity = 1); // reset kuantitas setelah ditambahkan
                    },
                  ),
                ),
                const SizedBox(width: 15),
                
                // TOMBOL BELI SEKARANG (SUDAH TERINTEGRASI KE CHECKOUT)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // PINDAH LANGSUNG KE HALAMAN CHECKOUT
                        // SAMBIL MEMBAWA HARGA PRODUK INI YANG SEBENARNYA
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              subTotal: AppStore.parsePrice(widget.productPrice) * _quantity,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Beli Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}