import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';


class ChatBotPage extends StatefulWidget {
  final String? initialMessage;

  const ChatBotPage({super.key, this.initialMessage});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<String> _chatHistory = [];
  String _response = '';
  bool _loading = false;

  Future<void> _sendQuestion() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add("User: $question"); // Show user's message immediately
      _controller.clear();
      _loading = true;
      // _response = '';
    });
    _scrollToBottom();

    try {
      final result = await askRagQuestion(question, _chatHistory);
      final answer = result['answer'];

      setState(() {
        _chatHistory.add("Bot: $answer");
        // _response = answer;
      });
        _scrollToBottom();
    } catch (e) {
      setState(() {
         _chatHistory.add("Bot: Error: $e");
        _response = "Error: $e";
        print(_response);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  @override
void initState() {
  super.initState();

  if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
    _sendInitialMessage(widget.initialMessage!);
    }
  }
  Future<void> _sendInitialMessage(String message) async {
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final result = await askRagQuestion(message, _chatHistory);
      final answer = result['answer'];

      setState(() {
        _chatHistory.add("Bot: $answer");
        _response = answer;
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
        print(_response);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }

  }
  void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with Bot"), backgroundColor: Colors.grey.shade100,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final isUser = _chatHistory[index].startsWith("User:");
                  final message = _chatHistory[index].replaceFirst(RegExp(r'^User: |^Bot: '), '');
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isUser
                        ? Text(message)
                        : MarkdownBody(
                            data: message,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(fontSize: 14),
                              strong: TextStyle(fontWeight: FontWeight.bold),
                              em: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),

                    ),
                  );
                },
              ),
            ),
           if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(width: 8),
                  Text("Bot is typing..."),
                ],
              ),
            ),

                SizedBox(height: 10),
            
            Stack(
              children: [
                TextField(
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade400.withOpacity(0.2),
                    filled: true,
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Ask a question...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  controller: _controller,
                ),
                Positioned(
                  right:8,
                  bottom: 7,

                  child:GestureDetector(
                    onTap: _loading ? null : _sendQuestion,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _loading ? Colors.grey : Colors.green.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const String apiUrl = "https://greenpathchat-62345034130.me-central1.run.app/ask";

Future<Map<String, dynamic>> askRagQuestion(String question, List<String> chatHistory) async {
  final headers = {
    "Content-Type": "application/json",
  };

  final body = jsonEncode({
    "question": question,
    "chat_history": chatHistory,
  });

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed: ${response.statusCode} - ${response.body}");
  }
}
