import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/app/util/dependency_injection.dart';
import 'package:sirapat_app/presentation/app.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await initServices();

  // Initialize dependencies
  await DependencyInjection.init();

  // Initialize notification controller
  Get.put(NotificationController());

  runApp(const App());
}

/// Initialize all services before running the app
Future<void> initServices() async {
  // ignore: avoid_print
  print('Starting services...');

  // Initialize LocalStorageService
  await Get.putAsync(() => LocalStorageService().init());

  // ignore: avoid_print
  print('All services started successfully');
}
