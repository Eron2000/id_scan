import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vioguard/stud_info.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const StudentIDScannerApp());
}

class StudentIDScannerApp extends StatelessWidget {
  const StudentIDScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IDScannerScreen(),
    );
  }
}

class IDScannerScreen extends StatefulWidget {
  const IDScannerScreen({super.key});

  @override
  State<IDScannerScreen> createState() => _IDScannerScreenState();
}

class _IDScannerScreenState extends State<IDScannerScreen> {
  CameraController? _cameraController;
  bool _flashOn = false;
  bool _isProcessing = false;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();
    if (await Permission.camera.isGranted) {
      final backCamera = (await availableCameras()).firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraController = CameraController(backCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _flashOn = !_flashOn);
    await _cameraController!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _scanID({int attempt = 1}) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() => _isProcessing = true);

      // Freeze frame
      XFile picture = await _cameraController!.takePicture();
      _capturedImage = File(picture.path);
      setState(() {}); // show frozen image immediately

      // Run OCR directly on full image
      String scannedText = await _extractTextFromFile(_capturedImage!);

      // Extract info
      final nameReg = RegExp(
        r'([A-Z][a-zA-Z]+,\s+(?:[A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*)(?:\s+[A-Z]\.?)?)',
        caseSensitive: false,
      );
      final courseReg = RegExp(r'\b([A-Z]{2,5})\b');
      final studNoReg = RegExp(r'\b(20\d{2}[- ]?\d{4,6})\b');

      String name = nameReg.firstMatch(scannedText)?.group(0) ?? '';
      String course = courseReg.firstMatch(scannedText)?.group(0) ?? '';
      String studentNo = studNoReg.firstMatch(scannedText)?.group(0) ?? '';
      name = name.replaceAll(',', '').trim();

      // Reset flash
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() => _flashOn = false);

      // Retry if no valid detection (max 2 tries)
      if ((name.isEmpty || studentNo.isEmpty) && attempt < 2) {
        debugPrint("⚠️ OCR incomplete. Retrying...");
        return _scanID(attempt: attempt + 1);
      }

      if (name.isEmpty || studentNo.isEmpty) {
        _showOverlayMessage("No valid ID detected");
        setState(() {
          _isProcessing = false;
          _capturedImage = null;
        });
        return;
      }

      // Navigate to next screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViolationScreen(
            name: name,
            course: course,
            studentNo: studentNo,
            violationsCount: 0,
          ),
        ),
      ).then((_) {
        setState(() {
          _capturedImage = null;
          _isProcessing = false;
        });
      });
    } catch (e) {
      debugPrint("❌ Scan error: $e");
      _showOverlayMessage("Failed to scan ID. Try again in good lighting.");
      setState(() {
        _isProcessing = false;
        _capturedImage = null;
      });
    }
  }

  Future<String> _extractTextFromFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  void _showOverlayMessage(String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () => overlay.remove());
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.width * 0.22;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Freeze frame if captured, else camera preview
          _capturedImage != null
              ? Image.file(
                  _capturedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : (_cameraController == null ||
                    !_cameraController!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    );
                  },
                ),

          // Scanner overlay (optional alignment guide)
          Positioned.fill(child: CustomPaint(painter: ScannerOverlay())),

          // Flash toggle
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _toggleFlash,
            ),
          ),

          // Capture button
          if (!_isProcessing)
            Positioned(
              bottom: 40,
              child: GestureDetector(
                onTap: _scanID,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Processing ID...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const padding = 10.0;
    final rectWidth = size.width - (padding * 5);
    final rectHeight = rectWidth / 0.625;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2;
    final right = left + rectWidth;
    final bottom = top + rectHeight;
    const cornerSize = 40.0;

    // Draw corners
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerSize), paint);
    canvas.drawLine(Offset(right, top), Offset(right - cornerSize, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerSize), paint);
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerSize, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - cornerSize, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
