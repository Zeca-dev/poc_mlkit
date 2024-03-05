import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/ScannerView/barcode_scanner_view.dart';
import 'package:poc_mlkit/views/ScannerView/camera_view.dart';
import 'package:poc_mlkit/views/ScannerView/qrcode_scanner_view.dart';

import 'scanner_type_enum.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key, required this.scannerType, required this.onDetect});

  final ScannerType scannerType;
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
    return CameraView(
      layout: switch (widget.scannerType) {
        ScannerType.BARCODE => const BarcodeScannerView(),
        ScannerType.QRCODE => const QrCodeScannerView(),
      },
      scannerType: widget.scannerType,
      onCaptureImage: _processImage,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    final List<BarcodeFormat> formats = switch (widget.scannerType) {
      ScannerType.BARCODE => [BarcodeFormat.itf],
      ScannerType.QRCODE => [BarcodeFormat.qrCode],
    };

    _barcodeScanner = BarcodeScanner(formats: formats);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final String? displayValue = barcode.displayValue;

          switch (widget.scannerType) {
            case ScannerType.BARCODE:
              {
                if (displayValue != null) {
                  if (displayValue.length == 46) {
                    _canProcess = false;

                    widget.onDetect.call(displayValue);
                    Navigator.pop(context);
                  }
                }
              }

            case ScannerType.QRCODE:
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
