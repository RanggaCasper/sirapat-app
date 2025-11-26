import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class SummaryDescription extends StatelessWidget {
  final String? description;

  const SummaryDescription({Key? key, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      description ??
          'Rapat membahas evaluasi sistem pendidikan Q4 dengan focus pada integrasi teknologi: Keputusan utama: migrasi sistem ke cloud dalam 3 bulan, budget dialokasikan Rp 500M, dan pembentuakn tim khusus IT-Education. Target go-live Maret 2025.',
      style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
    );
  }
}
