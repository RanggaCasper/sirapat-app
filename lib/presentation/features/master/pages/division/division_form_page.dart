import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

/// Halaman form untuk create/edit division
class DivisionFormPage extends StatelessWidget {
  final bool isEdit;

  const DivisionFormPage({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DivisionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Divisi' : 'Tambah Divisi'),
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

                  // Form Fields
                  Obx(
                    () => CustomTextField(
                      controller: controller.nameController,
                      labelText: 'Nama Divisi *',
                      hintText: 'Contoh: IT Department',
                      prefixIcon: Icons.business_outlined,
                      errorText: controller.getFieldError('name'),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        if (controller.getFieldError('name') != null) {
                          controller.clearFieldError('name');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => CustomTextField(
                      controller: controller.descriptionController,
                      labelText: 'Deskripsi (Opsional)',
                      hintText: 'Tambahkan deskripsi divisi...',
                      prefixIcon: Icons.description_outlined,
                      errorText: controller.getFieldError('description'),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        if (controller.getFieldError('description') != null) {
                          controller.clearFieldError('description');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '* Wajib diisi',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
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
                        if (Get.isDialogOpen ?? false) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMD,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoadingActionObs.value
                            ? null
                            : () async {
                                if (isEdit) {
                                  await controller.updateDivision();
                                } else {
                                  await controller.createDivision();
                                }
                                if (controller.fieldErrors.isEmpty &&
                                    context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEdit ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoadingActionObs.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEdit ? 'Update' : 'Simpan',
                                style: AppTextStyles.button,
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
}
