import 'package:flutter/material.dart';
import 'dart:async';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  // Simulated AI response (you’ll connect real backend later)
  Future<String> _getAiResponse(String query) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate response delay

    // Basic mock AI logic — replace this with actual AI API call
    if (query.toLowerCase().contains("event")) {
      return "You can explore upcoming campus events under the Events section! 🎉";
    } else if (query.toLowerCase().contains("study")) {
      return "Try joining a Study Group — it’s a great way to connect with peers who share your goals 📚";
    } else if (query.toLowerCase().contains("career")) {
      return "Our Career Hub helps you discover internships and job opportunities 🌟";
    } else if (query.toLowerCase().contains("linkup")) {
      return "LinkUp connects students with shared goals, interests, and events 💞";
    } else if (query.toLowerCase().contains("help")) {
      return "I can help you with campus events, study groups, your profile, or LinkUp features 💡";
    } else {
      return "Hmm... I’m still learning that! Try asking about campus, study, events, or LinkUp. 🤔";
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, _Message(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    final reply = await _getAiResponse(text);

    setState(() {
      _messages.insert(0, _Message(text: reply, isUser: false));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F3),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('AI Chatbot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: msg.isUser
                          ? const LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent])
                          : const LinearGradient(colors: [Colors.white, Color(0xFFFFE4E9)]),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: msg.isUser ? const Radius.circular(18) : const Radius.circular(0),
                        bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Ask LinkUp AI anything...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.pinkAccent),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message({required this.text, required this.isUser});
}
