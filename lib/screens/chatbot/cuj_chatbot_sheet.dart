import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CujChatbotSheet extends StatefulWidget {
  const CujChatbotSheet({super.key});

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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                "I could not fetch the answer right now. Check internet and AI key setup.",
            role: _MessageRole.system,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst("Exception: ", "")),
        ),
      );
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
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
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
                      hintText: "Ask me anything about admissions, fees, courses...",
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
  static const String _apiKey = String.fromEnvironment("GEMINI_API_KEY");
  static const String _apiBase = "https://generativelanguage.googleapis.com";
 static const List<String> _preferredModels = <String>[
  "gemini-1.5-flash",
];
  String? _resolvedModel;

  Future<String> ask(List<_ChatTurn> history) async {
    if (_apiKey.isEmpty) {
      return "Chatbot is not configured yet. Missing GEMINI_API_KEY at app startup. Build/run with --dart-define=GEMINI_API_KEY=YOUR_KEY.";
    }

    final model = await _resolveModel();

    final contents = history
        .map(
          (turn) => {
            "role": turn.role == "assistant" ? "model" : "user",
            "parts": [
              {"text": turn.text},
            ],
          },
        )
        .toList();

    var response = await _sendGenerateRequest(model: model, contents: contents);
    if (response.statusCode == 404) {
      final oldModel = model;
      _resolvedModel = null;
      final refreshedModel = await _resolveModel();
      if (refreshedModel != oldModel) {
        response = await _sendGenerateRequest(
          model: refreshedModel,
          contents: contents,
        );
      }
    }

    if (response.statusCode >= 400) {
      final serverMessage = _extractServerError(response.body);
      throw Exception(
        "AI request failed (${response.statusCode})${serverMessage == null ? "" : ": $serverMessage"}",
      );
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = jsonBody["candidates"];
    if (candidates is List) {
      for (final candidate in candidates) {
        if (candidate is Map<String, dynamic>) {
          final content = candidate["content"];
          if (content is Map<String, dynamic>) {
            final parts = content["parts"];
            if (parts is List) {
              for (final part in parts) {
                if (part is Map<String, dynamic>) {
                  final text = part["text"];
                  if (text is String && text.trim().isNotEmpty) {
                    return text.trim();
                  }
                }
              }
            }
          }
        }
      }
    }

    throw Exception("No response text returned by AI.");
  }

  Future<http.Response> _sendGenerateRequest({
    required String model,
    required List<Map<String, dynamic>> contents,
  }) {
    final apiUrl = "$_apiBase/v1beta/models/$model:generateContent?key=$_apiKey";
    return http
        .post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "system_instruction": {
              "parts": [
                {
                  "text":
                      "You are CUJ AI assistant for the Central University of Jammu (CUJ). Only answer questions related to CUJ. Use official CUJ website information (https://www.cujammu.ac.in/) only. If asked anything outside CUJ or if official CUJ website data is unavailable, politely refuse and ask the user to check the CUJ official website.",
                },
              ],
            },
            "generationConfig": {
              "maxOutputTokens": 350,
              "temperature": 0.3,
            },
            "contents": contents,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception(
            "AI request timed out. Please check mobile internet and try again.",
          ),
        );
  }

  Future<String> _resolveModel() async {
    if (_resolvedModel != null && _resolvedModel!.trim().isNotEmpty) {
      return _resolvedModel!;
    }

    final url = "$_apiBase/v1beta/models?key=$_apiKey";
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode < 400) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final models = body["models"];
        if (models is List) {
          final available = <String>{};
          for (final item in models) {
            if (item is! Map<String, dynamic>) continue;
            final name = item["name"];
            final methods = item["supportedGenerationMethods"];
            if (name is String && methods is List) {
              final supportsGenerate = methods.any(
                (m) => m is String && m == "generateContent",
              );
              if (supportsGenerate && name.startsWith("models/")) {
                available.add(name.replaceFirst("models/", ""));
              }
            }
          }

          for (final preferred in _preferredModels) {
            if (available.contains(preferred)) {
              _resolvedModel = preferred;
              return preferred;
            }
          }

          final firstGemini = available.where((m) => m.startsWith("gemini")).toList();
          if (firstGemini.isNotEmpty) {
            _resolvedModel = firstGemini.first;
            return firstGemini.first;
          }
        }
      }
    } catch (_) {
      // Fall back to preferred defaults below.
    }

    _resolvedModel = _preferredModels.first;
    return _resolvedModel!;
  }

  String? _extractServerError(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        final error = parsed["error"];
        if (error is Map<String, dynamic>) {
          final message = error["message"];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
