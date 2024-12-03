import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voicechatapplication/feature_box.dart';
import 'package:voicechatapplication/openai_service.dart';
import 'package:voicechatapplication/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  final openAIService = OpenAIService();
  final TextEditingController textController = TextEditingController(); // Controller for TextField

  List<Map<String, String>> messages = [];
  String lastWords = '';
  bool hasStartedConversation = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    textController.dispose(); // Dispose of the TextEditingController
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy-Assistant'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!hasStartedConversation) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Pallete.assistantCircleColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/avatar.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "Good Morning! How can I assist you today?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontFamily: 'Schyler',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Here are a few features:',
                  style: TextStyle(
                    fontFamily: 'Schyler',
                    color: Pallete.mainFontColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: 'ChatGPT',
                  descriptionText: "A smarter way to stay organized and informed with ChatGPT.",
                ),
                FeatureBox(
                  color: Pallete.secondSuggestionBoxColor,
                  headerText: 'Voice Assistance',
                  descriptionText: "Interact with your assistant through voice commands for a hands-free experience.",
                ),
              ],
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Pallete.firstSuggestionBoxColor
                          : Pallete.secondSuggestionBoxColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isUser ? 15 : 0),
                        topRight: Radius.circular(isUser ? 0 : 15),
                        bottomLeft: const Radius.circular(15),
                        bottomRight: const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isUser
                            ? Pallete.mainFontColor
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    if (await speechToText.hasPermission && speechToText.isNotListening) {
                      await startListening();
                    } else if (speechToText.isListening) {
                      final userMessage = lastWords;
                      if (userMessage.isNotEmpty) {
                        setState(() {
                          messages.add({'role': 'user', 'content': userMessage});
                          hasStartedConversation = true;
                        });
                      }
                      final assistantMessage = await openAIService.isArtPromptAPI(userMessage);
                      setState(() {
                        messages.add({'role': 'assistant', 'content': assistantMessage});
                      });
                      await systemSpeak(assistantMessage);
                      await stopListening();
                    } else {
                      initSpeechToText();
                    }
                  },
                  child: const Icon(Icons.mic),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: textController,
                    onSubmitted: (text) async {
                      if (text.isNotEmpty) {
                        setState(() {
                          messages.add({'role': 'user', 'content': text});
                          hasStartedConversation = true;
                        });
                        final assistantMessage = await openAIService.isArtPromptAPI(text);
                        setState(() {
                          messages.add({'role': 'assistant', 'content': assistantMessage});
                        });
                        await systemSpeak(assistantMessage);
                        textController.clear(); // Clear the TextField
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
