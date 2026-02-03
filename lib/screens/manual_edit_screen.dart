import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'voice_assistant_screen.dart';

class ManualEditScreen extends StatefulWidget {
  const ManualEditScreen({super.key});

  @override
  State<ManualEditScreen> createState() => _ManualEditScreenState();
}

class _ManualEditScreenState extends State<ManualEditScreen> {
  int _selectedToolIndex = 0;
  double _rotation = 0.0;
  double _scale = 1.0;

  final List<Map<String, dynamic>> _tools = [
    {'icon': Icons.crop, 'label': 'CROP'},
    {'icon': Icons.rotate_right, 'label': 'ROTATE'},
    {'icon': Icons.aspect_ratio, 'label': 'RESIZE'},
    {'icon': Icons.flip, 'label': 'FLIP'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure White Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manual Edit',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OPTIMIZATION',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Step 2 of 6',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 2 / 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Quick edits ',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '(optional)',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Image Preview Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.03),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1541336032412-2048a678540d?q=80&w=1000&auto=format&fit=crop'), // Poster placeholder
                    fit: BoxFit.contain, // Fit inside to show whole doc
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid lines overlay (simulated with Container for style)
                    Positioned.fill(
                      child: ClipRect(
                        child: Transform.rotate(
                          angle: _rotation,
                          child: Transform.scale(
                            scale: _scale,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1541336032412-2048a678540d?q=80&w=1000&auto=format&fit=crop',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 60, color: Colors.black26),
                                    Text("Image load failed",
                                        style:
                                            TextStyle(color: Colors.black38)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                    // Crop corners (simulated)
                    const Positioned(
                        top: 10,
                        left: 10,
                        child: _CornerWidget(quarterTurns: 0)),
                    const Positioned(
                        top: 10,
                        right: 10,
                        child: _CornerWidget(quarterTurns: 1)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bottom Tools & Actions
            Container(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 30, left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tools List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_tools.length, (index) {
                      return _buildToolItem(
                        index: index,
                        icon: _tools[index]['icon'],
                        label: _tools[index]['label'],
                        isSelected: _selectedToolIndex == index,
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const VoiceAssistantScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip Text
                  TextButton(
                    onPressed: () {
                      // Skip logic
                    },
                    child: Text(
                      'SKIP EDITS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedToolIndex = index;
          if (label == 'ROTATE') {
            _rotation += 90 * (3.14159 / 180);
          } else if (label == 'RESIZE') {
            _scale = (_scale == 1.0) ? 1.2 : 1.0;
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw vertical lines
    double stepX = size.width / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(stepX * i, 0), Offset(stepX * i, size.height), paint);
    }

    // Draw horizontal lines
    double stepY = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(0, stepY * i), Offset(size.width, stepY * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerWidget extends StatelessWidget {
  final int quarterTurns;

  const _CornerWidget({required this.quarterTurns});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black54, width: 2),
            left: BorderSide(color: Colors.black54, width: 2),
          ),
        ),
      ),
    );
  }
}
