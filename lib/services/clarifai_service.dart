import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ClarifaiService {
  final String _apiKey = 'YOUR_CLARIFAI_API_KEY';
  final String _modelId = 'general-image-recognition';

  Future<List<String>> analyzeImageBytes(Uint8List imageBytes) async {
    if (_apiKey == 'YOUR_CLARIFAI_API_KEY') {
      debugPrint('Clarifai API key is not configured. Skipping live analysis.');
      return [];
    }

    final base64Image = base64Encode(imageBytes);
    final url = Uri.parse('https://api.clarifai.com/v2/models/$_modelId/outputs');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Key $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': [
            {
              'data': {
                'image': {'base64': base64Image},
              },
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to analyze image. Status code: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final outputs = data['outputs'] as List<dynamic>?;
      if (outputs == null || outputs.isEmpty) {
        return [];
      }

      final concepts = outputs.first['data']?['concepts'] as List<dynamic>?;
      if (concepts == null) {
        return [];
      }

      return concepts
          .map((concept) => concept['name'].toString().toLowerCase())
          .toList();
    } catch (error) {
      debugPrint('Error Clarifai: $error');
      return [];
    }
  }
}
