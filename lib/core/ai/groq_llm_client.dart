import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'llm_client.dart';

class GroqLlmClient implements LlmClient {
  final String _modelName = 'llama-3.3-70b-versatile';
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  @override
  String get clientName => 'groq_$_modelName';

  @override
  Future<String> generate({
    required String systemPrompt,
    required String userInput,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY is not set in .env file');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _modelName,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userInput},
        ],
        // You can adjust temperature, max_tokens, etc. here if needed.
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Groq API failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (decoded.containsKey('choices') && (decoded['choices'] as List).isNotEmpty) {
      return decoded['choices'][0]['message']['content'] as String;
    }
    
    throw Exception('Unexpected Groq API response format: ${response.body}');
  }
}
