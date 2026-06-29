import 'package:flutter/material.dart';
import 'home.screen.dart'; 
import 'package:http/http.dart' as http; // Wajib untuk API
import 'dart:convert'; // Wajib untuk JSON


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// Fungsi untuk nembak API Produk
  Future<List<dynamic>> fetchProducts() async {
    // PENTING: Ganti dengan IP Address Laptop lu (192.168.x.x)
    const String apiUrl = 'http://192.168.1.34:8000/api/mobile/products'; 

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        if (resBody['status'] == 'success') {
          return resBody['data']; // Mengembalikan List of Products dari Laravel
        }
      }
      throw Exception('Gagal memuat produk dari server');
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kiwkiw E-Commerce',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIconColor: Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFA6)),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginScreen = true; 

  // Controller untuk input email & password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- FUNGSI LOGIN KE DATABASE LARAVEL ---
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password tidak boleh kosong!');
      return;
    }

    // PENTING: Ganti 192.168.1.15 sesuai IP Laptop lu (CMD: ipconfig)
    const String apiUrl = 'http://192.168.1.34:8000/api/mobile/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final resBody = jsonDecode(response.body);

      // Cek context biar ga error setelah proses async
      if (!mounted) return; 

      if (response.statusCode == 200 && resBody['status'] == 'success') {
        String loggedInUserName = resBody['data']['name'];
        String userRole = resBody['data']['role'] ?? 'customer'; 
        
        // Cek Role: Apakah Admin atau Customer?
        if (userRole == 'admin') {
          _showSnackBar('Login Sukses! Selamat Datang Admin $loggedInUserName.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          _showSnackBar('Login Sukses! Selamat Berbelanja $loggedInUserName.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()), 
          );
        }
      } else {
        _showSnackBar(resBody['message'] ?? 'Gagal login. Periksa email & password.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error Koneksi Database: $e');
    }
  }

  // --- FUNGSI DAFTAR / BUAT AKUN KE DATABASE LARAVEL ---
  Future<void> _handleRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password baru harus diisi!');
      return;
    }

    // Ambil teks sebelum @ di email sebagai nama
    String name = email.split('@')[0];

    // PENTING: Ganti 192.168.1.15 sesuai IP Laptop lu (CMD: ipconfig)
    const String apiUrl = 'http://192.168.1.34:8000/api/mobile/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final resBody = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 || (response.statusCode == 200 && resBody['status'] == 'success')) {
        setState(() {
          isLoginScreen = true; // Balik ke form login
        });
        _showSnackBar('Akun berhasil dibuat! Silakan masuk.');
        _passwordController.clear(); 
      } else {
        _showSnackBar(resBody['message'] ?? 'Gagal membuat akun! Email mungkin sudah dipakai.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error Koneksi Database: $e');
    }
  }

  // Fungsi memunculkan notifikasi bawah
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF142834), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO KIWKIW
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.white),
                    Positioned(top: 12, child: Icon(Icons.check, size: 45, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'KIWKIW E-COMERCE',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40), 

                Text(
                  isLoginScreen ? 'Silakan Masuk' : 'Buat Akun Baru',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan Email Anda (contoh: abel@gmail.com)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoginScreen ? _handleLogin : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFA6), 
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isLoginScreen ? 'LOGIN' : 'DAFTAR SEKARANG',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoginScreen ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoginScreen = !isLoginScreen;
                          _emailController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        isLoginScreen ? 'Buat Akun' : 'Masuk',
                        style: const TextStyle(color: Color(0xFF00FFA6), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// HALAMAN DASHBOARD KHUSUS ADMIN
// -------------------------------------------------------------
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard KIWKIW', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF142834),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat Datang Owner / Admin!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Di sini Anda bisa mengelola konten aplikasi mobile Kiwkiw.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildAdminMenuCard(Icons.add_photo_alternate_outlined, 'Upload Produk Baru', Colors.blue.shade100),
                  _buildAdminMenuCard(Icons.discount_outlined, 'Atur Diskon & Promo', Colors.green.shade100),
                  _buildAdminMenuCard(Icons.notifications_active_outlined, 'Kirim Notifikasi', Colors.amber.shade100),
                  _buildAdminMenuCard(Icons.analytics_outlined, 'Laporan Penjualan', Colors.purple.shade100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuCard(IconData icon, String title, Color bgColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: bgColor,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}