import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:voicechatapplication/secrets.dart';

class OpenAIService {
  // Initialize conversation history with a greeting
  List<String> conversationHistory = [
    'Buddy: Hello! I\'m Buddy, your friendly AI companion. How can I assist you today?'
  ];

  // Method to check if the prompt is asking to generate art
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: openAIAPIKey, // apiKey is imported from secrets.dart
      );

      // Add user input to the conversation history
      conversationHistory.add('User: $prompt');

      // Pass the full conversation history as context
      final response = await model.generateContent(
        [
          Content.text(conversationHistory.join("\n")), // Include history as context
        ],
      );

      // Add assistant's response to the conversation history
      conversationHistory.add('Assistant: ${response.text}');

      print(response.text);
      return response.text.toString();
    } catch (e) {
      return 'Error: ${e.toString()}'; // Handle any unexpected errors
    }
  }
}
