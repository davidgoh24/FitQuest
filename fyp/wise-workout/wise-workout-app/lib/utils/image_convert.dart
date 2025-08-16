import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Converts a YUV420 CameraImage to JPEG bytes
Uint8List convertCameraImageToJpeg(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;

  final img.Image rgbImage = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * image.planes[0].bytesPerRow + x;

      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
      final int yVal = yPlane[yIndex];
      final int uVal = uPlane[uvIndex];
      final int vVal = vPlane[uvIndex];

      final double yf = yVal.toDouble();
      final double uf = uVal.toDouble() - 128.0;
      final double vf = vVal.toDouble() - 128.0;

      final int r = (yf + 1.402 * vf).round().clamp(0, 255);
      final int g = (yf - 0.344136 * uf - 0.714136 * vf).round().clamp(0, 255);
      final int b = (yf + 1.772 * uf).round().clamp(0, 255);

      rgbImage.setPixelRgb(x, y, r, g, b);
    }
  }

  return Uint8List.fromList(img.encodeJpg(rgbImage, quality: 85));
}
