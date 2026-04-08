import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class CropScannerPage extends StatefulWidget {
  const CropScannerPage({super.key});

  @override
  State<CropScannerPage> createState() => _CropScannerPageState();
}

class _CropScannerPageState extends State<CropScannerPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isAnalyzing = true;
          _analysisResult = null;
        });

        // Simulate AI analysis delay
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        final auth = context.read<AuthService>();
        final db = context.read<DatabaseService>();

        String crop = auth.currentUser?.preferredCrop ?? 'Wheat';

        setState(() {
          _analysisResult = db.analyzeCropQuality(crop);
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _image = null;
      _analysisResult = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Crop Quality Scanner',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              if (_isAnalyzing) _buildAnalyzingState(),
              if (_analysisResult != null) _buildResultSection(),
              if (_image == null) _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _image != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(_image!, fit: BoxFit.cover),
                if (!_isAnalyzing && _analysisResult != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _resetScanner,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.focus,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(LucideIcons.camera, color: Colors.white),
                      label: const Text(
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(
                        LucideIcons.image,
                        color: AppTheme.primaryGreen,
                      ),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  color: AppTheme.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'How it works',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              '1',
              'Take a clear picture of your harvested crop.',
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '2',
              'Our AI will scan for visual quality indicators.',
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '3',
              'Get an instant grade and estimated market price.',
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '4',
              'See recommendations on nearby mandis for the best profit.',
            ),
          ],
        ),
      ).animate().fade().slideY(begin: 0.1),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          const SizedBox(height: 24),
          const Text(
                'Analyzing crop quality...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1500.ms,
                color: AppTheme.primaryGreen.withValues(alpha: 0.5),
              ),
          const SizedBox(height: 8),
          const Text(
            'Running AI models on cloud. Please wait.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    ).animate().fade();
  }

  Widget _buildResultSection() {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    String crop = auth.currentUser?.preferredCrop ?? 'Wheat';
    final grade = _analysisResult!['grade'];
    final minPrice = _analysisResult!['minPrice'];
    final maxPrice = _analysisResult!['maxPrice'];
    final bestMandiId = _analysisResult!['bestMandiId'];
    final recommendation = _analysisResult!['recommendation'];
    final mandi = db.getMandi(bestMandiId);

    Color gradeColor;
    IconData gradeIcon;
    switch (grade) {
      case 'A':
        gradeColor = AppTheme.secondaryGreen;
        gradeIcon = LucideIcons.checkCircle2;
        break;
      case 'B':
        gradeColor = AppTheme.primaryOrange;
        gradeIcon = LucideIcons.alertCircle;
        break;
      case 'C':
      default:
        gradeColor = Colors.redAccent;
        gradeIcon = LucideIcons.xCircle;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grade Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crop Quality Grade',
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Grade $grade',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          crop,
                          style: TextStyle(
                            color: gradeColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(gradeIcon, size: 48, color: gradeColor),
            ],
          ),
        ).animate().fade().slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Market Price & Mandi Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.banknote,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Expected Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${minPrice.toStringAsFixed(0)} - ₹${maxPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '/ quintal',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          color: AppTheme.primaryOrange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Best Mandi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mandi.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mandi.district,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),

        // Recommendation Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // Indigo tint
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.lightbulb,
                  color: Color(0xFF4F46E5),
                ), // Indigo
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),

        // Rescan Button
        ElevatedButton(
          onPressed: _resetScanner,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.textDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Scan Another Crop',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ).animate().fade(delay: 300.ms),
      ],
    );
  }
}
