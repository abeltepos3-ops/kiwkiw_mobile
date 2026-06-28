import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  static const List<Map<String, String>> _vouchers = [
    {
      'code': 'KIWKIW15',
      'title': 'Diskon 15% Semua Produk',
      'desc': 'Minimal belanja Rp 200.000, berlaku untuk semua kategori hoodie.',
    },
    {
      'code': 'GRATISONGKIR',
      'title': 'Gratis Ongkos Kirim',
      'desc': 'Minimal belanja Rp 300.000, khusus pengiriman standar.',
    },
    {
      'code': 'NEWUSER10',
      'title': 'Diskon 10% Pelanggan Baru',
      'desc': 'Berlaku untuk transaksi pertama kamu di KIWKIW.',
    },
  ];

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
        title: const Text(
          'Voucher',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _vouchers.length,
        itemBuilder: (context, index) {
          final voucher = _vouchers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(voucher['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(voucher['desc']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          voucher['code']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: voucher['code']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kode ${voucher['code']} disalin!')),
                        );
                      },
                      child: const Text('Salin', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}