import 'package:flutter/material.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();
  String _qrData = '';

  final List<Map<String, String>> _presetVisitors = [
    {
      'name': 'John Doe',
      'phone': '+91 9876543210',
      'purpose': 'Delivery',
    },
    {
      'name': 'Jane Smith',
      'phone': '+91 8765432109',
      'purpose': 'Guest Visit',
    },
    {
      'name': 'Mike Johnson',
      'phone': '+91 7654321098',
      'purpose': 'Maintenance',
    },
  ];

  void _generateQR() {
    if (_nameController.text.isNotEmpty && 
        _phoneController.text.isNotEmpty && 
        _purposeController.text.isNotEmpty) {
      
      final visitorId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _qrData = '$visitorId:${_nameController.text}:${_phoneController.text}:${_purposeController.text}';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _usePreset(Map<String, String> preset) {
    setState(() {
      _nameController.text = preset['name']!;
      _phoneController.text = preset['phone']!;
      _purposeController.text = preset['purpose']!;
    });
    _generateQR();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _purposeController.clear();
      _qrData = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preset Visitors Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Generate (Demo)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetVisitors.map((preset) {
                        return ElevatedButton(
                          onPressed: () => _usePreset(preset),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                            foregroundColor: AppTheme.secondary.withValues(alpha: 0.8),
                          ),
                          child: Text(preset['name']!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Manual Entry Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manual Entry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Visitor Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose of Visit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _generateQR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Generate QR Code',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // QR Code Display
            if (_qrData.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Generated QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.onPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.onBackgroundLight.withValues(alpha: 0.3)),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: AppTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.onBackgroundLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QR Data:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _qrData,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Scan this QR code with the visitor management scanner',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onBackgroundLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}