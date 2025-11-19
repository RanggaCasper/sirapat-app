import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

/// Form bottom sheet untuk create/edit division
class DivisionFormDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onSubmit;
  final String submitLabel;

  const DivisionFormDialog({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onSubmit,
    required this.submitLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DivisionController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: AppSpacing.paddingLG,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textMedium,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.borderLight),

          // Form Content
          Flexible(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomTextField(
                      controller: controller.descriptionController,
                      labelText: 'Deskripsi (Opsional)',
                      hintText: 'Tambahkan deskripsi divisi...',
                      prefixIcon: Icons.description_outlined,
                      errorText: controller.getFieldError('description'),
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
              color: AppColors.backgroundLight,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                            : onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
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
                            : Text(submitLabel, style: AppTextStyles.button),
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
