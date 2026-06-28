import 'package:flutter/material.dart';
import 'app.store.dart';
import 'main.dart'; // dipakai untuk tombol Keluar -> balik ke AuthScreen
import 'order.screen.dart';
import 'voucher.screen.dart';
import 'address.screen.dart';
import 'faq.screen.dart';
import 'service.screen.dart';
import 'settings.screen.dart';

// Pilihan avatar bawaan (warna + ikon), supaya fitur "ganti foto profil"
// tidak perlu package tambahan (tidak perlu image_picker, tidak perlu
// edit pubspec.yaml, tidak perlu izin kamera/galeri).
const List<Map<String, dynamic>> _avatarPresets = [
  {'id': 'avatar_0', 'color': Color(0xFF1D3557), 'icon': Icons.person},
  {'id': 'avatar_1', 'color': Color(0xFFE76F51), 'icon': Icons.face_retouching_natural},
  {'id': 'avatar_2', 'color': Color(0xFF2A9D8F), 'icon': Icons.emoji_emotions},
  {'id': 'avatar_3', 'color': Color(0xFFE9C46A), 'icon': Icons.pets},
  {'id': 'avatar_4', 'color': Color(0xFF9B5DE5), 'icon': Icons.star},
  {'id': 'avatar_5', 'color': Color(0xFFEF476F), 'icon': Icons.favorite},
];

Map<String, dynamic> _getPreset(String? id) {
  return _avatarPresets.firstWhere(
    (preset) => preset['id'] == id,
    orElse: () => _avatarPresets[0],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ==================== GANTI FOTO PROFIL (PILIH AVATAR) ====================
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Foto Profil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _avatarPresets.map((preset) {
                    return GestureDetector(
                      onTap: () {
                        AppStore.instance.userPhotoPath.value = preset['id'] as String;
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: preset['color'] as Color,
                        child: Icon(preset['icon'] as IconData, color: Colors.white, size: 28),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== UBAH NAMA ====================
  void _showEditNameDialog() {
    final controller = TextEditingController(text: AppStore.instance.userName.value);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ubah Nama'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Masukkan nama baru'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  AppStore.instance.userName.value = newName;
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==================== LOGOUT ====================
  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Keluar dari Akun'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Akun Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // ===== FOTO PROFIL (bisa diketuk untuk diganti) =====
            ValueListenableBuilder<String?>(
              valueListenable: AppStore.instance.userPhotoPath,
              builder: (context, photoId, _) {
                final preset = _getPreset(photoId);
                return Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: preset['color'] as Color,
                      child: Icon(preset['icon'] as IconData, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // ===== NAMA (bisa diketuk pensilnya untuk diubah) =====
            ValueListenableBuilder<String>(
              valueListenable: AppStore.instance.userName,
              builder: (context, name, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showEditNameDialog,
                      child: Icon(Icons.edit, size: 16, color: Colors.grey.shade500),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),

            // ===== STATISTIK PESANAN (otomatis sesuai riwayat order asli) =====
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: AppStore.instance.orderHistory,
              builder: (context, orders, _) {
                final processing = orders.where((o) => o['status'] == 'Diproses').length;
                final shipped = orders.where((o) => o['status'] == 'Dikirim').length;
                final readyPickup = orders.where((o) => o['status'] == 'Siap untuk Pickup').length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('$processing', 'Pengolahan'),
                    _verticalDivider(),
                    _buildStatItem('$shipped', 'Dikirim'),
                    _verticalDivider(),
                    _buildStatItem('$readyPickup', 'Siap untuk Pickup'),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // ===== MENU LIST (sekarang semuanya benar-benar berfungsi) =====
            _buildMenuItem(Icons.receipt_long_outlined, 'Order Saya', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderScreen()));
            }),
            _buildMenuItem(Icons.confirmation_number_outlined, 'Voucher', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VoucherScreen()));
            }),
            _buildMenuItem(Icons.location_on_outlined, 'Alamat Pengiriman', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen()));
            }),
            _buildMenuItem(Icons.help_outline, 'FAQ', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
            }),
            _buildMenuItem(Icons.headset_mic_outlined, 'Pelayanan Pelanggan', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerServiceScreen()));
            }),
            _buildMenuItem(Icons.settings_outlined, 'Pengaturan', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),

            const SizedBox(height: 20),

            // ===== TOMBOL KELUAR =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _showLogoutConfirm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}