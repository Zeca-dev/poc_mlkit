import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/camera_view.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key, required this.onDetectBarCode});

  final Function(String) onDetectBarCode;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

enum DetectorViewMode { liveFeed, gallery }

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: null,
      onImage: _processImage,
      onCameraFeedReady: null,
      onDetectorViewModeChanged: null,
      initialCameraLensDirection: CameraLensDirection.back,
      onCameraLensDirectionChanged: null,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    _barcodeScanner = BarcodeScanner(formats: formats);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final BarcodeType type = barcode.type;
          final Rect boundingBox = barcode.boundingBox;
          final String? displayValue = barcode.displayValue;
          final String? rawValue = barcode.rawValue;

          if (displayValue != null) {
            if (displayValue.length == 46) {
              _canProcess = false;
              //34191.75124 34567.871230 41234.560005 4 95250000026035
              //0341949525000002603517512345678712341234560000
              //0341949525000002603517512345678712341234560000

              widget.onDetectBarCode.call(displayValue);
              Navigator.pop(context);
            }
          }
        }
      });
    } catch (error) {
      log(error.toString());
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
