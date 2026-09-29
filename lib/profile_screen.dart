// Velvet — Profil ekranı (Flutter). Düzən index.tsx-dəki profil ilə eynidir.
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart' show appLogout;
import 'vip_screen.dart';
import 'legal_texts.dart';

const _img = 'https://xx-jade.vercel.app/images/images';
const _bg = Color(0xFF07000F);
const _purple = Color(0xFF7B2FF7);
const _pink = Color(0xFFFF3EA5);
const _lilac = Color(0xFFC084FC);

/// Tətbiq üzrə ortaq vəziyyət (demo)
final jetonBalance = ValueNotifier<int>(10000);
final activeFrame = ValueNotifier<String?>(null);

const kFrames = [
  ('gold', 'Qızıl Qanadlar', 'frame-gold-flap', Color(0xFFFFD700)),
  ('red', 'Qırmızı Qanadlar', 'frame-red-flap', Color(0xFFFF6060)),
  ('blue', 'Mavi Qanadlar', 'frame-blue-flap', Color(0xFF60A0FF)),
  ('green', 'Yaşıl Qanadlar', 'frame-green-flap', Color(0xFF50C878)),
  ('butterfly-sakura', 'Kəpənək Sakura', 'frame-butterfly-sakura', Color(0xFFFF80C0)),
  ('cyber-wings', 'Kiber Qanadlar', 'frame-cyber-wings', Color(0xFF00D4FF)),
  ('dragon-obsidian', 'Obsidian Əjdaha', 'frame-dragon-obsidian', Color(0xFFA060FF)),
];

Route<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

/// Profilə axıcı keçid
void openProfile(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const ProfileScreen(),
    transitionsBuilder: (_, a, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(begin: const Offset(.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  ));
}

class ProfileScreen extends StatefulWidget {
  final String name;
  final String userId;
  final String bio;
  final String country;
  final String flag;
  final String city;
  final int age;
  final int days;
  final int vip;
  const ProfileScreen({
    super.key,
    this.name = 'Demo İstifadəçi',
    this.userId = '48219037',
    this.bio = 'Velvet demo hesabı 🎮',
    this.country = 'Azərbaycan',
    this.flag = '🇦🇿',
    this.city = 'Bakı',
    this.age = 22,
    this.days = 142,
    this.vip = 0,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _scroll = ScrollController();
  double _offset = 0;
  bool _copied = false;
  late final _p = _ProfileData(widget.name, widget.bio, widget.country, widget.flag, widget.city, widget.age);
  late final _ring = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  late final _glow = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _offset = _scroll.offset));
  }

  @override
  void dispose() { _scroll.dispose(); _ring.dispose(); _glow.dispose(); super.dispose(); }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: widget.userId));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) setState(() => _copied = false); });
  }

  void _visitors() {
    const v = [
      ('Aynur M.', Color(0xFF7B2FF7), 7, 'Azərbaycan', '2 dəq əvvəl', 4),
      ('Rauf K.', Color(0xFFFF3EA5), 3, 'Türkiyə', '18 dəq əvvəl', 1),
      ('Sevinc H.', Color(0xFF00D4FF), 12, 'Azərbaycan', '1 saat əvvəl', 7),
      ('Tural B.', Color(0xFFFF6B35), 0, 'Rusiya', '3 saat əvvəl', 2),
      ('Nigar A.', Color(0xFF50C050), 5, 'Azərbaycan', 'Dünən 22:14', 3),
      ('Kənan S.', Color(0xFFC084FC), 9, 'Türkiyə', 'Dünən 19:40', 1),
    ];
    showGeneralDialog(
      context: context, barrierDismissible: true, barrierLabel: 'Bağla',
      barrierColor: Colors.black.withOpacity(.6),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: .94, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: c)),
      pageBuilder: (ctx, __, ___) => Center(child: Material(color: Colors.transparent, child: Container(
        width: math.min(400, MediaQuery.of(ctx).size.width - 40),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .8),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0x1FA06EF5))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 14, 14), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Profil Ziyarətçiləri', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Son 7 günün statistikası', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.45))),
            ])),
            ShaderMask(shaderCallback: (r) => const LinearGradient(colors: [_purple, _pink]).createShader(r),
                child: const Text('143', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white))),
            const SizedBox(width: 10),
            _NavIcon(icon: Icons.close_rounded, onTap: () => Navigator.pop(ctx)),
          ])),
          Flexible(child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), children: [
            for (final x in v)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(children: [
                ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  color: const Color(0x0FA06EF5),
                  child: Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: x.$2, child: Text(x.$1.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(x.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('${x.$4} • ${x.$5} • ${x.$6}× ziyarət', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.6))),
                    ])),
                    Text('VIP${x.$3}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFD700))),
                  ]),
                )),
                Positioned.fill(child: Container(color: const Color(0x4DA06EF5), child: Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white.withOpacity(.6)))),
              ]))),
            Container(
              margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0x1F7B2FF7), Color(0x14FF3EA5)]), border: Border.all(color: const Color(0x337B2FF7))),
              child: Column(children: [
                const Icon(Icons.workspace_premium_rounded, color: Color(0xB3FFC800), size: 28),
                const SizedBox(height: 8),
                const Text('Ziyarət edənləri görmək üçün', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('VIP 1-ə yüksəlin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xCCFFC800))),
                const SizedBox(height: 12),
                _Pressable(onTap: () { Navigator.pop(ctx); Navigator.of(context).push(_slide(VipScreen(name: _p.name))); }, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF9500)])),
                  child: const Text('VIP-ə keç →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2A0E00))),
                )),
              ]),
            ),
          ])),
        ]),
      ))),
    );
  }

  void _toast(String t) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(t, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF241F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 90),
        duration: const Duration(milliseconds: 1400),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final barSolid = _offset > 170;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Arxa plan parıltısı
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: RadialGradient(center: Alignment(.4, -1), radius: 1.2, colors: [Color(0x597B2FF7), Color(0x0007000F)]),
        ))),
        CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _hero()),
            SliverToBoxAdapter(child: Transform.translate(offset: const Offset(0, -20), child: _info())),
            SliverToBoxAdapter(child: _Entrance(delay: 140, child: _vipRow())),
            SliverToBoxAdapter(child: _menu()),
            SliverToBoxAdapter(child: _Entrance(delay: 520, child: _logout())),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
        // Üst panel
        Positioned(
          top: 0, left: 0, right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: barSolid ? 16 : 0, sigmaY: barSolid ? 16 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: barSolid ? const Color(0xD90D001E) : Colors.transparent,
                padding: EdgeInsets.fromLTRB(8, top + 4, 8, 4),
                child: Row(children: [
                  _NavIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.maybePop(context)),
                  Expanded(child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: barSolid ? 1 : 0,
                    child: Text(_p.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
                  _NavIcon(icon: Icons.visibility_outlined, onTap: _visitors),
                  _NavIcon(icon: Icons.edit_outlined, onTap: () => Navigator.of(context).push(_slide(_EditProfile(data: _p))).then((_) => setState(() {}))),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /* ─── Üst fon (paralaks + dartılma) ─── */
  Widget _hero() {
    final stretch = _offset < 0 ? -_offset : 0.0;
    final parallax = _offset > 0 ? _offset * .45 : 0.0;
    return SizedBox(
      height: 240 + stretch,
      child: Stack(fit: StackFit.expand, clipBehavior: Clip.hardEdge, children: [
        Transform.translate(
          offset: Offset(0, parallax - stretch),
          child: Transform.scale(
            scale: 1 + stretch / 400,
            alignment: Alignment.topCenter,
            child: Container(
              decoration: const BoxDecoration(gradient: RadialGradient(
                center: Alignment(-.4, -.2), radius: 1.1,
                colors: [Color(0xE63A0070), Color(0xFF0D001E)],
              )),
              child: Stack(children: [
                const Positioned(right: -40, top: -30, child: _Glow(size: 260, color: Color(0x997B0050))),
                Positioned(right: 24, bottom: -20, child: Text('V', style: TextStyle(fontSize: 180, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _purple.withOpacity(.06)))),
                AnimatedBuilder(
                  animation: _ring,
                  builder: (_, __) => Positioned(left: -80, top: -100, child: Transform.rotate(
                    angle: _ring.value * 2 * math.pi / 2.5,
                    child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _lilac.withOpacity(.07)))),
                  )),
                ),
              ]),
            ),
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, height: 80, child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [_bg, Color(0x0007000F)]),
        ))),
        Positioned(
          right: 14, bottom: 12,
          child: _Pressable(
            onTap: () => _toast('Şəkil yüklə'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.55), borderRadius: BorderRadius.circular(20), border: Border.all(color: _lilac.withOpacity(.2))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.upload_rounded, size: 13, color: Colors.white.withOpacity(.6)),
                const SizedBox(width: 5),
                Text('Şəkil yüklə', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.6))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  /* ─── Avatar, ad, ID, bio, məlumatlar ─── */
  Widget _info() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Entrance(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ValueListenableBuilder<String?>(valueListenable: activeFrame, builder: (_, frame, __) => _Pressable(
              onTap: () => _toast('Avatar'),
              child: _Framed(frame: frame, size: 82, child: SizedBox(
                width: 82, height: 82,
                child: Stack(children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([_ring, _glow]),
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          transform: GradientRotation(_ring.value * 2 * math.pi),
                          colors: const [Color(0xFFFFD700), Color(0xFFFF8C00), _lilac, _purple, Color(0xFFFFD700)],
                        ),
                        boxShadow: [BoxShadow(color: _purple.withOpacity(.3 + .35 * _glow.value), blurRadius: 18 + 16 * _glow.value)],
                      ),
                    ),
                  ),
                  Positioned.fill(child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A0035)),
                      alignment: Alignment.center,
                      child: Text(_p.name.isNotEmpty ? _p.name[0].toUpperCase() : 'İ', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    ),
                  )),
                  Positioned(right: 2, bottom: 2, child: Container(
                    width: 15, height: 15,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00FF88), border: Border.all(color: _bg, width: 2.5)),
                  )),
                ]),
              )),
            )),
            const SizedBox(width: 14),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _copyId,
                  child: Row(children: [
                    Text('ID: ${widget.userId}', style: TextStyle(fontSize: 12, color: const Color(0xFFE9E2FF).withOpacity(.55))),
                    const SizedBox(width: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: c),
                      child: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, key: ValueKey(_copied), size: 13,
                          color: _copied ? const Color(0xFF50C050) : const Color(0x80D2C3FA)),
                    ),
                  ]),
                ),
              ]),
            )),
          ])),
          const SizedBox(height: 14),
          if (_p.bio.isNotEmpty)
            _Entrance(delay: 60, child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_p.bio, style: TextStyle(fontSize: 13, height: 1.5, color: const Color(0xFFE9E2FF).withOpacity(.65))),
            )),
          _Entrance(delay: 100, child: Wrap(spacing: 6, runSpacing: 6, children: [
            _Pill(leading: Text(_p.flag, style: const TextStyle(fontSize: 13)), text: _p.country),
            _Pill(leading: const Icon(Icons.location_on_outlined, size: 12, color: Color(0x66D2C3FA)), text: _p.city),
            _Pill(leading: const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0x66D2C3FA)), text: '${_p.age} yaş'),
            _Pill(leading: const Icon(Icons.schedule_rounded, size: 12, color: Color(0x66D2C3FA)), text: '${widget.days} gün'),
          ])),
        ]),
      );

  /* ─── VIP rozeti + admin ünvanı ─── */
  Widget _vipRow() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 148, height: 54,
              child: Stack(children: [
                Positioned.fill(child: Image.network('$_img/viparxaplan.PNG', fit: BoxFit.cover, alignment: Alignment.centerLeft,
                    errorBuilder: (_, __, ___) => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A1150), Color(0xFF4A2280)]))))),
                Positioned(left: 6, top: 6, bottom: 6, child: Image.network('$_img/VIP${widget.vip}.png', width: 42, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 42))),
                Positioned(left: 54, top: 0, bottom: 0, child: Center(child: Text('VIP ${widget.vip}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFFD700), shadows: [Shadow(color: Color(0x59A06EF5), blurRadius: 4)])))),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(height: 62, child: Image.network('$_img/adminunvan.gif', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox())),
        ]),
      );

  /* ─── Menyu ─── */
  Widget _menu() {
    final sections = [
      ('Hesab və status', [
        _Item(Icons.account_balance_wallet_outlined, const Color(0xFF34C759), 'Cüzdanım', 'Balans və ödənişlər'),
        _Item(Icons.shield_outlined, const Color(0xFFFF9F0A), 'VIP', 'Üstünlüklər və səviyyələr', badge: 'VIP ${widget.vip}', badgeVip: true),
        _Item(Icons.emoji_events_outlined, const Color(0xFF0A84FF), 'Reytinq', 'Ümumi sıralamadakı yerin', badge: '#142'),
      ]),
      ('Mağaza və bonuslar', [
        _Item(Icons.shopping_bag_outlined, const Color(0xFFAF52DE), 'Mağaza', 'Çərçivələr və bəzəklər'),
        _Item(Icons.card_giftcard_rounded, const Color(0xFFFF375F), 'Gündəlik bonus', 'Bugünkü hədiyyəni götür'),
      ]),
      ('Dəstək', [
        _Item(Icons.chat_bubble_outline_rounded, const Color(0xFF32ADE6), 'Kömək mərkəzi', 'Suallar və dəstək'),
        _Item(Icons.settings_outlined, const Color(0xFF8E8E93), 'Parametrlər', 'Hesab və məxfilik'),
      ]),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Entrance(delay: 180, child: Padding(
          padding: EdgeInsets.only(left: 2, bottom: 12),
          child: Text('Hesabım', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        )),
        for (final (si, s) in sections.indexed)
          _Entrance(
            delay: 220 + si * 90,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 7),
                  child: Text(s.$1.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFE9E2FF).withOpacity(.46))),
                ),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.045),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x1A965AF0)),
                    boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 4))],
                  ),
                  child: Column(children: [
                    for (final (i, it) in s.$2.indexed) ...[
                      if (i > 0) Container(height: 1, color: const Color(0x13965AF0)),
                      _MenuRow(item: it, onTap: () {
                        if (it.label == 'Cüzdanım') { Navigator.of(context).push(_slide(const WalletScreen())); }
                        else if (it.label == 'VIP') { Navigator.of(context).push(_slide(VipScreen(name: _p.name))); }
                        else if (it.label == 'Mağaza') { Navigator.of(context).push(_slide(StoreScreen(name: _p.name))).then((_) => setState(() {})); }
                        else { _toast(it.label); }
                      }),
                    ],
                  ]),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _logout() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
        child: _Pressable(
          onTap: () { HapticFeedback.mediumImpact(); Navigator.of(context).popUntil((r) => r.isFirst); appLogout?.call(); },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.045),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x4D965AF0), width: .5),
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout_rounded, size: 20, color: Color(0xFFFF5A7A)),
              SizedBox(width: 8),
              Text('Çıxış', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFFF3B30))),
            ]),
          ),
        ),
      );
}

/* ─────────── Kiçik komponentlər ─────────── */
class _Item {
  final IconData icon;
  final Color color;
  final String label, desc;
  final String? badge;
  final bool badgeVip;
  _Item(this.icon, this.color, this.label, this.desc, {this.badge, this.badgeVip = false});
}

class _MenuRow extends StatefulWidget {
  final _Item item;
  final VoidCallback onTap;
  const _MenuRow({required this.item, required this.onTap});
  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () { HapticFeedback.selectionClick(); widget.onTap(); },
        onHighlightChanged: (v) => setState(() => _down = v),
        splashColor: _purple.withOpacity(.18),
        highlightColor: _purple.withOpacity(.08),
        child: AnimatedScale(
          scale: _down ? .98 : 1,
          duration: Duration(milliseconds: _down ? 90 : 320),
          curve: _down ? Curves.easeOut : Curves.elasticOut,
          child: SizedBox(
            height: 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [it.color.withOpacity(.33), it.color.withOpacity(.08)]),
                    border: Border.all(color: it.color.withOpacity(.33)),
                  ),
                  child: Icon(it.icon, size: 19, color: it.color),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(it.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(it.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: const Color(0xFFE9E2FF).withOpacity(.48))),
                ])),
                if (it.badge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: it.badgeVip ? const Color(0xFFFFF6D8) : const Color(0xFFEAF7FB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(it.badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: it.badgeVip ? const Color(0xFF8C6600) : const Color(0xFF17718B))),
                  ),
                Icon(Icons.chevron_right_rounded, size: 18, color: const Color(0xFF965AF0).withOpacity(.4)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget leading;
  final String text;
  const _Pill({required this.leading, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0x14A06EF5), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          leading,
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: const Color(0xFFE9E2FF).withOpacity(.65))),
        ]),
      );
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: SizedBox(
          width: 44, height: 44,
          child: Icon(icon, size: 23, color: Colors.white, shadows: const [Shadow(color: Color(0x80000000), blurRadius: 4)]),
        ),
      );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
      );
}

class _Entrance extends StatelessWidget {
  final Widget child;
  final int delay;
  const _Entrance({required this.child, this.delay = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + delay),
        curve: Interval(delay / (520 + delay), 1, curve: Curves.easeOutCubic),
        builder: (_, t, c) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: c)),
        child: child,
      );
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});
  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
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


/* ═══════════════ ÇƏRÇİVƏLİ AVATAR ═══════════════ */
class _Framed extends StatelessWidget {
  final String? frame;
  final double size;
  final Widget child;
  const _Framed({required this.frame, required this.size, required this.child});
  @override
  Widget build(BuildContext context) {
    if (frame == null) return child;
    final f = kFrames.firstWhere((x) => x.$1 == frame, orElse: () => kFrames.first);
    final outer = size * 1.5;
    return SizedBox(
      width: outer, height: outer,
      child: Stack(alignment: Alignment.center, children: [
        Transform.scale(scale: .95, child: child),
        IgnorePointer(child: Image.network('$_img/${f.$3}.gif', width: outer, height: outer, fit: BoxFit.contain, gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const SizedBox())),
      ]),
    );
  }
}

/* ═══════════════ ÜMUMİ BAŞLIQ ═══════════════ */
class _Header extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final bool center;
  const _Header({required this.title, this.actions = const [], this.center = true});
  @override
  Widget build(BuildContext context) => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(6, MediaQuery.of(context).padding.top + 2, 8, 4),
            decoration: BoxDecoration(color: const Color(0xCC0D001E), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.08), width: .5))),
            child: SizedBox(
              height: 48,
              child: Stack(alignment: Alignment.center, children: [
                if (center) Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Row(children: [
                  _NavIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.maybePop(context)),
                  if (!center) Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  ...actions,
                ]),
              ]),
            ),
          ),
        ),
      );
}

String _fmtN(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

/* ═══════════════ CÜZDANIM ═══════════════ */
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  static const _packs = [
    (1, 18546, 2781, 110, '0.80'),
    (2, 93500, 14025, 510, '4.80'),
    (3, 222460, 33369, 1100, '9.99'),
    (4, 410888, 61633, 1899, '19.50'),
    (5, 980245, 147036, 5000, '56.99'),
    (6, 2156789, 323518, 9999, '110.99'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        const Positioned(top: -80, right: -60, child: _Glow(size: 300, color: Color(0x557B2FF7))),
        const Positioned(bottom: -100, left: -80, child: _Glow(size: 280, color: Color(0x33FF3EA5))),
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 70, 16, 30),
          children: [
            // Balans
            _Entrance(child: ValueListenableBuilder<int>(valueListenable: jetonBalance, builder: (_, bal, __) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFF3C1A6E), Color(0xFF1A0A35)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: const Color(0x33FFD700)),
                boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Row(children: [
                Image.network('$_img/jeton.PNG', width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on_rounded, size: 40, color: Color(0xFFFFD700))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cari balans', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6))),
                  const SizedBox(height: 2),
                  Text(_fmtN(bal), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFFFD700))),
                ]),
              ]),
            ))),
            const SizedBox(height: 12),
            // VIP kartı
            _Entrance(delay: 60, child: _Pressable(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x33965AF0))),
                child: Row(children: [
                  Image.network('$_img/VIP0.png', width: 44, height: 44, errorBuilder: (_, __, ___) => const Icon(Icons.shield_rounded, size: 40, color: _lilac)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Səviyyə keçmək üçün EXP lazımdır.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(.35)),
                ]),
              ),
            )),
            const SizedBox(height: 16),
            // Paketlər
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _packs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .52),
              itemBuilder: (_, i) {
                final p = _packs[i];
                return _Entrance(delay: 120 + i * 50, child: _Pressable(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    jetonBalance.value += p.$2 + p.$3;
                    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                      content: Text('Demo: +${_fmtN(p.$2 + p.$3)} jeton əlavə olundu', textAlign: TextAlign.center),
                      behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF241F2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), margin: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x33965AF0)),
                    ),
                    child: Column(children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                        decoration: BoxDecoration(color: const Color(0x2622C55E), borderRadius: BorderRadius.circular(8)),
                        child: const Text('15% tokenin geri qaytarılması', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF5DDB8A), height: 1.2)),
                      ),
                      Expanded(child: Image.network('$_img/v${p.$1}.PNG', fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on_rounded, size: 48, color: Color(0xFFFFD700)))),
                      Text(_fmtN(p.$2), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      Text('+${_fmtN(p.$3)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF4D6A))),
                      Text('${p.$4} VİP EXP', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.5))),
                      const SizedBox(height: 8),
                      Container(
                        height: 32, width: double.infinity, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(colors: [_purple, Color(0xFF9D5CFF)]),
                          boxShadow: [BoxShadow(color: _purple.withOpacity(.35), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Text('USD ${p.$5}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ));
              },
            ),
            const SizedBox(height: 18),
            Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('Bu sifarişi təqdim etməklə, siz ', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.45))),
              GestureDetector(onTap: () => Navigator.of(context).push(_slide(const _LegalPage(title: 'Xidmət Şərtləri'))),
                  child: const Text('"Xidmət Şərtləri"', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _lilac))),
              Text(' və ', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.45))),
              GestureDetector(onTap: () => Navigator.of(context).push(_slide(const _LegalPage(title: 'Məxfilik Siyasəti'))),
                  child: const Text('"Məxfilik Siyasəti"', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _lilac))),
              Text(' ilə razılaşırsınız.', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.45))),
            ]),
          ],
        ),
        Positioned(top: 0, left: 0, right: 0, child: _Header(title: 'Cüzdanım', actions: [
          _NavIcon(icon: Icons.headset_mic_outlined, onTap: () {}),
          _NavIcon(icon: Icons.history_rounded, onTap: () {}),
        ])),
      ]),
    );
  }
}

class _LegalPage extends StatelessWidget {
  final String title;
  const _LegalPage({required this.title});
  @override
  Widget build(BuildContext context) {
    final data = title == 'Xidmət Şərtləri' ? kTerms : kPrivacy;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _Header(title: title),
        Expanded(child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
          children: [
            Text('Velvet $title', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Son yenilənmə: 28 sentyabr 2026', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.45))),
            const SizedBox(height: 18),
            for (final sec in data) ...[
              Text(sec.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final p in sec.$2)
                Padding(
                  padding: EdgeInsets.only(bottom: 8, left: p.startsWith('•') ? 8 : 0),
                  child: Text(p, style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white.withOpacity(.78),
                      fontWeight: RegExp(r'^[a-c]\)').hasMatch(p) ? FontWeight.w700 : FontWeight.w400)),
                ),
              const SizedBox(height: 12),
            ],
          ],
        )),
      ]),
    );
  }
}

/* ═══════════════ PROFİLİ DÜZƏLT ═══════════════ */
class _ProfileData {
  String name, bio, country, flag, city;
  int age;
  String gender = 'Kişi';
  _ProfileData(this.name, this.bio, this.country, this.flag, this.city, this.age);
}

const _countries = {
  'Azərbaycan': ('🇦🇿', ['Bakı', 'Gəncə', 'Sumqayıt', 'Mingəçevir', 'Naxçıvan', 'Lənkəran', 'Şəki', 'Quba', 'Şamaxı', 'Qəbələ', 'Şuşa']),
  'Türkiyə': ('🇹🇷', ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya', 'Trabzon']),
  'Rusiya': ('🇷🇺', ['Moskva', 'Sankt-Peterburq', 'Kazan', 'Novosibirsk', 'Yekaterinburq']),
  'Gürcüstan': ('🇬🇪', ['Tbilisi', 'Kutaisi', 'Batumi', 'Rustavi']),
  'Almaniya': ('🇩🇪', ['Berlin', 'Hamburq', 'Münhen', 'Köln', 'Frankfurt']),
  'ABŞ': ('🇺🇸', ['Nyu-York', 'Los-Anceles', 'Çikaqo', 'Hyuston']),
  'Ukrayna': ('🇺🇦', ['Kiyev', 'Xarkov', 'Odessa', 'Lvov']),
  'Qazaxıstan': ('🇰🇿', ['Almatı', 'Astana', 'Şymkent']),
  'Özbəkistan': ('🇺🇿', ['Daşkənd', 'Samarqənd', 'Buxara']),
  'İngiltərə': ('🇬🇧', ['London', 'Mançester', 'Liverpool']),
};

class _EditProfile extends StatefulWidget {
  final _ProfileData data;
  const _EditProfile({required this.data});
  @override
  State<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
  late final _name = TextEditingController(text: widget.data.name);
  late final _bio = TextEditingController(text: widget.data.bio);
  late String _country = _countries.containsKey(widget.data.country) ? widget.data.country : 'Azərbaycan';
  late String _city = widget.data.city;
  late int _age = widget.data.age;
  late String _gender = widget.data.gender;

  @override
  void dispose() { _name.dispose(); _bio.dispose(); super.dispose(); }

  void _save() {
    final d = widget.data;
    d.name = _name.text.trim().isEmpty ? d.name : _name.text.trim();
    d.bio = _bio.text.trim();
    d.country = _country;
    d.flag = _countries[_country]!.$1;
    d.city = _city;
    d.age = _age;
    d.gender = _gender;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  Widget _row(IconData icon, String label, Widget right) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x1AA06EF5))),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(.65)),
          const SizedBox(width: 12),
          SizedBox(width: 96, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(child: Align(alignment: Alignment.centerRight, child: right)),
        ]),
      );

  Widget _dropdown(String value, List<String> items, ValueChanged<String> onChanged) => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: const Color(0xFF1A0035),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          iconEnabledColor: _lilac,
          items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i))],
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cities = _countries[_country]!.$2;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _Header(title: 'Profili Düzəlt', actions: [
          _Pressable(onTap: _save, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [_purple, _pink])),
            child: const Text('Saxla', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          )),
        ]),
        Expanded(child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 40),
          children: [
            _row(Icons.person_outline_rounded, 'İstifadəçi adı', TextField(
              controller: _name, textAlign: TextAlign.right, cursorColor: _lilac,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'Ad daxil edin'),
            )),
            _row(Icons.wc_rounded, 'Cins', Wrap(spacing: 6, children: [
              for (final g in ['Kişi', 'Qadın', 'Digər'])
                _Pressable(onTap: () => setState(() => _gender = g), child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9),
                      color: _gender == g ? _purple.withOpacity(.25) : Colors.transparent,
                      border: Border.all(color: _gender == g ? _purple : const Color(0x24A06EF5))),
                  child: Text(g, style: TextStyle(fontSize: 12, color: _gender == g ? _lilac : Colors.white54)),
                )),
            ])),
            _row(Icons.cake_outlined, 'Yaş', Row(mainAxisSize: MainAxisSize.min, children: [
              _step(Icons.remove_rounded, () => setState(() => _age = math.max(18, _age - 1))),
              SizedBox(width: 40, child: Text('$_age', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              _step(Icons.add_rounded, () => setState(() => _age = math.min(99, _age + 1))),
            ])),
            _row(Icons.public_rounded, 'Ölkə', _dropdown(_country, _countries.keys.toList(), (v) => setState(() { _country = v; _city = _countries[v]!.$2.first; }))),
            _row(Icons.location_on_outlined, 'Bölgə', _dropdown(_city, cities, (v) => setState(() => _city = v))),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x1AA06EF5))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.notes_rounded, size: 18, color: Colors.white.withOpacity(.65)), const SizedBox(width: 10), const Text('Haqqında', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 10),
                TextField(
                  controller: _bio, maxLines: 3, cursorColor: _lilac, style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Özün haqqında yaz...', filled: true, fillColor: const Color(0x12A06EF5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ]),
            ),
          ],
        )),
      ]),
    );
  }

  Widget _step(IconData i, VoidCallback onTap) => _Pressable(onTap: onTap, child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: const Color(0x14A06EF5), border: Border.all(color: const Color(0x26A06EF5))),
        child: Icon(i, size: 16),
      ));
}

/* ═══════════════ DEKORASİYA MAĞAZASI ═══════════════ */
class StoreScreen extends StatefulWidget {
  final String name;
  const StoreScreen({super.key, required this.name});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tab = 0;
  static const _prices = {3: 100, 7: 200, 30: 500};

  void _openFrame((String, String, String, Color) f) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.5),
      builder: (_) => _FrameSheet(frame: f, name: widget.name, prices: _prices),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        ClipRect(child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            color: const Color(0xCC0D001E),
            padding: EdgeInsets.fromLTRB(6, top + 2, 12, 0),
            child: Column(children: [
              SizedBox(height: 48, child: Row(children: [
                _NavIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.maybePop(context)),
                const Text('Dekorasiya Mağazası', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const Spacer(),
                _Pressable(onTap: () {}, child: Container(
                  height: 32, padding: const EdgeInsets.only(left: 9, right: 12),
                  decoration: BoxDecoration(color: const Color(0xFFE0102D), borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x4DE0102D), blurRadius: 8, offset: Offset(0, 2))]),
                  child: const Row(children: [Icon(Icons.person_outline_rounded, size: 16), SizedBox(width: 4), Text('Mənim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]),
                )),
              ])),
              Row(children: [
                for (final (i, t) in ['Çərçivələr', 'Giriş Animasiyası'].indexed)
                  GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); setState(() => _tab = i); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 10, right: 12),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == i ? Colors.white : Colors.transparent, width: 2))),
                      child: Text(t, style: TextStyle(fontSize: 15, fontWeight: _tab == i ? FontWeight.w600 : FontWeight.w300, color: _tab == i ? Colors.white : Colors.white54)),
                    ),
                  ),
              ]),
            ]),
          ),
        )),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _tab == 0 ? _frames() : _entrance(),
        )),
        // Balans paneli
        ValueListenableBuilder<int>(valueListenable: jetonBalance, builder: (_, bal, __) => Container(
          padding: EdgeInsets.fromLTRB(18, 12, 18, math.max(16, MediaQuery.of(context).padding.bottom)),
          decoration: BoxDecoration(color: const Color(0x26A06EF5), border: Border(top: BorderSide(color: Colors.white.withOpacity(.06)))),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CARİ JETONUM', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white.withOpacity(.4))),
              const SizedBox(height: 4),
              Row(children: [
                Image.network('$_img/jeton.PNG', width: 22, height: 22, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on_rounded, size: 22, color: Color(0xFFFFD700))),
                const SizedBox(width: 7),
                Text(_fmtN(bal), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFFFD700))),
              ]),
            ]),
            const Spacer(),
            _Pressable(
              onTap: () => Navigator.of(context).push(_slide(const WalletScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF9500)]),
                    boxShadow: const [BoxShadow(color: Color(0x4DFF9600), blurRadius: 16, offset: Offset(0, 4))]),
                child: const Text('+ Yüklə', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2A0E00))),
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _frames() => GridView.builder(
        key: const ValueKey('frames'),
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        itemCount: kFrames.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .8),
        itemBuilder: (_, i) {
          final f = kFrames[i];
          final active = activeFrame.value == f.$1;
          return _Entrance(delay: i * 40, child: _Pressable(
            onTap: () => _openFrame(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: active ? f.$4.withOpacity(.08) : Colors.white.withOpacity(.03),
                border: Border.all(color: active ? f.$4 : const Color(0x1AA06EF5), width: 1.5),
                boxShadow: active ? [BoxShadow(color: f.$4.withOpacity(.4), blurRadius: 18)] : [],
              ),
              child: Column(children: [
                Expanded(child: Stack(alignment: Alignment.center, children: [
                  FractionallySizedBox(widthFactor: .62, heightFactor: .62, child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A0035), border: Border.all(color: Colors.white, width: 1.5)),
                    alignment: Alignment.center,
                    child: Text(widget.name[0].toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  )),
                  Image.network('$_img/${f.$3}.gif', fit: BoxFit.contain, gaplessPlayback: true, errorBuilder: (_, __, ___) => const SizedBox()),
                  if (active) Positioned(top: 6, right: 6, child: Container(
                    width: 18, height: 18, decoration: BoxDecoration(color: f.$4, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, size: 12, color: Colors.black),
                  )),
                ])),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.network('$_img/jeton.PNG', width: 12, height: 12, errorBuilder: (_, __, ___) => const SizedBox()),
                    const SizedBox(width: 4),
                    Text(active ? 'Aktiv' : '${_prices[7]}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? f.$4 : const Color(0xFFFFD700))),
                  ]),
                ),
              ]),
            ),
          ));
        },
      );

  Widget _entrance() => ListView(
        key: const ValueKey('entrance'),
        padding: const EdgeInsets.all(16),
        children: [
          _Entrance(child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: const Color(0x0FA06EF5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1AA06EF5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(aspectRatio: 16 / 9, child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A0060), Color(0xFF0D001E)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                alignment: Alignment.center,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _purple.withOpacity(.8), boxShadow: [BoxShadow(color: _purple.withOpacity(.6), blurRadius: 24)]),
                  child: const Icon(Icons.directions_car_rounded, size: 28),
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Maşın Giriş Animasiyası v1', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Otağa girəndə xüsusi giriş animasiyası', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.6))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Image.network('$_img/jeton.PNG', width: 14, height: 14, errorBuilder: (_, __, ___) => const SizedBox()),
                    const SizedBox(width: 6),
                    const Text('800 / 30 gün', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFFD700))),
                    const Spacer(),
                    _Pressable(
                      onTap: () {
                        if (jetonBalance.value < 800) { _warn(); return; }
                        jetonBalance.value -= 800;
                        HapticFeedback.mediumImpact();
                        _done('Giriş animasiyası aktivləşdi');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [_purple, _lilac])),
                        child: const Text('Aktivləşdir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          )),
        ],
      );

  void _warn() => ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(const SnackBar(
        content: Text('Jeton kifayət etmir', textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFFFF9500)));
  void _done(String t) => ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
        content: Text(t, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF241F2E)));
}

class _FrameSheet extends StatefulWidget {
  final (String, String, String, Color) frame;
  final String name;
  final Map<int, int> prices;
  const _FrameSheet({required this.frame, required this.name, required this.prices});
  @override
  State<_FrameSheet> createState() => _FrameSheetState();
}

class _FrameSheetState extends State<_FrameSheet> {
  int _days = 7;
  String? _err;
  @override
  Widget build(BuildContext context) {
    final f = widget.frame;
    final price = widget.prices[_days]!;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, math.max(24, MediaQuery.of(context).padding.bottom + 12)),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF130030), Color(0xFF09001A)]),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        SizedBox(width: 180, height: 180, child: Stack(alignment: Alignment.center, children: [
          Container(
            width: 124, height: 124,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A0035)),
            alignment: Alignment.center,
            child: Text(widget.name[0].toUpperCase(), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          ),
          Image.network('$_img/${f.$3}.gif', width: 180, height: 180, fit: BoxFit.contain, gaplessPlayback: true, errorBuilder: (_, __, ___) => const SizedBox()),
        ])),
        const SizedBox(height: 8),
        Text('AVATAR ÇƏRÇİVƏSİ', style: TextStyle(fontSize: 11, letterSpacing: 3, color: Colors.white.withOpacity(.5))),
        const SizedBox(height: 6),
        Text(f.$2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: f.$4, shadows: [Shadow(color: f.$4.withOpacity(.5), blurRadius: 12)])),
        const SizedBox(height: 18),
        Row(children: [
          for (final d in [3, 7, 30])
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _Pressable(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _days = d); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _days == d ? f.$4.withOpacity(.12) : const Color(0x0FA06EF5),
                    border: Border.all(color: _days == d ? f.$4 : const Color(0x1AA06EF5), width: 1.5),
                    boxShadow: _days == d ? [BoxShadow(color: f.$4.withOpacity(.35), blurRadius: 12)] : [],
                  ),
                  child: Column(children: [
                    Text('$d', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _days == d ? f.$4 : Colors.white)),
                    Text('GÜN', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.55))),
                    const SizedBox(height: 6),
                    Text('${widget.prices[d]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _days == d ? const Color(0xFFFFD700) : const Color(0x99FFC800))),
                  ]),
                ),
              ),
            )),
        ]),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _err == null ? const SizedBox(height: 0) : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_err!, style: const TextStyle(color: Color(0xFFFF9500), fontWeight: FontWeight.w700)),
          ),
        ),
        _Pressable(
          onTap: () {
            if (jetonBalance.value < price) { HapticFeedback.vibrate(); setState(() => _err = 'Jeton kifayət etmir'); return; }
            jetonBalance.value -= price;
            activeFrame.value = f.$1;
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          child: Container(
            height: 52, width: double.infinity, alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [f.$4, f.$4.withOpacity(.7)]),
              boxShadow: [BoxShadow(color: f.$4.withOpacity(.45), blurRadius: 24, offset: const Offset(0, 6))],
            ),
            child: Text('Aktivləşdir — $price Jeton', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(valueListenable: jetonBalance, builder: (_, b, __) =>
            Text('Balans: ${_fmtN(b)} jeton', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.5)))),
      ]),
    );
  }
}
