import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/photo_view.dart/photo_view_layout.dart';

import '../camera/camera_preview_app.dart';

class PhotoCameraView extends StatefulWidget {
  const PhotoCameraView({super.key, required this.photoViewLayout});

  final PhotoViewLayout photoViewLayout;

  @override
  State<PhotoCameraView> createState() => _PhotoCameraViewState();
}

class _PhotoCameraViewState extends State<PhotoCameraView> {
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreviewApp(
      cameraViewLayout: widget.photoViewLayout,
      onCaptureImage: _onCapture,
    );
  }

  Future<void> _onCapture(InputImage? inputInage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    try {
      if (widget.photoViewLayout is Teste) {
        if (inputInage != null) {
          (widget.photoViewLayout as Teste).onCaptureImage?.call(inputInage);
          _canProcess = false;
        }
      }
    } catch (error) {
      log(error.toString(), name: 'PhtoCameraView.onCapture()');
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
