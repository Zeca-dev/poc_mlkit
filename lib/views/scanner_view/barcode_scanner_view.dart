import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_preview_app.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_type_enum.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    super.key,
    required this.onDetect,
    this.deviceOrientation = DeviceOrientation.landscapeRight,
  });

  final DeviceOrientation deviceOrientation;
  final Function(String) onDetect;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return ScannerPreview(
      scannerType: ScannerType.BARCODE_SCANNER,
      deviceOrientation: widget.deviceOrientation,
      onCaptureImage: _processImage,

      //
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.red,
                                    )),
                                child: const Text('Barcode'),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.itf]);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final String? displayValue = barcode.displayValue;

          if (displayValue != null) {
            log(displayValue);
            if (displayValue.length == 46) {
              _canProcess = false;

              widget.onDetect.call(displayValue);
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
