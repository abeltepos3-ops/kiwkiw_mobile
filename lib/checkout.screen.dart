import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'app.store.dart'; // dipakai untuk mencatat pesanan ke "Order Saya"

class CheckoutScreen extends StatefulWidget {
  // Total harga barang yang mau dibayar, dikirim dari halaman sebelumnya
  // (Keranjang, Detail Home, Detail Pencarian, atau Wishlist).
  // Default 350000 hanya sebagai jaga-jaga kalau suatu saat ada pemanggilan
  // yang lupa mengirim nilai ini.
  final int subTotal;

  const CheckoutScreen({super.key, this.subTotal = 350000});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // --- STATE ALUR NAVIGATION ---
  // 1 = Alamat Penagihan, 2 = Opsi Pembayaran, 3 = Pesanan Sukses (Sesuai gambar image_0a9780.png)
  int _currentStep = 1;

  // --- STATE FOR ALAMAT (LANGKAH 1) ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  String? _selectedProvince;
  String? _selectedCountry;
  String? _selectedShipping = 'Pengiriman Standar ( + Rp. 12.000 )';
  bool _saveDetails = false; 

  // --- STATE FOR PEMBAYARAN (LANGKAH 2) ---
  String _selectedMethod = 'mandiri';
  final String _accountName = 'ABEL NAYAKA LAKSA PU';
  final String _mandiriNumber = '1840005852783';
  final String _danaNumber = '081234567890';
  bool _hasUploadedProof = false;
  String _uploadedFileName = '';

  // Harga dasar barang -> sekarang ikut dari halaman sebelumnya (widget.subTotal),
  // bukan angka tetap 350000 lagi. Ini yang memperbaiki bug ketidaksinkronan harga.
  int get _subTotal => widget.subTotal;

  // Logika hitung biaya pengiriman secara dinamis
  int get _shippingFee {
    if (_selectedShipping == 'Pengiriman Cepat ( + Rp. 25.000 )') {
      return 25000;
    } else if (_selectedShipping == 'Ambil Sendiri ( Rp. 0 )') {
      return 0;
    }
    return 12000;
  }

  int get _totalPayment => _subTotal + _shippingFee;

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  // Format tanggal manual (tidak pakai DateFormat ber-locale supaya tidak perlu
  // initializeDateFormatting tambahan, jadi tetap aman tanpa setup ekstra).
  String _formatOrderDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute';
  }

  void _simulateUploadProof() {
    setState(() {
      _hasUploadedProof = true;
      _uploadedFileName = 'TRX_BUKTI_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti transfer berhasil diunggah!')),
    );
  }

  void _handleBackPress() {
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 3) {
      // Jika sudah di halaman sukses, tombol back akan mengembalikan ke halaman utama belanja
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackPress();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D3557), size: 20),
            onPressed: _handleBackPress,
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(
              color: Color(0xFF1D3557), 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // 1. STEPPER INDIKATOR PROSES (Update dinamis warna hitam jika aktif/selesai)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: _currentStep >= 1 ? Colors.black : Colors.grey.shade400, size: 28),
                        _buildDotSpacer(isActive: _currentStep >= 2),
                        Icon(Icons.credit_card, color: _currentStep >= 2 ? Colors.black : Colors.grey.shade400, size: 28),
                        _buildDotSpacer(isActive: _currentStep == 3),
                        Icon(Icons.check_circle, color: _currentStep == 3 ? Colors.black : Colors.grey.shade400, size: 26),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // TAMPILKAN ELEMEN SESUAI LANGKAH YANG AKTIF
                    if (_currentStep == 1) 
                      _buildBillingAddressStep() 
                    else if (_currentStep == 2) 
                      _buildPaymentOptionStep() 
                    else 
                      _buildSuccessStep(), // Memanggil UI Sukses sesuai gambar
                  ],
                ),
              ),
            ),

            // 2. BAGIAN BAWAH (Hanya muncul di Langkah 1 & 2. Di Langkah 3 digantikan tombol bawaan halaman sukses)
            if (_currentStep < 3) _buildBottomActionArea(),
          ],
        ),
      ),
    );
  }

  // ==================== TAMPILAN LANGKAH 1: ALAMAT PENAGIHAN ====================
  Widget _buildBillingAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Billing address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 25),
        _buildInputField(label: 'Nama Lengkap', hint: 'Masukkan nama lengkap Anda', controller: _nameController),
        const SizedBox(height: 20),
        _buildInputField(label: 'Alamat', hint: 'Masukkan alamat rumah lengkap', controller: _addressController),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Provinsi',
                hint: 'Pilih Provinsi',
                value: _selectedProvince,
                items: ['DKI Jakarta', 'Jawa Tengah', 'Jawa Barat', 'Jawa Timur', 'D.I. Yogyakarta'],
                onChanged: (val) => setState(() => _selectedProvince = val),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInputField(label: 'Pos Kode', hint: 'Contoh: 13978', controller: _zipController, keyboardType: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Negara',
          hint: 'Pilih Negara',
          value: _selectedCountry,
          items: ['Indonesia', 'Malaysia', 'Singapore', 'Thailand'],
          onChanged: (val) => setState(() => _selectedCountry = val),
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Opsi Pengiriman',
          hint: 'Pilih Opsi Pengiriman',
          value: _selectedShipping,
          items: [
            'Pengiriman Standar ( + Rp. 12.000 )',
            'Pengiriman Cepat ( + Rp. 25.000 )',
            'Ambil Sendiri ( Rp. 0 )'
          ],
          onChanged: (val) => setState(() => _selectedShipping = val),
        ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(value: _saveDetails, activeColor: Colors.black, onChanged: (val) => setState(() => _saveDetails = val!)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Simpan detail untuk alamat penagihan di masa mendatang',
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==================== TAMPILAN LANGKAH 2: METODE PEMBAYARAN ====================
  Widget _buildPaymentOptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Option', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 20),
        _buildPaymentMethodCard(id: 'mandiri', title: 'Transfer Bank Mandiri', iconPath: Icons.account_balance_wallet_outlined, trailingText: 'MANDIRI'),
        const SizedBox(height: 15),
        _buildPaymentMethodCard(id: 'dana', title: 'Transfer Digital DANA', iconPath: Icons.phone_android_outlined, trailingText: 'DANA'),
        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedMethod == 'mandiri' ? 'Detail Rekening Mandiri Seller:' : 'Detail Akun DANA Seller:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text('Nama Penerima:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(_accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Text(_selectedMethod == 'mandiri' ? 'Nomor Rekening:' : 'Nomor DANA:', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedMethod == 'mandiri' ? _mandiriNumber : _danaNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent, letterSpacing: 0.5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _selectedMethod == 'mandiri' ? _mandiriNumber : _danaNumber));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor berhasil disalin!')));
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        const Text('Upload Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _simulateUploadProof,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _hasUploadedProof ? Colors.green : Colors.grey.shade300, width: 1.5),
            ),
            child: _hasUploadedProof
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_uploadedFileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Text('Ketuk untuk mengganti foto bukti', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 6),
                      Text('Upload Screenshot Bukti Transfer', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==================== TAMPILAN LANGKAH 3: HALAMAN PESANAN SUKSES (MENGACU PADA image_0a9780.png) ====================
  Widget _buildSuccessStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          
          // Custom Icon Keranjang Belanja + Centang (Sesuai mockup ui)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                child: const Icon(
                  Icons.shopping_cart_outlined, 
                  size: 90, 
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle, 
                    size: 38, 
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Judul Pesanan Sukses
          const Text(
            'Pesanan Sukses',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle Pesanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Terima kasih telah membeli. Pesanan Anda\nakan dikirim dalam 3-5 hari kerja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, 
                color: Colors.grey.shade400,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 100),

          // Tombol Kembali Belanja Sesuai Layout Bawah Mockup
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman katalog belanja utama
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Kembali Belanja',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RINGKASAN BIAYA (STEP 1 & STEP 2) ====================
  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30, top: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sub-total', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(_formatRupiah(_subTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biaya Pengiriman', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(_formatRupiah(_shippingFee), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.white, thickness: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              Text(_formatRupiah(_totalPayment), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 1) {
                  if (_nameController.text.isEmpty || _addressController.text.isEmpty || _selectedProvince == null || _selectedShipping == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap lengkapi semua data alamat & pengiriman!')),
                    );
                    return;
                  }
                  setState(() {
                    _currentStep = 2;
                  });
                } else if (_currentStep == 2) {
                  if (!_hasUploadedProof) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap upload screenshot bukti transfer terlebih dahulu!')),
                    );
                    return;
                  }

                  // CATAT PESANAN INI KE RIWAYAT, SUPAYA MUNCUL DI MENU "ORDER SAYA"
                  AppStore.instance.addOrder({
                    'date': _formatOrderDate(),
                    'method': _selectedMethod == 'mandiri' ? 'Transfer Bank Mandiri' : 'Transfer Digital DANA',
                    'total': _totalPayment,
                    'status': _selectedShipping == 'Ambil Sendiri ( Rp. 0 )' ? 'Siap untuk Pickup' : 'Diproses',
                  });
                  
                  // LANGKAH UPDATE: Berpindah langsung ke Halaman Sukses Mockup
                  setState(() {
                    _currentStep = 3;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
              child: Text(
                _currentStep == 1 ? 'Lanjutkan ke Pembayaran' : 'Pesan',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Dots Indikator Atas
  Widget _buildDotSpacer({bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: List.generate(4, (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.grey.shade300, 
            shape: BoxShape.circle,
          ),
        )),
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
          ),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({required String id, required String title, required IconData iconPath, required String trailingText}) {
    final isSelected = _selectedMethod == id;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
      ),
      child: RadioListTile<String>(
        value: id,
        groupValue: _selectedMethod,
        activeColor: Colors.black,
        title: Row(
          children: [
            Icon(iconPath, color: Colors.black54),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          ],
        ),
        secondary: Text(trailingText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
        onChanged: (String? value) => setState(() => _selectedMethod = value!),
      ),
    );
  }
}