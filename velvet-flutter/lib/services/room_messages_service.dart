import 'package:supabase_flutter/supabase_flutter.dart';

class RoomMessage {
  final String id;
  final String userId;
  final String displayName;
  final String text;
  final DateTime createdAt;

  const RoomMessage({required this.id, required this.userId, required this.displayName, required this.text, required this.createdAt});

  factory RoomMessage.fromJson(Map<String, dynamic> json) => RoomMessage(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: (json['display_name'] as String?) ?? 'Velvet kullanıcısı',
    text: json['body'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class RoomMessagesService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<RoomMessage>> watch(String roomId) => _client
      .from('room_messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at')
      .limit(200)
      .map((rows) => rows.map(RoomMessage.fromJson).toList());

  Future<void> send({required String roomId, required String text}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı');
    final profile = await _client.from('profiles').select('display_name').eq('id', user.id).maybeSingle();
    await _client.from('room_messages').insert({
      'room_id': roomId,
      'user_id': user.id,
      'display_name': profile?['display_name'] ?? user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'Velvet kullanıcısı',
      'body': text.trim(),
    });
  }
}
