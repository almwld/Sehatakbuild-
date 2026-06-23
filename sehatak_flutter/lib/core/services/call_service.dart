import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:callwave_flutter/callwave_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  late RtcEngine _engine;
  bool _isInitialized = false;
  
  static const String AGORA_APP_ID = 'YOUR_AGORA_APP_ID_HERE';
  static const String TOKEN_SERVER_URL = 'https://your-token-server.com/access_token';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AGORA_APP_ID,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine.enableVideo();
    await _engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      dimensions: VideoDimensions(width: 640, height: 480),
      frameRate: FrameRate.fps15,
      bitrate: VideoBitrateStandard,
      orientationMode: OrientationMode.orientationModeAdaptive,
    ));

    CallwaveFlutter.instance.configure(
      CallwaveConfiguration(
        engine: _SehatakCallwaveEngine(),
        incomingCallHandling: const IncomingCallHandling.realtime(),
        androidManifestConfig: const AndroidManifestConfig(
          ringtoneAssetPath: 'assets/ringtones/call_ringtone.mp3',
          iconResId: 'mipmap/ic_launcher',
        ),
      ),
    );

    _isInitialized = true;
  }

  Future<void> startCall({
    required String doctorId,
    required String patientId,
    required String callType,
  }) async {
    final channelName = 'call_${doctorId}_${patientId}_${DateTime.now().millisecondsSinceEpoch}';
    final token = await _getToken(channelName);
    
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final userName = userData.data()?['name'] ?? 'مستخدم';

    final callData = CallData(
      callId: channelName,
      callerName: userName,
      handle: doctorId,
      extra: {
        'roomToken': token,
        'channelName': channelName,
        'callType': callType,
        'doctorId': doctorId,
        'patientId': patientId,
      },
    );

    await CallwaveFlutter.instance.startCall(callData);
    
    await FirebaseFirestore.instance.collection('calls').doc(channelName).set({
      'doctorId': doctorId,
      'patientId': patientId,
      'channelName': channelName,
      'callType': callType,
      'status': 'ringing',
      'startedAt': FieldValue.serverTimestamp(),
      'callerId': user?.uid,
    });
  }

  Future<void> answerCall(String callId) async {
    final session = CallwaveFlutter.instance.getSession(callId);
    if (session != null) {
      await CallwaveFlutter.instance.answerCall(callId);
      await FirebaseFirestore.instance.collection('calls').doc(callId).update({
        'status': 'connected',
        'answeredAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> endCall(String callId) async {
    await CallwaveFlutter.instance.endCall(callId);
    
    final callDoc = await FirebaseFirestore.instance.collection('calls').doc(callId).get();
    final startedAt = callDoc.data()?['startedAt'] as Timestamp?;
    int duration = 0;
    if (startedAt != null) {
      duration = DateTime.now().difference(startedAt.toDate()).inSeconds;
    }

    await FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
      'duration': duration,
    });
  }

  Future<void> rejectCall(String callId) async {
    await CallwaveFlutter.instance.endCall(callId);
    await FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'status': 'rejected',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _getToken(String channelName) async {
    try {
      final response = await http.get(
        Uri.parse('$TOKEN_SERVER_URL?channelName=$channelName'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting token: $e');
      return '';
    }
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> toggleMute() async {
    final isMuted = await _engine.isLocalAudioTrackMuted();
    if (isMuted) {
      await _engine.muteLocalAudioTrack(false);
    } else {
      await _engine.muteLocalAudioTrack(true);
    }
  }

  Future<void> toggleVideo() async {
    final isMuted = await _engine.isLocalVideoTrackMuted();
    if (isMuted) {
      await _engine.muteLocalVideoTrack(false);
    } else {
      await _engine.muteLocalVideoTrack(true);
    }
  }

  RtcEngine get engine => _engine;
}

class _SehatakCallwaveEngine extends CallwaveEngine {
  @override
  Future<void> onAnswerCall(CallSession session) async {
    final roomToken = session.callData.extra?['roomToken'];
    final channelName = session.callData.extra?['channelName'];
    final callType = session.callData.extra?['callType'];
    
    await CallService().engine.joinChannel(
      token: roomToken,
      channelId: channelName,
      options: ChannelMediaOptions(
        autoSubscribeVideo: callType == 'video',
        autoSubscribeAudio: true,
        publishCameraTrack: callType == 'video',
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
    
    await CallService().engine.setAudioProfile(
      AudioProfileType.speechStandard,
      AudioScenarioType.audioScenarioDefault,
    );
    
    session.reportConnected();
  }

  @override
  Future<void> onStartCall(CallSession session) async {
    await _joinChannel(session);
    session.reportConnected();
  }

  @override
  Future<void> onEndCall(CallSession session) async {
    await CallService().engine.leaveChannel();
  }

  Future<void> _joinChannel(CallSession session) async {
    final roomToken = session.callData.extra?['roomToken'];
    final channelName = session.callData.extra?['channelName'];
    final callType = session.callData.extra?['callType'];

    await CallService().engine.joinChannel(
      token: roomToken,
      channelId: channelName,
      options: ChannelMediaOptions(
        autoSubscribeVideo: callType == 'video',
        autoSubscribeAudio: true,
        publishCameraTrack: callType == 'video',
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }
}
