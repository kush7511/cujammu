import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CujChatbotSheet extends StatefulWidget {
  final String studentName;
  final String enrollmentNumber;

  const CujChatbotSheet({
    super.key,
    required this.studentName,
    required this.enrollmentNumber,
  });

  @override
  State<CujChatbotSheet> createState() => _CujChatbotSheetState();
}

class _CujChatbotSheetState extends State<CujChatbotSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hi, I am CUJ Assistant. Ask me anything about Central University of Jammu.",
      role: _MessageRole.assistant,
    ),
  ];

  final _CujAiChatService _chatService = _CujAiChatService();

  bool _isLoading = false;
  String? _conversationId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: userText, role: _MessageRole.user));
      _isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      // Create conversation document first time
      if (_conversationId == null) {
        final doc = await FirebaseFirestore.instance
            .collection('chat_conversations')
            .add({
          "studentName": widget.studentName,
          "enrollmentNumber": widget.enrollmentNumber,
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        });

        _conversationId = doc.id;
      }

      final reply = await _chatService.ask(
        _messages
            .where((m) => m.role != _MessageRole.system)
            .map((m) => _ChatTurn(role: m.role.name, text: m.text))
            .toList(),
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(text: reply, role: _MessageRole.assistant),
        );
      });

      final messagesRef = FirebaseFirestore.instance
          .collection('chat_conversations')
          .doc(_conversationId)
          .collection('messages');

      await messagesRef.add({
        "sender": "user",
        "text": userText,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await messagesRef.add({
        "sender": "bot",
        "text": reply,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('chat_conversations')
          .doc(_conversationId)
          .update({
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                "I could not fetch the answer right now. Please try again.",
            role: _MessageRole.system,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset(
                    "assets/images/CU_JAMMU-removebg-preview.png",
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.school, color: Color(0xFF003366)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "CUJ AI Agent",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Answers are limited to Central University of Jammu topics.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final message = _messages[index];
                  final isUser = message.role == _MessageRole.user;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints:
                          const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF003366)
                            : Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color:
                              isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText:
                          "Ask me anything about admissions, fees, courses...",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _MessageRole { user, assistant, system }

class _ChatMessage {
  final String text;
  final _MessageRole role;

  const _ChatMessage({required this.text, required this.role});
}

class _ChatTurn {
  final String role;
  final String text;

  const _ChatTurn({required this.role, required this.text});
}

class _CujAiChatService {
  static const String _apiKey =
      String.fromEnvironment("GEMINI_API_KEY");
  static const String _model = "gemini-1.5-flash";

  Future<String> ask(List<_ChatTurn> history) async {
    if (_apiKey.isEmpty) {
      throw Exception("GEMINI_API_KEY not provided.");
    }

    final uri = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$_apiKey",
    );

    final contents = history.map((turn) {
      return {
        "role": turn.role == "assistant" ? "model" : "user",
        "parts": [
          {"text": turn.text}
        ]
      };
    }).toList();

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "system_instruction": {
  "parts": [
    {
      "text":
          "You are CUJ AI Assistant for the Central University of Jammu (CUJ). "
          "Provide detailed, well-structured, and professional answers of at least 200-300 words. "
          "Start responses with a friendly and professional tone like: "
          "'Certainly! Here is a detailed explanation regarding your query:' or similar natural openings. "
          "Organize answers using short paragraphs and bullet points when helpful. "
          "Explain clearly and completely. "
          "Only answer questions related to Central University of Jammu (CUJ). "
          "Use official CUJ website information (https://www.cujammu.ac.in/) only. "
          "If asked anything outside CUJ topics, politely refuse and guide the user to check the official CUJ website.",
    },
  ],
},
"generationConfig": {
  "maxOutputTokens": 900,
  "temperature": 0.4,
  "topP": 0.9,
},}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "API Error ${response.statusCode}: ${response.body}");
    }

    final data = jsonDecode(response.body);

    return data["candidates"][0]["content"]["parts"][0]["text"]
        .toString()
        .trim();
  }
}