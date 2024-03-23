import 'package:flutter/material.dart';
import 'package:poc_mlkit/views/ScannerView/scanner_type_enum.dart';
import 'package:poc_mlkit/views/camera/camera_view_layout.dart';

abstract class ScannerViewLayout extends CameraViewLayout {
  const ScannerViewLayout({
    super.key,
    required super.deviceOrientation,
    required this.scannerType,
  });

  final ScannerType scannerType;

  @override
  State<ScannerViewLayout> createState() => _ScannerViewLayoutState();
}

class _ScannerViewLayoutState extends State<ScannerViewLayout> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
