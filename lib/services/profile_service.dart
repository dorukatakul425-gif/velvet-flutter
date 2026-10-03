// lib/services/profile_service.dart
// Velvet — Tam Supabase profil servisi
// Oxuma, yazma, avatar/cover yükləmə, real-time, online status

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/* ─────────────── Model ─────────────── */
class VelvetProfile {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? coverUrl;
  final String country;
  final int? age;
  final String? bio;
  final bool isOnline;
  final int wealthLevel;
  final int vipLevel;
  final int coinBalance;
  final DateTime createdAt;

  // Stats (profile_stats cədvəlindən JOIN)
  final int roomCount;
  final int visitorCount;
  final int followingCount;
  final int followerCount;

  // Nişanlar
  final List<String> badgeKeys;

  const VelvetProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.coverUrl,
    this.country = 'Azərbaycan',
    this.age,
    this.bio,
    this.isOnline = false,
    this.wealthLevel = 1,
    this.vipLevel = 0,
    this.coinBalance = 0,
    required this.createdAt,
    this.roomCount = 0,
    this.visitorCount = 0,
    this.followingCount = 0,
    this.followerCount = 0,
    this.badgeKeys = const [],
  });

  factory VelvetProfile.fromMap(Map<String, dynamic> m) {
    final stats = m['profile_stats'] as Map<String, dynamic>?;
    final badges = (m['profile_badges'] as List<dynamic>?)
            ?.map((b) => b['badge_key'] as String)
            .toList() ??
        [];
    return VelvetProfile(
      id: m['id'] as String,
      username: m['username'] as String? ?? '',
      displayName: m['display_name'] as String? ?? 'Velvet istifadəçisi',
      avatarUrl: m['avatar_url'] as String?,
      coverUrl: m['cover_url'] as String?,
      country: m['country'] as String? ?? 'Azərbaycan',
      age: m['age'] as int?,
      bio: m['bio'] as String?,
      isOnline: m['is_online'] as bool? ?? false,
      wealthLevel: m['wealth_level'] as int? ?? 1,
      vipLevel: m['vip_level'] as int? ?? 0,
      coinBalance: m['coin_balance'] as int? ?? 0,
      createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      roomCount: stats?['room_count'] as int? ?? 0,
      visitorCount: stats?['visitor_count'] as int? ?? 0,
      followingCount: stats?['following_count'] as int? ?? 0,
      followerCount: stats?['follower_count'] as int? ?? 0,
      badgeKeys: badges,
    );
  }

  VelvetProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? coverUrl,
    String? country,
    int? age,
    String? bio,
    bool? isOnline,
    int? wealthLevel,
    int? vipLevel,
    int? coinBalance,
    int? roomCount,
    int? visitorCount,
    int? followingCount,
    int? followerCount,
    List<String>? badgeKeys,
  }) =>
      VelvetProfile(
        id: id,
        username: username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        country: country ?? this.country,
        age: age ?? this.age,
        bio: bio ?? this.bio,
        isOnline: isOnline ?? this.isOnline,
        wealthLevel: wealthLevel ?? this.wealthLevel,
        vipLevel: vipLevel ?? this.vipLevel,
        coinBalance: coinBalance ?? this.coinBalance,
        createdAt: createdAt,
        roomCount: roomCount ?? this.roomCount,
        visitorCount: visitorCount ?? this.visitorCount,
        followingCount: followingCount ?? this.followingCount,
        followerCount: followerCount ?? this.followerCount,
        badgeKeys: badgeKeys ?? this.badgeKeys,
      );

  /// Neçə gündür Velvet-dədir
  int get daysOnVelvet => DateTime.now().difference(createdAt).inDays + 1;

  /// Wealth level etiketi
  String get wealthLabel => 'Sv.$wealthLevel';
}

/* ─────────────── Servis ─────────────── */
class ProfileService {
  static final ProfileService _i = ProfileService._();
  factory ProfileService() => _i;
  ProfileService._();

  final SupabaseClient _sb = Supabase.instance.client;

  // Profil dəyişikliklərini dinləyənlər üçün ValueNotifier
  final ValueNotifier<VelvetProfile?> current = ValueNotifier(null);

  RealtimeChannel? _channel;

  /* ── Cari istifadəçinin profilini yüklə ── */
  Future<VelvetProfile?> loadCurrent() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final row = await _sb
          .from('profiles')
          .select('*, profile_stats(*), profile_badges(badge_key)')
          .eq('id', uid)
          .single();
      final p = VelvetProfile.fromMap(row);
      current.value = p;
      _subscribeRealtime(uid);
      await _setOnline(true);
      return p;
    } catch (e) {
      debugPrint('[ProfileService] loadCurrent error: $e');
      return null;
    }
  }

  /* ── İstənilən istifadəçinin profilini oxu (ziyarətçi görünüşü) ── */
  Future<VelvetProfile?> loadById(String uid) async {
    try {
      final row = await _sb
          .from('profiles')
          .select('*, profile_stats(*), profile_badges(badge_key)')
          .eq('id', uid)
          .single();
      return VelvetProfile.fromMap(row);
    } catch (e) {
      debugPrint('[ProfileService] loadById error: $e');
      return null;
    }
  }

  /* ── Profil məlumatlarını yenilə ── */
  Future<void> updateProfile({
    String? displayName,
    String? country,
    int? age,
    String? bio,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception('Oturum yoxdur');

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName.trim();
    if (country != null) updates['country'] = country;
    if (age != null) updates['age'] = age;
    if (bio != null) updates['bio'] = bio.trim();

    await _sb.from('profiles').update(updates).eq('id', uid);

    // Lokal vəziyyəti dərhal yenilə
    if (current.value != null) {
      current.value = current.value!.copyWith(
        displayName: displayName,
        country: country,
        age: age,
        bio: bio,
      );
    }
  }

  /* ── Avatar yüklə → Supabase Storage ── */
  Future<String?> uploadAvatar(File file) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final path = '$uid/avatar.$ext';
      await _sb.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final url = _sb.storage.from('avatars').getPublicUrl(path);
      // Cache buster
      final publicUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      await _sb.from('profiles').update({'avatar_url': publicUrl}).eq('id', uid);
      if (current.value != null) {
        current.value = current.value!.copyWith(avatarUrl: publicUrl);
      }
      return publicUrl;
    } catch (e) {
      debugPrint('[ProfileService] uploadAvatar error: $e');
      return null;
    }
  }

  /* ── Arxa fon (cover) yüklə → Supabase Storage ── */
  Future<String?> uploadCover(File file) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final path = '$uid/cover.$ext';
      await _sb.storage.from('covers').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final url = _sb.storage.from('covers').getPublicUrl(path);
      final publicUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      await _sb.from('profiles').update({'cover_url': publicUrl}).eq('id', uid);
      if (current.value != null) {
        current.value = current.value!.copyWith(coverUrl: publicUrl);
      }
      return publicUrl;
    } catch (e) {
      debugPrint('[ProfileService] uploadCover error: $e');
      return null;
    }
  }

  /* ── Online status ── */
  Future<void> _setOnline(bool val) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _sb.from('profiles').update({'is_online': val}).eq('id', uid);
    } catch (_) {}
  }

  /* ── App bağlananda offline yaz ── */
  Future<void> goOffline() async {
    await _setOnline(false);
    _channel?.unsubscribe();
    _channel = null;
  }

  /* ── Realtime: profil dəyişikliklərini dinlə ── */
  void _subscribeRealtime(String uid) {
    _channel?.unsubscribe();
    _channel = _sb
        .channel('profile_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: uid,
          ),
          callback: (payload) {
            final updated = payload.newRecord;
            if (current.value != null && updated.isNotEmpty) {
              current.value = current.value!.copyWith(
                displayName: updated['display_name'] as String?,
                isOnline: updated['is_online'] as bool?,
                coinBalance: updated['coin_balance'] as int?,
                wealthLevel: updated['wealth_level'] as int?,
                vipLevel: updated['vip_level'] as int?,
                coverUrl: updated['cover_url'] as String?,
                avatarUrl: updated['avatar_url'] as String?,
              );
            }
          },
        )
        .subscribe();
  }

  /* ── Follow / Unfollow ── */
  Future<void> follow(String targetId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null || uid == targetId) return;
    try {
      await _sb.from('follows').insert({
        'follower_id': uid,
        'following_id': targetId,
      });
      if (current.value != null) {
        current.value = current.value!.copyWith(
          followingCount: current.value!.followingCount + 1,
        );
      }
    } catch (_) {}
  }

  Future<void> unfollow(String targetId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _sb
          .from('follows')
          .delete()
          .eq('follower_id', uid)
          .eq('following_id', targetId);
      if (current.value != null) {
        current.value = current.value!.copyWith(
          followingCount: (current.value!.followingCount - 1).clamp(0, 999999),
        );
      }
    } catch (_) {}
  }

  Future<bool> isFollowing(String targetId) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final row = await _sb
          .from('follows')
          .select('follower_id')
          .eq('follower_id', uid)
          .eq('following_id', targetId)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }
}
