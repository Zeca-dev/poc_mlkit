import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CameraViewLayout extends StatefulWidget {
  const CameraViewLayout({
    super.key,
    required this.deviceOrientation,
  });

  final DeviceOrientation deviceOrientation;

  @override
  State<CameraViewLayout> createState() => _CameraViewLayoutState();
}

class _CameraViewLayoutState extends State<CameraViewLayout> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
