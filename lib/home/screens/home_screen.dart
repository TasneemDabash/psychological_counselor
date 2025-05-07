import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../../../data/services/gpt_service.dart';
import '../../../home/screens/home_screen.dart';
import '../../../main/navigation/routes/name.dart';
import '../../ai_chat/provider/chat_provider.dart';
import '../../ai_chat/widgets/build_message.dart';
import '../../ai_chat/widgets/chat_text_field.dart';
import '../../ai_chat/widgets/send_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage("user", message);

    setState(() {
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final response = await getGPTResponse(message, '23');
    if (response != null) {
      chatProvider.addMessage("gpt", response);
    }

    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
                icon: const Icon(Icons.video_call),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCall),
          ),
          // The text field
          Expanded(
            child: ChatTextField(controller: _controller, context: context),
          ),
          const SizedBox(width: 10),
          // The send button
          SendButton(
            path: 'send',
            onTap: () {
              if (_controller.text.isNotEmpty) {
                FocusScope.of(context).unfocus();
                _sendMessage(_controller.text);
              }
            },
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobileLayout = constraints.maxWidth < 600;

          if (isMobileLayout) {
            return Column(
              children: [
                SizedBox(height: 40.h,),
                SizedBox(
                  height: 250,
                  child: ModelViewer(
                    backgroundColor: Colors.white,
                    src: 'assets/avatars/avatar.glb',
                    alt: 'A 3D model of an avatar',
                    autoRotate: false,
                    iosSrc: 'assets/avatars/avatar.glb',
                    disableZoom: true,
                    disablePan: true,
                    disableTap: true,
                    cameraOrbit: "0deg 90deg 0m",
                    cameraTarget: "0m 1.5m 0m",
                    fieldOfView: "15deg",
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // The chat messages
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) =>
                              buildMessage(chatProvider.messages[index], context),
                        ),
                      ),
                      _buildInputField(),
                      SizedBox(height: 20.h),

                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: ModelViewer(
                        backgroundColor: Colors.white,
                        src: 'assets/avatars/avatar.glb',
                        alt: 'A 3D model of an avatar',
                        autoRotate: false,
                        iosSrc: 'assets/avatars/avatar.glb',
                        disableZoom: true,
                        disablePan: true,
                        disableTap: true,
                        cameraOrbit: "0deg 90deg 0m",
                        cameraTarget: "0m 1.5m 0m",
                        fieldOfView: "15deg",
                      ),
                    ),
                  ),
                ),
                // Right side: Chat column
                Expanded(
                  flex: 2,
                  child: Column(
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
                      SizedBox(height: 20.h),

                    ],
                  ),

                ),
              ],
            );
          }
        },
      ),
    );
  }
}
