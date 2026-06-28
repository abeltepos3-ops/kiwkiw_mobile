import 'package:flutter/material.dart';
import 'package:kiwkiw_mobile_app/detail2.screen.dart'; // Import halaman detail baru

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allProducts = [
    {
      'name': 'LMC Global Management Hoodie - Navy',
      'price': 'Rp 450.000',
      'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&q=80',
    },
    {
      'name': 'Ben Davis Superior Quality Hoodie - Purple',
      'price': 'Rp 420.000',
      'image': 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500&q=80',
    },
    {
      'name': 'Urban Streetwear Hoodie - Black',
      'price': 'Rp 399.000',
      'image': 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?w=500&q=80',
    },
  ];

  List<Map<String, String>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) => product['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Pencarian',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _filteredProducts.isEmpty
          ? Center(
              child: Text(
                'Produk tidak ditemukan',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                
                return GestureDetector(
                  onTap: () {
                    // SEKARANG DIARAHKAN KE PILIH SIZE DULU, SAMBIL MEMBAWA DATA PRODUK YANG DI-KLIK
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(product: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            product['image']!,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 280,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product['name']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['price']!,
                          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}