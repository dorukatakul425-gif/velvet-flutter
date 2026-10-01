// Velvet — Otaq ekranı (premium Flutter versiyası)
// İstifadə: flutter create velvet_app → lib/main.dart faylını bununla əvəz et → flutter run
// Şəkillər saytdan yüklənir. Əlavə paket lazım deyil.

import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/live_audio_service.dart';
import 'services/room_messages_service.dart';

const kImg = 'https://xx-jade.vercel.app/images/images';
const kBg = Color(0xFF07000F);
const kPurple = Color(0xFF7B2FF7);
const kPink = Color(0xFFFF3EA5);
const kLilac = Color(0xFFC9A6FF);
const kGreen = Color(0xFF22C55E);
const kGold = Color(0xFFFFCF5A);

/* ───────────────────────── MODELLƏR ───────────────────────── */
class Seat {
  final String name;
  final Color color;
  bool speaking, muted;
  Seat(this.name, this.color, {this.speaking = false, this.muted = false});
}

class ChatMsg {
  final String name, text;
  final Color color;
  final bool me;
  ChatMsg(this.name, this.text, this.color, {this.me = false});
}

class Gift {
  final String id, name, iconAsset, videoAsset;
  final int price;
  const Gift(this.id, this.name, this.iconAsset, this.videoAsset, this.price);
}

const kPalette = [
  Color(0xFF7F77DD), Color(0xFFD4537E), Color(0xFF378ADD), Color(0xFF1D9E75),
  Color(0xFFEF9F27), Color(0xFFE24B4A), Color(0xFF639922), Color(0xFF534AB7),
  Color(0xFFD85A30), Color(0xFF0F6E56), Color(0xFF993556),
];

/* ───────────────────────── OTAQ EKRANI ───────────────────────── */
class RoomScreen extends StatefulWidget {
  final String myName;
  const RoomScreen({super.key, required this.myName});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  final _seats = List<Seat?>.filled(24, null);
  final _msgs = <ChatMsg>[];
  final _audio = LiveAudioService();
  final _messageService = RoomMessagesService();
  StreamSubscription<List<RoomMessage>>? _messageSub;
  static const _roomId = 'velvet-main';
  bool _muted = true;
  bool _speakerOn = true;
  bool _menuOpen = false;
  bool _shared = false;
  int _jeton = 10000;
  Gift? _playing;
  int _giftRun = 0;
  void _finishGift(int run) {
    if (mounted && run == _giftRun) setState(() => _playing = null);
  }

  @override
  void initState() {
    super.initState();
    _audio.addListener(_syncParticipants);
    _audio.connect(roomName: _roomId, participantName: widget.myName);
    _messageSub = _messageService.watch(_roomId).listen((items) {
      if (!mounted) return;
      setState(() {
        _msgs
          ..clear()
          ..addAll(items.map((m) => ChatMsg(m.displayName, m.text, kPalette[m.userId.hashCode.abs() % kPalette.length], me: m.displayName == widget.myName)));
      });
    });
  }

  @override
  void dispose() { _messageSub?.cancel(); _audio.removeListener(_syncParticipants); _audio.dispose(); super.dispose(); }

  int get _mySeat => _seats.indexWhere((s) => s?.name == widget.myName);
  int get _people => _seats.where((s) => s != null).length;

  void _sit(int i) {
    HapticFeedback.lightImpact();
    setState(() {
      final m = _mySeat;
      if (m >= 0) _seats[m] = null;
      _muted = false;
      _seats[i] = Seat(widget.myName, kPurple, speaking: true);
    });
  }

  void _leaveSeat() => setState(() { final m = _mySeat; if (m >= 0) _seats[m] = null; _muted = true; });

  void _syncParticipants() {
    if (!mounted) return;
    final people = _audio.members;
    setState(() {
      _seats.fillRange(0, _seats.length, null);
      for (var i = 0; i < people.length && i < _seats.length; i++) {
        final p = people[i];
        _seats[i] = Seat(p.name, kPalette[p.identity.hashCode.abs() % kPalette.length], speaking: p.isSpeaking, muted: p.isMuted);
      }
      _muted = !_audio.microphoneEnabled;
      _speakerOn = _audio.speakerEnabled;
    });
  }

  Future<void> _toggleMic() async {
    HapticFeedback.selectionClick();
    final ok = await _audio.toggleMicrophone();
    if (!ok && mounted && _audio.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_audio.error!)));
    }
  }

  Future<void> _toggleSpeaker() async {
    await _audio.setSpeakerEnabled(!_speakerOn);
  }

  Future<void> _share() async {
    await Clipboard.setData(const ClipboardData(text: 'https://xx-jade.vercel.app'));
    HapticFeedback.lightImpact();
    setState(() => _shared = true);
    Future.delayed(const Duration(milliseconds: 1200), () { if (mounted) setState(() => _shared = false); });
  }

  Future<void> _leave() async { await _audio.disconnect(); if (mounted) Navigator.maybePop(context); }

  void _openSeatProfile(int i) {
    final s = _seats[i]!;
    final mine = s.name == widget.myName;
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.55),
      builder: (_) => Container(
        margin: const EdgeInsets.only(top: 44),
        padding: EdgeInsets.fromLTRB(20, 0, 20, math.max(24, MediaQuery.of(context).padding.bottom + 10)),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2346), Color(0xFF16122A)]),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(offset: const Offset(0, -44), child: Avatar(name: s.name, color: s.color, size: 88, border: Colors.white)),
          Transform.translate(offset: const Offset(0, -34), child: Column(children: [
            Text(s.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('ID: ${10000000 + i * 7919} · ${s.muted ? "🔇 Sessiz" : "🎙️ Danışır"}', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.65))),
            const SizedBox(height: 16),
            if (mine) Row(children: [
              Expanded(child: _SheetBtn(label: _muted ? 'Mikrofonu aç' : 'Mikrofonu bağla', filled: true, onTap: () { Navigator.pop(context); _toggleMic(); })),
              const SizedBox(width: 10),
              Expanded(child: _SheetBtn(label: 'Oturacaqdan qalx', filled: false, onTap: () { Navigator.pop(context); _leaveSeat(); })),
            ]) else _SheetBtn(label: 'Bağla', filled: true, onTap: () => Navigator.pop(context)),
          ])),
        ]),
      ),
    );
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.35),
      builder: (_) => _ChatSheet(msgs: _msgs, myName: widget.myName, onSend: (t) async { try { await _messageService.send(roomId: _roomId, text: t); } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj göndərilmədi'))); } }),
    );
  }

  void _openGifts() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.4),
      builder: (_) => GiftSheet(
        jeton: _jeton,
        people: _audio.members.map((member) => member.name).toList(),
        onSend: (gift, qty, to) {
          final cost = gift.price * qty;
          if (_jeton < cost) return false;
          setState(() {
            _jeton -= cost;
            _msgs.add(ChatMsg(widget.myName, '🎁 $to ${gift.name} ×$qty göndərdi', kPurple, me: true));
            _playing = gift;
            _giftRun++;
          });
          HapticFeedback.heavyImpact();
          return true;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Android naviqasiya düymələri və iPhone ev xətti üçün real alt boşluq
    final safeBottom = math.max(mq.viewPadding.bottom, mq.padding.bottom);
    final barBottom = safeBottom + 8;
    const barH = 42.0;
    return Scaffold(
      backgroundColor: const Color(0xFF120C65),
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        // Otaq fonu
        Positioned.fill(child: Image.network('$kImg/velvet-room-bg.JPG', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3B2A9E), Color(0xFF120C65)]))))),
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40180F69), Color(0x80100847)])))),

        // Tək ekran — sürüşdürmə yoxdur, hər şey ekrana sığır
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, barBottom + barH + 10),
            child: Column(children: [
              _Entrance(child: _header()),
              const SizedBox(height: 10),
              _Entrance(delay: 60, child: _rankRow()),
              const SizedBox(height: 12),
              Expanded(child: LayoutBuilder(builder: (context, box) {
                // Oturacaq sırasının hündürlüyünü ekrana görə hesabla
                final cellW = box.maxWidth / 6;
                final rowH = math.min(cellW / .74, (box.maxHeight * .62 - 3 * 6) / 4).clamp(44.0, 90.0);
                return Column(children: [
                  SizedBox(
                    height: rowH * 4 + 3 * 6,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 24,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 6, mainAxisExtent: rowH),
                      itemBuilder: (_, i) => _Entrance(delay: 90 + 15 * i, child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SeatTile(
                          index: i, seat: _seats[i], isMe: _seats[i]?.name == widget.myName,
                          onTap: () => _seats[i] != null ? _openSeatProfile(i) : _sit(i),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Entrance(delay: 420, child: _audience()),
                  const SizedBox(height: 8),
                  Flexible(child: _Entrance(delay: 480, child: Align(
                    alignment: Alignment.topLeft,
                    child: FractionallySizedBox(
                      widthFactor: .8,
                      child: _DarkBox(child: const Text(
                        'Söhbət otağına xoş gəldiniz! Zəhmət olmasa söhbətlərdə hörmətli olun. Yetkinlik yaşına çatmayanların yayımı və onları riskə atan paylaşımlar qəti qadağandır. Açıq-saçıq məzmun, qumar, dələduzluq, təhqir, istismar, hədə və digər qayda pozuntuları cəzalandırılır. Pozuntunu görsəniz, bildirin.',
                        maxLines: 4, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF31EF9B)),
                      )),
                    ),
                  ))),
                  const SizedBox(height: 6),
                  _Entrance(delay: 520, child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: .8,
                      child: _DarkBox(opacity: .58, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), child: Row(children: [
                        const Expanded(child: Text('Daha çox adam qoşulsun deyə otağı paylaşın', maxLines: 2, style: TextStyle(fontSize: 12.5, color: Color(0xFF31EF9B)))),
                        const SizedBox(width: 6),
                        Pressable(onTap: _share, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const LinearGradient(colors: [Color(0xFF8F64FF), Color(0xFFD85CFF)])),
                          child: Text(_shared ? 'Kopyalandı' : 'Paylaş', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        )),
                      ])),
                    ),
                  )),
                ]);
              })),
            ]),
          ),
        ),

        // Video otağın tamamı boyunca göstərilir; idarəetmə düymələrinə toxunulmur.
        if (_playing != null)
          Positioned.fill(child: IgnorePointer(child: GiftBurst(
            key: ValueKey(_giftRun), gift: _playing!,
            onFinished: () => _finishGift(_giftRun),
          ))),

        // Sağ altda — hədiyyə ikonunun üstündə iki GIF (alt-alta)
        Positioned(
          right: 6,
          bottom: barBottom + barH + 12,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Pressable(onTap: _openGifts, child: Image.asset('assets/gifts/odul-hediye-guclu-v3.gif', width: 58, height: 58, fit: BoxFit.contain, gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const SizedBox(width: 58, height: 58))),
            const SizedBox(height: 6),
            Pressable(onTap: () => _soon('Xəzinə tezliklə'), child: Image.asset('assets/gifts/hazine-guclu-v3.gif', width: 58, height: 58, fit: BoxFit.contain, gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const SizedBox(width: 58, height: 58))),
          ]),
        ),

        // Alt panel — sistem düymələrinin üstündə
        Positioned(left: 12, right: 6, bottom: barBottom, child: _bottomBar()),

        // Otaq menyusu
        IgnorePointer(
          ignoring: !_menuOpen,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _menuOpen ? 1 : 0,
            child: GestureDetector(
              onTap: () => setState(() => _menuOpen = false),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: const Color(0x61080818),
                  padding: EdgeInsets.fromLTRB(14, mq.padding.top + 64, 14, 0),
                  alignment: Alignment.topCenter,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    offset: _menuOpen ? Offset.zero : const Offset(0, -.15),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 16, top: 6),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.14)))),
                      child: Row(children: [
                        _MenuCircle(icon: Icons.power_settings_new_rounded, label: 'Çıxış et', onTap: _leave),
                        _MenuCircle(icon: Icons.person_add_alt_1_rounded, label: 'Dəvət et', onTap: () { _share(); setState(() => _menuOpen = false); }),
                        _MenuCircle(icon: Icons.close_fullscreen_rounded, label: 'Kiçilt', onTap: _leave),
                        _MenuCircle(icon: Icons.meeting_room_outlined, label: 'Otaq dəyiş', onTap: _leave),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  static const _exitSvg = """
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF"/>
      <stop offset="1" stop-color="#FFE3E8"/>
    </linearGradient>
  </defs>
  <path d="M12 3.4v7.8" fill="none" stroke="url(#g)" stroke-width="2.4" stroke-linecap="round"/>
  <path d="M7.05 6.35a7.6 7.6 0 1 0 9.9 0" fill="none" stroke="url(#g)" stroke-width="2.4" stroke-linecap="round"/>
</svg>""";

  Widget _header() => Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(.88), width: 3),
            gradient: const LinearGradient(colors: [Color(0xFFFFC5DF), Color(0xFF8B72FF)]),
            boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 12, offset: Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: const Text('V', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Velvet otağı', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, shadows: [Shadow(color: Color(0x66000000), blurRadius: 3)])),
          SizedBox(height: 3),
          Text('ID: 10136161', style: TextStyle(fontSize: 14, color: Color(0xB8FFFFFF))),
        ])),
        const Icon(Icons.workspace_premium_rounded, size: 31, color: Color(0xFFFFD64A), shadows: [Shadow(color: Color(0x59000000), blurRadius: 5)]),
        const SizedBox(width: 10),
        Pressable(onTap: () => HapticFeedback.selectionClick(), child: const Padding(padding: EdgeInsets.all(3), child: Icon(Icons.more_horiz_rounded, size: 30))),
        const SizedBox(width: 10),
        // Çıxış — SVG ikon
        Pressable(
          onTap: () { HapticFeedback.selectionClick(); setState(() => _menuOpen = true); },
          child: Container(
            width: 36, height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF6B7F), Color(0xFFE0102D)]),
              border: Border.all(color: Colors.white.withOpacity(.55), width: 1),
              boxShadow: const [BoxShadow(color: Color(0x66E0102D), blurRadius: 12, offset: Offset(0, 3))],
            ),
            child: SvgPicture.string(_exitSvg),
          ),
        ),
      ]);

  Widget _rankRow() => SizedBox(height: 42, child: Row(children: [
        Expanded(flex: 30, child: _DarkPill(child: const Row(children: [
          Icon(Icons.military_tech_rounded, size: 22, color: Color(0xFFFFD64A)),
          SizedBox(width: 6),
          Text('OP50+', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFFFD64A))),
        ]))),
        const SizedBox(width: 8),
        SizedBox(width: 52, child: _DarkPill(padding: EdgeInsets.zero, child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.radio_rounded, size: 17),
          Text('0%', style: TextStyle(fontSize: 11)),
        ]))),
        const Spacer(flex: 22),
        Expanded(flex: 34, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), gradient: const LinearGradient(colors: [Color(0xE668364F), Color(0xD9BC5E2F)])),
          child: const Text('Məhdud\npulsuz', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, height: 1.05, fontWeight: FontWeight.w900, color: Color(0xFFFFE55D))),
        )),
      ]));

  Widget _audience() => _DarkBox(
        opacity: .68,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2D831D)),
              alignment: Alignment.center, child: const Text('V', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Expanded(child: SizedBox(height: 30, child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final member in _audio.members)
                Padding(padding: const EdgeInsets.only(right: 6), child: Avatar(name: member.name, color: kPalette[member.identity.hashCode.abs() % kPalette.length], size: 30)),
            ],
          ))),
          Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.white.withOpacity(.3)))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.people_alt_outlined, size: 20),
              Text('$_people', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
      );

  void _soon(String t) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t), duration: const Duration(milliseconds: 1500)));
  }

  Widget _bottomBar() => SizedBox(
        height: 42,
        child: Row(children: [
          Expanded(child: Pressable(
            onTap: _openChat,
            child: Container(
              height: 42,
              padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
              decoration: BoxDecoration(color: const Color(0xB80C0826), borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                Expanded(child: Text('Yazın...', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(.6)))),
                const _WinkFace(size: 30),
              ]),
            ),
          )),
          const SizedBox(width: 10),
          _RoundBtn(onTap: _toggleMic, color: _muted ? null : const Color(0xFF28A96B), child: Icon(_muted ? Icons.mic_off_rounded : Icons.mic_rounded, size: 22, color: const Color(0xFFD6D6DA))),
          const SizedBox(width: 4),
          _RoundBtn(onTap: _toggleSpeaker, child: Icon(_speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded, size: 23, color: const Color(0xFFD6D6DA))),
          const SizedBox(width: 4),
          _RoundBtn(onTap: _openChat, badge: '2', color: const Color(0x21FFFFFF), child: const Icon(Icons.chat_bubble_rounded, size: 22, color: Color(0xFFE2E2E6))),
          const SizedBox(width: 4),
          _RoundBtn(onTap: () => _soon('Oyunlar tezliklə'), child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFB36BFF), Color(0xFF7A4BF0), Color(0xFFFFB84D)]).createShader(r),
            child: const Icon(Icons.sports_esports_rounded, size: 26, color: Colors.white),
          )),
          const SizedBox(width: 4),
          _RoundBtn(onTap: () => _soon('Katalog tezliklə'), child: const Icon(Icons.grid_view_rounded, size: 21, color: Color(0xFFD6D6DA))),
          const SizedBox(width: 4),
          _RoundBtn(onTap: _openGifts, child: const Icon(Icons.card_giftcard_rounded, size: 24, color: Color(0xFFFF7DA5))),
        ]),
      );
}

/* ───────── Otaq üçün kiçik komponentlər ───────── */
class _DarkBox extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsets padding;
  const _DarkBox({required this.child, this.opacity = .72, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10)});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(padding: padding, color: const Color(0xFF12074F).withOpacity(opacity), child: child),
        ),
      );
}

class _DarkPill extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _DarkPill({required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 10)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xA1120855), borderRadius: BorderRadius.circular(12)),
        child: child,
      );
}

class _RoundBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? badge;
  final Color? color;
  final Gradient? gradient;
  const _RoundBtn({required this.child, required this.onTap, this.badge, this.color, this.gradient});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 38, height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: gradient == null ? (color ?? const Color(0xB80C0826)) : null, gradient: gradient,
                boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3))]),
            child: child,
          ),
          if (badge != null) Positioned(right: -6, top: -9, child: Container(
            constraints: const BoxConstraints(minWidth: 21, minHeight: 21),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(color: const Color(0xFFE8485F), borderRadius: BorderRadius.circular(11)),
            child: Text(badge!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          )),
        ]),
      );
}

class _WinkFace extends StatelessWidget {
  final double size;
  const _WinkFace({this.size = 30});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _WinkPainter()));
}

class _WinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32, size.height / 32);
    const dark = Color(0xFF2A2A30);
    canvas.drawCircle(const Offset(16, 16), 14.5, Paint()..color = const Color(0xFFD6D6DA));
    canvas.drawOval(Rect.fromCenter(center: const Offset(11, 12.6), width: 3.6, height: 5), Paint()..color = dark);
    final wink = Path()..moveTo(18.4, 10.6)..relativeLineTo(4.8, 2)..relativeLineTo(-4.8, 2);
    canvas.drawPath(wink, Paint()..color = dark..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    final mouth = Path()..moveTo(7.4, 17.2)..relativeCubicTo(0, 4.9, 3.7, 8.4, 8.6, 8.4)..relativeCubicTo(4.9, 0, 8.6, -3.5, 8.6, -8.4)..close();
    canvas.drawPath(mouth, Paint()..color = dark);
    final tongue = Path()..moveTo(11.4, 23.4)..relativeCubicTo(1.2, 1.1, 2.7, 1.7, 4.6, 1.7)..relativeCubicTo(1.9, 0, 3.4, -0.6, 4.6, -1.7)..relativeCubicTo(-1.2, -1.5, -2.7, -2.2, -4.6, -2.2)..relativeCubicTo(-1.9, 0, -3.4, 0.7, -4.6, 2.2)..close();
    canvas.drawPath(tongue, Paint()..color = const Color(0xFF9C9CA3));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MenuCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuCircle({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: Pressable(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: Column(children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.1), border: Border.all(color: Colors.white.withOpacity(.5), width: 1.5),
                boxShadow: const [BoxShadow(color: Color(0x47000000), blurRadius: 26, offset: Offset(0, 10))]),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.4))),
              child: Icon(icon, size: 32, shadows: const [Shadow(color: Color(0x73000000), blurRadius: 4)]),
            ),
          ),
          const SizedBox(height: 9),
          Text(label, style: const TextStyle(fontSize: 13, shadows: [Shadow(color: Color(0x99000000), blurRadius: 5)])),
        ]),
      ));
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _SheetBtn({required this.label, required this.filled, required this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        child: Container(
          height: 46, alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            color: filled ? const Color(0xFF8C61FF) : Colors.transparent,
            border: filled ? null : Border.all(color: Colors.white.withOpacity(.3)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
}

class _ChatSheet extends StatefulWidget {
  final List<ChatMsg> msgs;
  final String myName;
  final void Function(String) onSend;
  const _ChatSheet({required this.msgs, required this.myName, required this.onSend});
  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _c = TextEditingController();
  final _scroll = ScrollController();
  @override
  void dispose() { _c.dispose(); _scroll.dispose(); super.dispose(); }
  void _send() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    widget.onSend(t);
    _c.clear();
    HapticFeedback.selectionClick();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    });
  }
  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        decoration: const BoxDecoration(color: Color(0xF2140E3A), borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        child: Column(children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const Text('Söhbət', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Expanded(child: ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.all(14),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.msgs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => ChatBubble(msg: widget.msgs[i], animate: i == widget.msgs.length - 1),
          )),
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, math.max(10, kb > 0 ? 10 : MediaQuery.of(context).padding.bottom)),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(.08)))),
            child: Row(children: [
              Expanded(child: Container(
                height: 42, padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(21)),
                alignment: Alignment.center,
                child: TextField(
                  controller: _c, autofocus: true,
                  style: const TextStyle(fontSize: 16), cursorColor: kLilac,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'Mesaj yaz…', hintStyle: TextStyle(color: Colors.white.withOpacity(.4))),
                ),
              )),
              const SizedBox(width: 8),
              Pressable(onTap: _send, child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kPurple, Color(0xFF9D5CFF)])),
                child: const Icon(Icons.arrow_upward_rounded, size: 20),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

/* ───────────────────────── OTURACAQ ───────────────────────── */
class SeatTile extends StatelessWidget {
  final int index;
  final Seat? seat;
  final bool isMe;
  final VoidCallback onTap;
  const SeatTile({super.key, required this.index, required this.seat, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = seat;
    return Pressable(
      onTap: onTap,
      child: Column(children: [
        SizedBox(
          width: 50, height: 50,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.elasticOut,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: s == null
                ? Container(
                    key: const ValueKey('empty'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.06),
                      border: Border.all(color: kLilac.withOpacity(.35), width: 1.3),
                    ),
                    child: Icon(Icons.add_rounded, size: 20, color: kLilac.withOpacity(.9)),
                  )
                : Stack(key: ValueKey(s.name), clipBehavior: Clip.none, children: [
                    if (s.speaking) const Positioned.fill(child: _SpeakingRings()),
                    Positioned.fill(child: Avatar(name: s.name, color: s.color, size: 50, border: Colors.white.withOpacity(.9))),
                    Positioned(
                      right: -2, bottom: -2,
                      child: Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: s.muted ? const Color(0xFF8E8E93) : kGreen, border: Border.all(color: kBg, width: 2)),
                        child: Icon(s.muted ? Icons.mic_off_rounded : Icons.mic_rounded, size: 10),
                      ),
                    ),
                  ]),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          s?.name ?? '${index + 1}',
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, fontWeight: s != null ? FontWeight.w600 : FontWeight.w500,
              color: s != null ? (isMe ? kLilac : Colors.white) : Colors.white.withOpacity(.38)),
        ),
      ]),
    );
  }
}

class _SpeakingRings extends StatefulWidget {
  const _SpeakingRings();
  @override
  State<_SpeakingRings> createState() => _SpeakingRingsState();
}

class _SpeakingRingsState extends State<_SpeakingRings> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(clipBehavior: Clip.none, children: [
          for (final off in [0.0, .5])
            Builder(builder: (_) {
              final t = (_c.value + off) % 1;
              return Transform.scale(
                scale: 1 + t * .5,
                child: Container(decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: Color.lerp(kLilac, kPink, off)!.withOpacity(1 - t), width: 2))),
              );
            }),
        ]),
      );
}

/* ───────────────────────── MESAJ ───────────────────────── */
class ChatBubble extends StatelessWidget {
  final ChatMsg msg;
  final bool animate;
  const ChatBubble({super.key, required this.msg, this.animate = false});
  @override
  Widget build(BuildContext context) {
    final body = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Avatar(name: msg.name, color: msg.color, size: 34, border: Colors.white.withOpacity(.85)),
      const SizedBox(width: 8),
      Flexible(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(msg.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: msg.me ? kLilac : Colors.white.withOpacity(.78))),
            const SizedBox(width: 4),
            Image.network('$kImg/vlogo15.png', height: 15, errorBuilder: (_, __, ___) => const SizedBox()),
          ]),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: msg.me ? kPurple.withOpacity(.3) : Colors.white.withOpacity(.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border.all(color: msg.me ? kLilac.withOpacity(.35) : Colors.white.withOpacity(.1), width: .5),
            ),
            child: Text(msg.text, style: const TextStyle(fontSize: 14, height: 1.35)),
          ),
        ]),
      ),
    ]);
    if (!animate) return body;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(-16 * (1 - t), 0), child: child)),
      child: body,
    );
  }
}

/* ───────────────────────── HƏDİYYƏ PANELİ ───────────────────────── */
class GiftSheet extends StatefulWidget {
  final int jeton;
  final List<String> people;
  final bool Function(Gift gift, int qty, String to) onSend;
  const GiftSheet({super.key, required this.jeton, required this.people, required this.onSend});
  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> {
  static const _tabs = ['Çanta', 'Hədiyyə', 'Şanslı', 'Tədbirlər', 'İnteraktiv'];
  static const _gifts = {
    'Hədiyyə': [
      Gift('kaplan', 'Qızıl Kaplan', 'assets/gifts/logo-kaplan.png', 'assets/gifts/temiz-kaplan-animasyonu.mp4', 399),
      Gift('para', 'Pul Yağışı', 'assets/gifts/logo-para.png', 'assets/gifts/temiz-para-animasyonu.mp4', 188),
      Gift('emoji', 'Emoji Partlayışı', 'assets/gifts/logo-emoji.png', 'assets/gifts/temiz-emoji-animasyonu.mp4', 99),
      Gift('neon', 'Neon Şəhər', 'assets/gifts/logo-neon-sehir.png', 'assets/gifts/temiz-neon-sehir-animasyonu.mp4', 588),
      Gift('qanadli', 'Qanadlı Kaplan', 'assets/gifts/logo-kanatli-kaplan.png', 'assets/gifts/temiz-kanatli-kaplan-animasyonu.mp4', 888),
    ],
  };
  int _tab = 1, _to = -1, _qty = 1;
  String? _sel = 'kaplan';
  bool _warn = false;

  @override
  Widget build(BuildContext context) {
    final list = _gifts[_tabs[_tab]] ?? const <Gift>[];
    final gift = list.where((g) => g.id == _sel).firstOrNull;
    return Container(
      height: MediaQuery.of(context).size.height * .58,
      decoration: const BoxDecoration(color: Color(0xFF17141F), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Column(children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          // Alıcılar
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              physics: const BouncingScrollPhysics(),
              children: [
                Pressable(
                  onTap: () => setState(() => _to = -1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _to < 0 ? kPink.withOpacity(.15) : Colors.transparent,
                      border: Border.all(color: _to < 0 ? kPink : Colors.white24, width: _to < 0 ? 1.5 : 1),
                    ),
                    child: const Text('Hamı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                for (final (i, p) in widget.people.indexed)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Pressable(
                      onTap: () => setState(() => _to = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _to == i ? kPink : Colors.transparent, width: 2)),
                        child: Avatar(name: p, color: i == 0 ? kPurple : kPalette[i % kPalette.length], size: 38),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tablar
          Container(
            height: 40,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.1), width: .5))),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                for (final (i, t) in _tabs.indexed)
                  GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); setState(() => _tab = i); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == i ? kPink : Colors.transparent, width: 2))),
                      child: Text(t, style: TextStyle(fontSize: 13, fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400,
                          color: _tab == i ? Colors.white : Colors.white54)),
                    ),
                  ),
              ],
            ),
          ),
          // Hədiyyələr
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Bu bölmədə hələ əşya yoxdur', style: TextStyle(color: Colors.white38, fontSize: 13)))
                : GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.all(10),
                    mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: .82,
                    children: [
                      for (final g in list)
                        Pressable(
                          onTap: () { HapticFeedback.selectionClick(); setState(() => _sel = g.id); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: _sel == g.id ? kPink.withOpacity(.12) : Colors.transparent,
                              border: Border.all(color: _sel == g.id ? kPink : Colors.transparent, width: 1.5),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              ClipOval(child: Image.asset(g.iconAsset, width: 52, height: 52, fit: BoxFit.cover)),
                              const SizedBox(height: 4),
                              Text(g.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                Image.network('$kImg/jeton.PNG', width: 12, height: 12, errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 10, color: kGold)),
                                const SizedBox(width: 3),
                                Text('${g.price}', style: const TextStyle(fontSize: 11, color: kGold, fontWeight: FontWeight.w600)),
                              ]),
                            ]),
                          ),
                        ),
                    ],
                  ),
          ),
          // Alt: balans + say + göndər
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(.08), width: .5))),
            child: Row(children: [
              Image.network('$kImg/jeton.PNG', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 18, color: kGold)),
              const SizedBox(width: 6),
              Text(_fmt(widget.jeton), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kGold)),
              const Spacer(),
              AnimatedOpacity(
                opacity: _warn ? 1 : 0, duration: const Duration(milliseconds: 200),
                child: const Padding(padding: EdgeInsets.only(right: 8), child: Text('Jeton kifayət etmir', style: TextStyle(fontSize: 12, color: Color(0xFFFF9F0A)))),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: kPink, width: 1.5)),
                child: Row(children: [
                  PopupMenuButton<int>(
                    initialValue: _qty,
                    color: const Color(0xFF241F2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    position: PopupMenuPosition.over,
                    onSelected: (v) => setState(() => _qty = v),
                    itemBuilder: (_) => [for (final q in [100, 30, 10, 5, 1]) PopupMenuItem(value: q, height: 38, child: Text('$q', style: TextStyle(color: q == _qty ? kPink : Colors.white, fontWeight: FontWeight.w600)))],
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Row(children: [
                        Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                      ]),
                    ),
                  ),
                  Pressable(
                    onTap: () {
                      if (gift == null) return;
                      final to = _to < 0 ? 'hamıya' : widget.people[_to];
                      if (widget.onSend(gift, _qty, to)) {
                        Navigator.pop(context);
                      } else {
                        HapticFeedback.vibrate();
                        setState(() => _warn = true);
                        Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _warn = false); });
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [Color(0xFFFF5FA8), Color(0xFFFF2D7A)]),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF2D7A).withOpacity(.45), blurRadius: 14, offset: const Offset(0, 4))],
                      ),
                      child: const Text('Göndər', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/* ───────────────────────── HƏDİYYƏ ANİMASİYASI ───────────────────────── */
class GiftBurst extends StatefulWidget {
  final Gift gift;
  final VoidCallback onFinished;
  const GiftBurst({super.key, required this.gift, required this.onFinished});

  @override
  State<GiftBurst> createState() => _GiftBurstState();
}

class _GiftBurstState extends State<GiftBurst> with SingleTickerProviderStateMixin {
  late final VideoPlayerController _video = VideoPlayerController.asset(widget.gift.videoAsset);
  late final AnimationController _fade = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 360),
  );
  bool _ready = false;
  bool _ending = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _video.addListener(_onVideoTick);
    _start();
  }

  Future<void> _start() async {
    try {
      await _video.initialize();
      if (!mounted) return;
      await _video.setLooping(false);
      await _video.setVolume(1);
      await _video.seekTo(Duration.zero);
      if (!mounted) return;
      setState(() => _ready = true);
      await _fade.forward();
      if (mounted) await _video.play();
    } catch (_) {
      // Media eksikse oda çökmez; ikon kısa süre görünür ve kaybolur.
      if (!mounted) return;
      setState(() => _failed = true);
      await _fade.forward();
      await Future<void>.delayed(const Duration(milliseconds: 1300));
      if (mounted) _finish();
    }
  }

  void _onVideoTick() {
    if (!_ready || _ending || !_video.value.isInitialized) return;
    final value = _video.value;
    if (value.hasError) {
      _finish();
      return;
    }
    final duration = value.duration;
    if (duration > Duration.zero &&
        value.position >= duration - const Duration(milliseconds: 380)) {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_ending || !mounted) return;
    _ending = true;
    await _fade.reverse();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _video.removeListener(_onVideoTick);
    _video.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _fade, curve: Curves.easeInOut),
    child: _ready && !_failed
        ? SizedBox.expand(child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _video.value.size.width,
              height: _video.value.size.height,
              child: VideoPlayer(_video),
            ),
          ))
        : Center(child: Image.asset(widget.gift.iconAsset,
            width: 180, height: 180, fit: BoxFit.contain)),
  );
}

/* ───────────────────────── KÖMƏKÇİLƏR ───────────────────────── */
class _AmbientBackground extends StatefulWidget {
  const _AmbientBackground();
  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Stack(children: [
            Container(color: kBg),
            _blob(Alignment(-.8 + .2 * math.sin(t), -1 + .1 * math.cos(t)), kPurple, .5, 420),
            _blob(Alignment(1 + .15 * math.cos(t), -.1 + .2 * math.sin(t)), kPink, .26, 360),
            _blob(Alignment(-.2 + .2 * math.sin(t + 1), 1.1), const Color(0xFF00B4D8), .16, 420),
          ]);
        },
      );
  Widget _blob(Alignment a, Color c, double o, double s) => Align(
        alignment: a,
        child: Container(width: s, height: s,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.withOpacity(o), c.withOpacity(0)]))),
      );
}

class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const Glass({super.key, required this.child, this.radius = 16, this.padding = EdgeInsets.zero});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.07),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(.1), width: .5),
            ),
            child: child,
          ),
        ),
      );
}

class _RoundGlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  const _RoundGlassIcon({required this.icon, this.color = Colors.white, this.size = 38, this.onTap});
  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap ?? () => HapticFeedback.selectionClick(),
        child: Glass(radius: size / 2, child: SizedBox(width: size, height: size, child: Icon(icon, size: size * .5, color: color))),
      );
}

class Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final Color? border;
  const Avatar({super.key, required this.name, required this.color, required this.size, this.border});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.black, .25)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: border != null ? Border.all(color: border!, width: 2) : null,
          boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        alignment: Alignment.center,
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: size * .38, fontWeight: FontWeight.w700)),
      );
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: .35, end: 1.0).animate(_c),
        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
      );
}

/// Açılışda aşağıdan süzülərək gəlmə
class _Entrance extends StatelessWidget {
  final Widget child;
  final int delay;
  const _Entrance({required this.child, this.delay = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + delay),
        curve: Interval(delay / (520 + delay), 1, curve: Curves.easeOutCubic),
        builder: (_, t, c) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: c)),
        child: child,
      );
}

/// Basanda sıxılıb yay kimi açılma
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const Pressable({super.key, required this.child, required this.onTap});
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? .9 : 1,
          duration: Duration(milliseconds: _down ? 90 : 380),
          curve: _down ? Curves.easeOut : Curves.elasticOut,
          child: widget.child,
        ),
      );
}

String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
