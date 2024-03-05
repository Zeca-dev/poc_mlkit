import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poc_mlkit/views/ScannerView/scanner_type_enum.dart';
import 'package:poc_mlkit/views/ScannerView/scanner_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';

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
            heroTag: ScannerType.QRCODE,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerView(
                    scannerType: ScannerType.QRCODE,
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
            heroTag: ScannerType.BARCODE,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerView(
                    scannerType: ScannerType.BARCODE,
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
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
