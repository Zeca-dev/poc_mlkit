import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_camera_preview.dart';

class AppCameraView extends StatefulWidget {
  const AppCameraView({super.key, required this.onImageCapture});

  ///Método que será executado quando houver a captura de uma imagem.
  /// Retorna os bytes [Uint8List?] da imagem.
  ///
  final Function(Uint8List? image) onImageCapture;

  @override
  State<AppCameraView> createState() => _AppCameraViewState();
}

class _AppCameraViewState extends State<AppCameraView> {
  CameraController? _cameraController;
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCameraPreview(
      onInit: (cameraController) {
        _cameraController = cameraController;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                final bytes = await _takePicture();
                if (bytes != null) {
                  _onCapture(bytes);
                }
              },
              child: const Text('Teste')),
        ),
      ),
    );
  }

  Future<Uint8List?> _takePicture() async {
    final image = await _cameraController?.takePicture();
    if (image == null) {
      return null;
    }
    Uint8List bytes = await image.readAsBytes();
    return bytes;
  }

  Future<void> _onCapture(Uint8List? imaage) async {
    if (!_canProcess) return;
    if (_isBusy) return;

    if (imaage != null) {
      widget.onImageCapture.call(imaage);
      _isBusy = true;
      Navigator.pop(context);
    }

    try {
      _canProcess = false;
    } catch (error) {
      log(error.toString(), name: 'PhotoCameraView.onCapture()');
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
