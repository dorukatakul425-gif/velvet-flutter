// Velvet — VIP ekranı (index.tsx-dəki dizayn)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'common.dart';

class VipScreen extends StatefulWidget {
  final String name;
  const VipScreen({super.key, this.name = 'Demo İstifadəçi'});
  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> with TickerProviderStateMixin {
  late final _drift = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);
  late final _spin = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  late final _bars = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..repeat();

  @override
  void dispose() { _drift.dispose(); _spin.dispose(); _bars.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        AnimatedBuilder(animation: _drift, builder: (_, __) {
          final t = Curves.easeInOut.transform(_drift.value);
          return Stack(children: [
            Positioned(top: -70 - 26 * t, right: -60 + 18 * t, child: const VGlow(size: 300, color: Color(0x8C7B2FF7))),
            Positioned(top: 320 + 20 * t, left: -80 - 22 * t, child: const VGlow(size: 260, color: Color(0x57FF3EA5))),
            Positioned(bottom: -110, right: -70 + 18 * t, child: const VGlow(size: 300, color: Color(0x3300D4FF))),
          ]);
        }),
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, top + 8, 0, 40),
          children: [
            // Nav
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Row(children: [
                _navBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.maybePop(context)),
                const Expanded(child: Text('VIP', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                _navBtn(Icons.help_outline_rounded, () => vToast(context, 'VIP haqqında')),
              ]),
            ),
            // İstifadəçi kartı
            VEntrance(child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: kPurple.withOpacity(.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [kPurple, kLilac]), border: Border.all(color: kLilac.withOpacity(.4), width: 2)),
                    alignment: Alignment.center,
                    child: Text(widget.name[0].toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
                  Text('VIP0', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2, color: kLilac.withOpacity(.35))),
                ]),
                const SizedBox(height: 12),
                Text.rich(TextSpan(style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withOpacity(.55)), children: const [
                  TextSpan(text: 'İstənilən məbləğdə yükləmə edərək VIP olun '),
                  TextSpan(text: 'VIP >', style: TextStyle(color: kLilac, fontWeight: FontWeight.w600)),
                ])),
              ]),
            )),
            _secHeader('VIP Səviyyə Üstünlükləri'),
            // VIP kartı
            VEntrance(delay: 80, child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A0035), Color(0xFF0D001E), Color(0xFF200040)]),
                border: Border.all(color: kPurple.withOpacity(.4)),
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0x4D7B2FF7), Color(0x80C084FC), Color(0x4DFF3EA5), Color(0x80C084FC), Color(0x4D7B2FF7)]),
                    border: Border(bottom: BorderSide(color: kLilac.withOpacity(.2))),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Padding(padding: EdgeInsets.only(left: 12), child: Text('✦', style: TextStyle(color: kLilac))),
                    Text('VIP1 Kilidini Aç', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFE0C0FF))),
                    Padding(padding: EdgeInsets.only(right: 12), child: Text('✦', style: TextStyle(color: kLilac))),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _badge(active: true, label: 'VIP Nişanı'),
                    _badge(active: false, label: 'VIP Profil Çərçivəsi'),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (var i = 0; i < 5; i++)
                      Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 7, height: 7,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? kLilac : Colors.white.withOpacity(.15))),
                  ]),
                ),
              ]),
            )),
            // Animasiya zolağı
            VEntrance(delay: 140, child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFF08001A), borderRadius: BorderRadius.circular(20), border: Border.all(color: kPurple.withOpacity(.2))),
              child: AnimatedBuilder(
                animation: Listenable.merge([_spin, _bars]),
                builder: (_, __) => Stack(alignment: Alignment.center, children: [
                  const Positioned(left: 15, top: -80, child: VGlow(size: 160, color: Color(0x337B2FF7))),
                  Transform.rotate(angle: _spin.value * 2 * math.pi / 3, child: Container(width: 50, height: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kLilac.withOpacity(.2), width: 1.5)))),
                  for (final (i, c) in const [kPink, kLilac, kCyan].indexed)
                    Transform.translate(
                      offset: Offset(math.cos(_spin.value * 2 * math.pi / 1.2 + i * 2.1) * 25, math.sin(_spin.value * 2 * math.pi / 1.2 + i * 2.1) * 25),
                      child: Container(width: 5, height: 5, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                    ),
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF1E003E), Color(0xFF320068)]), border: Border.all(color: kPurple.withOpacity(.5), width: 1.5)),
                    alignment: Alignment.center,
                    child: const Text('V', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  ),
                  Positioned(right: 22, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    for (final (i, c) in const [Color(0xFFFF6B35), kPink, kLilac, kPurple, kCyan, kPink, kLilac].indexed)
                      Container(
                        margin: const EdgeInsets.only(left: 2.5),
                        width: 4,
                        height: 32 * (.15 + .85 * ((math.sin(_bars.value * 2 * math.pi + i * .6) + 1) / 2)),
                        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                      ),
                  ])),
                  const Positioned(left: 18, child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('✦', style: TextStyle(fontSize: 9, color: kPink)),
                    SizedBox(height: 7),
                    Text('✦', style: TextStyle(fontSize: 7, color: kLilac)),
                    SizedBox(height: 7),
                    Text('✦', style: TextStyle(fontSize: 9, color: kCyan)),
                  ])),
                ]),
              ),
            )),
            _secHeader('Funksional Üstünlüklər'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
              child: GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.35,
                children: [
                  for (final (i, f) in const [
                    (Icons.lock_outline_rounded, 'Otağı Kilidləmə'),
                    (Icons.person_off_outlined, 'Ölkə Məlumatını Gizlət'),
                    (Icons.visibility_off_outlined, 'Onlayn Statusunu Gizlət'),
                    (Icons.tab_outlined, 'Tab Xüsusiyyəti'),
                  ].indexed)
                    VEntrance(delay: 200 + i * 60, child: VPress(
                      onTap: () => vToast(context, '${f.$2} — VIP1 lazımdır'),
                      child: Container(
                        decoration: BoxDecoration(color: kPurple.withOpacity(.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: kPurple.withOpacity(.25))),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                                gradient: const RadialGradient(center: Alignment(-.2, -.3), colors: [Color(0x807B2FF7), Color(0xCC3C0078)]),
                                border: Border.all(color: kLilac.withOpacity(.35), width: 1.5)),
                            child: Icon(f.$1, size: 24, color: kLilac),
                          ),
                          const SizedBox(height: 10),
                          Text(f.$2, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(.75))),
                        ]),
                      ),
                    )),
                ],
              ),
            ),
            VPress(
              scale: .97,
              onTap: () => vToast(context, 'Cüzdan: Profil → Cüzdanım'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [Color(0x26FF3EA5), Color(0x337B2FF7)]),
                  border: Border.all(color: kPink.withOpacity(.4)),
                ),
                child: const Text('İstədiyiniz məbləğdə yükləmə edin və VIP olun!', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFB0D8))),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _navBtn(IconData i, VoidCallback onTap) => VPress(onTap: onTap, child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: kPurple.withOpacity(.12), border: Border.all(color: kPurple.withOpacity(.25))),
        child: Icon(i, size: 17),
      ));

  Widget _secHeader(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Row(children: [
          Expanded(child: Container(height: 1, color: kLilac.withOpacity(.2))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('✦', style: TextStyle(color: kLilac))),
          Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: kLilac)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('✦', style: TextStyle(color: kLilac))),
          Expanded(child: Container(height: 1, color: kLilac.withOpacity(.2))),
        ]),
      );

  Widget _badge({required bool active, required String label}) => Column(children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          Container(decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(center: const Alignment(-.3, -.4), colors: active ? const [Color(0xFF2A0060), Color(0xFF0D0020)] : const [Color(0xFF180030), Color(0xFF080010)]),
              border: Border.all(color: kPurple.withOpacity(active ? .6 : .25), width: 2))),
          if (active) AnimatedBuilder(animation: _spin, builder: (_, __) => Transform.rotate(
            angle: _spin.value * 2 * math.pi,
            child: CustomPaint(size: const Size(92, 92), painter: _ArcPainter()),
          )),
          Container(
            width: 64, height: 64,
            decoration: active
                ? const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-.3, -.4), colors: [kPurple, Color(0xFF3D0880)]))
                : BoxDecoration(shape: BoxShape.circle, color: kPurple.withOpacity(.08), border: Border.all(color: kPurple.withOpacity(.3), width: 2)),
            child: Stack(alignment: Alignment.center, children: [
              Icon(active ? Icons.radio_button_checked_rounded : Icons.blur_circular_rounded, size: 30, color: active ? kLilac : kPurple.withOpacity(.5)),
              if (active) const Positioned(bottom: 7, child: Text('VIP1', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1, color: kGold))),
            ]),
          ),
        ])),
        const SizedBox(height: 10),
        SizedBox(width: 95, child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.3, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(.8)))),
      ]);
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawArc(r, -math.pi / 2, math.pi / 2, false, Paint()..color = kLilac..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
    c.drawArc(r, 0, math.pi / 2, false, Paint()..color = kPink..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_) => false;
}
