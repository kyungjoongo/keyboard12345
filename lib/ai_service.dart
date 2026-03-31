import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> correctTypo(String input) async {
    if (input.trim().isEmpty) return input;

    const systemPrompt = '너는 국어 맞춤법 및 오타 교정 전문가야. 입력된 한국어 문장에서 오타와 맞춤법 실수를 찾아내어 자연스럽게 교정해줘. 다른 설명 없이 오직 교정된 결과 문장만 보내줘.';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return input;
      }
    } catch (e) {
      return input;
    }
  }
}
