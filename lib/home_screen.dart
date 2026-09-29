// Velvet — Ana səhifə (index.tsx-dəki son dizayn)
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final int jeton;
  final VoidCallback onRoom;
  final VoidCallback onProfile;
  const HomeScreen({super.key, required this.name, required this.jeton, required this.onRoom, required this.onProfile});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _page = PageController();
  int _slide = 0;
  int _cat = 0;
  Timer? _timer;
  static const _banners = ['turnir.JPG', 'vipheftesi.PNG'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!_page.hasClients) return;
      final next = (_slide + 1) % _banners.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final b in _banners) { precacheImage(NetworkImage('$kImg/$b'), context); }
    precacheImage(const NetworkImage('$kImg/home-header.JPG'), context);
  }

  @override
  void dispose() { _timer?.cancel(); _page.dispose(); super.dispose(); }

  void _soon(String game) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Bağla',
      barrierColor: Colors.black.withOpacity(.7),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => Center(child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330, padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF29134A), Color(0xFF110B20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Color(0x7A000000), blurRadius: 70, offset: Offset(0, 24))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(width: 78, height: 78,
                child: game == 'Domino' ? netImg('domino-4d.JPG', align: const Alignment(.46, 0)) : Container(color: kPurple, child: const Icon(Icons.emoji_events_rounded, size: 32)))),
            const SizedBox(height: 18),
            Text(game.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFFDCB9FF), fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Tezliklə yayımlanacaq', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('$game oyunu hazırlanır. Çox yaxında burada oynaya biləcəksiniz.', textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.55, color: Color(0xFFC9BED7))),
            const SizedBox(height: 22),
            VPress(onTap: () => Navigator.pop(context), child: Container(
              height: 48, alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [kPurple, Color(0xFFE535A4)])),
              child: const Text('Bağla', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      )),
      transitionBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: .92, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned(top: -80, left: -60, child: VGlow(size: 260, color: Color(0x177B2FF7))),
      CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _topBar()),
          SliverToBoxAdapter(child: Transform.translate(offset: const Offset(0, -18), child: VEntrance(child: _banner()))),
          SliverToBoxAdapter(child: VEntrance(delay: 80, child: _quick())),
          SliverToBoxAdapter(child: _head('Oyunlar')),
          SliverToBoxAdapter(child: VEntrance(delay: 140, child: _games())),
          SliverToBoxAdapter(child: _head('Canlı otaqlar')),
          SliverToBoxAdapter(child: VEntrance(delay: 200, child: _chips())),
          SliverToBoxAdapter(child: VEntrance(delay: 240, child: _rooms())),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    ]);
  }

  Widget _topBar() {
    final top = MediaQuery.of(context).padding.top;
    return Stack(children: [
      Positioned.fill(child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent], stops: [0, .5, 1]).createShader(r),
        blendMode: BlendMode.dstIn,
        child: netImg('home-header.JPG', align: Alignment.topCenter),
      )),
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kBg.withOpacity(.1), kBg.withOpacity(.25), kBg.withOpacity(.7), kBg], stops: const [0, .25, .65, 1])))),
      Padding(
        padding: EdgeInsets.fromLTRB(16, math.max(10, top), 16, 40),
        child: SizedBox(height: 44, child: Row(children: [
          VPress(onTap: widget.onProfile, child: Container(
            width: 40, height: 40, padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kPurple, kPink])),
            child: Stack(children: [
              Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A0035)), alignment: Alignment.center,
                  child: Text(widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'V', style: const TextStyle(color: kLilac, fontWeight: FontWeight.w800, fontSize: 15))),
              Positioned(right: 0, bottom: 0, child: Container(width: 11, height: 11,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF22C55E), border: Border.all(color: kBg, width: 2)))),
            ]),
          )),
          const SizedBox(width: 16),
          VPress(onTap: widget.onProfile, child: Container(
            height: 34, padding: const EdgeInsets.only(left: 8, right: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(17)),
            child: Row(children: [
              netImg('jeton.PNG', w: 18, h: 18, fit: BoxFit.contain),
              const SizedBox(width: 6),
              Text(fmtNum(widget.jeton), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(width: 6),
              Container(width: 26, height: 26, decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, size: 16)),
            ]),
          )),
          const Spacer(),
          VPress(onTap: () => vToast(context, 'Axtarış tezliklə'), child: Container(
            width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(.08), shape: BoxShape.circle),
            child: const Icon(Icons.search_rounded, size: 20),
          )),
          const SizedBox(width: 8),
          VPress(onTap: () => vToast(context, 'Gündəlik bonus'), child: SizedBox(width: 36, height: 36,
              child: Transform.scale(scale: 1.4, child: netImg('icon.gif', fit: BoxFit.contain)))),
        ])),
      ),
    ]);
  }

  Widget _banner() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(height: 168, child: Stack(children: [
            Container(color: const Color(0xFF140A24)),
            PageView.builder(
              controller: _page,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _slide = i),
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _page,
                builder: (_, child) {
                  double d = 0;
                  if (_page.hasClients && _page.position.haveDimensions) d = (_page.page ?? 0) - i;
                  return Transform.translate(offset: Offset(d * 40, 0), child: child);
                },
                child: VPress(scale: .97, onTap: () => vToast(context, i == 0 ? 'Həftəlik Turnir' : 'VIP həftəsi'),
                    child: netImg(_banners[i])),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 10, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var k = 0; k < _banners.length; k++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350), curve: Curves.easeOutBack,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: k == _slide ? 18 : 6, height: 6,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: k == _slide ? Colors.white : Colors.white54),
                ),
            ])),
          ])),
        ),
      );

  Widget _quick() {
    final items = [
      ('Bonus', const Color(0xFFFF7B6D), const Color(0xFFFF174D), Icons.inventory_2_outlined),
      ('Mağaza', const Color(0xFFD170FF), const Color(0xFF7C2CFF), Icons.shopping_bag_outlined),
      ('Reytinq', const Color(0xFFFFD257), const Color(0xFFF47B0B), Icons.emoji_events_outlined),
      ('Tədbirlər', const Color(0xFF5AD8FF), const Color(0xFF087EE8), Icons.calendar_month_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Row(children: [
        for (final q in items)
          Expanded(child: VPress(
            onTap: () => q.$1 == 'Mağaza' || q.$1 == 'Bonus' ? widget.onProfile() : vToast(context, '${q.$1} tezliklə'),
            child: Column(children: [
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [q.$2, q.$3]),
                  border: Border.all(color: Colors.white.withOpacity(.24)),
                  boxShadow: [BoxShadow(color: q.$3.withOpacity(.4), blurRadius: 22, offset: const Offset(0, 9))],
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Positioned(left: 7, top: 4, child: Container(width: 35, height: 13,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withOpacity(.25)))),
                  Icon(q.$4, size: 29, shadows: const [Shadow(color: Color(0x57000000), blurRadius: 2, offset: Offset(0, 2))]),
                ]),
              ),
              const SizedBox(height: 8),
              Text(q.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(.9))),
            ]),
          )),
      ]),
    );
  }

  Widget _head(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(children: [
          Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('Hamısı ›', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.5))),
        ]),
      );

  Widget _games() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
        child: Row(children: [
          Expanded(child: _gameCard('Domino', '1.2K', img: 'domino-4d.JPG')),
          const SizedBox(width: 10),
          Expanded(child: _gameCard('Kart', '840', c1: kPink, c2: const Color(0xFF72243E))),
        ]),
      );

  Widget _gameCard(String n, String p, {String? img, Color c1 = kPurple, Color c2 = const Color(0xFF3C3489)}) => VPress(
        onTap: () => _soon(n),
        child: Container(
          height: 120,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: img == null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]) : null,
            color: img != null ? const Color(0xFF160817) : null,
            boxShadow: const [BoxShadow(color: Color(0x3D50228C), blurRadius: 20, offset: Offset(0, 8))],
          ),
          child: Stack(children: [
            if (img != null) Positioned.fill(child: _Hover(child: netImg(img)))
            else Positioned(right: -10, bottom: -18, child: Container(width: 96, height: 96, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.14)))),
            Positioned(right: 10, top: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.28), borderRadius: BorderRadius.circular(9)),
              child: const Text('Tezliklə', style: TextStyle(fontSize: 10)),
            )),
            Positioned(left: 12, bottom: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black54, blurRadius: 6)])),
              Row(children: [
                const _LiveDot(),
                const SizedBox(width: 4),
                Text('$p oynayır', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.9))),
              ]),
            ])),
          ]),
        ),
      );

  Widget _chips() {
    const cats = ['Hamısı', '🔥 Populyar', '🎵 Musiqi', '💬 Söhbət', '🎮 Oyun'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, k) => VPress(
          onTap: () => setState(() => _cat = k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: k == _cat ? Colors.white : Colors.white.withOpacity(.05),
              border: Border.all(color: k == _cat ? Colors.transparent : Colors.white.withOpacity(.14), width: .5),
            ),
            child: Text(cats[k], style: TextStyle(fontSize: 12, fontWeight: k == _cat ? FontWeight.w700 : FontWeight.w500,
                color: k == _cat ? const Color(0xFF1A0035) : Colors.white.withOpacity(.78))),
          ),
        ),
      ),
    );
  }

  Widget _rooms() {
    const rooms = [
      ('Qızıl Saatlar', 'Aynur', '128', 'Söhbət', kPurple, kPink),
      ('Gecə Partisi', 'Rauf', '64', 'Musiqi', Color(0xFF0F6E56), kCyan),
      ('VIP Lounge', 'Sevinc', '256', 'VIP', Color(0xFFBA7517), Color(0xFFFAC775)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        for (final r in rooms)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: VPress(
              scale: .97,
              onTap: widget.onRoom,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.08), width: .5)),
                child: Row(children: [
                  Container(
                    width: 78, height: 78,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [r.$5, r.$6])),
                    child: Stack(alignment: Alignment.center, children: [
                      Text(r.$2[0], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                      Positioned(left: 6, top: 6, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(7)),
                        child: const Text('CANLI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                      )),
                      const Positioned(bottom: 7, child: _Wave()),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('Aparıcı: ${r.$2} • #${r.$4}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.55))),
                    const SizedBox(height: 8),
                    Row(children: [
                      SizedBox(width: 52, height: 22, child: Stack(children: [
                        for (final (k, c) in const [Color(0xFFD4537E), Color(0xFF378ADD), Color(0xFF1D9E75)].indexed)
                          Positioned(left: k * 15.0, child: Container(width: 22, height: 22,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: Border.all(color: const Color(0xFF0D0620), width: 2)))),
                      ])),
                      const SizedBox(width: 6),
                      Icon(Icons.headphones_rounded, size: 14, color: Colors.white.withOpacity(.72)),
                      const SizedBox(width: 3),
                      Text(r.$3, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.72))),
                    ]),
                  ])),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [kPurple, kPink]),
                        boxShadow: [BoxShadow(color: kPurple.withOpacity(.4), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: const Icon(Icons.play_arrow_rounded, size: 20),
                  ),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: .35, end: 1.0).animate(_c),
        child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF5DCAA5), shape: BoxShape.circle)),
      );
}

class _Wave extends StatefulWidget {
  const _Wave();
  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var k = 0; k < 4; k++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 3,
              height: 14 * (.25 + .75 * ((math.sin((_c.value * 2 * math.pi) + k * .9) + 1) / 2)),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
            ),
        ]),
      );
}

class _Hover extends StatefulWidget {
  final Widget child;
  const _Hover({required this.child});
  @override
  State<_Hover> createState() => _HoverState();
}

class _HoverState extends State<_Hover> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, c) {
          final t = Curves.easeInOut.transform(_c.value);
          return Transform.translate(offset: Offset(0, -4 * t), child: Transform.scale(scale: 1.03 + .04 * t, child: c));
        },
        child: widget.child,
      );
}
