import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceMember {
  final String identity;
  final String name;
  final bool isSpeaking;
  final bool isMuted;
  final bool isLocal;

  const VoiceMember({required this.identity, required this.name, required this.isSpeaking, required this.isMuted, required this.isLocal});
}

class LiveAudioService extends ChangeNotifier {
  static const tokenEndpoint = String.fromEnvironment('LIVEKIT_TOKEN_ENDPOINT');
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  bool connected = false;
  bool connecting = false;
  bool microphoneEnabled = false;
  bool speakerEnabled = true;
  String? error;

  List<VoiceMember> get members {
    final room = _room;
    if (room == null) return const [];
    final result = <VoiceMember>[];
    final local = room.localParticipant;
    if (local != null) {
      result.add(VoiceMember(
        identity: local.identity,
        name: local.name.isNotEmpty ? local.name : local.identity,
        isSpeaking: local.isSpeaking,
        isMuted: !microphoneEnabled,
        isLocal: true,
      ));
    }
    for (final participant in room.remoteParticipants.values) {
      final hasLiveMic = participant.audioTrackPublications.any((publication) => publication.subscribed && !publication.muted);
      result.add(VoiceMember(
        identity: participant.identity,
        name: participant.name.isNotEmpty ? participant.name : participant.identity,
        isSpeaking: participant.isSpeaking,
        isMuted: !hasLiveMic,
        isLocal: false,
      ));
    }
    return result;
  }

  Future<void> connect({required String roomName, required String participantName}) async {
    if (connecting || connected) return;
    connecting = true;
    error = null;
    notifyListeners();
    try {
      if (tokenEndpoint.isEmpty) throw Exception('LIVEKIT_TOKEN_ENDPOINT tanımlanmamış');
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) throw Exception('Oturum bulunamadı');
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Authorization': 'Bearer ${session.accessToken}', 'Content-Type': 'application/json'},
        body: jsonEncode({'room_name': roomName, 'participant_name': participantName}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Oda bağlantısı reddedildi (${response.statusCode})');
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final serverUrl = payload['server_url'] as String?;
      final participantToken = payload['participant_token'] as String?;
      if (serverUrl == null || participantToken == null) throw Exception('Token yanıtı geçersiz');

      final room = Room(roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true));
      _listener = room.createListener()
        ..on<ParticipantConnectedEvent>((_) => notifyListeners())
        ..on<ParticipantDisconnectedEvent>((_) => notifyListeners())
        ..on<ActiveSpeakersChangedEvent>((_) => notifyListeners())
        ..on<TrackMutedEvent>((_) => notifyListeners())
        ..on<TrackUnmutedEvent>((_) => notifyListeners())
        ..on<RoomDisconnectedEvent>((_) {
          connected = false;
          microphoneEnabled = false;
          notifyListeners();
        });
      await room.connect(serverUrl, participantToken);
      _room = room;
      connected = true;
      await setSpeakerEnabled(true);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      await disconnect();
    } finally {
      connecting = false;
      notifyListeners();
    }
  }

  Future<bool> toggleMicrophone() async {
    final room = _room;
    if (room == null || !connected) return false;
    if (!microphoneEnabled) {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        error = 'Mikrofon izni verilmedi';
        notifyListeners();
        return false;
      }
    }
    microphoneEnabled = !microphoneEnabled;
    await room.localParticipant?.setMicrophoneEnabled(microphoneEnabled);
    notifyListeners();
    return true;
  }

  Future<void> setSpeakerEnabled(bool enabled) async {
    speakerEnabled = enabled;
    await Hardware.instance.setSpeakerphoneOn(enabled);
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _room?.disconnect();
    await _listener?.dispose();
    await _room?.dispose();
    _listener = null;
    _room = null;
    connected = false;
    microphoneEnabled = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
