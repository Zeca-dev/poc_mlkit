import 'package:flutter/material.dart';
import 'package:poc_mlkit/views/barcode_scanner_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _barCode = '';

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
              _barCode,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeScannerView(
                onDetectBarCode: (barcode) {
                  setState(() {
                    _barCode = barcode;
                    print(_barCode);
                  });
                },
              ),
            ),
          );
        },
        tooltip: 'Open scanner',
        child: const Icon(Icons.barcode_reader),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
