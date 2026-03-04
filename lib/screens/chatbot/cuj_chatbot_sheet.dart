import 'dart:convert';

// ignore: depend_on_referenced_packages
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
      final reply = await _chatService.ask(
        _messages
            .where((m) => m.role != _MessageRole.system)
            .map((m) => _ChatTurn(role: m.role.name, text: m.text))
            .toList(),
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, role: _MessageRole.assistant));
      });

      // Best-effort persistence. AI reply should still work if Firestore fails.
      await _persistConversationTurn(userText: userText, botReply: reply);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: _chatService.userFacingError(e),
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

  Future<void> _persistConversationTurn({
    required String userText,
    required String botReply,
  }) async {
    try {
      if (_conversationId == null) {
        final doc = await FirebaseFirestore.instance
            .collection("chat_conversations")
            .add({
          "studentName": widget.studentName,
          "enrollmentNumber": widget.enrollmentNumber,
          "description":
          "Chat between ${widget.studentName} (${widget.enrollmentNumber}) and CUJ AI Assistant",
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        });
        _conversationId = doc.id;
      }

      final messagesRef = FirebaseFirestore.instance
          .collection("chat_conversations")
          .doc(_conversationId)
          .collection("messages");

      await messagesRef.add({
        "sender": "user",
        "text": userText,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await messagesRef.add({
        "sender": "bot",
        "text": botReply,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection("chat_conversations")
          .doc(_conversationId)
          .update({
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignore Firestore failures to keep chat functional.
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF003366)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
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
                        borderRadius: BorderRadius.circular(12),
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
  static const String _apiKeyFromDefine =
      String.fromEnvironment("GEMINI_API_KEY");

  static const List<String> _models = [
    "gemini-2.0-flash",
    "gemini-1.5-flash",
    "gemini-1.5-flash-latest",
  ];

  Future<String> ask(List<_ChatTurn> history) async {
    final apiKey = _apiKeyFromDefine.trim();

    if (apiKey.isEmpty) {
      throw Exception(
        "Gemini API key is not configured. Run/build with --dart-define=GEMINI_API_KEY=YOUR_KEY.",
      );
    }

    final contents = history.map((turn) {
      return {
        "role": turn.role == "assistant" ? "model" : "user",
        "parts": [
          {"text": turn.text}
        ]
      };
    }).toList();

    Exception? lastError;
    for (final model in _models) {
      try {
        final text = await _askWithModel(
          apiKey: apiKey,
          model: model,
          contents: contents,
        );
        if (text.isNotEmpty) return text;
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }

    throw lastError ?? Exception("No response from AI.");
  }

  Future<String> _askWithModel({
    required String apiKey,
    required String model,
    required List<Map<String, dynamic>> contents,
  }) async {
    final uri = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
    );

    final response = await http
        .post(
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
                      "'Certainly! Here is a detailed explanation regarding your query:' "
                      "Organize answers clearly using paragraphs and bullet points where required. "
                      "Only answer questions related to CUJ.",
                }
              ]
            },
            "generationConfig": {
              "maxOutputTokens": 800,
              "temperature": 0.5,
              "topP": 0.9,
            },
            "contents": contents,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      String errorMessage = "HTTP ${response.statusCode}";
      try {
        final error = jsonDecode(response.body);
        final apiMsg = error["error"]?["message"]?.toString();
        if (apiMsg != null && apiMsg.isNotEmpty) {
          errorMessage = "HTTP ${response.statusCode}: $apiMsg";
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);
    final candidates = data["candidates"];
    if (candidates is! List || candidates.isEmpty) {
      throw Exception("No response candidates returned by AI.");
    }

    final content = candidates.first["content"];
    if (content is! Map<String, dynamic>) {
      throw Exception("Invalid AI response content.");
    }

    final parts = content["parts"];
    if (parts is! List || parts.isEmpty) {
      throw Exception("AI returned empty response.");
    }

    final text = parts
        .whereType<Map>()
        .map((p) => p["text"]?.toString() ?? "")
        .where((t) => t.trim().isNotEmpty)
        .join("\n")
        .trim();

    if (text.isEmpty) {
      throw Exception("AI returned no text.");
    }
    return text;
  }

  String userFacingError(Object error) {
    final msg = error.toString();
    if (msg.contains("API key is not configured") ||
        msg.contains("API_KEY_INVALID")) {
      return "Chatbot is not configured with a valid AI key. Please contact support to set GEMINI_API_KEY.";
    }
    if (msg.contains("PERMISSION_DENIED")) {
      return "Chatbot permission is denied for this API key. Please verify Gemini API access.";
    }
    if (msg.contains("timed out")) {
      return "Chatbot request timed out. Please check internet and try again.";
    }
    return "I could not fetch the answer right now. Please try again.";
  }
}
