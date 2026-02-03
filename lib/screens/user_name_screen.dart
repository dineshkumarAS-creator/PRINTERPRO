import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'file_upload_screen.dart';
import 'dart:math' as math;

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  String _selectedName = '';

  // TTS (AI Voice)
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  // Speech to Text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  double _soundLevel = 0.0;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  // Wave animation values
  List<double> _waveHeights = List.generate(12, (index) => 0.3);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTTS();
    _initSpeechToText();
  }

  void _initAnimations() {
    // Pulse animation for the mic button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ripple animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.linear),
    );

    // Wave animation for recording effect
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        if (_isListening) {
          _updateWaveHeights();
        }
      });
  }

  void _updateWaveHeights() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _waveHeights.length; i++) {
        // Create dynamic wave effect based on sound level
        double baseHeight = 0.3 + (_soundLevel * 1.5);
        double variation =
            math.sin((DateTime.now().millisecondsSinceEpoch / 80) + (i * 0.5)) *
                0.5;
        _waveHeights[i] = (baseHeight + variation).clamp(0.2, 1.0);
      }
    });
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45); // Slightly slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0); // Natural pitch

    // Get available voices and try to set a futuristic-sounding one
    List<dynamic> voices = await _flutterTts.getVoices;

    // Try to find a good voice (prefer female voices for futuristic AI feel)
    for (var voice in voices) {
      if (voice['name'] != null &&
          (voice['name'].toString().toLowerCase().contains('zira') ||
              voice['name'].toString().toLowerCase().contains('david') ||
              voice['name'].toString().toLowerCase().contains('hazel'))) {
        await _flutterTts
            .setVoice({"name": voice['name'], "locale": voice['locale']});
        break;
      }
    }

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
      // Start listening after AI finishes speaking
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    });

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    // Start the AI greeting after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _speakGreeting();
    });
  }

  Future<void> _initSpeechToText() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              _stopListening();
            }
          }
        },
        onError: (error) {
          print('Speech recognition error: $error');
          _stopListening();
        },
      );
    }
  }

  Future<void> _speakGreeting() async {
    if (_isSpeaking) return;

    setState(() => _isSpeaking = true);
    _pulseController.repeat(reverse: true);

    await _flutterTts.speak("Hello! What's your name?");
  }

  Future<void> _startListening() async {
    if (!_speechEnabled || _isListening || _isSpeaking) return;

    setState(() {
      _isListening = true;
      _lastWords = '';
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          if (result.finalResult && _lastWords.isNotEmpty) {
            _onNameSelected(_extractName(_lastWords));
          }
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          // Normalize sound level (typically -2 to 10)
          // Boost sensitivity for better visual feedback
          double normalized = (level.abs() / 10.0);
          if (normalized < 0.2 && level != 0) normalized = 0.3;
          _soundLevel = normalized.clamp(0.0, 1.0);
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: false,
      localeId: "en-IN",
    );
  }

  String _extractName(String words) {
    // Simple name extraction - take the last word or the whole phrase if short
    List<String> parts = words.trim().split(' ');

    // Common patterns: "My name is X", "I am X", "It's X", "X"
    List<String> prefixes = [
      'my',
      'name',
      'is',
      'i',
      'am',
      "i'm",
      "it's",
      'call',
      'me'
    ];

    for (int i = parts.length - 1; i >= 0; i--) {
      String word = parts[i].toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (!prefixes.contains(word) && word.isNotEmpty) {
        // Capitalize first letter
        return word[0].toUpperCase() + word.substring(1);
      }
    }

    return words.isNotEmpty ? words[0].toUpperCase() + words.substring(1) : '';
  }

  void _stopListening() {
    _speechToText.stop();
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();

    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
      _waveHeights = List.generate(12, (index) => 0.3);
    });
  }

  void _toggleListening() {
    if (_isSpeaking) return;

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _waveController.dispose();
    _nameController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  void _onNameSelected(String name) {
    _stopListening();
    setState(() {
      _selectedName = name;
      _nameController.text = name;
    });

    // AI acknowledges the name
    Future.delayed(const Duration(milliseconds: 300), () {
      _flutterTts.speak("Nice to meet you, $name! Let's get started.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FileUploadScreen(),
                                      ),
                                    );
                                  },
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
                                widthFactor: 1 / 7,
                                child: Container(
                                  color: const Color(0xFF000000),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Main Title with speaking indicator
                            Center(
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      'Hi there!',
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _isSpeaking
                                            ? const Color(0xFF6366F1)
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      'What\'s your name?',
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _isSpeaking
                                            ? const Color(0xFF6366F1)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (_isSpeaking)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildSpeakingDot(0),
                                          const SizedBox(width: 4),
                                          _buildSpeakingDot(1),
                                          const SizedBox(width: 4),
                                          _buildSpeakingDot(2),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Mic with Recording Animation
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: AnimatedBuilder(
                                      animation: Listenable.merge([
                                        _pulseController,
                                        _rippleController
                                      ]),
                                      builder: (context, child) {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Recording wave effect
                                            if (_isListening)
                                              ..._buildWaveEffect(),

                                            // Ripple effects
                                            if (!_isListening)
                                              ...List.generate(3, (index) {
                                                double delay = index * 0.35;
                                                double progress =
                                                    (_rippleAnimation.value +
                                                            delay) %
                                                        1.0;
                                                return Container(
                                                  width: 80 + (120 * progress),
                                                  height: 80 + (120 * progress),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.12 *
                                                                  (1 -
                                                                      progress)),
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                );
                                              }),

                                            // Recording glow effect
                                            if (_isListening)
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 100 + (_soundLevel * 40),
                                                height:
                                                    100 + (_soundLevel * 40),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFFEF4444)
                                                          .withValues(
                                                              alpha: 0.3 +
                                                                  (_soundLevel *
                                                                      0.4)),
                                                      blurRadius: 30 +
                                                          (_soundLevel * 20),
                                                      spreadRadius: 5 +
                                                          (_soundLevel * 10),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            // AI Speaking glow effect
                                            if (_isSpeaking)
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 110,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF6366F1)
                                                          .withValues(
                                                              alpha: 0.4),
                                                      blurRadius: 40,
                                                      spreadRadius: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            // Main Mic Button
                                            GestureDetector(
                                              onTap: _toggleListening,
                                              child: ScaleTransition(
                                                scale: _isListening ||
                                                        _isSpeaking
                                                    ? _pulseAnimation
                                                    : const AlwaysStoppedAnimation(
                                                        1.0),
                                                child: Container(
                                                  width: 90,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: _isListening
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color(0xFFEF4444),
                                                              Color(0xFFDC2626)
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : _isSpeaking
                                                            ? const LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFF6366F1),
                                                                  Color(
                                                                      0xFF4F46E5)
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              )
                                                            : const LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  Color(
                                                                      0xFFF8F9FA)
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.1),
                                                        blurRadius: 25,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.05),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    _isListening
                                                        ? Icons.stop_rounded
                                                        : _isSpeaking
                                                            ? Icons
                                                                .volume_up_rounded
                                                            : Icons
                                                                .mic_none_outlined,
                                                    color: (_isListening ||
                                                            _isSpeaking)
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Status text
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _isSpeaking
                                          ? '🤖 AI SPEAKING...'
                                          : _isListening
                                              ? '🎙️ LISTENING...'
                                              : 'TAP TO SPEAK',
                                      key: ValueKey(
                                          '${_isSpeaking}_${_isListening}'),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _isListening
                                            ? const Color(0xFFEF4444)
                                            : _isSpeaking
                                                ? const Color(0xFF6366F1)
                                                : Colors.black54,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),

                                  // Show recognized words while listening
                                  if (_isListening && _lastWords.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F9FF),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: const Color(0xFF6366F1)
                                                  .withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          '"$_lastWords"',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF6366F1),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Input
                            TextField(
                              controller: _nameController,
                              style: GoogleFonts.inter(
                                  color: Colors.black, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Or type your name...',
                                hintStyle:
                                    GoogleFonts.inter(color: Colors.black26),
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: Colors.black38),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6366F1), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
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

                      // Greeting Card
                      if (_selectedName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.auto_awesome,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hi $_selectedName! 👋',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Let\'s get your prints ready',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
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
                            onPressed: _selectedName.isNotEmpty
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FileUploadScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
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
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 20),
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

  // Build speaking indicator dots
  Widget _buildSpeakingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8 +
              (math.sin(DateTime.now().millisecondsSinceEpoch / 200 + index) *
                  6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  // Build wave effect for recording
  List<Widget> _buildWaveEffect() {
    return List.generate(_waveHeights.length, (index) {
      double angle = (index / _waveHeights.length) * 2 * math.pi;
      double radius = 70 + (_waveHeights[index] * 50);

      return Positioned(
        left: 110 + math.cos(angle) * radius - 3,
        top: 110 + math.sin(angle) * radius - 15,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 8,
          height: 30 + (_waveHeights[index] * 40),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFEF4444),
              const Color(0xFFFCA5A5),
              _waveHeights[index],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNameChip(String name) {
    bool isSelected = _selectedName.toLowerCase() == name.toLowerCase();
    return InkWell(
      onTap: () => _onNameSelected(name),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.black12,
          ),
        ),
        child: Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
