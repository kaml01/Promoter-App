import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promoterapp/provider/DropdownProvider.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {

  final String skulist, image;
  final int skuid, idx;
  final num quantity;
  final VoidCallback? onDelete;

  MyWidget(this.skulist, this.skuid, this.image, this.idx, this.quantity, {this.onDelete});

  final TextEditingController op_stock = TextEditingController();
  final TextEditingController clo_stock = TextEditingController();
  final TextEditingController samp_stock = TextEditingController();
  final TextEditingController sale = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dropdownOptionsProvider = Provider.of<DropdownProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section: Product Name and Delete Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2, size: 20, color: Color(0xFF063A06)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    skulist,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF063A06),
                    ),
                  ),
                ),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.cancel, color: Colors.redAccent, size: 22),
                  ),
              ],
            ),
          ),

          // Content Section: Image and Inputs
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                  ),
                ),
                const SizedBox(width: 20),

                // Input Fields Group
                Expanded(
                  child: Column(
                    children: [
                      _buildModernField(
                        controller: samp_stock,
                        label: "Sample Stock",
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            dropdownOptionsProvider.addsamplestock(idx, int.parse(value), skuid);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildModernField(
                        controller: sale,
                        label: "Sale Units",
                        isPrimary: true,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            dropdownOptionsProvider.addsale(idx, int.parse(value), skuid, quantity);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    bool isPrimary = false,
  }) {

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isPrimary ? const Color(0xFF063A06) : Colors.grey[600], fontSize: 12),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isPrimary ? Colors.green.withOpacity(0.02) : Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF063A06), width: 1.5),
        ),
      ),
    );


  }
}

