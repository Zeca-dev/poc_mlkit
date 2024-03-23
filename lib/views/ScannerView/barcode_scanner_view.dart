import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poc_mlkit/views/ScannerView/scanner_view_layout.dart';

class BarcodeScannerView extends ScannerViewLayout {
  const BarcodeScannerView({super.key, super.deviceOrientation = DeviceOrientation.landscapeRight});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
