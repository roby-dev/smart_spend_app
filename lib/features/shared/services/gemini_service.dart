import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_spend_app/constants/api_keys.dart';

class GeminiService {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;

  GeminiService() {
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
    _textModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
        "Analiza esta imagen de un producto. Extrae el nombre del producto y el precio si es visible. "
        "Devuelve un JSON con el formato: {\"nombre\": \"Nombre del producto\", \"precio\": 0.0}. "
        "Si no encuentras el precio, pon 0.0. Solo devuelve el JSON, sin markdown.",
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return _parseResponse(response.text);
    } catch (e) {
      debugPrint('Error processing image: $e');
      return {'nombre': 'Error al procesar imagen', 'precio': 0.0};
    }
  }

  Future<Map<String, dynamic>> processText(String text) async {
    try {
      final prompt =
          "Analiza el siguiente texto de una compra por voz: '$text'. "
          "Extrae el nombre del producto y el precio. "
          "Devuelve un JSON con el formato: {\"nombre\": \"Nombre del producto\", \"precio\": 0.0}. "
          "Si no se menciona precio, pon 0.0. Solo devuelve el JSON, sin markdown.";

      final response = await _textModel.generateContent([Content.text(prompt)]);

      return _parseResponse(response.text);
    } catch (e) {
      debugPrint('Error processing text: $e');
      return {'nombre': 'Error al procesar texto', 'precio': 0.0};
    }
  }

  Map<String, dynamic> _parseResponse(String? responseText) {
    if (responseText == null) {
      return {'nombre': 'No se obtuvo respuesta', 'precio': 0.0};
    }

    try {
      // Clean up markdown code blocks if present
      String cleanText =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic> jsonResponse = jsonDecode(cleanText);
      return {
        'nombre': jsonResponse['nombre'] ?? 'Desconocido',
        'precio': (jsonResponse['precio'] is num)
            ? (jsonResponse['precio'] as num).toDouble()
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error parsing response: $e');
      return {'nombre': 'Error de lectura', 'precio': 0.0};
    }
  }
}
