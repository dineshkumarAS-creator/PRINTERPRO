import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'review_settings_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _nameController = TextEditingController();
  
  // Speech to Text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _showConfirmation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Animation for ripples
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initSpeech();
  }

  /// Initialize Speech Engine
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          setState(() {
             _errorMessage = "Speech error: ${error.errorMsg}";
             _isListening = false;
             _controller.stop();
          });
        },
        onStatus: (status) {
          if (status == 'notListening') {
             setState(() {
               _isListening = false;
               _controller.stop();
             });
          }
        },
      );
      setState(() {});
    } catch (e) {
      setState(() => _errorMessage = "Speech initialization failed: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    // _speechToText.stop(); // Best practice ensuring it stops
    super.dispose();
  }

  /// Start Listening (Live)
  void _startListening() async {
    setState(() {
      _errorMessage = null;
      _showConfirmation = false;
    });

    if (!_speechEnabled) {
      _initSpeech(); // Retry init if needed
      return;
    }

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_IN', // Request Indian English if available
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );

    setState(() {
      _isListening = true;
      _controller.repeat();
    });
  }

  /// Stop Listening
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _controller.stop();
      _controller.reset();
    });
  }

  /// Handle Real-time Results
  void _onSpeechResult(SpeechRecognitionResult result) {
    String spokenText = result.recognizedWords;
    
    // Logic: Extract name & Capitalize
    // Filter out common prefixes
    String cleanText = spokenText.toLowerCase()
        .replaceAll("my name is", "")
        .replaceAll("i am", "")
        .trim();
    
    // Capitalize Each Word
    if (cleanText.isNotEmpty) {
      String formattedName = cleanText.split(' ').map((word) {
        if (word.isEmpty) return "";
        return "${word[0].toUpperCase()}${word.substring(1)}";
      }).join(' ');

      setState(() {
        _nameController.text = formattedName;
        // If final result, show confirmation
        if (result.finalResult && formattedName.isNotEmpty) {
           _showConfirmation = true;
           _isListening = false;
           _controller.stop();
           _controller.reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP 01', 
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '1/7',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Hi there!\nWhat’s your name?', 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 60),

                      // Microphone Button with Ripple Animation
                      GestureDetector(
                        onTap: () {
                          if (_isListening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_isListening) ...List.generate(3, (index) {
                                  double delay = index * 0.3;
                                  double progress = (_controller.value + delay) % 1.0;
                                  return Opacity(
                                    opacity: (1 - progress).clamp(0.0, 1.0),
                                    child: Container(
                                      width: 100 + (150 * progress),
                                      height: 100 + (150 * progress),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black.withOpacity(0.1),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isListening ? Colors.redAccent : Colors.black,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isListening ? Icons.stop : Icons.mic_none_outlined,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        _isListening ? 'LISTENING...' : 'OR SPEAK',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isListening ? Colors.redAccent : Colors.black45,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Name Input Field
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your name...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 24,
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                           if (val.isNotEmpty && !_showConfirmation) {
                             // Manual typing handling
                           }
                        },
                        onSubmitted: (val) {
                          if (val.isNotEmpty) {
                            setState(() {
                              _showConfirmation = true;
                            });
                          }
                        }
                      ),

                      const SizedBox(height: 24),

                      // Suggestion Chips
                      if (!_showConfirmation)
                        Wrap(
                          spacing: 12,
                          children: ['Rahul', 'Priya', 'Anish'].map((name) {
                            return ActionChip(
                              label: Text(name),
                              labelStyle: GoogleFonts.inter(color: Colors.black87),
                              backgroundColor: Colors.grey[100],
                              shape: const StadiumBorder(side: BorderSide.none),
                              onPressed: () {
                                _nameController.text = name;
                                setState(() {
                                  _showConfirmation = true;
                                });
                              },
                            );
                          }).toList(),
                        ),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // Confirmation Card
                      if (_showConfirmation)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Hi ${_nameController.text}! Let’s get your prints ready',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to next screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ReviewSettingsScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Start Printing',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

