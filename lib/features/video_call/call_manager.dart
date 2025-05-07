import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  RtcEngine? _engine;
  String? _currentChannel;
  List<int> remoteUids = [];

  RtcEngine? get engine => _engine;
  String get currentChannel => _currentChannel ?? '';

  Future<void> initialize() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine?.initialize(
      RtcEngineContext(appId: dotenv.get('AGORA_APP_ID')),
    );

    await _engine?.enableVideo();
    await _engine?.setChannelProfile(ChannelProfileType.channelProfileCommunication);

    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user joined: $remoteUid");
          remoteUids.add(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          remoteUids.remove(remoteUid);
        },
      ),
    );
  }

  Future<void> joinChannel(String channelName) async {
    await [Permission.camera, Permission.microphone].request();
    await _engine?.joinChannel(
      token: dotenv.get('AGORA_TOKEN'),
      channelId: channelName,
      uid: 0, // Using 0 for auto-assignment or generate a specific ID
      options: const ChannelMediaOptions(),
    );
    _currentChannel = channelName;
  }

  Future<void> endCall() async {
    await _engine?.leaveChannel();
    remoteUids.clear();
    _currentChannel = null;
  }

  Future<String> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  Future<String> uploadRecording(String filePath) async {
    // Add Firebase logic if needed later
    return Future.value("upload_stub"); // Replace with actual logic
  }
}
