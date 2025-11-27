import 'package:flutter/material.dart';
import 'package:sirapat_app/app/util/dependency_injection.dart';
import 'package:sirapat_app/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all permanent dependencies (LocalStorage, NotificationController)
  await DependencyInjection.init();

  runApp(const App());
}
