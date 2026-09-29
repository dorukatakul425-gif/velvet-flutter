// Velvet — Otaq ekranı (premium Flutter versiyası)
// İstifadə: flutter create velvet_app → lib/main.dart faylını bununla əvəz et → flutter run
// Şəkillər saytdan yüklənir. Əlavə paket lazım deyil.

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final String id, name, emoji;
  final int price;
  const Gift(this.id, this.name, this.emoji, this.price);
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
  final _msgs = <ChatMsg>[
    ChatMsg('Aynur', 'Salam, xoş gəldin! 👋', kPalette[1]),
    ChatMsg('Rauf', 'Otaq çox gözəldir 🔥', kPalette[2]),
  ];
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _chatScroll = ScrollController();
  final _viewers = ['Aynur', 'Rauf', 'Sevinc', 'Tural', 'Nigar', 'Kənan', 'Leyla', 'Orxan', 'Aysel', 'Elvin'];
  bool _following = false;
  int _jeton = 10000;
  Gift? _playing;
  late final AnimationController _giftAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    _seats[0] = Seat('Aynur', kPalette[1], speaking: true);
    _seats[3] = Seat('Rauf', kPalette[2], speaking: true);
    _seats[7] = Seat('Nigar', kPalette[4], muted: true);
    _focus.addListener(() => setState(() {}));
    _giftAnim.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _playing = null);
    });
  }

  @override
  void dispose() {
    _input.dispose(); _focus.dispose(); _chatScroll.dispose(); _giftAnim.dispose();
    super.dispose();
  }

  int? get _mySeat => _seats.indexWhere((s) => s?.name == widget.myName) < 0 ? null : _seats.indexWhere((s) => s?.name == widget.myName);

  void _tapSeat(int i) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_seats[i]?.name == widget.myName) {
        _seats[i] = null;
      } else if (_seats[i] == null) {
        final m = _mySeat;
        if (m != null) _seats[m] = null;
        _seats[i] = Seat(widget.myName, kPurple, speaking: true);
      }
    });
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _msgs.add(ChatMsg(widget.myName, t, kPurple, me: true)));
    _input.clear();
    _scrollChat();
  }

  void _scrollChat() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScroll.hasClients) {
          _chatScroll.animateTo(_chatScroll.position.maxScrollExtent, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
        }
      });

  void _openGifts() {
    HapticFeedback.mediumImpact();
    _focus.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.4),
      builder: (_) => GiftSheet(
        jeton: _jeton,
        people: [widget.myName, ..._viewers.take(6)],
        onSend: (gift, qty, to) {
          final cost = gift.price * qty;
          if (_jeton < cost) return false;
          setState(() {
            _jeton -= cost;
            _msgs.add(ChatMsg(widget.myName, '🎁 $to ${gift.name} ×$qty göndərdi', kPurple, me: true));
            _playing = gift;
          });
          _giftAnim.forward(from: 0);
          HapticFeedback.heavyImpact();
          _scrollChat();
          return true;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;
    final typing = _focus.hasFocus;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        const _AmbientBackground(),
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                sliver: SliverToBoxAdapter(child: _header()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 10, childAspectRatio: .74),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _Entrance(delay: 20 * i, child: SeatTile(index: i, seat: _seats[i], isMe: _seats[i]?.name == widget.myName, onTap: () => _tapSeat(i))),
                    childCount: 24,
                  ),
                ),
              ),
              SliverPadding(padding: const EdgeInsets.fromLTRB(12, 16, 12, 10), sliver: SliverToBoxAdapter(child: _viewersStrip())),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190,
                    child: ListView.separated(
                      controller: _chatScroll,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _msgs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => ChatBubble(msg: _msgs[i], animate: i == _msgs.length - 1),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),

        // Yazarkən: mesajlar ortada, otaq arxada şəffaf
        IgnorePointer(
          ignoring: !typing,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: typing ? 1 : 0,
            child: GestureDetector(
              onTap: () => _focus.unfocus(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: kBg.withOpacity(.55),
                  padding: EdgeInsets.fromLTRB(14, MediaQuery.of(context).padding.top + 16, 14, kb + 76),
                  alignment: Alignment.bottomLeft,
                  child: ListView(
                    shrinkWrap: true,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    children: [for (final m in _msgs.reversed.take(30)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ChatBubble(msg: m))],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Hədiyyə animasiyası
        if (_playing != null)
          Positioned(
            left: 0, right: 0, bottom: kb + 70, height: MediaQuery.of(context).size.height * .42,
            child: IgnorePointer(child: GiftBurst(controller: _giftAnim, gift: _playing!)),
          ),

        // Alt panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          left: 0, right: 0, bottom: kb,
          child: _bottomBar(kb > 0),
        ),
      ]),
    );
  }

  /* ─── Üst panel ─── */
  Widget _header() => _Entrance(
        child: Row(children: [
          Glass(
            radius: 22,
            padding: const EdgeInsets.fromLTRB(3, 3, 4, 3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38, height: 38,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPurple, kPink])),
                  child: Image.network('$kImg/oda.png', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Text('Q', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                ),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                const Text('Qızıl Saatlar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(children: [
                  const _PulseDot(color: kGreen),
                  const SizedBox(width: 4),
                  Text('${_viewers.length + 1} onlayn', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.55))),
                ]),
              ]),
              const SizedBox(width: 8),
              Pressable(
                onTap: () { HapticFeedback.lightImpact(); setState(() => _following = !_following); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _following ? Colors.white.withOpacity(.12) : kPurple,
                    boxShadow: _following ? [] : [BoxShadow(color: kPurple.withOpacity(.5), blurRadius: 10)],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                    child: Icon(_following ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(_following), size: 16, color: _following ? kPink : Colors.white),
                  ),
                ),
              ),
            ]),
          ),
          const Spacer(),
          const _RoundGlassIcon(icon: Icons.emoji_events_rounded, color: Color(0xFFFF9F0A)),
          const SizedBox(width: 6),
          const _RoundGlassIcon(icon: Icons.info_outline_rounded),
          const SizedBox(width: 6),
          _RoundGlassIcon(icon: Icons.power_settings_new_rounded, color: const Color(0xFFFF5A6E), onTap: () => Navigator.maybePop(context)),
        ]),
      );

  /* ─── İzləyicilər ─── */
  Widget _viewersStrip() => Row(children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _viewers.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final n = i == 0 ? widget.myName : _viewers[i - 1];
                return Avatar(name: n, color: i == 0 ? kPurple : kPalette[i % kPalette.length], size: 32, border: kBg);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Glass(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.person_outline_rounded, size: 16),
            const SizedBox(width: 4),
            Text('${_viewers.length + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ]);

  /* ─── Alt panel ─── */
  Widget _bottomBar(bool keyboardOpen) {
    final bottom = keyboardOpen ? 8.0 : math.max(8.0, MediaQuery.of(context).padding.bottom);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF0D001E).withOpacity(.78),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(.08), width: .5)),
          ),
          child: Row(children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.09),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: _focus.hasFocus ? kPurple.withOpacity(.6) : Colors.white.withOpacity(.1)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      style: const TextStyle(fontSize: 16),
                      cursorColor: kLilac,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) { _send(); _focus.requestFocus(); },
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Mesaj yaz…',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(.4)),
                      ),
                    ),
                  ),
                  AnimatedScale(
                    scale: _input.text.trim().isEmpty ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Pressable(
                      onTap: _send,
                      child: Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kPurple, Color(0xFF9D5CFF)])),
                        child: const Icon(Icons.arrow_upward_rounded, size: 18),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            const _RoundGlassIcon(icon: Icons.chat_bubble_outline_rounded, size: 42),
            const SizedBox(width: 8),
            const _RoundGlassIcon(icon: Icons.grid_view_rounded, size: 42),
            const SizedBox(width: 8),
            Pressable(
              onTap: _openGifts,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFF5F8F), Color(0xFFFF2D55)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF2D55).withOpacity(.45), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.card_giftcard_rounded, size: 21),
              ),
            ),
          ]),
        ),
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
  static const _gifts = {'Hədiyyə': [Gift('aslan', 'Aslan', '🦁', 99)]};
  int _tab = 1, _to = -1, _qty = 1;
  String? _sel = 'aslan';
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
                              Text(g.emoji, style: const TextStyle(fontSize: 38)),
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
class GiftBurst extends StatelessWidget {
  final AnimationController controller;
  final Gift gift;
  const GiftBurst({super.key, required this.controller, required this.gift});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final t = controller.value;
          final scale = Curves.elasticOut.transform((t / .35).clamp(0, 1)) * (1 + .05 * math.sin(t * 20));
          final fade = t > .8 ? (1 - (t - .8) / .2) : 1.0;
          return Opacity(
            opacity: fade.clamp(0, 1),
            child: Stack(alignment: Alignment.center, children: [
              // Parıltı halqası
              Transform.scale(
                scale: .6 + t * 1.6,
                child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: kGold.withOpacity((1 - t).clamp(0, 1)), width: 3))),
              ),
              // Qığılcımlar
              for (var i = 0; i < 12; i++)
                Transform.translate(
                  offset: Offset(math.cos(i * math.pi / 6) * 140 * t, math.sin(i * math.pi / 6) * 140 * t),
                  child: Icon(Icons.auto_awesome_rounded, size: 18, color: (i.isEven ? kGold : kPink).withOpacity((1 - t).clamp(0, 1))),
                ),
              Transform.scale(scale: scale, child: Text(gift.emoji, style: const TextStyle(fontSize: 130))),
            ]),
          );
        },
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
