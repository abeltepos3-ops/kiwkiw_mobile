import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label disalin!')),
    );
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
        title: const Text(
          'Pelayanan Pelanggan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Butuh bantuan? Hubungi kami melalui salah satu kontak di bawah ini.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildContactCard(context, Icons.chat_bubble_outline, 'WhatsApp', '0812-3456-7890', copyable: true),
          const SizedBox(height: 14),
          _buildContactCard(context, Icons.email_outlined, 'Email', 'cs@kiwkiw.com', copyable: true),
          const SizedBox(height: 14),
          _buildContactCard(
            context,
            Icons.access_time,
            'Jam Operasional',
            'Setiap hari, 08.00 - 21.00 WIB',
            copyable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    required bool copyable,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
              onPressed: () => _copy(context, label, value),
            ),
        ],
      ),
    );
  }
}