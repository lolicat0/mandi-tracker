import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class CropScannerDialog extends StatefulWidget {
  const CropScannerDialog({super.key});

  @override
  State<CropScannerDialog> createState() => _CropScannerDialogState();
}

class _CropScannerDialogState extends State<CropScannerDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
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
          _image = pickedFile;
          _isAnalyzing = true;
          _analysisResult = null;
        });

        _simulateAnalysis();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _simulateAnalysis() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate AI delay
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        // Mock output
        _analysisResult = {
          'grade': 'Grade A',
          'quality': 'Excellent',
          'estimatedPrice': '₹2,400 - ₹2,550 / qtl',
          'recommendation': 'Sell at High Demand Market (24km away)',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: AppTheme.background,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Crop Scanner',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content Area
              if (_image == null)
                _buildImageSelection()
              else if (_isAnalyzing)
                _buildAnalyzingState()
              else if (_analysisResult != null)
                _buildResultState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.scanLine,
                size: 64,
                color: AppTheme.primaryGreen.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload a clear photo of your crop to instantly get an AI quality grade and price estimate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(LucideIcons.camera),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(LucideIcons.image),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceWhite,
                  foregroundColor: AppTheme.textDark,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fade().slideY(begin: 0.1);
  }

  Widget _buildAnalyzingState() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: kIsWeb
              ? Image.network(_image!.path, height: 200, width: double.infinity, fit: BoxFit.cover)
              : Image.file(File(_image!.path), height: 200, width: double.infinity, fit: BoxFit.cover),
        ).animate().fade(),
        const SizedBox(height: 32),
        const CircularProgressIndicator(color: AppTheme.primaryGreen),
        const SizedBox(height: 16),
        const Text(
          'AI is analyzing crop quality...',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(begin: 0.5, end: 1.0),
      ],
    );
  }

  Widget _buildResultState() {
    final res = _analysisResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: kIsWeb
              ? Image.network(_image!.path, height: 160, width: double.infinity, fit: BoxFit.cover)
              : Image.file(File(_image!.path), height: 160, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.secondaryGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quality Grade', style: TextStyle(color: AppTheme.textMuted)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      res['grade'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text('Estimated Price', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Text(
                res['estimatedPrice'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, color: AppTheme.primaryOrange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        res['recommendation'],
                        style: const TextStyle(color: Color(0xFFB45309), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _image = null;
              _analysisResult = null;
            });
          },
          child: const Text('Scan Another Crop'),
        ),
      ],
    ).animate().fade().slideY(begin: 0.1);
  }
}
