// Velvet — Ana səhifə (Flutter versiyası)
// İstifadə: flutter create velvet_app → lib/main.dart faylını bununla əvəz et → flutter run
// Şəkillər birbaşa saytdan yüklənir (asset quraşdırmağa ehtiyac yoxdur).

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'room_screen.dart' show RoomScreen;

const kImg = 'https://xx-jade.vercel.app/images/images';
const kBg = Color(0xFF07000F);
const kPurple = Color(0xFF7B2FF7);
const kPink = Color(0xFFFF3EA5);
const kLilac = Color(0xFFC084FC);
const kCyan = Color(0xFF00D4FF);

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const VelvetApp());
}

class VelvetApp extends StatelessWidget {
  const VelvetApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velvet',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        fontFamily: 'Helvetica Neue',
        useMaterial3: true,
      ),
      home: const HomeScreen(name: 'Demo İstifadəçi', jeton: 10000),
    );
  }
}

/* ─────────────── ANA SƏHİFƏ ─────────────── */
class HomeScreen extends StatefulWidget {
  final String name;
  final int jeton;
  const HomeScreen({super.key, required this.name, required this.jeton});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(children: [
        // Arxa plan parıltıları
        const Positioned(top: -80, left: -60, child: _Orb(size: 260, color: kPurple, opacity: .09)),
        const Positioned(top: -20, right: -40, child: _Orb(size: 200, color: kPink, opacity: .06)),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _TopBar(name: widget.name, jeton: widget.jeton)),
            const SliverToBoxAdapter(child: _Hero()),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Oyunlar',
                chip: 'Tezliklə daha çox',
                child: _GameCard(onTap: () => _showSoon(context)),
              ),
            ),
            const SliverToBoxAdapter(
              child: _Section(title: 'Canlı otaqlar', chip: 'Hamısı', child: _LiveRooms()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ]),
      bottomNavigationBar: _BottomNav(index: _tab, onTap: (i) { if (i == 2) { openRoom(context); return; } setState(() => _tab = i); }),
    );
  }

  void _showSoon(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Bağla',
      barrierColor: Colors.black.withOpacity(.6),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const _SoonDialog(),
      transitionBuilder: (_, a, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: a, child: child),
      ),
    );
  }
}

/* ─────────────── ÜST MENYU ─────────────── */
class _TopBar extends StatelessWidget {
  final String name;
  final int jeton;
  const _TopBar({required this.name, required this.jeton});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(children: [
      // arxaplan.PNG — aşağıya doğru səhifə rənginə yumşaq keçid
      Positioned.fill(
        child: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0, .45, 1],
          ).createShader(r),
          blendMode: BlendMode.dstIn,
          child: Image.network('$kImg/arxaplan.PNG', fit: BoxFit.cover, alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const SizedBox()),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16, math.max(10, top), 16, 40),
        child: SizedBox(
          height: 44,
          child: Row(children: [
            // Avatar
            Container(
              width: 40, height: 40, padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kPurple, kPink])),
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1A0035), border: Border.all(color: const Color(0xFF1A0035), width: 2)),
                  alignment: Alignment.center,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'V',
                      style: const TextStyle(color: kLilac, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
                Positioned(right: 0, bottom: 0, child: Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF22C55E), border: Border.all(color: kBg, width: 2)),
                )),
              ]),
            ),
            const SizedBox(width: 16),
            // Jeton
            Container(
              height: 34, padding: const EdgeInsets.only(left: 8, right: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(17)),
              child: Row(children: [
                Image.network('$kImg/jeton.PNG', width: 18, height: 18, errorBuilder: (_, __, ___) => const Icon(Icons.circle, size: 18, color: Colors.amber)),
                const SizedBox(width: 6),
                Text(_fmt(jeton), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(width: 6),
                Container(width: 26, height: 26, decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle),
                    child: const Icon(Icons.add_rounded, size: 16, color: Colors.white)),
              ]),
            ),
            const Spacer(),
            _CircleBtn(icon: Icons.search_rounded, onTap: () {}),
            const SizedBox(width: 8),
            SizedBox(width: 36, height: 36, child: Transform.scale(scale: 1.4,
                child: Image.network('$kImg/icon.gif', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()))),
          ]),
        ),
      ),
    ]);
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: Colors.white.withOpacity(.08), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      );
}

/* ─────────────── HERO ─────────────── */
class _Hero extends StatefulWidget {
  const _Hero();
  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF0D0022), borderRadius: BorderRadius.circular(24)),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Stack(alignment: Alignment.center, children: [
            Positioned(top: -40, left: -20, child: _Orb(size: 180, color: kPurple, opacity: .35 + .1 * math.sin(t))),
            Positioned(bottom: -30, right: 20, child: _Orb(size: 150, color: kPink, opacity: .25 + .08 * math.cos(t))),
            // Fırlanan halqalar
            Transform.rotate(angle: t / 2.5, child: _Ring(size: 100, color: kLilac.withOpacity(.2))),
            Transform.rotate(angle: -t / 1.75, child: _Ring(size: 84, color: kPink.withOpacity(.18), dashed: true)),
            // Orbit nöqtələri
            for (final (i, col) in [kPink, kLilac, kCyan].indexed)
              Transform.translate(
                offset: Offset(math.cos(t + i * 2.094) * 52, math.sin(t + i * 2.094) * 52),
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: col, shape: BoxShape.circle, boxShadow: [BoxShadow(color: col, blurRadius: 6)])),
              ),
            // V loqosu
            Transform.scale(
              scale: 1 + .04 * math.sin(t * 2),
              child: Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF1A0035), Color(0xFF2D0060)]),
                  border: Border.all(color: kPurple.withOpacity(.6), width: 2),
                  boxShadow: [BoxShadow(color: kPurple.withOpacity(.45), blurRadius: 24)],
                ),
                alignment: Alignment.center,
                child: const Text('V', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
            ),
            // Səs dalğası
            Positioned(
              right: 20,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final (i, col) in [const Color(0xFFFF6B35), kPink, kLilac, kPurple, kCyan, kLilac].indexed)
                  Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 5,
                    height: 46 * (.2 + .8 * ((math.sin(t * 4 + i * .8) + 1) / 2)),
                    decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3)),
                  ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

/* ─────────────── BÖLMƏ ─────────────── */
class _Section extends StatelessWidget {
  final String title, chip;
  final Widget child;
  const _Section({required this.title, required this.chip, required this.child});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: kPurple.withOpacity(.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: kPurple.withOpacity(.3))),
              child: Row(children: [
                Text(chip, style: const TextStyle(fontSize: 10, color: kLilac, fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right_rounded, size: 14, color: kLilac),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

/* ─────────────── OYUN KARTI ─────────────── */
class _GameCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GameCard({required this.onTap});
  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          height: 200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const RadialGradient(colors: [Color(0xFF1A0050), Color(0xFF0A0018)], radius: .9),
            border: Border.all(color: kPurple.withOpacity(.25)),
          ),
          child: Stack(children: [
            const Positioned(top: -80, left: -60, child: _Orb(size: 300, color: kPurple, opacity: .2)),
            const Positioned(bottom: -60, right: -20, child: _Orb(size: 200, color: kPink, opacity: .15)),
            Center(child: Image.network('$kImg/domino.PNG', height: 110, errorBuilder: (_, __, ___) => const Icon(Icons.casino_rounded, size: 80, color: Colors.white))),
            Positioned(top: 14, right: 14, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: kCyan.withOpacity(.4))),
              child: const Row(children: [
                CircleAvatar(radius: 3, backgroundColor: kCyan),
                SizedBox(width: 5),
                Text('1.2K', style: TextStyle(fontSize: 10, color: kCyan, fontWeight: FontWeight.w700)),
              ]),
            )),
            Positioned(bottom: 14, left: 14, child: Row(children: [
              for (final (i, c) in [kPink, kPurple, kCyan].indexed)
                Transform.translate(offset: Offset(-10.0 * i, 0), child: Container(width: 26, height: 26,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: kBg, width: 2)))),
              const Text('+48', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
            ])),
            Positioned(bottom: 14, right: 14, child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [kPurple, kPink]),
                  boxShadow: [BoxShadow(color: kPurple.withOpacity(.5), blurRadius: 16, offset: const Offset(0, 4))]),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            )),
          ]),
        ),
      );
}

/* ─────────────── CANLI OTAQLAR ─────────────── */
class _LiveRooms extends StatelessWidget {
  const _LiveRooms();
  static const _rooms = [
    ('Qızıl Saatlar', '128', [kPink, kPurple, kCyan]),
    ('Gecə Partisi', '64', [kLilac, Color(0xFFFF6B35), kPink]),
    ('VIP Lounge', '256', [kPink, kPurple, kLilac]),
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _rooms.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final (name, count, cols) = _rooms[i];
            return _Pressable(
              onTap: () => openRoom(context),
              child: Container(
                width: 140, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kPurple.withOpacity(.1), borderRadius: BorderRadius.circular(18), border: Border.all(color: kPurple.withOpacity(.25))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    CircleAvatar(radius: 2.5, backgroundColor: kCyan), SizedBox(width: 4),
                    Text('CANLI', style: TextStyle(fontSize: 8, color: kCyan, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(height: 26, child: Stack(children: [
                    for (final (k, c) in cols.indexed)
                      Positioned(left: k * 19.0, child: Container(width: 26, height: 26,
                          decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0018), width: 2)))),
                  ])),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('$count dinləyici', style: const TextStyle(fontSize: 9, color: Color(0xFFD9C6FF))),
                  const Spacer(),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(color: kPurple.withOpacity(.3), borderRadius: BorderRadius.circular(8), border: Border.all(color: kPurple.withOpacity(.5))),
                    alignment: Alignment.center,
                    child: const Text('Qoşul →', style: TextStyle(fontSize: 9, color: kLilac, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            );
          },
        ),
      );
}

/* ─────────────── TEZLİKLƏ DİALOQU ─────────────── */
class _SoonDialog extends StatelessWidget {
  const _SoonDialog();
  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300, padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A0035), Color(0xFF0D001E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kPurple.withOpacity(.5)),
              boxShadow: [BoxShadow(color: kPurple.withOpacity(.35), blurRadius: 40)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 70, height: 70, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kPurple, kPink])),
                  child: const Icon(Icons.sports_esports_rounded, size: 34, color: Colors.white)),
              const SizedBox(height: 16),
              const Text('DOMINO', style: TextStyle(fontSize: 9, letterSpacing: 3, color: kLilac, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Tezliklə!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Bu oyun hazırlanır. Tezliklə aktiv olacaqdır.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: kLilac, height: 1.6)),
              const SizedBox(height: 20),
              _Pressable(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48, width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [kPurple, kPink])),
                  alignment: Alignment.center,
                  child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      );
}

/* ─────────────── ALT MENYU ─────────────── */
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});
  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Ana səhifə', null),
    (Icons.sports_esports_outlined, Icons.sports_esports_rounded, 'Oyunlar', null),
    (Icons.mic_none_rounded, Icons.mic_rounded, 'Otaq', null),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Mesajlar', '18'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil', null),
  ];
  @override
  Widget build(BuildContext context) => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF0D001E).withOpacity(.92), border: Border(top: BorderSide(color: Colors.white.withOpacity(.1), width: .5))),
            padding: EdgeInsets.only(bottom: math.max(6, MediaQuery.of(context).padding.bottom)),
            child: SizedBox(
              height: 54,
              child: Row(children: [
                for (final (i, it) in _items.indexed)
                  Expanded(
                    child: _Pressable(
                      onTap: () { HapticFeedback.selectionClick(); onTap(i); },
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Stack(clipBehavior: Clip.none, children: [
                          Icon(index == i ? it.$2 : it.$1, size: 24, color: index == i ? kPurple : const Color(0xFF8E8E93)),
                          if (it.$4 != null)
                            Positioned(top: -4, right: -9, child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4), constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                              decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(9), border: Border.all(color: kBg, width: 2)),
                              alignment: Alignment.center,
                              child: Text(it.$4!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                            )),
                        ]),
                        const SizedBox(height: 3),
                        Text(it.$3, style: TextStyle(fontSize: 10, fontWeight: index == i ? FontWeight.w600 : FontWeight.w500, color: index == i ? kPurple : const Color(0xFF8E8E93))),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

/* ─────────────── KÖMƏKÇİLƏR ─────────────── */
class _Orb extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _Orb({required this.size, required this.color, required this.opacity});
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(width: size, height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(opacity), color.withOpacity(0)]))),
      );
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final bool dashed;
  const _Ring({required this.size, required this.color, this.dashed = false});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _RingPainter(color, dashed));
}

class _RingPainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _RingPainter(this.color, this.dashed);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final r = Rect.fromLTWH(0, 0, s.width, s.height);
    if (!dashed) { c.drawOval(r, p); return; }
    for (var a = 0.0; a < 2 * math.pi; a += .35) { c.drawArc(r, a, .18, false, p); }
  }
  @override
  bool shouldRepaint(_) => false;
}

/// Basanda iOS kimi yüngül sıxılma effekti
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
        child: AnimatedScale(scale: _down ? .95 : 1, duration: const Duration(milliseconds: 120), child: widget.child),
      );
}

/// Otağa axıcı (fade + slide) keçid
void openRoom(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const RoomScreen(myName: 'Demo'),
    transitionsBuilder: (_, a, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .06), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  ));
}

String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
