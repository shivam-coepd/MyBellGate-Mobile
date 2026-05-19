import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool flashOn = false;
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: AppTheme.onBackgroundDark,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                flashOn = !flashOn;
              });
            },
            icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppTheme.onBackgroundDark,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasScanned ? 'QR Code Detected!' : 'Point camera at QR code',
                      style: const TextStyle(
                        color: AppTheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.stop(),
                          child: const Text('Pause'),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.start(),
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (hasScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          hasScanned = true;
        });
        _processQRCode(barcode.rawValue!);
      }
    }
  }

  void _processQRCode(String qrData) {
    controller.stop();
    
    try {
      final parts = qrData.split(':');
      if (parts.length >= 4) {
        final visitorData = {
          'id': parts[0],
          'name': parts[1],
          'phone': parts[2],
          'purpose': parts[3],
          'scannedAt': DateTime.now().toIso8601String(),
        };
        
        Navigator.pop(context, visitorData);
      } else {
        _showErrorDialog('Invalid QR code format');
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                hasScanned = false;
              });
              controller.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}