import 'package:flutter/material.dart';
import 'package:poc_mlkit/views/barcode_scanner_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
