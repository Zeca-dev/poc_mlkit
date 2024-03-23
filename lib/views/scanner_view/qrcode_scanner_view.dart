import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_preview_app.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_type_enum.dart';

class QrCodeScannerView extends StatefulWidget {
  const QrCodeScannerView({
    super.key,
    required this.onDetect,
  });

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
    const colorFundo = Color(0xB3000000);
    return ScannerPreview(
      scannerType: ScannerType.QRCODE_SCANNER,
      deviceOrientation: DeviceOrientation.portraitUp,
      onCaptureImage: _processImage,
      //
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    //Lateral esquerda
                    Flexible(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(color: colorFundo),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          //Top
                          Flexible(
                            flex: 4,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(color: colorFundo),
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
                                      'Posicione o QRCode no\n quadro abaixo',
                                      strutStyle: StrutStyle(),
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          //Center - Scanner
                          Flexible(
                            flex: 3,
                            child: Container(
                              height: 220,
                              width: 220,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              // child: AppIcons.scan_helper.setColor(AppColors.principal_1).setSize(220, 220),
                              child: const _ScannerHelperView(size: 206),
                            ),
                          ),
                          //Bottom
                          Flexible(
                            flex: 6,
                            child: Container(
                              decoration: const BoxDecoration(color: colorFundo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Lateral direita
                    Flexible(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(color: colorFundo),
                      ),
                    ),
                  ],
                ),

                //
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
                )
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

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    try {
      await _barcodeScanner.processImage(inputImage).then((barcodes) {
        for (Barcode barcode in barcodes) {
          final String? displayValue = barcode.displayValue;

          if (displayValue != null) {
            _canProcess = false;
            widget.onDetect.call(displayValue);
            Navigator.pop(context);
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

class _ScannerHelperView extends StatefulWidget {
  final double size;
  const _ScannerHelperView({super.key, required this.size});

  @override
  State<_ScannerHelperView> createState() => _ScannerHelperViewState();
}

class _ScannerHelperViewState extends State<_ScannerHelperView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ScannerHelperPainter(size: widget.size),
      ),
    );
  }
}

class _ScannerHelperPainter extends CustomPainter {
  final double size;

  _ScannerHelperPainter({super.repaint, required this.size});

  final strokeWidth = 10.0;
  final line = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    canvas.drawPath(_createTopLeft(), paint);
    canvas.drawPath(_createTopRight(), paint);
    canvas.drawPath(_creatBottomRight(), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Path _createTopLeft() {
    return Path()
          ..moveTo(0, 0)
          ..lineTo(0, line)
          ..moveTo(0, 0)
          ..lineTo(line, 0)
//
        ;
  }

  Path _createTopRight() {
    return Path()
          ..moveTo(size - (line + strokeWidth), 0)
          ..lineTo(size - strokeWidth, 0)
          ..moveTo(size - strokeWidth, 0)
          ..lineTo(size - strokeWidth, line)
//
        ;
  }

  Path _creatBottomRight() {
    return Path()
          ..moveTo(size - strokeWidth, size - (strokeWidth + line))
          ..lineTo(size - strokeWidth, size - strokeWidth)
// ..moveTo(size.height - 5, size.height)
// ..lineTo(size.height - 5, line)
//
        ;
  }
}
