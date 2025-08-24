import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';

final class AppCameraPreview extends StatefulWidget {
  ///Essa abre a camera do dispositivo para a captura de uma imagem.
  ///
  const AppCameraPreview({super.key, required this.child, required this.onInit});

  ///Widget que será exibido na preview da câmera. Representa seu layout.
  ///
  final Widget child;

  ///Método executado na inicialização da camera.
  ///
  ///Retorna um CameraController [cameraController]
  ///
  final Function(CameraController cameraController) onInit;

  @override
  State<AppCameraPreview> createState() => _AppCameraPreviewState();
}

class _AppCameraPreviewState extends State<AppCameraPreview> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _initialize();
  }

  @override
  void dispose() {
    _stopCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: (_cameras.isEmpty || _controller == null || _controller?.value.isInitialized == false)
            ? Container()
            : SizedBox.expand(
                child: CameraPreview(_controller!, child: Center(child: widget.child)),
              ),
      ),
    );
  }

  Future<void> _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    if (!await _hasCamera()) {
      //TODO(zeca): mostrar mensagem de erro e só depois fechar
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
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

  Future<void> _startScamera() async {
    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      if (!_hasAutoFocus()) {
        //TODO(zeca): mostrar mensagem de erro e só depois fechar
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      widget.onInit(_controller!);
      _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

      setState(() {});
    });
  }

  Future<void> _stopCamera() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<bool> _hasCamera() async {
    return _cameras.isNotEmpty;
  }

  bool _hasAutoFocus() {
    return _controller?.value.focusMode == FocusMode.auto;
  }
}
