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
    const colorFundo = Color(0xB3000000);
    return AppCameraPreview(
      onInit: (cameraController) {
        _cameraController = cameraController;
      },
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              color: colorFundo,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white70,
                    child: IconButton(
                        onPressed: () async {
                          final bytes = await _takePicture();
                          if (bytes != null) {
                            _onCapture(bytes);
                          }
                        },
                        icon: const Icon(Icons.camera_alt, size: 30)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _takePicture() async {
    await _cameraController?.startVideoRecording();
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
