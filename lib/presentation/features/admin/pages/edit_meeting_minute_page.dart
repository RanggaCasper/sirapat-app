import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

class EditMeetingMinutePage extends StatefulWidget {
  final int meetingMinuteId;
  final MeetingMinute? meetingMinute;

  const EditMeetingMinutePage({
    super.key,
    required this.meetingMinuteId,
    this.meetingMinute,
  });

  @override
  State<EditMeetingMinutePage> createState() => _EditMeetingMinutePageState();
}

class _EditMeetingMinutePageState extends State<EditMeetingMinutePage> {
  final controller = Get.find<MeetingMinuteController>();

  // Text controllers
  late TextEditingController originalTextController;
  late TextEditingController summaryController;
  late TextEditingController pembahasanController;
  late TextEditingController totalAnggaranController;
  late TextEditingController catatanAnggaranController;

  // Lists
  late List<String> keputusanList;
  late List<String> tindakanList;
  late List<Map<String, dynamic>> anggaranList;

  // Controllers for list items
  final Map<int, TextEditingController> keputusanControllers = {};
  final Map<int, TextEditingController> tindakanControllers = {};
  final Map<int, Map<String, TextEditingController>> anggaranControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final minute = widget.meetingMinute;

    originalTextController =
        TextEditingController(text: minute?.originalText ?? '');
    summaryController = TextEditingController(text: minute?.summary ?? '');
    pembahasanController =
        TextEditingController(text: minute?.pembahasan ?? '');
    totalAnggaranController =
        TextEditingController(text: minute?.totalAnggaran ?? '');
    catatanAnggaranController =
        TextEditingController(text: minute?.catatanAnggaran ?? '');

    keputusanList = List<String>.from(minute?.keputusan ?? []);
    tindakanList = List<String>.from(minute?.tindakan ?? []);
    anggaranList = List<Map<String, dynamic>>.from(
      (minute?.anggaran ?? []).map((item) => Map<String, dynamic>.from(item)),
    );

    // Initialize keputusan controllers
    for (int i = 0; i < keputusanList.length; i++) {
      keputusanControllers[i] = TextEditingController(text: keputusanList[i]);
    }

    // Initialize tindakan controllers
    for (int i = 0; i < tindakanList.length; i++) {
      tindakanControllers[i] = TextEditingController(text: tindakanList[i]);
    }

    // Initialize anggaran controllers
    for (int i = 0; i < anggaranList.length; i++) {
      final jumlah = anggaranList[i]['jumlah'];
      final deskripsi = anggaranList[i]['deskripsi'];

      anggaranControllers[i] = {
        'jumlah': TextEditingController(
          text: jumlah != null ? jumlah.toString() : '',
        ),
        'deskripsi': TextEditingController(
          text: deskripsi != null ? deskripsi.toString() : '',
        ),
      };
    }
  }

  @override
  void dispose() {
    originalTextController.dispose();
    summaryController.dispose();
    pembahasanController.dispose();
    totalAnggaranController.dispose();
    catatanAnggaranController.dispose();

    for (var c in keputusanControllers.values) {
      c.dispose();
    }
    for (var c in tindakanControllers.values) {
      c.dispose();
    }
    for (var map in anggaranControllers.values) {
      for (var c in map.values) {
        c.dispose();
      }
    }

    super.dispose();
  }

  void _addKeputusan() {
    setState(() {
      final index = keputusanList.length;
      keputusanList.add('');
      keputusanControllers[index] = TextEditingController();
    });
  }

  void _removeKeputusan(int index) {
    setState(() {
      keputusanList.removeAt(index);
      keputusanControllers[index]?.dispose();
      keputusanControllers.remove(index);

      // Reindex remaining controllers
      final newControllers = <int, TextEditingController>{};
      for (int i = index; i < keputusanList.length; i++) {
        newControllers[i] = keputusanControllers[i + 1]!;
      }
      for (var entry in newControllers.entries) {
        keputusanControllers[entry.key] = entry.value;
      }
      keputusanControllers.remove(keputusanList.length);
    });
  }

  void _addTindakan() {
    setState(() {
      final index = tindakanList.length;
      tindakanList.add('');
      tindakanControllers[index] = TextEditingController();
    });
  }

  void _removeTindakan(int index) {
    setState(() {
      tindakanList.removeAt(index);
      tindakanControllers[index]?.dispose();
      tindakanControllers.remove(index);

      // Reindex remaining controllers
      final newControllers = <int, TextEditingController>{};
      for (int i = index; i < tindakanList.length; i++) {
        newControllers[i] = tindakanControllers[i + 1]!;
      }
      for (var entry in newControllers.entries) {
        tindakanControllers[entry.key] = entry.value;
      }
      tindakanControllers.remove(tindakanList.length);
    });
  }

  void _addAnggaran() {
    setState(() {
      final index = anggaranList.length;
      anggaranList.add({'jumlah': '', 'deskripsi': ''});
      anggaranControllers[index] = {
        'jumlah': TextEditingController(),
        'deskripsi': TextEditingController(),
      };
    });
  }

  void _removeAnggaran(int index) {
    setState(() {
      anggaranList.removeAt(index);
      anggaranControllers[index]?.values.forEach((c) => c.dispose());
      anggaranControllers.remove(index);

      // Reindex remaining controllers
      final newControllers = <int, Map<String, TextEditingController>>{};
      for (int i = index; i < anggaranList.length; i++) {
        newControllers[i] = anggaranControllers[i + 1]!;
      }
      for (var entry in newControllers.entries) {
        anggaranControllers[entry.key] = entry.value;
      }
      anggaranControllers.remove(anggaranList.length);
    });
  }

  Future<void> _handleSubmit() async {
    // Clear previous errors
    controller.fieldErrors.clear();

    // Collect data from controllers
    final keputusanData = keputusanControllers.entries
        .map((e) => e.value.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final tindakanData = tindakanControllers.entries
        .map((e) => e.value.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final anggaranData = anggaranControllers.entries
        .map((e) {
          return {
            'jumlah': e.value['jumlah']!.text,
            'deskripsi': e.value['deskripsi']!.text,
          };
        })
        .where((item) =>
            item['jumlah']!.isNotEmpty || item['deskripsi']!.isNotEmpty)
        .toList();

    final result = await controller.updateMeetingMinute(
      meetingMinuteId: widget.meetingMinuteId,
      originalText: originalTextController.text.isNotEmpty
          ? originalTextController.text
          : null,
      summary:
          summaryController.text.isNotEmpty ? summaryController.text : null,
      pembahasan: pembahasanController.text.isNotEmpty
          ? pembahasanController.text
          : null,
      keputusan: keputusanData.isNotEmpty ? keputusanData : null,
      tindakan: tindakanData.isNotEmpty ? tindakanData : null,
      anggaran: anggaranData.isNotEmpty ? anggaranData : null,
      totalAnggaran: totalAnggaranController.text.isNotEmpty
          ? totalAnggaranController.text
          : null,
      catatanAnggaran: catatanAnggaranController.text.isNotEmpty
          ? catatanAnggaranController.text
          : null,
    );

    if (result != null) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Notulen'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLG,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Original Text
                    _buildFormField(
                      label: 'Teks Asli',
                      controller: originalTextController,
                      hintText: 'Masukkan teks asli dari rekaman',
                      fieldKey: 'original_text',
                      maxLines: 4,
                      prefixIcon: Icons.text_snippet_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Summary
                    _buildFormField(
                      label: 'Ringkasan',
                      controller: summaryController,
                      hintText: 'Masukkan ringkasan notulen',
                      fieldKey: 'summary',
                      maxLines: 4,
                      prefixIcon: Icons.summarize_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Pembahasan
                    _buildFormField(
                      label: 'Pembahasan',
                      controller: pembahasanController,
                      hintText: 'Masukkan pembahasan rapat',
                      fieldKey: 'pembahasan',
                      maxLines: 4,
                      prefixIcon: Icons.chat_bubble_outline,
                    ),
                    const SizedBox(height: 20),

                    // Keputusan Section
                    _buildListSection(
                      title: 'Keputusan',
                      items: keputusanList,
                      controllers: keputusanControllers,
                      onAdd: _addKeputusan,
                      onRemove: _removeKeputusan,
                      icon: Icons.gavel_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),

                    // Tindakan Section
                    _buildListSection(
                      title: 'Tindakan',
                      items: tindakanList,
                      controllers: tindakanControllers,
                      onAdd: _addTindakan,
                      onRemove: _removeTindakan,
                      icon: Icons.assignment_turned_in_outlined,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),

                    // Anggaran Section
                    _buildAnggaranSection(),
                    const SizedBox(height: 20),

                    // Total Anggaran
                    _buildFormField(
                      label: 'Total Anggaran',
                      controller: totalAnggaranController,
                      hintText: 'Contoh: Rp100.000.000',
                      fieldKey: 'total_anggaran',
                      prefixIcon: Icons.money_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Catatan Anggaran
                    _buildFormField(
                      label: 'Catatan Anggaran',
                      controller: catatanAnggaranController,
                      hintText: 'Masukkan catatan terkait anggaran',
                      fieldKey: 'catatan_anggaran',
                      maxLines: 3,
                      prefixIcon: Icons.note_outlined,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoadingAction ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoadingAction
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String fieldKey,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Obx(() {
      final error = this.controller.fieldErrors[fieldKey];
      return CustomTextField(
        controller: controller,
        labelText: label,
        hintText: hintText,
        maxLines: maxLines,
        prefixIcon: prefixIcon,
        errorText: error,
        onChanged: (value) {
          if (error != null) {
            this.controller.fieldErrors.remove(fieldKey);
          }
        },
      );
    });
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required Map<int, TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAdd,
                icon: Icon(Icons.add_circle, color: color),
                tooltip: 'Tambah $title',
              ),
            ],
          ),
          if (items.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Belum ada $title. Klik tombol + untuk menambahkan.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...List.generate(items.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controllers[index]!,
                        labelText: '$title ${index + 1}',
                        hintText: 'Masukkan $title',
                        maxLines: 2,
                        onChanged: (value) {
                          items[index] = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAnggaranSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.blue, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Anggaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addAnggaran,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                tooltip: 'Tambah Anggaran',
              ),
            ],
          ),
          if (anggaranList.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Belum ada anggaran. Klik tombol + untuk menambahkan.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...List.generate(anggaranList.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header dengan nomor dan delete button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Anggaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeAnggaran(index),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        // Content dengan padding jelas
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Jumlah Field
                              CustomTextField(
                                controller:
                                    anggaranControllers[index]!['jumlah']!,
                                labelText: 'Jumlah Anggaran',
                                hintText: 'Contoh: Rp10.000.000',
                                prefixIcon: Icons.attach_money,
                                onChanged: (value) {
                                  anggaranList[index]['jumlah'] = value;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Deskripsi Field
                              CustomTextField(
                                controller:
                                    anggaranControllers[index]!['deskripsi']!,
                                labelText: 'Deskripsi Anggaran',
                                hintText: 'Masukkan deskripsi anggaran',
                                maxLines: 2,
                                onChanged: (value) {
                                  anggaranList[index]['deskripsi'] = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
