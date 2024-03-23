import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScannerViewLayout extends StatefulWidget {
  const ScannerViewLayout({super.key, required this.deviceOrientation});

  final DeviceOrientation deviceOrientation;

  @override
  State<ScannerViewLayout> createState() => _ScannerViewLayoutState();
}

class _ScannerViewLayoutState extends State<ScannerViewLayout> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
