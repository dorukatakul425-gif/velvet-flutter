import 'package:supabase_flutter/supabase_flutter.dart';

class VelvetProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String bio;

  const VelvetProfile({required this.id, required this.displayName, this.avatarUrl, required this.bio});
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<VelvetProfile?> current() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row == null) return null;
    return VelvetProfile(id: row['id'], displayName: row['display_name'], avatarUrl: row['avatar_url'], bio: row['bio'] ?? '');
  }

  Future<void> update({required String displayName, required String bio, String? avatarUrl}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı');
    await _client.from('profiles').update({'display_name': displayName.trim(), 'bio': bio.trim(), 'avatar_url': avatarUrl}).eq('id', user.id);
  }
}
