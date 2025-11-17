import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NotificationType { success, error, warning, info }

class NotificationController extends GetxController {
  final RxBool isVisible = false.obs;
  final RxString message = ''.obs;
  final Rx<NotificationType> type = NotificationType.info.obs;

  void show(String msg, NotificationType notifType) {
    message.value = msg;
    type.value = notifType;
    isVisible.value = true;

    // Auto hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hide();
    });
  }

  void hide() {
    isVisible.value = false;
  }

  void showSuccess(String msg) => show(msg, NotificationType.success);
  void showError(String msg) => show(msg, NotificationType.error);
  void showWarning(String msg) => show(msg, NotificationType.warning);
  void showInfo(String msg) => show(msg, NotificationType.info);
}

class CustomNotification extends StatelessWidget {
  const CustomNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Obx(() {
      if (!controller.isVisible.value) {
        return const SizedBox.shrink();
      }

      Color backgroundColor;
      Color textColor;
      IconData icon;

      switch (controller.type.value) {
        case NotificationType.success:
          backgroundColor = Colors.green.shade600;
          textColor = Colors.white;
          icon = Icons.check_circle;
          break;
        case NotificationType.error:
          backgroundColor = Colors.red.shade600;
          textColor = Colors.white;
          icon = Icons.error;
          break;
        case NotificationType.warning:
          backgroundColor = Colors.orange.shade600;
          textColor = Colors.white;
          icon = Icons.warning;
          break;
        case NotificationType.info:
          backgroundColor = Colors.blue.shade600;
          textColor = Colors.white;
          icon = Icons.info;
          break;
      }

      return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            offset: controller.isVisible.value
                ? const Offset(0, 0)
                : const Offset(0, -2),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.message.value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.hide,
                    icon: Icon(Icons.close, color: textColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
