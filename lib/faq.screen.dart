import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'Berapa lama proses pengiriman?',
      'a': 'Pesanan biasanya dikirim dalam 3-5 hari kerja setelah pembayaran dikonfirmasi.',
    },
    {
      'q': 'Bagaimana cara melakukan pembayaran?',
      'a': 'Kamu bisa transfer melalui Bank Mandiri atau DANA, lalu upload bukti transfer di halaman Checkout.',
    },
    {
      'q': 'Apakah bisa retur atau tukar ukuran?',
      'a': 'Bisa, hubungi Pelayanan Pelanggan kami dalam waktu 3 hari setelah barang diterima.',
    },
    {
      'q': 'Bagaimana cara melacak pesanan saya?',
      'a': 'Status pesanan kamu bisa dicek di menu Order Saya pada halaman Akun Saya.',
    },
    {
      'q': 'Apakah ada minimal pembelian?',
      'a': 'Tidak ada minimal pembelian, kecuali untuk penggunaan voucher tertentu.',
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
          'FAQ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                iconColor: Colors.black,
                collapsedIconColor: Colors.grey,
                title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq['a']!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                    ),
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