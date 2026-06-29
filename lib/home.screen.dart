import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kiwkiw_mobile_app/search.screen.dart';
import 'detail.screen.dart';
import 'cart.screen.dart';
import 'wishlist.screen.dart';
import 'profile.screen.dart';
import 'app.store.dart';

// ==========================================
// KELAS MAIN LAYOUT
// ==========================================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppStore.instance.cartItems,
              builder: (context, items, _) {
                return Badge(
                  label: Text('${items.length}'),
                  backgroundColor: Colors.amber,
                  textColor: Colors.black,
                  isLabelVisible: items.isNotEmpty,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppStore.instance.wishlistItems,
              builder: (context, items, _) {
                return Badge(
                  label: Text('${items.length}'),
                  backgroundColor: Colors.cyan,
                  textColor: Colors.white,
                  isLabelVisible: items.isNotEmpty,
                  child: const Icon(Icons.favorite_border),
                );
              },
            ),
            label: 'Favorite',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// KELAS HOME SCREEN
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ⚠️ PENTING: Ganti dengan IP Address laptop lu!
  final String ipAddress = '192.168.1.34';

  late Future<List<dynamic>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  // --- FUNGSI AMBIL DATA DARI API ---
  Future<List<dynamic>> fetchProducts() async {
    final String apiUrl = 'http://$ipAddress:8000/api/mobile/products';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      // DEBUG: uncomment baris ini kalau mau lihat response API-nya
      // print('=== RESPONSE API ===');
      // print(response.body.substring(0, 500)); // Print 500 karakter pertama

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data')) {
            return decodedData['data'];
          } else if (decodedData.containsKey('products')) {
            return decodedData['products'];
          } else {
            throw Exception('Data dibungkus tapi labelnya ga ketemu');
          }
        } else if (decodedData is List) {
          return decodedData;
        } else {
          throw Exception('Format JSON tidak dikenali');
        }
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // --- FUNGSI BANTU: Build URL gambar dari path Laravel ---
  // Handle 2 kemungkinan format dari API:
  // 1. Path relatif  → "products/foto.jpg"
  // 2. URL lengkap   → "http://192.168.1.34:8000/storage/products/foto.jpg"
  String _buildImageUrl(dynamic imagePath) {
    if (imagePath == null || imagePath.toString().isEmpty) return '';

    final String path = imagePath.toString();

    // Kalau sudah full URL, langsung pakai
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Kalau path relatif, gabungkan dengan base URL storage Laravel
    // Hapus slash di depan kalau ada, biar ga double slash
    final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return 'http://$ipAddress:8000/storage/$cleanPath';
  }

  // --- FUNGSI BANTU: Build widget gambar ---
  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      // Tampilkan loading spinner saat gambar sedang dimuat
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: Colors.grey.shade400,
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // Tampilkan icon error kalau gambar gagal dimuat
      errorBuilder: (context, error, stackTrace) {
        // DEBUG: uncomment baris ini kalau gambar masih error
        // print('=== IMAGE ERROR ===');
        // print('URL: $imageUrl');
        // print('Error: $error');
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> brands = ['OBEY', 'BEN DAVIS', 'LMC.', 'SANTA CRUZ'];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SAPAAN USER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hi, Abel !',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage('https://picsum.photos/100'),
                )
              ],
            ),
            const SizedBox(height: 20),

            // --- BANNER PROMO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFA6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promo Hodie Obey 15%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Beli Sekarang',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://picsum.photos/id/225/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- STRUKTUR BRAND LIST ---
            const Text(
              'Brands',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.redAccent.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        brands[index],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // --- GRID PRODUK DARI DATABASE ---
            FutureBuilder<List<dynamic>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                          color: Colors.black),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.red)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child:
                          Text('Belum ada produk di database.'));
                }

                final products = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // 1. Ambil data teks
                    String namaProduk =
                        product['name'] ?? 'Tanpa Nama';
                    String hargaProduk = product['price'] != null
                        ? 'Rp. ${product['price']}'
                        : 'Rp. 0';
                    String ratingProduk =
                        product['rating']?.toString() ?? '5.0';

                    // 2. LOGIKA GAMBAR - pakai path dari Laravel storage
                    // Coba field 'image', 'image_url', atau 'photo' — sesuaikan
                    // dengan nama field yang ada di response API lu
                    final rawImagePath = product['image'] ??
                        product['image_url'] ??
                        product['photo'] ??
                        '';
                    final String imageUrl =
                        _buildImageUrl(rawImagePath);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              productName: namaProduk,
                              productPrice: hargaProduk,
                              imageUrl: imageUrl, // Kirim URL ke DetailScreen
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(15),
                                child: SizedBox.expand(
                                  child: _buildImageWidget(imageUrl),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            namaProduk,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                hargaProduk,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber,
                                      size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    ratingProduk,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ); // ← closing GridView.builder
              },
            ), // ← closing FutureBuilder
          ],
        ),
      ),
    );
  }
}