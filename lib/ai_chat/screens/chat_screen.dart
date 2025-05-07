import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/services/gpt_service.dart';
import '../provider/chat_provider.dart';
import '../widgets/build_message.dart';
import '../widgets/chat_text_field.dart';
import '../widgets/scroller.dart';
import '../widgets/send_button.dart';
import '../../../main/navigation/routes/name.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;
  final ScrollController _scrollController =
      ScrollController(); // Add a ScrollController




  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the ScrollController

    super.dispose();
  }


  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.addMessage("user", message);
    setState(() {
      _isLoading = true;
    });

    _controller.clear();
    scrollToBottom(_scrollController);

    final response = await getGPTResponse(message,'23');

    if (response != null) {
      chatProvider.addMessage("gpt", response);
    }

    setState(() {
      _isLoading = false;
    });
    scrollToBottom(_scrollController);
  }

  Widget _buildInputField() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [

          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChatTextField(
                controller: _controller,
                context: context,
              ),
              SizedBox(width: 10.w),
              SendButton(
                path: 'send',
                onTap: () {
                  if (_controller.text.isNotEmpty) {
                    FocusScope.of(context).unfocus(); // Dismiss the keyboard
                    _sendMessage(_controller.text);
                  }
                },
                isLoading: _isLoading,
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCall),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) =>
                  buildMessage(chatProvider.messages[index], context),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

}
