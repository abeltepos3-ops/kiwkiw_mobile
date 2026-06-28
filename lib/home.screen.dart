import 'package:flutter/material.dart';
import 'package:kiwkiw_mobile_app/search.screen.dart';
// MENYAMBUNGKAN KE FILE DETAIL SCREEN YANG BARU
import 'detail.screen.dart';
// HALAMAN KERANJANG & WISHLIST YANG SUDAH NYATA (BUKAN PLACEHOLDER LAGI)
import 'cart.screen.dart';
import 'wishlist.screen.dart';
// HALAMAN PROFIL CUSTOMER YANG SUDAH NYATA (BUKAN PLACEHOLDER LAGI)
import 'profile.screen.dart';
// STORE UNTUK BADGE JUMLAH ITEM DI BOTTOM NAV
import 'app.store.dart';

// Wrapper untuk mengatur Bottom Navigation Bar
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
            // Angka di badge sekarang otomatis ikut jumlah barang di Keranjang
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
            // Angka di badge sekarang otomatis ikut jumlah barang di Wishlist
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
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> brands = ['OBEY', 'BEN DAVIS', 'LMC.', 'SANTA CRUZ'];

    // DATA PRODUK YANG AKAN DIKIRIM KE DETAIL SCREEN SAAT DIKLIK
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Hodie Obey', 
        'price': 'Rp. 350.000', 
        'rating': '5.0',
        'image': 'https://picsum.photos/id/225/500' // Gambar Hoodie Merah/Hitam Obey
      },
      {
        'name': 'Hodie Ben DAVIS', 
        'price': 'Rp. 300.000', 
        'rating': '5.0',
        'image': 'https://picsum.photos/id/338/500'
      },
      {
        'name': 'Hodie LMC Mozaic', 
        'price': 'Rp. 500.000', 
        'rating': '5.0',
        'image': 'https://picsum.photos/id/312/500'
      },
      {
        'name': 'Hodie Santa Cruz', 
        'price': 'Rp. 550.000', 
        'rating': '5.0',
        'image': 'https://picsum.photos/id/443/500'
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SAPAAN USER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hi, Abel !',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

            // BANNER PROMO
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          child: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        image: NetworkImage('https://picsum.photos/id/225/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // STRUKTUR BRAND LIST
            const Text(
              'Brands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      border: Border.all(color: Colors.redAccent.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        brands[index],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // GRID PRODUK YANG SUDAH TERINTEGRASI DENGAN DETAIL_SCREEN.DART
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  // AKSI KLIK: Otomatis pindah halaman dan mengirim data spesifik produk
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          productName: product['name'],
                          productPrice: product['price'],
                          imageUrl: product['image'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(product['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product['price'],
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                product['rating'],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}