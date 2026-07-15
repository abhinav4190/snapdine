import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:staff_app/models/menu_item_model.dart';

class OcrServices {
  Future<List<MenuItemModel>> extractMenuFromImage(File imageFile) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found in .env');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    const prompt = '''
You extract structured menu data from photos of physical restaurant/cafe menus.
Return ONLY a JSON object with a single key "items", whose value is an array.
Each element: {"name": string, "price": number, "category": string, "description": string}.
Infer a sensible category (e.g. Beverages, Starters, Main Course, Desserts) if not explicit.
If description isn't printed on the menu, write one.
If a price is unreadable, skip that item entirely rather than guessing.
''';

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "response_format": {"type": "json_object"},
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
            }
          ]
        }
      ],
      "max_tokens": 2000,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI API error (${response.statusCode}): ${response.body}');
    }

    final decodedResponse = jsonDecode(response.body);
    final rawContent =
        decodedResponse['choices'][0]['message']['content'] as String? ?? '{}';

    final cleaned =
        rawContent.replaceAll('```json', '').replaceAll('```', '').trim();

    List<dynamic> parsed;
    try {
      final parsedJson = jsonDecode(cleaned);
      parsed = parsedJson is Map<String, dynamic>
          ? (parsedJson['items'] as List<dynamic>? ?? [])
          : parsedJson as List<dynamic>;
    } catch (_) {
      throw Exception('Could not parse menu from image. Try a clearer photo.');
    }

    return parsed.map((raw) {
      final map = raw as Map<String, dynamic>;
      return MenuItemModel(
        id: '',
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        category: map['category'] as String? ?? 'Uncategorized',
        description: map['description'] as String? ?? '',
        isAvailable: true,
        imageUrl: '',
      );
    }).toList();
  }

  // Future<List<MenuItemModel>> extractMenuFromImageGemini(File imageFile) async {
  //   final apiKey = dotenv.env['GEMINI_API_KEY'];
  //   final model = GenerativeModel(
  //     model: 'gemini-2.0-flash',
  //     apiKey: apiKey!,
  //     generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  //   );
  //
  //   final bytes = await imageFile.readAsBytes();
  //
  //   const prompt = '''
  //   You extract structured menu data from photos of physical restaurant/cafe menus.
  //   Return ONLY a JSON array, no prose, no markdown fences.
  //   Each element: {"name": string, "price": number, "category": string, "description": string}.
  //   Infer a sensible category (e.g. Beverages, Starters, Main Course, Desserts) if not explicit.
  //   If description isn't printed on the menu, write one.
  //   If a price is unreadable, skip that item entirely rather than guessing.
  //   ''';
  //
  //   final response = await model.generateContent([
  //     Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
  //   ]);
  //
  //   final raw = response.text ?? '[]';
  //   final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
  //
  //   List<dynamic> parsed;
  //   try {
  //     parsed = jsonDecode(cleaned) as List<dynamic>;
  //   } catch (_) {
  //     throw Exception('Could not parse menu from image. Try a clearer photo.');
  //   }
  //
  //   return parsed.map((raw) {
  //     final map = raw as Map<String, dynamic>;
  //     return MenuItemModel(
  //       id: '',
  //       name: map['name'] as String? ?? '',
  //       price: (map['price'] as num?)?.toDouble() ?? 0,
  //       category: map['category'] as String? ?? 'Uncategorized',
  //       description: map['description'] as String? ?? '',
  //       isAvailable: true,
  //       imageUrl: '',
  //     );
  //   }).toList();
  // }
}