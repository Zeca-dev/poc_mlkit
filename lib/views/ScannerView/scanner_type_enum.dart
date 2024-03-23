///Define o tipo de scanner.
///
/// [QRCODE_SCANNER, BARCODE_SCANNER]
enum ScannerType {
  ///Leitor de QRCode
  ///
  QRCODE_SCANNER(type: 'QRCODE_SCANNER'),

  ///Leitor de códigos de barra
  ///
  BARCODE_SCANNER(type: 'BARCODE_SCANNER');

  final String type;

  const ScannerType({required this.type});
}
