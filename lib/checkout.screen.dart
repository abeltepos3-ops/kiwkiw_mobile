import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'app.store.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  final int subTotal;
  const CheckoutScreen({super.key, this.subTotal = 350000});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 1;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  String? _selectedProvince;
  String? _selectedCountry;
  String? _selectedShipping = 'Pengiriman Standar ( + Rp. 12.000 )';
  bool _saveDetails = false;

  String _selectedMethod = 'mandiri';
  final String _accountName = 'ABEL NAYAKA LAKSA PU';
  final String _mandiriNumber = '1840005852783';
  final String _danaNumber = '081234567890';
  bool _hasUploadedProof = false;
  String _uploadedFileName = '';

  int get _subTotal => widget.subTotal;
  int get _shippingFee {
    if (_selectedShipping == 'Pengiriman Cepat ( + Rp. 25.000 )') return 25000;
    if (_selectedShipping == 'Ambil Sendiri ( Rp. 0 )') return 0;
    return 12000;
  }
  int get _totalPayment => _subTotal + _shippingFee;

  // FUNGSI API (Sudah diperbaiki strukturnya)
  Future<void> _kirimDataKeDatabase() async {
    // PENTING: Ganti dengan IP Address WiFi laptop lu!
    const String apiUrl = 'http://192.168.1.5:8000/api/checkout'; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'user_id': 1,
          'total_amount': _totalPayment,
          'nama_penerima': _nameController.text,
          'alamat': _addressController.text,
          'shipping': _selectedShipping,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Sukses: Data masuk ke database!');
      } else {
        print('Gagal: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _formatRupiah(int amount) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  String _formatOrderDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${now.day} ${months[now.month - 1]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _simulateUploadProof() {
    setState(() {
      _hasUploadedProof = true;
      _uploadedFileName = 'TRX_BUKTI_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.png';
    });
  }

  void _handleBackPress() {
    if (_currentStep == 2) setState(() => _currentStep = 1);
    else Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBackPress)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_currentStep == 1) _buildBillingAddressStep(),
                  if (_currentStep == 2) _buildPaymentOptionStep(),
                  if (_currentStep == 3) _buildSuccessStep(),
                ],
              ),
            ),
          ),
          if (_currentStep < 3) _buildBottomActionArea(),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildBillingAddressStep() => Column(children: [
    _buildInputField(label: 'Nama Lengkap', hint: 'Masukkan nama', controller: _nameController),
    _buildInputField(label: 'Alamat', hint: 'Masukkan alamat', controller: _addressController),
  ]);

  Widget _buildPaymentOptionStep() => Column(children: [
    const Text('Pilih Metode Pembayaran'),
    _buildPaymentMethodCard(id: 'mandiri', title: 'Mandiri', iconPath: Icons.account_balance, trailingText: 'MANDIRI'),
  ]);

  Widget _buildSuccessStep() => const Center(child: Text('Pesanan Sukses!'));

  Widget _buildBottomActionArea() => Container(
    padding: const EdgeInsets.all(24),
    child: ElevatedButton(
      onPressed: () async {
        if (_currentStep == 1) {
          setState(() => _currentStep = 2);
        } else if (_currentStep == 2) {
          await _kirimDataKeDatabase(); // Panggil fungsi API
          AppStore.instance.addOrder({'date': _formatOrderDate(), 'total': _totalPayment});
          setState(() => _currentStep = 3);
        }
      },
      child: Text(_currentStep == 1 ? 'Lanjut Pembayaran' : 'Pesan Sekarang'),
    ),
  );

  Widget _buildInputField({required String label, required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label, hintText: hint));
  }

  Widget _buildDropdownField({required String label, required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(value: value, items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged, decoration: InputDecoration(labelText: label));
  }

  Widget _buildPaymentMethodCard({required String id, required String title, required IconData iconPath, required String trailingText}) {
    return RadioListTile(value: id, groupValue: _selectedMethod, title: Text(title), onChanged: (val) => setState(() => _selectedMethod = val.toString()));
  }
}