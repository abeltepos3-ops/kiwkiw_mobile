import 'package:flutter/material.dart';
import 'app.store.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  void _showAddressForm(BuildContext context, {int? editIndex}) {
    final existing = editIndex != null ? AppStore.instance.addresses.value[editIndex] : null;
    final labelController = TextEditingController(text: existing?['label'] ?? '');
    final recipientController = TextEditingController(text: existing?['recipient'] ?? '');
    final phoneController = TextEditingController(text: existing?['phone'] ?? '');
    final addressController = TextEditingController(text: existing?['address'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editIndex != null ? 'Ubah Alamat' : 'Tambah Alamat',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                _buildField('Label Alamat (contoh: Rumah, Kantor)', labelController),
                const SizedBox(height: 14),
                _buildField('Nama Penerima', recipientController),
                const SizedBox(height: 14),
                _buildField('Nomor Telepon', phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildField('Alamat Lengkap', addressController, maxLines: 3),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      if (labelController.text.trim().isEmpty ||
                          recipientController.text.trim().isEmpty ||
                          addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap lengkapi semua data alamat!')),
                        );
                        return;
                      }
                      final newAddress = {
                        'label': labelController.text.trim(),
                        'recipient': recipientController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'address': addressController.text.trim(),
                      };
                      if (editIndex != null) {
                        AppStore.instance.updateAddress(editIndex, newAddress);
                      } else {
                        AppStore.instance.addAddress(newAddress);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Alamat'),
          content: const Text('Yakin ingin menghapus alamat ini?'),
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
                AppStore.instance.removeAddress(index);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
          'Alamat Pengiriman',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showAddressForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: AppStore.instance.addresses,
        builder: (context, addresses, _) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada alamat tersimpan', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk tombol + di kanan bawah untuk menambah',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              final phone = (addr['phone'] as String?) ?? '';
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            (addr['label'] as String?) ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showAddressForm(context, editIndex: index),
                              child: Icon(Icons.edit, size: 18, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: () => _confirmDelete(context, index),
                              child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (addr['recipient'] as String?) ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      (addr['address'] as String?) ?? '',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}