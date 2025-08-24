import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_view/app_camera_view.dart';
import 'scanner_view/barcode_scanner_view.dart';
import 'scanner_view/qrcode_scanner_view.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_foto != null) Image.memory(_foto!, height: 400, width: 400),
                const Text('Código de barras:'),
                Text(_result, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: 'qr_code',
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
              heroTag: 'barcode',
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarcodeScannerView(
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
              heroTag: 'camera',
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppCameraView(
                      onImageCapture: (inputImage) {
                        setState(() {
                          _foto = inputImage;

                          setState(() {});
                        });
                      },
                    ),
                  ),
                );
              },
              tooltip: 'Open scanner',
              child: const Icon(Icons.camera),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
