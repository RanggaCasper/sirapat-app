import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final meetingController = Get.find<MeetingController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      meetingController.clearForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Rapat'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Judul Rapat *',
                    controller: meetingController.titleController,
                    hintText: 'Masukkan judul rapat',
                    fieldKey: 'title',
                    prefixIcon: Icons.title_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    label: 'Deskripsi',
                    controller: meetingController.descriptionController,
                    hintText: 'Masukkan deskripsi rapat',
                    maxLines: 3,
                    fieldKey: 'description',
                    prefixIcon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    label: 'Lokasi',
                    controller: meetingController.locationController,
                    hintText: 'Masukkan lokasi rapat',
                    fieldKey: 'location',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    label: 'Agenda',
                    controller: meetingController.agendaController,
                    hintText: 'Masukkan agenda rapat',
                    maxLines: 3,
                    fieldKey: 'agenda',
                    prefixIcon: Icons.list_alt_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDateField(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTimeField(isStartTime: true)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildTimeField(isStartTime: false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '* Wajib diisi',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Actions
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Close any open snackbars first
                        if (Get.isSnackbarOpen) {
                          Get.closeAllSnackbars();
                        }
                        // Then navigate back
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMD,
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: meetingController.isLoadingAction
                            ? null
                            : () => meetingController.createMeeting(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                          elevation: 0,
                        ),
                        child: meetingController.isLoadingAction
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Tambah',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      final error = meetingController.fieldErrors[fieldKey];
      return CustomTextField(
        controller: controller,
        labelText: label,
        hintText: hintText,
        maxLines: maxLines,
        prefixIcon: prefixIcon,
        errorText: error,
        onChanged: (value) {
          if (error != null) {
            meetingController.fieldErrors.remove(fieldKey);
          }
        },
      );
    });
  }

  Widget _buildDateField() {
    return Obx(() {
      final error = meetingController.fieldErrors['date'];
      return CustomTextField(
        controller: meetingController.dateController,
        labelText: 'Tanggal *',
        hintText: 'Pilih tanggal',
        prefixIcon: Icons.calendar_today_outlined,
        readOnly: true,
        errorText: error,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            meetingController.dateController.text =
                date.toIso8601String().split('T')[0];
            if (error != null) {
              meetingController.fieldErrors.remove('date');
            }
          }
        },
      );
    });
  }

  Widget _buildTimeField({required bool isStartTime}) {
    final controller = isStartTime
        ? meetingController.startTimeController
        : meetingController.endTimeController;
    final label = isStartTime ? 'Waktu Mulai *' : 'Waktu Selesai *';
    final fieldKey = isStartTime ? 'start_time' : 'end_time';

    return Obx(() {
      final error = meetingController.fieldErrors[fieldKey];
      return CustomTextField(
        controller: controller,
        labelText: label,
        hintText: '00:00',
        prefixIcon: Icons.access_time_outlined,
        readOnly: true,
        errorText: error,
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            controller.text =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            if (error != null) {
              meetingController.fieldErrors.remove(fieldKey);
            }
          }
        },
      );
    });
  }
}
