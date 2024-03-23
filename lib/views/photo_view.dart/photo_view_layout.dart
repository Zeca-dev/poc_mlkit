import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../camera/camera_view_layout.dart';

abstract class PhotoViewLayout extends CameraViewLayout {
  const PhotoViewLayout({
    super.key,
    required super.deviceOrientation,
  });

  @override
  State<PhotoViewLayout> createState() => _PhotoViewLayoutState();
}

class _PhotoViewLayoutState extends State<PhotoViewLayout> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Teste extends PhotoViewLayout {
  const Teste({super.key, required super.deviceOrientation, this.onCaptureImage});

  final Function(InputImage)? onCaptureImage;

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              // widget.onCaptureImage.call();
            },
            child: const Text('Teste')),
      ),
    );
  }
}
