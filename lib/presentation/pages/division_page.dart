import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';
import 'package:sirapat_app/domain/entities/division.dart';

class DivisionPage extends GetView<DivisionController> {
  const DivisionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Divisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchDivisions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingObs.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.divisions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada divisi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap tombol + untuk menambah divisi',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Divisi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDivisions,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.divisions.length,
            itemBuilder: (context, index) {
              final division = controller.divisions[index];
              return _buildDivisionCard(division);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Divisi',
      ),
    );
  }

  Widget _buildDivisionCard(Division division) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(division),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      division.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (division.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        division.description!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(division),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.deleteDivision(division.id!),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(Division division) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.business, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Detail Divisi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama', division.name),
            const SizedBox(height: 12),
            _buildDetailRow('Deskripsi', division.description ?? '-'),
            if (division.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Dibuat', _formatDate(division.createdAt!)),
            ],
            if (division.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Diperbarui', _formatDate(division.updatedAt!)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _showEditDialog(division);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateDialog() {
    controller.clearForm();
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text('Tambah Divisi'),
          ],
        ),
        content: _buildFormContent(),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoadingActionObs.value
                  ? null
                  : controller.createDivision,
              icon: controller.isLoadingActionObs.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Division division) {
    controller.prepareEdit(division);
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Edit Divisi'),
          ],
        ),
        content: _buildFormContent(),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoadingActionObs.value
                  ? null
                  : controller.updateDivision,
              icon: controller.isLoadingActionObs.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name Field
          Obx(
            () => TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Nama Divisi *',
                hintText: 'Contoh: IT Department',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
                errorText: controller.getFieldError('name'),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: controller.getFieldError('name') != null
                        ? Colors.red
                        : Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                if (controller.getFieldError('name') != null) {
                  controller.clearFieldError('name');
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Description Field
          Obx(
            () => TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                hintText: 'Tambahkan deskripsi divisi...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                errorText: controller.getFieldError('description'),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: controller.getFieldError('description') != null
                        ? Colors.red
                        : Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (controller.getFieldError('description') != null) {
                  controller.clearFieldError('description');
                }
              },
            ),
          ),

          const SizedBox(height: 8),

          // Helper text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '* Wajib diisi',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
