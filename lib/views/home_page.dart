import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poc_mlkit/views/photo_view.dart/photo_view.dart';
import 'package:poc_mlkit/views/photo_view.dart/photo_view_layout.dart';
import 'package:poc_mlkit/views/scanner_view/barcode_scanner_view.dart';
import 'package:poc_mlkit/views/scanner_view/qrcode_scanner_view.dart';
import 'package:poc_mlkit/views/scanner_view/scanner_type_enum.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';
  Uint8List? _foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_foto != null) Image.memory(_foto!),
            const Text(
              'Código de barras:',
            ),
            Text(
              _result,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: ScannerType.QRCODE_SCANNER,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCodeScannerView(
                    onDetect: (result) {
                      setState(() {
                        _result = result;
                        log(_result);
                      });
                    },
                  ),
                ),
              );
            },
            tooltip: 'Open scanner',
            child: const Icon(Icons.qr_code),
          ),
          FloatingActionButton(
            heroTag: ScannerType.BARCODE_SCANNER,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerView(
                    deviceOrientation: DeviceOrientation.landscapeLeft,
                    onDetect: (result) {
                      setState(() {
                        _result = result;
                        log(_result);
                      });
                    },
                  ),
                ),
              );
            },
            tooltip: 'Open scanner',
            child: const Icon(Icons.barcode_reader),
          ),
          FloatingActionButton(
            heroTag: 'teste',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoCameraView(
                    photoViewLayout: Teste(
                      deviceOrientation: DeviceOrientation.portraitUp,
                      onCaptureImage: (p0) {
                        setState(() {
                          _foto = p0.bytes;
                          print(_foto);
                        });
                      },
                    ),
                  ),
                ),
              );
            },
            tooltip: 'Open scanner',
            child: const Icon(Icons.camera),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
