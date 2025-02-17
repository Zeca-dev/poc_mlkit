import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:poc_mlkit/views/scanner_view/qrcode_scanner_preview.dart';

///Essa classe define o um scanner de QRCodes.
///
class QrCodeScannerView extends StatefulWidget {
  const QrCodeScannerView({
    super.key,
    required this.onDetect,
  });

  ///Método que será executado quando houver a detecção de um QRCode.
  /// Retorna os dados do QRCode detectado.
  ///
  final Function(String) onDetect;

  @override
  State<QrCodeScannerView> createState() => _QrCodeScannerViewState();
}

class _QrCodeScannerViewState extends State<QrCodeScannerView> {
  BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return QrCodeScannerPreview(
      deviceOrientation: DeviceOrientation.portraitUp,
      onCaptureImage: _processImage,
      //
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _QRCodeCustomPaint(size: size),
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
                  const Icon(Icons.qr_code, color: Colors.white, size: 80),
                  const Text(
                    'Posicione o QRCode no\n quadro abaixo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, wordSpacing: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    _isBusy = true;

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final String? displayValue = barcode.displayValue;

          if (displayValue != null) {
            _canProcess = false;
            widget.onDetect.call(displayValue);
            if (mounted) {
              Navigator.pop(context);
            }
          }
        }
        _barcodeScanner.close();
      });
    } catch (error) {
      log(error.toString(), name: 'QrCodeScannerView._processImage()');
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class _QRCodeCustomPaint extends StatefulWidget {
  final Size size;
  const _QRCodeCustomPaint({required this.size});

  @override
  State<_QRCodeCustomPaint> createState() => _QRCodeCustomPaintState();
}

class _QRCodeCustomPaintState extends State<_QRCodeCustomPaint> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: _QRCodeScannerPainter(size: widget.size),
    );
  }
}

class _QRCodeScannerPainter extends CustomPainter {
  final Size size;

  _QRCodeScannerPainter({required this.size});

  final line = 70.0;

  @override
  void paint(Canvas canvas, Size size) {
    const colorFundo = Color(0xB3000000);
    const widthFactor = 0.60;
    const strokeWidth = 10.0;
    const strokeFactor = strokeWidth / 2;

    final sizeQR = Size(size.width * widthFactor, size.width * widthFactor);

    final paintBackground = Paint()
      ..color = colorFundo
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.fill;

    final paintCorners = Paint()
      ..color = Colors.red
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    //Posições do QRCode
    final left = size.width * (1.0 - widthFactor) / 2;
    final right = sizeQR.width + left;
    final top = size.height * 0.27;
    final bottom = top + sizeQR.height;

    final backgroundPath = Path()..addRect(Offset.zero & size);

    final rectangleQRCode = Path()
      ..addRect(
        Rect.fromLTWH(left, top, sizeQR.width, sizeQR.height),
      );

    final pathCombined = Path.combine(PathOperation.difference, backgroundPath, rectangleQRCode);
    canvas.drawPath(pathCombined, paintBackground);

    final borderTopLeft = Path()
      ..moveTo(left + strokeFactor, top + strokeFactor)
      ..lineTo(left + strokeFactor, top + line)
      ..moveTo(left + strokeFactor, top + strokeFactor)
      ..lineTo(left + strokeFactor + line, top + strokeFactor);

    final borderTopRight = Path()
      ..moveTo(right - strokeFactor, top + strokeFactor)
      ..lineTo(right - strokeFactor, top + line)
      ..moveTo(right - strokeFactor, top + strokeFactor)
      ..lineTo(right - strokeFactor - line, top + strokeFactor);

    final borderBottomLeft = Path()
      ..moveTo(left + strokeFactor, bottom - strokeFactor)
      ..lineTo(left + strokeFactor, bottom - line)
      ..moveTo(left + strokeFactor, bottom - strokeFactor)
      ..lineTo(left + strokeFactor + line, bottom - strokeFactor);

    final borderBottomRight = Path()
      ..moveTo(right - strokeFactor, bottom - strokeFactor)
      ..lineTo(right - strokeFactor, bottom - line)
      ..moveTo(right - strokeFactor, bottom - strokeFactor)
      ..lineTo(right - strokeFactor - line, bottom - strokeFactor);

    canvas.drawPath(borderTopLeft, paintCorners);
    canvas.drawPath(borderTopRight, paintCorners);
    canvas.drawPath(borderBottomLeft, paintCorners);
    canvas.drawPath(borderBottomRight, paintCorners);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
