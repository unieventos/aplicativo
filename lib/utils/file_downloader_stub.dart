import 'dart:typed_data';

/// Implementação padrão para Desktop/Mobile (requer path_provider, etc. se for necessário no futuro).
void downloadFileImpl(Uint8List bytes, String filename) {
  // Apenas informamos no log. Para suportar Android/iOS/Linux seria necessário salvar com dart:io e abrir.
  print('Download automático de PDF não suportado nesta plataforma sem bibliotecas nativas adicionais. Arquivo: $filename');
}
