// ignore_for_file: constant_identifier_names

enum ScannerType {
  BARCODE(type: 'BARCODE'),
  QRCODE(type: 'QRCODE');

  final String type;

  const ScannerType({required this.type});
}
