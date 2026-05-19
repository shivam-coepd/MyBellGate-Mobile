import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class VoiceCommandEntryScreen extends StatefulWidget {
  const VoiceCommandEntryScreen({super.key});

  @override
  State<VoiceCommandEntryScreen> createState() => _VoiceCommandEntryScreenState();
}

class _VoiceCommandEntryScreenState extends State<VoiceCommandEntryScreen> {
  bool _isListening = false;
  String _recognizedText = '';
  String _visitorName = '';
  String _flatNumber = '';
  String _purpose = '';

  final List<Map<String, dynamic>> _voiceCommands = [
    {
      'command': 'Add visitor',
      'example': '"Add visitor Rajesh Kumar for flat A-101"',
    },
    {
      'command': 'Approve entry',
      'example': '"Approve entry for visitor ID 123"',
    },
    {
      'command': 'Reject entry',
      'example': '"Reject entry for visitor ID 123"',
    },
    {
      'command': 'Search visitor',
      'example': '"Search visitor Rajesh Kumar"',
    },
  ];

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isListening = false;
        _recognizedText = 'Rajesh Kumar for flat A-101';
        _visitorName = 'Rajesh Kumar';
        _flatNumber = 'A-101';
        _purpose = 'Delivery';
      });
    });
  }

  void _processVoiceCommand() {
    if (_recognizedText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice command processed successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      setState(() {
        _recognizedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Voice Command Entry'),
              actions: [
                IconButton(
                  onPressed: () {
                    // Help action
                  },
                  icon: const Icon(Icons.help),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voice Command Instructions
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voice Command Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Press the microphone button and speak your command. '
                            'The system will recognize and process your request.',
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Supported Commands:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._voiceCommands.map(
                            (command) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ${command['command']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '  Example: ${command['example']}',
                                    style: const TextStyle(
                                      color: AppTheme.onBackgroundLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Voice Recognition
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Voice Recognition',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Microphone Button
                          Center(
                            child: GestureDetector(
                              onTap: _startListening,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _isListening ? AppTheme.error : AppTheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isListening
                                          ? AppTheme.error.withValues(alpha: 0.3)
                                          : AppTheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: AppTheme.onPrimary,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isListening ? 'Listening...' : 'Tap microphone to speak',
                            style: TextStyle(
                              color: _isListening ? AppTheme.error : AppTheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_recognizedText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recognized Text:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(_recognizedText),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (_recognizedText.isNotEmpty)
                            ElevatedButton(
                              onPressed: _processVoiceCommand,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Process Command',
                                style: TextStyle(color: AppTheme.onPrimary)
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Recognized Visitor Details
                  if (_visitorName.isNotEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recognized Visitor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(_visitorName),
                              subtitle: Text('Flat: $_flatNumber'),
                              trailing: const Icon(Icons.check_circle, color: AppTheme.success),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Purpose of Visit:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(_purpose),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Reject entry
                                    },
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Approve entry
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Visitor entry approved!'),
                                          backgroundColor: AppTheme.success,
                                        ),
                                      );
                                      setState(() {
                                        _visitorName = '';
                                        _flatNumber = '';
                                        _purpose = '';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                    ),
                                    child: const Text(
                                      'Approve Entry',
                                      style: TextStyle(color: AppTheme.onPrimary),
                                    ),
                                  ),
                                ),
                              ],
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}