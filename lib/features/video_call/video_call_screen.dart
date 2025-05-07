import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:phychological_counselor/features/video_call/call_manager.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final CallManager _callManager;

  @override
  void initState() {
    super.initState();
    _callManager = CallManager();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    print("Initializing call...");
    await _callManager.initialize();
    print("Joining channel...");
    // await _callManager.joinChannel('consultation_${DateTime.now().millisecondsSinceEpoch}');
    await _callManager.joinChannel('test_channel');
    print("Joined channel!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _remoteVideoView(),
          _localPreviewWithAvatar(),
          _callControls(),
        ],
      ),
    );
  }

  Widget _remoteVideoView() {
    if (_callManager.remoteUids.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _callManager.engine!,
        connection: RtcConnection(channelId: _callManager.currentChannel),
        canvas: VideoCanvas(uid: _callManager.remoteUids.first),
      ),
    );
  }

  Widget _localPreviewWithAvatar() {
    return Positioned(
      top: 40,
      right: 20,
      child: SizedBox(
        width: 120,
        height: 200,
        child: Stack(
          children: [
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _callManager.engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
            ModelViewer(
              backgroundColor: Colors.transparent,
              src: 'assets/avatars/avatar.glb',
              alt: 'A 3D model of an animated avatar',
              autoPlay: true, 
              autoRotate: true, 
              iosSrc: 'assets/avatars/avatar.glb',
              disableZoom: true,
              disablePan: true,
              disableTap: true,
              cameraOrbit: "0deg 90deg 0m",
              cameraTarget: "0m 1.5m 0m",
              fieldOfView: "15deg",
            ),
          ],
        ),
      ),
    );
  }

  Widget _callControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _callManager.endCall();
    super.dispose();
  }
}