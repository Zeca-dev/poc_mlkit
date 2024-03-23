import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:poc_mlkit/views/camera/camera_view_layout.dart';
import 'package:poc_mlkit/views/photo_view.dart/photo_view.dart';
import 'package:poc_mlkit/views/scanner_view/barcode_scanner_view.dart';

import '../scanner_view/qrcode_scanner_view.dart';

final class CameraPreviewApp extends StatefulWidget {
  const CameraPreviewApp({
    Key? key,
    required this.cameraViewLayout,
    required this.onCaptureImage,
  }) : super(key: key);

  final CameraViewLayout cameraViewLayout;
  final Function(InputImage inputImage) onCaptureImage;

  @override
  State<CameraPreviewApp> createState() => _CameraPreviewAppState();
}

class _CameraPreviewAppState extends State<CameraPreviewApp> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.back) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startScamera();
    }
  }

  @override
  void dispose() {
    _stopCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _cameraBody());
  }

  Widget _cameraBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();

    return SafeArea(
      child: SizedBox.expand(
        child: CameraPreview(
          _controller!,
          child: Center(
            child: switch (widget.cameraViewLayout.runtimeType) {
              QrCodeScannerView => OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  }
                  return widget.cameraViewLayout;
                }),
              BarcodeScannerView => OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    SystemChrome.setPreferredOrientations([widget.cameraViewLayout.deviceOrientation]);
                  }
                  return widget.cameraViewLayout;
                }),
              PhotoCameraView => widget.cameraViewLayout,
              _ => widget.cameraViewLayout
            },
          ),
        ),
      ),
    );
  }

  Future _startScamera() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      final cameraView = widget.cameraViewLayout;
      _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (cameraView is QrCodeScannerView) {
        _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      }
      if (cameraView is BarcodeScannerView) {
        switch (cameraView.deviceOrientation) {
          case DeviceOrientation.landscapeRight:
            _controller?.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
          default:
            _controller?.lockCaptureOrientation(DeviceOrientation.landscapeRight);
        }
      }

      // _controller?.startImageStream(_processCameraImage).then((value) {});
      _controller?.startImageStream(_processCameraImage).then((value) {});

      setState(() {});
    });
  }

  Future _stopCamera() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onCaptureImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
