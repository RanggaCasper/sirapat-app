import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          isScanning = false;
        });
        _handleQrCode(code);
        break;
      }
    }
  }

  void _handleQrCode(String code) {
    // Pause scanning
    cameraController.stop();

    // Show result bottom sheet
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'QR Code Terdeteksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resumeScanning();
                    },
                    child: const Text('Scan Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(code);
                    },
                    child: const Text('Gunakan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: false,
    );
  }

  void _resumeScanning() {
    setState(() {
      isScanning = true;
    });
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          _buildScannerOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        Expanded(child: Container(color: Colors.black54)),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.black54)),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner decorations
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCorner(true, true),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCorner(true, false),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCorner(false, true),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCorner(false, false),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(color: Colors.black54)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Arahkan kamera ke kode QR',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
