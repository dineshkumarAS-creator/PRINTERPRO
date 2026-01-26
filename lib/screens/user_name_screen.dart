import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'file_upload_screen.dart';

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _micController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  final TextEditingController _nameController = TextEditingController();
  String _selectedName = '';
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ApiService _apiService = ApiService();
  bool _isRecording = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _micController, curve: Curves.linear),
    );

    _initVoiceFlow();
  }

  Future<void> _initVoiceFlow() async {
    // 1. Ask Name (Server)
    File? audioFile = await _apiService.askName();
    if (audioFile != null) {
      // 2. Play Audio
      await _audioPlayer.play(DeviceFileSource(audioFile.path));
      _audioPlayer.onPlayerComplete.listen((_) {
        // 3. Start Recording after audio finishes
        _startRecording();
      });
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() => _isRecording = true);
      
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/user_response_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
    }
  }

  Future<void> _stopRecordingAndRecognize() async {
    if (!_isRecording) return; 

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    final path = await _audioRecorder.stop();
    if (path != null) {
      // 4. Send to Server
      final result = await _apiService.recognizeName(path);
      
      if (result['success'] == true && result['name'] != null) {
        _onNameSelected(result['name']);
      } else {
        // Retry Loop: Simple snackbar for now or retry logic
        // Ideally fetch retry audio here if backend provided it
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't hear you, trying again...")));
         _initVoiceFlow(); // Restart flow
      }
    }
    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _micController.dispose();
    _nameController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onNameSelected(String name) {
    setState(() {
      _selectedName = name;
      _nameController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure White Background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP 01',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '1/7',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.black12,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1/7,
                      child: Container(
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Hi there!',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'What\'s your name?',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Mic
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: AnimatedBuilder(
                            animation: _micController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Layered Ripples
                                  ...List.generate(3, (index) {
                                    double delay = index * 0.35;
                                    double progress = (_rippleAnimation.value + delay) % 1.0;
                                    return Container(
                                      width: 80 + (120 * progress),
                                      height: 80 + (120 * progress),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black.withValues(alpha: 0.12 * (1 - progress)),
                                          width: 1.2,
                                        ),
                                      ),
                                    );
                                  }),
                                  // Main Mic Circle
                                  GestureDetector(
                                    onTap: _stopRecordingAndRecognize,
                                    child: ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isRecording ? Colors.redAccent : Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 25,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            width: 1,
                                          ),
                                        ),
                                          child: _isProcessing 
                                            ? const Padding(
                                                padding: EdgeInsets.all(24.0),
                                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                                              )
                                            : Icon(
                                                _isRecording ? Icons.stop : Icons.mic_none_outlined,
                                                color: _isRecording ? Colors.white : Colors.black,
                                                size: 38,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'OR SPEAK',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Input
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.inter(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Type your name...',
                      hintStyle: GoogleFonts.inter(color: Colors.black26),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                    onChanged: (val) {
                      setState(() {
                         _selectedName = val;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNameChip('Rahul'),
                      const SizedBox(width: 12),
                      _buildNameChip('Priya'),
                      const SizedBox(width: 12),
                      _buildNameChip('Anish'),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Greeting Card (Only show if name is detected/entered, simulated here)
            if (_selectedName.isNotEmpty || true) // Forcibly showing for demo match
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black, // Black accent
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi ${_selectedName.isEmpty ? 'Rahul' : _selectedName}!',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Let\'s get your prints ready',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Start Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FileUploadScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Printing',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'SECURE CLOUD PRINTING SERVICE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  }

  Widget _buildNameChip(String name) {
    return InkWell(
      onTap: () => _onNameSelected(name),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
