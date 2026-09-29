// Velvet — Profil ekranı (Flutter). Düzən index.tsx-dəki profil ilə eynidir.
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _img = 'https://xx-jade.vercel.app/images/images';
const _bg = Color(0xFF07000F);
const _purple = Color(0xFF7B2FF7);
const _pink = Color(0xFFFF3EA5);
const _lilac = Color(0xFFC084FC);

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
                    child: Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
                  _NavIcon(icon: Icons.visibility_outlined, onTap: () => _toast('Profil ziyarətçiləri')),
                  _NavIcon(icon: Icons.edit_outlined, onTap: () => _toast('Profili düzəlt')),
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
            _Pressable(
              onTap: () => _toast('Avatar'),
              child: SizedBox(
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
                      child: Text(widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'İ', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    ),
                  )),
                  Positioned(right: 2, bottom: 2, child: Container(
                    width: 15, height: 15,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00FF88), border: Border.all(color: _bg, width: 2.5)),
                  )),
                ]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
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
          if (widget.bio.isNotEmpty)
            _Entrance(delay: 60, child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(widget.bio, style: TextStyle(fontSize: 13, height: 1.5, color: const Color(0xFFE9E2FF).withOpacity(.65))),
            )),
          _Entrance(delay: 100, child: Wrap(spacing: 6, runSpacing: 6, children: [
            _Pill(leading: Text(widget.flag, style: const TextStyle(fontSize: 13)), text: widget.country),
            _Pill(leading: const Icon(Icons.location_on_outlined, size: 12, color: Color(0x66D2C3FA)), text: widget.city),
            _Pill(leading: const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0x66D2C3FA)), text: '${widget.age} yaş'),
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
                      _MenuRow(item: it, onTap: () => _toast(it.label)),
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
          onTap: () { HapticFeedback.mediumImpact(); _toast('Çıxış'); },
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
