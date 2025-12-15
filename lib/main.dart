import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sirapat_app/app/util/dependency_injection.dart';
import 'package:sirapat_app/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID');

  // Initialize all permanent dependencies
  await DependencyInjection.init();

  runApp(const App());
}
