import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/ScannerView/scanner_view_layout.dart';
import 'package:poc_mlkit/views/camera/camera_preview_app.dart';

import 'scanner_type_enum.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.scannerViewLayout,
    required this.onDetect,
  });

  final ScannerViewLayout scannerViewLayout;
  final Function(String) onDetect;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

enum DetectorViewMode { liveFeed, gallery }

class _ScannerViewState extends State<ScannerView> {
  BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreviewApp(
      cameraViewLayout: widget.scannerViewLayout,
      onCaptureImage: _processImage,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    final List<BarcodeFormat> formats = switch (widget.scannerViewLayout.scannerType) {
      ScannerType.BARCODE_SCANNER => [BarcodeFormat.itf],
      ScannerType.QRCODE_SCANNER => [BarcodeFormat.qrCode],
    };

    _barcodeScanner = BarcodeScanner(formats: formats);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final String? displayValue = barcode.displayValue;

          switch (widget.scannerViewLayout.scannerType) {
            case ScannerType.BARCODE_SCANNER:
              {
                if (displayValue != null) {
                  log(displayValue);
                  if (displayValue.length == 46) {
                    _canProcess = false;

                    widget.onDetect.call(displayValue);
                    Navigator.pop(context);
                  }
                }
              }

            case ScannerType.QRCODE_SCANNER:
              {
                if (displayValue != null) {
                  _canProcess = false;
                  widget.onDetect.call(displayValue);
                  Navigator.pop(context);
                }
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
