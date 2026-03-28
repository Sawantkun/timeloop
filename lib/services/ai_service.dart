import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class AiService {
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Suggests complementary skills for a user to learn next.
  Future<List<String>> suggestSkillsToLearn(
    List<String> currentSkills,
    List<String> availableSkills,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Suggest complementary skills. Return ONLY a JSON array of skill name strings. No markdown.',
            },
            {
              'role': 'user',
              'content':
                  'User knows: ${currentSkills.join(", ")}. '
                  'Available to learn: ${availableSkills.join(", ")}. '
                  'Suggest 3 skills to learn next.',
            },
          ],
          'max_tokens': 100,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            ((data['choices'] as List)[0]['message']['content'] as String)
                .trim()
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();
        return List<String>.from(jsonDecode(content) as List);
      }
    } catch (_) {}
    return availableSkills.take(3).toList();
  }

  /// Generates a friendly skill-swap proposal message.
  Future<String> generateSwapProposal({
    required String yourSkill,
    required String theirSkill,
    required String theirName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Write friendly skill-swap proposals. Keep it under 3 sentences.',
            },
            {
              'role': 'user',
              'content':
                  'Write a proposal to $theirName: I offer $yourSkill, I want $theirSkill.',
            },
          ],
          'max_tokens': 150,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ((data['choices'] as List)[0]['message']['content'] as String)
            .trim();
      }
    } catch (_) {}
    return "Hi $theirName! I'd love to swap my $yourSkill skills for your $theirSkill expertise. Let's connect!";
  }
}
