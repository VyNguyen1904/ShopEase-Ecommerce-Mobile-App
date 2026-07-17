import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';

class ImageService {
  final Dio _dio = Dio();
  // Using public API key from FreeImage.host for demo
  static const String _apiKey = '6d207e02198a847aa98d0a2a901485a5';

  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      String base64Image = base64Encode(imageBytes);
      FormData formData = FormData.fromMap({
        "key": _apiKey,
        "action": "upload",
        "source": base64Image,
        "format": "json",
      });

      Response response = await _dio.post(
        "https://freeimage.host/api/1/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['image']['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
