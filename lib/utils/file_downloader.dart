import 'dart:typed_data';

import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart';

/// Faz o download ou salvamento do arquivo em disco dependendo da plataforma.
void downloadPdf(Uint8List bytes, String filename) {
  downloadFileImpl(bytes, filename);
}
