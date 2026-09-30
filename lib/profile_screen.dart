// Velvet — Profil ekranı + Ziyarətçi profili (Flutter)
//
// QURAŞDIRMA
//  1) pubspec.yaml → dependencies: altına əlavə et:
//        flutter_svg: ^2.0.10
//  2) Bu faylı lib/profile_screen.dart kimi saxla.
//  3) main.dart-ı bununla əvəz et:  export 'profile_screen.dart';  və ya birbaşa bu faylı işə sal.
//
// 120 HZ ÜÇÜN
//  • iOS: ios/Runner/Info.plist içinə əlavə et →
//        <key>CADisableMinimumFrameDurationOnPhone</key><true/>
//  • Android: flutter_displaymode paketi ilə ən yüksək yeniləmə tezliyini seç.
//
// PERFORMANS QAYDALARI (kodda tətbiq olunub)
//  • Hər animasiya öz RepaintBoundary-sində, yalnız lazım olan hissə yenidən çəkilir.
//  • Scroll zamanı setState yoxdur; bütün ekran yenidən qurulmur.
//  • Bulanıqlıq (blur/BackdropFilter) əvəzinə ucuz RadialGradient işıqlanma.
//  • Sayğac yalnız bir Text-i yeniləyir (ValueListenableBuilder).
//  • Ulduzlar tək CustomPainter ilə çəkilir (repaint: animasiya).
//  • SVG ikonlar sətir açarı ilə keşlənir.
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const VelvetApp());
}

class VelvetApp extends StatelessWidget {
  const VelvetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: kBg, useMaterial3: true),
        home: const ProfileScreen(),
      );
}

/* ───────────── Rənglər ───────────── */
const kBg = Color(0xFF07000F);
const kPurple = Color(0xFF7B2FF7);
const kPink = Color(0xFFFF3EA5);
const kLilac = Color(0xFFC084FC);
const kTeal = Color(0xFF19D4B4);
const kMut = Color(0x8CE9E2FF);
const kInk = Color(0xFFF1EAFF);

/* ───────────── SVG ikonlar ───────────── */
const _defs = r'''<defs>
<linearGradient id="gGr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#7cf0c4"/><stop offset="1" stop-color="#1fb58a"/></linearGradient>
<linearGradient id="gBl" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#6cc4ff"/><stop offset="1" stop-color="#3a78f0"/></linearGradient>
<linearGradient id="gPk" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ff7aa8"/><stop offset="1" stop-color="#e8306a"/></linearGradient>
<linearGradient id="gOr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffb347"/><stop offset="1" stop-color="#f26b2a"/></linearGradient>
<linearGradient id="gYe" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffe35c"/><stop offset="1" stop-color="#f5a800"/></linearGradient>
<linearGradient id="gPu" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#b98bff"/><stop offset="1" stop-color="#6a3ae0"/></linearGradient>
<linearGradient id="gGo" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffe680"/><stop offset="1" stop-color="#f0a000"/></linearGradient>
<linearGradient id="gDi" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#8fe0ff"/><stop offset="1" stop-color="#1c7cf0"/></linearGradient>
<linearGradient id="gSi" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#b3b9d6"/></linearGradient>
</defs>''';

const Map<String, (String, String)> _icons = {
  'wallet': ('0 0 32 32', '<rect x="2" y="6" width="28" height="20" rx="7" fill="url(#gGr)"/><rect x="18" y="12" width="12" height="9" rx="4.5" fill="#d8fff0" opacity=".9"/><circle cx="23.5" cy="16.5" r="1.8" fill="#1fb58a"/>'),
  'family': ('0 0 32 32', '<path d="M6 4h20a4 4 0 014 4v15a4 4 0 01-4 4h-7l-3 3-3-3H6a4 4 0 01-4-4V8a4 4 0 014-4z" fill="url(#gBl)"/><circle cx="12.5" cy="12.5" r="3.4" fill="#fff"/><path d="M6.5 21c0-3.6 2.6-5.3 6-5.3s6 1.7 6 5.3z" fill="#fff"/><circle cx="21.5" cy="13.5" r="2.6" fill="#dff0ff"/><path d="M19 19.5c.8-1.6 2.2-2.3 4-2.3 2.2 0 3.5 1.2 3.5 3.3h-7.5z" fill="#dff0ff"/>'),
  'heart': ('0 0 32 32', '<path d="M16 29C3 20 2 11.5 8.5 7.5 12.3 5.3 15 7.5 16 9.6 17 7.5 19.7 5.3 23.5 7.5 30 11.5 29 20 16 29z" fill="url(#gPk)"/><path d="M6.5 16.5h5l2-4 3.5 8 2-4h6" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>'),
  'svip': ('0 0 32 32', '<path d="M3 10l7 6 6-11 6 11 7-6-3 16H6z" fill="url(#gOr)"/><path d="M16 14l3.5 5L16 24l-3.5-5z" fill="#fff" opacity=".92"/><circle cx="3.5" cy="10" r="2" fill="#ffd38a"/><circle cx="28.5" cy="10" r="2" fill="#ffd38a"/><circle cx="16" cy="4.5" r="2" fill="#ffd38a"/>'),
  'vip': ('0 0 32 32', '<path d="M4 9.5C4 8 5 7 6.5 7h19c1.5 0 2.5 1 2.5 2.5 0 1-.3 1.8-.9 2.6L17.3 26.4c-.6.9-2 .9-2.6 0L4.9 12.1C4.3 11.3 4 10.5 4 9.5z" fill="url(#gYe)"/><path d="M10.5 11.5L16 20l5.5-8.5" fill="none" stroke="#fff" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"/>'),
  'store': ('0 0 32 32', '<rect x="5" y="14" width="22" height="14" rx="4" fill="#ffc08a"/><path d="M6 4h20l4 9c0 2.3-1.8 4-4 4s-4-1.7-4-4c0 2.3-1.8 4-4 4s-4-1.7-4-4c0 2.3-1.8 4-4 4s-4-1.7-4-4z" fill="url(#gOr)"/><rect x="11.5" y="20" width="9" height="4.5" rx="2.2" fill="#fff" opacity=".9"/>'),
  'shirt': ('0 0 32 32', '<path d="M11 3L3 7.5l3.5 7L10 12.5V28h12V12.5l3.5 2 3.5-7L21 3c-1 2.5-2.8 3.8-5 3.8S12 5.5 11 3z" fill="url(#gPu)"/><path d="M16 12.5l1.5 3.7 3.7 1.5-3.7 1.5L16 23l-1.5-3.8-3.7-1.5 3.7-1.5z" fill="#fff"/>'),
  'invite': ('0 0 32 32', '<rect x="4" y="10" width="24" height="18" rx="6" fill="none" stroke="#f1eaff" stroke-width="2.4"/><rect x="10" y="3.5" width="12" height="9" rx="3.5" fill="#19d4b4" stroke="#f1eaff" stroke-width="2.4"/>'),
  'agent': ('0 0 32 32', '<path d="M16 3.5l10 3.3V15c0 7-4.5 11-10 13.5C10.5 26 6 22 6 15V6.8z" fill="none" stroke="#f1eaff" stroke-width="2.4" stroke-linejoin="round"/><path d="M16 10.5l1.6 3.2 3.5.5-2.5 2.5.6 3.5-3.2-1.7-3.2 1.7.6-3.5-2.5-2.5 3.5-.5z" fill="#19d4b4"/>'),
  'chat': ('0 0 32 32', '<path d="M16 4C9 4 4 8.8 4 14.5c0 3 1.4 5.6 3.7 7.5L6 27.5l5.8-2.6c1.3.4 2.7.6 4.2.6 7 0 12-4.8 12-10.5S23 4 16 4z" fill="none" stroke="#f1eaff" stroke-width="2.4" stroke-linejoin="round"/><path d="M11.5 14.5q4.5 4.5 9 0" fill="none" stroke="#19d4b4" stroke-width="2.4" stroke-linecap="round"/>'),
  'fb': ('0 0 32 32', '<path d="M20 5H10a6 6 0 00-6 6v11a6 6 0 006 6h12a6 6 0 006-6v-8" fill="none" stroke="#f1eaff" stroke-width="2.4" stroke-linecap="round"/><path d="M9.5 21q3 2.5 6 0" fill="none" stroke="#f1eaff" stroke-width="2.4" stroke-linecap="round"/><path d="M27 3l-9 9" stroke="#19d4b4" stroke-width="3.2" stroke-linecap="round"/>'),
  'set': ('0 0 32 32', '<path d="M16 3l11 6.3v12.4L16 28 5 21.7V9.3z" fill="none" stroke="#f1eaff" stroke-width="2.4" stroke-linejoin="round"/><circle cx="16" cy="15.5" r="4.2" fill="none" stroke="#19d4b4" stroke-width="3"/>'),
  'coin': ('0 0 24 24', '<circle cx="12" cy="12" r="11" fill="url(#gGo)"/><circle cx="12" cy="12" r="8" fill="none" stroke="#fff3b0" stroke-width="1.2"/><path d="M12 6.5l1.6 3.3 3.6.5-2.6 2.5.6 3.6-3.2-1.7-3.2 1.7.6-3.6-2.6-2.5 3.6-.5z" fill="#fff6c8"/>'),
  'gem': ('0 0 24 24', '<path d="M6 3h12l5 6-11 13L1 9z" fill="url(#gDi)"/><path d="M1 9h22M8.5 9L12 22l3.5-13M6 3l2.5 6L12 3l3.5 6L18 3" fill="none" stroke="#dff6ff" stroke-width=".9" opacity=".8"/>'),
  'chev': ('0 0 16 16', '<path d="M5.5 2.5L11 8l-5.5 5.5" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'),
  'copy': ('0 0 16 16', '<rect x="5" y="5" width="9" height="9" rx="2.5" fill="#9c93b8"/><path d="M11 3.5V3.2C11 2.5 10.5 2 9.8 2H3.2C2.5 2 2 2.5 2 3.2v6.6C2 10.5 2.5 11 3.2 11h.3" fill="none" stroke="#9c93b8" stroke-width="1.6" stroke-linecap="round"/>'),
  'edit': ('0 0 32 32', '<path d="M17 5H9a5 5 0 00-5 5v13a5 5 0 005 5h13a5 5 0 005-5v-8" fill="none" stroke="#fff" stroke-width="2.8" stroke-linecap="round"/><path d="M12 20l1-5L26 3l3 3-12 13z" fill="none" stroke="#fff" stroke-width="2.8" stroke-linejoin="round"/>'),
  'back': ('0 0 24 24', '<path d="M15 4l-8 8 8 8" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>'),
  'clock': ('0 0 16 16', '<circle cx="8" cy="8" r="6.5" fill="none" stroke="#fff" stroke-width="1.6"/><path d="M8 4.5V8l2.5 1.5" fill="none" stroke="#fff" stroke-width="1.6" stroke-linecap="round"/>'),
  'lv': ('0 0 16 16', '<circle cx="8" cy="8" r="8" fill="#0fae5f"/><path d="M8 3l4.5 8h-9z" fill="#0b3b27" stroke="#7dffb8" stroke-width="1" stroke-linejoin="round"/>'),
  'hg': ('0 0 16 16', '<circle cx="8" cy="8" r="8" fill="#ffd6ec"/><path d="M8 13C3 10 3 6 5.5 5c1.2-.4 2 .4 2.5 1.2C8.5 5.4 9.3 4.6 10.5 5 13 6 13 10 8 13z" fill="#ff5fa8"/><path d="M8 5.5l1.5 2L8 10 6.5 7.5z" fill="#fff"/>'),
  'age': ('0 0 16 16', '<circle cx="8" cy="8" r="6.3" fill="none" stroke="#b8afd6" stroke-width="1.4"/><circle cx="6" cy="7" r=".9" fill="#b8afd6"/><circle cx="10" cy="7" r=".9" fill="#b8afd6"/><path d="M5.5 9.5q2.5 2 5 0" fill="none" stroke="#b8afd6" stroke-width="1.2" stroke-linecap="round"/>'),
  'leaf': ('0 0 16 16', '<circle cx="8" cy="8" r="8" fill="#fff" opacity=".9"/><path d="M4 11.5C4 7 7 4 12 4c0 5-3 8-7 8M4 12l4-4" fill="#2fbf4a" stroke="#1d8f35" stroke-width=".8" stroke-linecap="round"/>'),
  'gift': ('0 0 64 64', '<ellipse cx="44" cy="55" rx="15" ry="5" fill="#d98a00"/><ellipse cx="44" cy="51" rx="15" ry="5" fill="url(#gGo)"/><ellipse cx="44" cy="47" rx="15" ry="5" fill="#ffe680"/><ellipse cx="44" cy="43" rx="15" ry="5" fill="url(#gGo)"/><rect x="6" y="28" width="38" height="28" rx="5" fill="url(#gPk)"/><rect x="3" y="20" width="44" height="12" rx="4" fill="url(#gOr)"/><rect x="21" y="20" width="8" height="36" fill="#ffe35c"/><path d="M25 20c-7-2-13-4-11-9s9-2 11 9zm0 0c7-2 13-4 11-9s-9-2-11 9z" fill="#ffd23c" stroke="#f5a800" stroke-width="1.5"/>'),
  'b1': ('0 0 48 48', '<path d="M24 2l6 4 7-1 3 7 6 4-2 7 2 7-6 4-3 7-7-1-6 4-6-4-7 1-3-7-6-4 2-7-2-7 6-4 3-7 7 1z" fill="url(#gOr)"/><circle cx="24" cy="24" r="14" fill="#7a3a10" opacity=".35"/><path d="M24 14l9 8-9 13-9-13z" fill="#ffe3b8"/><path d="M15 22h18M24 14l-3 8 3 13 3-13z" fill="none" stroke="#f29a4a" stroke-width="1.2"/>'),
  'b2': ('0 0 48 48', '<circle cx="24" cy="24" r="20" fill="url(#gPk)" stroke="#ffd38a" stroke-width="2.5"/><circle cx="24" cy="24" r="12.5" fill="none" stroke="#ffd38a" stroke-width="2"/><circle cx="24" cy="24" r="5.5" fill="#ffd38a"/><path d="M4 26l-2 8 6-2M44 26l2 8-6-2" fill="#ffb347"/>'),
  'car': ('0 0 64 40', '<path d="M3 27c0-4 3-6 8-7l11-8c2-1.5 4-2 7-2h10c4 0 7 1.5 9 4l5 5c4 1 8 2 8 6v3c0 1.5-1 2.5-2.5 2.5H5.5C4 30.5 3 29.5 3 28z" fill="url(#gSi)"/><path d="M24 14l-7 6h14v-7h-4c-1 0-2 .4-3 1zm10-1v7h13l-4-5c-1-1.5-3-2-5-2z" fill="#7f8fd0" opacity=".85"/><circle cx="18" cy="31" r="6" fill="#2b2540" stroke="#c6cbe2" stroke-width="2"/><circle cx="48" cy="31" r="6" fill="#2b2540" stroke="#c6cbe2" stroke-width="2"/>'),
  'cal': ('0 0 24 24', '<rect x="3" y="5" width="18" height="16" rx="4" fill="url(#gYe)"/><rect x="3" y="5" width="18" height="6" rx="3" fill="#ffc21c"/><rect x="7" y="2.5" width="2.5" height="5" rx="1.2" fill="#ffe680"/><rect x="14.5" y="2.5" width="2.5" height="5" rx="1.2" fill="#ffe680"/>'),
  'pen': ('0 0 24 24', '<path d="M4 19l1-5L16 3l5 5L10 19z" fill="url(#gYe)"/><path d="M3 22h18" stroke="#ffd23c" stroke-width="2" stroke-linecap="round"/>'),
};

/// SVG ikon (sətir açarı ilə keşlənir)
class Ico extends StatelessWidget {
  final String name;
  final double size;
  final double? height;
  final double opacity;
  const Ico(this.name, {super.key, this.size = 24, this.height, this.opacity = 1});
  static final _cache = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final svg = _cache.putIfAbsent(name, () {
      final i = _icons[name]!;
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${i.$1}">$_defs${i.$2}</svg>';
    });
    final w = SvgPicture.string(svg, width: size, height: height ?? size);
    return opacity == 1 ? w : Opacity(opacity: opacity, child: w);
  }
}

/* ───────────── Ortaq köməkçilər ───────────── */
void velvetToast(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(m, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF241F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 30),
      duration: const Duration(milliseconds: 1400),
    ));
}

Route<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: a,
          child: SlideTransition(position: Tween(begin: const Offset(.12, 0), end: Offset.zero).animate(c), child: child),
        );
      },
    );

/// Girişdə aşağıdan yuxarı yumşaq çıxış
class _Reveal extends StatefulWidget {
  final int delay;
  final Widget child;
  const _Reveal({this.delay = 0, required this.child});
  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final int _total = 500 + widget.delay;
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: _total))..forward();
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Interval(widget.delay / _total, 1, curve: Curves.easeOutCubic));
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        child: widget.child,
        builder: (_, c) => Opacity(opacity: _a.value, child: Transform.translate(offset: Offset(0, 14 * (1 - _a.value)), child: c)),
      );
}

/// Fırlanan rəngli halqalı avatar
class _Avatar extends StatelessWidget {
  final double size;
  final Animation<double> ring;
  final bool online;
  const _Avatar({required this.size, required this.ring, this.online = false});
  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: SizedBox(
          width: size, height: size,
          child: Stack(children: [
            RotationTransition(
              turns: ring,
              child: const RepaintBoundary(child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00), kLilac, kPurple, kTeal, Color(0xFFFFD700)]),
                  boxShadow: [BoxShadow(color: Color(0x667B2FF7), blurRadius: 22)],
                ),
                child: SizedBox.expand(),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB06BFF), Color(0xFF6A2BE0)]),
                ),
                child: Center(child: Text('V', style: TextStyle(
                  fontSize: size * .41, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white,
                  shadows: const [Shadow(color: Color(0xFF4A1AA8), offset: Offset(0, 2))],
                ))),
              ),
            ),
            if (online)
              Positioned(right: 3, bottom: 5, child: Container(
                width: 15, height: 15,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00FF88), border: Border.all(color: kBg, width: 2.5)),
              )),
          ]),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String icon, text;
  final Gradient? grad;
  final Color fg;
  const _Chip(this.icon, this.text, {this.grad, this.fg = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(5, 3, 9, 3),
        decoration: BoxDecoration(
          gradient: grad,
          color: grad == null ? const Color(0x17FFFFFF) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Ico(icon, size: 16),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );
}

/* ═════════════════ PROFİL EKRANI ═════════════════ */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  static const _name = 'Velvet istifadəçisi';
  static const _id = '48219037';

  late final _ring = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  late final _aur = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat(reverse: true);
  late final _gift = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  late final _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
  final _left = ValueNotifier<int>(3 * 86400 + 23 * 3600 + 56 * 60 + 9);
  final _copied = ValueNotifier<bool>(false);
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) { if (_left.value > 0) _left.value--; });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _ring.dispose(); _aur.dispose(); _gift.dispose(); _shine.dispose();
    _left.dispose(); _copied.dispose();
    super.dispose();
  }

  void _copyId() {
    Clipboard.setData(const ClipboardData(text: _id));
    HapticFeedback.lightImpact();
    _copied.value = true;
    velvetToast(context, 'ID kopyalandı');
    Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) _copied.value = false; });
  }

  String _fmt(int s) {
    String p(int n) => n.toString().padLeft(2, '0');
    final d = s ~/ 86400, r = s % 86400;
    return '$d gün ${p(r ~/ 3600)}:${p(r % 3600 ~/ 60)}:${p(r % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(children: [
        Positioned(top: 0, left: 0, right: 0, height: 340, child: IgnorePointer(child: RepaintBoundary(child: _Aurora(ctrl: _aur)))),
        CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(18, top + 10, 18, 0),
              child: Align(alignment: Alignment.centerRight, child: _Tap(
                onTap: () => velvetToast(context, 'Profili redaktə et'),
                child: const Ico('edit', size: 28),
              )),
            )),
            SliverToBoxAdapter(child: _Reveal(child: _header())),
            SliverToBoxAdapter(child: _Reveal(delay: 80, child: _stats())),
            SliverToBoxAdapter(child: _Reveal(delay: 160, child: _banner())),
            SliverToBoxAdapter(child: _Reveal(delay: 240, child: _card1())),
            SliverToBoxAdapter(child: _Reveal(delay: 320, child: _card2())),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ]),
    );
  }

  Widget _header() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { HapticFeedback.selectionClick(); Navigator.of(context).push(_slide(const PublicProfileScreen())); },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            _Avatar(size: 78, ring: _ring),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              const Wrap(spacing: 6, runSpacing: 6, children: [_Chip('lv', 'Zənginlik:Sv.1'), _Chip('hg', 'Aktiv deyil')]),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _copyId,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('ID:$_id', style: TextStyle(fontSize: 12, color: kMut)),
                  const SizedBox(width: 5),
                  ValueListenableBuilder<bool>(
                    valueListenable: _copied,
                    builder: (_, c, __) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Ico(c ? 'lv' : 'copy', key: ValueKey(c), size: 14),
                    ),
                  ),
                ]),
              ),
            ])),
            const Ico('chev', size: 16, opacity: .4),
          ]),
        ),
      );

  Widget _stats() {
    Widget s(String n, String l) => Expanded(child: Column(children: [
          Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(l, style: const TextStyle(fontSize: 12, color: kMut)),
        ]));
    Widget d() => Container(width: 1, height: 26, color: const Color(0x1AFFFFFF));
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 22, 10, 0),
      child: Row(children: [s('2', 'Otaq'), d(), s('2', 'Ziyarətçi'), d(), s('1', 'İzlənilən'), d(), s('0', 'İzləyici')]),
    );
  }

  Widget _banner() => Padding(
        padding: const EdgeInsets.fromLTRB(14, 26, 14, 0),
        child: GestureDetector(
          onTap: () => velvetToast(context, 'Məhdud vaxtlı mükafat'),
          child: RepaintBoundary(
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x6619D4B4), width: 1.5),
                gradient: const LinearGradient(colors: [Color(0x38FF3EA5), Color(0x477B2FF7), Color(0x3819D4B4)]),
                boxShadow: const [BoxShadow(color: Color(0x407B2FF7), blurRadius: 22)],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                Positioned.fill(child: AnimatedBuilder(
                  animation: _shine,
                  builder: (_, __) {
                    final v = Curves.easeInOut.transform((_shine.value * 1.6).clamp(0.0, 1.0));
                    return Align(
                      alignment: Alignment(-1.5 + 3.2 * v, 0),
                      child: Transform(
                        transform: Matrix4.skewX(-.35),
                        child: Container(width: 60, height: 120, decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x38FFFFFF), Color(0x00FFFFFF)]),
                        )),
                      ),
                    );
                  },
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 6),
                  child: Row(children: [
                    AnimatedBuilder(
                      animation: _gift,
                      child: const Ico('gift', size: 62),
                      builder: (_, c) {
                        final e = Curves.easeInOut.transform(_gift.value);
                        return Transform.translate(offset: Offset(0, -5 * e), child: Transform.rotate(angle: -.07 * e, child: c));
                      },
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Yeni istifadəçiyə özəl mükafat', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('1652 jetona qədər qazan!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
                    ])),
                    const Ico('chev', size: 16, opacity: .7),
                  ]),
                ),
                Positioned(top: 0, left: 0, right: 0, child: Center(child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 2, 22, 3),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFE8364F), Color(0xFFF0894F)]),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Ico('clock', size: 13),
                    const SizedBox(width: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: _left,
                      builder: (_, s, __) => Text(_fmt(s), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
                    ),
                  ]),
                ))),
              ]),
            ),
          ),
        ),
      );

  Widget _card1() => _MenuCard(rows: [
        _Item('wallet', 'Pulqabı', () => velvetToast(context, 'Pulqabı'), right: Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 13, 5),
          decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(18)),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Ico('coin', size: 20), SizedBox(width: 6),
            Text('40', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(width: 8), SizedBox(width: 1, height: 14, child: ColoredBox(color: Color(0x33FFFFFF))), SizedBox(width: 8),
            Ico('gem', size: 20), SizedBox(width: 6),
            Text('0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        )),
        _Item('family', 'Ailə', () => velvetToast(context, 'Ailə'), right: Row(mainAxisSize: MainAxisSize.min, children: const [
          Ico('coin', size: 18), SizedBox(width: 5),
          Text('Qoşul, ', style: TextStyle(fontSize: 13, color: kMut)),
          Text('30 Jeton qazan', style: TextStyle(fontSize: 13, color: Color(0xFFFFA033))),
        ])),
        _Item('heart', 'Yaxın dost', () => velvetToast(context, 'Yaxın dost'), text: 'İlk yaxın dostunu əlavə et'),
        _Item('svip', 'SVIP', () => velvetToast(context, 'SVIP'), text: 'Get və aç'),
        _Item('vip', 'VIP', () => velvetToast(context, 'VIP'), text: 'Get və aç'),
        _Item('store', 'Mağaza', () => velvetToast(context, 'Mağaza')),
        _Item('shirt', 'Aksesuar', () => velvetToast(context, 'Aksesuar')),
      ]);

  Widget _card2() => _MenuCard(rows: [
        _Item('invite', 'Dost dəvət et', () => velvetToast(context, 'Dost dəvət et'), text: 'Jeton qazan', color: const Color(0xFFFFB020)),
        _Item('agent', 'Agentlik Meydanı', () => velvetToast(context, 'Agentlik Meydanı')),
        _Item('chat', 'Onlayn müştəri xidməti', () => velvetToast(context, 'Onlayn müştəri xidməti')),
        _Item('fb', 'Problem bildir', () => velvetToast(context, 'Problem bildir')),
        _Item('set', 'Parametrlər', () => velvetToast(context, 'Parametrlər'), text: 'Hesabınız risk altındadır, e-poçt bağlayın', color: const Color(0xFFFF6B8A)),
      ]);
}

/* ─────────── Menyu komponentləri ─────────── */
class _Item {
  final String icon, label;
  final VoidCallback onTap;
  final Widget? right;
  final String? text;
  final Color color;
  const _Item(this.icon, this.label, this.onTap, {this.right, this.text, this.color = kMut});
}

class _MenuCard extends StatelessWidget {
  final List<_Item> rows;
  const _MenuCard({required this.rows});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x0DFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x24965AF0)),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 6))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Material(
                type: MaterialType.transparency,
                child: Column(children: [for (final r in rows) _MenuRow(item: r)]),
              ),
            ),
          ),
        ),
      );
}

class _MenuRow extends StatelessWidget {
  final _Item item;
  const _MenuRow({required this.item});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () { HapticFeedback.selectionClick(); item.onTap(); },
        splashColor: const Color(0x2E7B2FF7),
        highlightColor: const Color(0x147B2FF7),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Ico(item.icon, size: 36),
              const SizedBox(width: 14),
              Text(item.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: kInk)),
              Expanded(child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: item.right ?? (item.text == null ? const SizedBox() : Text(item.text!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: item.color))),
                ),
              )),
              const Ico('chev', size: 16, opacity: .4),
            ]),
          ),
        ),
      );
}

/// Basanda yumşaq kiçilən düymə
class _Tap extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _Tap({required this.onTap, required this.child});
  @override
  State<_Tap> createState() => _TapState();
}

class _TapState extends State<_Tap> {
  bool _d = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _d = true),
        onTapCancel: () => setState(() => _d = false),
        onTapUp: (_) { setState(() => _d = false); HapticFeedback.selectionClick(); widget.onTap(); },
        child: AnimatedScale(scale: _d ? .88 : 1, duration: const Duration(milliseconds: 120), child: widget.child),
      );
}

/// Yuxarı işıqlanma (blur yoxdur, yalnız ucuz gradient)
class _Aurora extends StatelessWidget {
  final Animation<double> ctrl;
  const _Aurora({required this.ctrl});
  Widget _blob(double w, double h, Color c) => Container(
        width: w, height: h,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c, c.withAlpha(0)])),
      );
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.hardEdge, children: [
        AnimatedBuilder(
          animation: ctrl,
          builder: (_, __) {
            final t = Curves.easeInOut.transform(ctrl.value);
            return Stack(children: [
              Positioned(left: -60 + 30 * t, top: -80 + 26 * t, child: Transform.scale(scale: 1 + .2 * t, child: _blob(320, 280, kPurple.withAlpha(150)))),
              Positioned(right: -50 - 30 * t, top: -60 + 20 * t, child: Transform.scale(scale: 1 + .15 * t, child: _blob(280, 260, kPink.withAlpha(110)))),
              Positioned(left: 90 - 40 * t, top: 10 + 24 * t, child: _blob(260, 210, kTeal.withAlpha(70))),
            ]);
          },
        ),
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0007000F), kBg], stops: [.35, 1]),
        ))),
      ]);
}

/* ═════════════════ ZİYARƏTÇİ PROFİLİ ═════════════════ */
class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});
  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> with TickerProviderStateMixin {
  late final _ring = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  late final _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
  late final _star = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  final _copied = ValueNotifier<bool>(false);

  @override
  void dispose() { _ring.dispose(); _bob.dispose(); _star.dispose(); _copied.dispose(); super.dispose(); }

  Widget _bigV({required Paint? stroke, Color? color}) => Text('V', style: TextStyle(
        fontSize: 200, height: 1, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: stroke == null ? color : null, foreground: stroke,
      ));

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final outline = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeJoin = StrokeJoin.round..color = const Color(0xFF8448E8);
    final shadow = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeJoin = StrokeJoin.round..color = const Color(0x66501AAA);
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(fit: StackFit.passthrough, children: [
          // Üz qabığı
          RepaintBoundary(
            child: SizedBox(
              height: 330,
              child: Stack(alignment: Alignment.center, children: [
                const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6F3DF0), Color(0xFFA566F8), Color(0xFFD08CFF)], stops: [0, .62, 1]),
                ))),
                AnimatedBuilder(
                  animation: _bob,
                  child: Stack(alignment: Alignment.center, children: [
                    Transform.translate(offset: const Offset(0, 10), child: _bigV(stroke: shadow)),
                    _bigV(stroke: outline),
                    _bigV(stroke: null, color: Colors.white),
                  ]),
                  builder: (_, c) => Transform.translate(offset: Offset(0, -8 * Curves.easeInOut.transform(_bob.value)), child: c),
                ),
                Positioned.fill(child: CustomPaint(painter: _SparklePainter(_star))),
                Positioned(bottom: 44, child: Container(width: 9, height: 9, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
              ]),
            ),
          ),
          Positioned(top: top + 12, left: 14, child: _Tap(onTap: () => Navigator.of(context).maybePop(), child: const Ico('back', size: 30))),
          Positioned(top: top + 12, right: 14, child: _Tap(onTap: () => velvetToast(context, 'Profili redaktə et'), child: const Ico('edit', size: 30))),
          // Alt vərəq
          Padding(padding: const EdgeInsets.only(top: 296), child: _sheet()),
        ]),
      ),
    );
  }

  Widget _sheet() => Stack(clipBehavior: Clip.none, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Color(0x337B2FF7), blurRadius: 30, offset: Offset(0, -10))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 56, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text('Azərbaycan', style: TextStyle(fontSize: 15, color: kMut)),
              const SizedBox(width: 10),
              Container(width: 1, height: 16, color: const Color(0x26FFFFFF)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '48219037'));
                  HapticFeedback.lightImpact();
                  _copied.value = true;
                  velvetToast(context, 'ID kopyalandı');
                  Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) _copied.value = false; });
                },
                child: Row(children: [
                  const Text('ID:48219037', style: TextStyle(fontSize: 15, color: kMut)),
                  const SizedBox(width: 5),
                  ValueListenableBuilder<bool>(valueListenable: _copied, builder: (_, c, __) => Ico(c ? 'lv' : 'copy', size: 15)),
                ]),
              ),
            ])),
            const SizedBox(height: 22),
            const Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('Velvet istifadəçisi', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              _Chip('age', '22', fg: Color(0xFFCFC6EA)),
              _Chip('leaf', 'Yeni başlayan', grad: LinearGradient(colors: [Color(0xFF2FD84A), Color(0xFF8BE34A)])),
              _Chip('lv', '1', grad: LinearGradient(colors: [Color(0xFF0FAE5F), Color(0xFF2BD6A0)])),
            ]),
            const SizedBox(height: 10),
            const Text('1 İzlənilən · 0 İzləyici', style: TextStyle(fontSize: 17, color: kMut)),
            const SizedBox(height: 34),
            const Text('Nişanlarım', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _Honor('SVIP', 'Hələ əldə edilməyib', 'b1', const Color(0xFFFF8C50), isNew: true, bob: _bob, onTap: () => velvetToast(context, 'SVIP'))),
              const SizedBox(width: 10),
              Expanded(child: _Honor('VIP', 'Hələ əldə edilməyib', 'b2', const Color(0xFFFFBE46), isNew: true, bob: _bob, onTap: () => velvetToast(context, 'VIP'))),
              const SizedBox(width: 10),
              Expanded(child: _Honor('Ailə', 'Qoşulmayıb', 'family', const Color(0xFF5A8CFF), bob: _bob, onTap: () => velvetToast(context, 'Ailə'))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Honor('Avtomobil', 'Hələ əldə edilməyib', 'car', const Color(0xFF96A0FF), h: 84, iw: 54, ih: 40, bob: _bob, onTap: () => velvetToast(context, 'Avtomobil'))),
              const SizedBox(width: 10),
              Expanded(child: _Honor('Hədiyyə divarı', '0/450', 'gift', kLilac, h: 84, iw: 44, ih: 44, bob: _bob, onTap: () => velvetToast(context, 'Hədiyyə divarı'))),
            ]),
            _LineRow('Yaxın dost', 'dəvət et', () => velvetToast(context, 'Yaxın dost')),
            _LineRow('Paylaşımlar', 'Möhtəşəm anlarını paylaş', () => velvetToast(context, 'Paylaşımlar')),
            const SizedBox(height: 24),
            const Text('Şəxsi məlumat', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const _Info('cal', 'Velvet-də bu gün 3-cü gün'),
            const _Info('pen', 'Heç bir məlumat qoyulmayıb~'),
          ]),
        ),
        Positioned(left: 18, top: -58, child: _Avatar(size: 88, ring: _ring)),
        Positioned(left: 14, top: 26, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x4019D4B4))),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: kTeal, boxShadow: [BoxShadow(color: kTeal, blurRadius: 8)]), child: SizedBox(width: 9, height: 9)),
            SizedBox(width: 6),
            Text('Onlayn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTeal)),
          ]),
        )),
      ]);
}

class _Honor extends StatelessWidget {
  final String title, sub, icon;
  final Color tone;
  final bool isNew;
  final double h, iw, ih;
  final Animation<double> bob;
  final VoidCallback onTap;
  const _Honor(this.title, this.sub, this.icon, this.tone, {this.isNew = false, this.h = 100, this.iw = 44, this.ih = 44, required this.bob, required this.onTap});
  @override
  Widget build(BuildContext context) => _Tap(
        onTap: onTap,
        child: Container(
          height: h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tone.withAlpha(46)),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tone.withAlpha(56), tone.withAlpha(14)]),
          ),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                FractionallySizedBox(widthFactor: .66, child: Text(sub, style: const TextStyle(fontSize: 12.5, color: kMut))),
              ]),
            ),
            Positioned(right: 10, bottom: 10, child: AnimatedBuilder(
              animation: bob,
              child: Ico(icon, size: iw, height: ih),
              builder: (_, c) => Transform.translate(offset: Offset(0, -3 * Curves.easeInOut.transform(bob.value)), child: c),
            )),
            if (isNew)
              Positioned(top: 0, right: 0, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFF6A5A), Color(0xFFFF3E7E)]),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(10)),
                ),
                child: const Text('YENİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              )),
          ]),
        ),
      );
}

class _LineRow extends StatelessWidget {
  final String title, hint;
  final VoidCallback onTap;
  const _LineRow(this.title, this.hint, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        child: SizedBox(
          height: 62,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            Row(children: [
              Text(hint, style: const TextStyle(fontSize: 15, color: kMut)),
              const SizedBox(width: 4),
              const Ico('chev', size: 15, opacity: .5),
            ]),
          ]),
        ),
      );
}

class _Info extends StatelessWidget {
  final String icon, text;
  const _Info(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Row(children: [Ico(icon, size: 30), const SizedBox(width: 14), Text(text, style: const TextStyle(fontSize: 17))]),
      );
}

/// Dörd işıldayan ulduz, tək CustomPainter
class _SparklePainter extends CustomPainter {
  final Animation<double> t;
  _SparklePainter(this.t) : super(repaint: t);
  static const _pts = [(.12, .46, 0.0), (.86, .30, .25), (.30, .72, .5), (.74, .76, .75)];
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    for (final q in _pts) {
      final v = (t.value + q.$3) % 1;
      final k = .5 + .5 * math.sin(v * 2 * math.pi);
      final s = 2 + 5 * k;
      final x = size.width * q.$1, y = size.height * q.$2;
      p.color = Colors.white.withAlpha((80 + 175 * k).round());
      canvas.drawPath(
        Path()
          ..moveTo(x, y - 2 * s)..lineTo(x + .4 * s, y - .4 * s)..lineTo(x + 2 * s, y)..lineTo(x + .4 * s, y + .4 * s)
          ..lineTo(x, y + 2 * s)..lineTo(x - .4 * s, y + .4 * s)..lineTo(x - 2 * s, y)..lineTo(x - .4 * s, y - .4 * s)..close(),
        p,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _SparklePainter old) => false;
}
