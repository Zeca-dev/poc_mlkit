import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_preview.dart';

class BarcodeScannerView extends StatefulWidget {
  ///Essa define o um scanner de códigos de barra.
  ///
  const BarcodeScannerView({
    super.key,
    required this.onDetect,
    this.deviceOrientation = DeviceOrientation.landscapeRight,
  });

  ///Define a orientação padrão da preview.
  ///
  ///Opções: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp].
  ///
  final DeviceOrientation deviceOrientation;

  ///Método que será executado quando houver a detecção de um código de barras.
  /// Retorna os dados do código de barras detectado.
  ///
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
    final size = MediaQuery.sizeOf(context);

    return ScannerPreview(
      scannerType: ScannerType.BARCODE_SCANNER,
      deviceOrientation: widget.deviceOrientation,
      onCaptureImage: _processImage,

      //
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BarcodeCustomPaint(size: size),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            )
          ],
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
      log(error.toString(), name: 'BarcodeScannerView._processImage()');
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class _BarcodeCustomPaint extends StatefulWidget {
  final Size size;
  const _BarcodeCustomPaint({required this.size});

  @override
  State<_BarcodeCustomPaint> createState() => _BarcodeCustomPaintState();
}

class _BarcodeCustomPaintState extends State<_BarcodeCustomPaint> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _BarcodePainter(size: widget.size),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final Size size;

  _BarcodePainter({required this.size});

  final cornerSize = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    const widthFactor = 0.80;
    const strokeWidth = 15.0;
    const strokeFactor = strokeWidth / 2;

    final barcodeWidth = size.width * widthFactor;
    final barcodeHeigth = size.height * 0.4;
    final sizeBarcode = Size(barcodeWidth, barcodeHeigth);

    final paintCorners = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    //Posições do Barcode
    final left = size.width * (1.0 - widthFactor) / 2;
    final right = sizeBarcode.width + left;
    final top = size.height * 0.3;
    final bottom = top + sizeBarcode.height;

    //Background params
    const colorFundo = Color(0xB3000000);
    final paintBackground = Paint()
      ..color = colorFundo
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()..addRect(Offset.zero & size);

    final rectangleBarCode = Path()
      ..addRect(
        Rect.fromLTWH(left, top, sizeBarcode.width, sizeBarcode.height),
      );

    final pathCombined = Path.combine(PathOperation.difference, backgroundPath, rectangleBarCode);
    canvas.drawPath(pathCombined, paintBackground);

    //cornerPath
    final borderTopLeft = Path()
      ..moveTo(left + strokeFactor, top + strokeFactor)
      ..lineTo(left + strokeFactor, top + cornerSize)
      ..moveTo(left + strokeFactor, top + strokeFactor)
      ..lineTo(left + strokeFactor + cornerSize, top + strokeFactor);

    final borderTopRight = Path()
      ..moveTo(right - strokeFactor, top + strokeFactor)
      ..lineTo(right - strokeFactor, top + cornerSize)
      ..moveTo(right - strokeFactor, top + strokeFactor)
      ..lineTo(right - strokeFactor - cornerSize, top + strokeFactor);

    final borderBottomLeft = Path()
      ..moveTo(left + strokeFactor, bottom - strokeFactor)
      ..lineTo(left + strokeFactor, bottom - cornerSize)
      ..moveTo(left + strokeFactor, bottom - strokeFactor)
      ..lineTo(left + strokeFactor + cornerSize, bottom - strokeFactor);

    final borderBottomRight = Path()
      ..moveTo(right - strokeFactor, bottom - strokeFactor)
      ..lineTo(right - strokeFactor, bottom - cornerSize)
      ..moveTo(right - strokeFactor, bottom - strokeFactor)
      ..lineTo(right - strokeFactor - cornerSize, bottom - strokeFactor);

    canvas.drawPath(borderTopLeft, paintCorners);
    canvas.drawPath(borderTopRight, paintCorners);
    canvas.drawPath(borderBottomLeft, paintCorners);
    canvas.drawPath(borderBottomRight, paintCorners);

    //line central
    final paintLine = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final lineCentralPath = Path()
      ..moveTo(barcodeWidth * 0.2, top + barcodeHeigth / 2)
      ..lineTo(barcodeWidth + barcodeWidth * 0.05, top + barcodeHeigth / 2);

    canvas.drawPath(lineCentralPath, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
