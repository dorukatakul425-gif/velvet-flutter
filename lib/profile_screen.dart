// lib/profile_screen.dart
// Velvet — Profil ekranı (Supabase real data)
// Bütün statik məlumatlar ProfileService.current ValueNotifier-dən gəlir
// Avatar / Cover → Supabase Storage-a yüklənir

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common.dart';
import 'services/profile_service.dart';
import 'profile_parametrler.dart';
import 'vip_screen.dart';

/* ───────────── Rənglər ───────────── */
const kTeal   = Color(0xFF19D4B4);
const kOrange = Color(0xFFFF7336);
const kMut    = Color(0x8CE9E2FF);
const kInk    = Color(0xFFF1EAFF);
const kLilac  = Color(0xFFC084FC);

const kSheetBg    = Color(0xFFF2F2F7);
const kCardBg     = Color(0xFFF7F6FF);
const kCardBgWarm = Color(0xFFFDF6EE);
const kCardBgBlue = Color(0xFFEEF3FF);
const kCardText   = Color(0xFF111111);
const kCardSub    = Color(0xFF999999);

/* ───────────── SVG ikonlar ───────────── */
const String _ink   = '#E9E2FF';
const String _mut   = '#B3A8CC';
const String _teal  = '#19D4B4';
const String _gold  = '#F0B429';
const String _pink  = '#FF5FA8';
const String _green = '#3FCF6A';

String _st(String c, [double w = 2.2]) =>
    'fill="none" stroke="$c" stroke-width="$w" stroke-linecap="round" stroke-linejoin="round"';

final Map<String, (String, String)> _icons = {
  'room':    ('0 0 32 32', '<path d="M5 14.5L16 5l11 9.5V26a2.5 2.5 0 01-2.5 2.5h-17A2.5 2.5 0 015 26z" ${_st(_ink)}/><path d="M12.5 28.5V19a1.5 1.5 0 011.5-1.5h4a1.5 1.5 0 011.5 1.5v9.5" ${_st(_mut, 2)}/>'),
  'visit':   ('0 0 32 32', '<path d="M2.5 16S8 6.5 16 6.5 29.5 16 29.5 16 24 25.5 16 25.5 2.5 16 2.5 16z" ${_st(_ink)}/><circle cx="16" cy="16" r="4.8" ${_st(_mut, 2)}/>'),
  'follow':  ('0 0 32 32', '<circle cx="13" cy="9.5" r="5.5" ${_st(_ink)}/><path d="M3.5 27.5c0-5.8 4.2-9 9.5-9 2.4 0 4.5.6 6.2 1.8" ${_st(_ink)}/><path d="M21.5 25.5l3.2 3.2L30 23" ${_st(_teal, 2.4)}/>'),
  'fans':    ('0 0 32 32', '<circle cx="12" cy="10" r="5.5" ${_st(_ink)}/><path d="M3 27.5c0-5.6 4-8.7 9-8.7s9 3.1 9 8.7" ${_st(_ink)}/><path d="M20.5 5.4a5.5 5.5 0 010 9.9M24 19.3c3 .9 5 3.4 5 7" ${_st(_mut, 2)}/>'),
  'wallet':  ('0 0 32 32', '<rect x="4" y="8" width="24" height="18" rx="4.5" ${_st(_ink)}/><path d="M28 13.5h-5.5a3.5 3.5 0 000 7H28" ${_st(_mut, 2)}/><circle cx="22.8" cy="17" r="1.3" ${_st(_mut, 1.6)}/>'),
  'vip':     ('0 0 32 32', '<path d="M9 6h14l6 7-13 14L3 13z" ${_st(_gold)}/><path d="M3 13h26M9 6l3.5 7L16 27l3.5-14L23 6" ${_st(_gold, 1.4)}/>'),
  'store':   ('0 0 32 32', '<path d="M5 13v14a2 2 0 002 2h18a2 2 0 002-2V13" ${_st(_ink)}/><path d="M4 13l2.5-8h19L28 13c0 2-1.6 3.5-3.7 3.5-2 0-3.4-1.3-3.9-3-.5 1.7-1.9 3-3.9 3s-3.4-1.3-3.9-3c-.5 1.7-1.9 3-3.9 3C5.6 16.5 4 15 4 13z" ${_st(_ink, 2)}/><path d="M12 29v-8h8v8" ${_st(_mut, 2)}/>'),
  'shirt':   ('0 0 32 32', '<path d="M12 4L4 8l2.5 6L10 12.5V28h12V12.5l3.5 1.5L28 8l-8-4c-1 1.8-2.3 2.8-4 2.8S13 5.8 12 4z" ${_st(_ink, 2)}/>'),
  'invite':  ('0 0 32 32', '<rect x="4" y="9" width="20" height="15" rx="3.5" ${_st(_ink)}/><path d="M4.5 11l9.5 7 9.5-7" ${_st(_ink, 2)}/><circle cx="24.5" cy="24" r="6" fill="#07000F" ${_st(_teal, 2)}/><path d="M24.5 21v6M21.5 24h6" ${_st(_teal, 2)}/>'),
  'chat':    ('0 0 32 32', '<path d="M16 5C9.4 5 4 9.4 4 14.8c0 2.9 1.5 5.5 3.9 7.3L6.5 27l5.3-2.4c1.3.4 2.7.6 4.2.6 6.6 0 12-4.4 12-9.8S22.6 5 16 5z" ${_st(_ink)}/><path d="M11.5 14.5q4.5 4 9 0" ${_st(_teal, 2)}/>'),
  'fb':      ('0 0 32 32', '<circle cx="16" cy="16" r="12" ${_st(_ink)}/><path d="M16 9.5v8" ${_st(_ink)}/><circle cx="16" cy="21.8" r="1.6" fill="$_ink"/>'),
  'set':     ('0 0 32 32', '<circle cx="16" cy="16" r="5.5" ${_st(_ink)}/><path d="M16 3.5v3.7M16 24.8v3.7M3.5 16h3.7M24.8 16h3.7M7 7l2.6 2.6M22.4 22.4L25 25M25 7l-2.6 2.6M9.6 22.4L7 25" ${_st(_mut, 2)}/>'),
  'coin':    ('0 0 24 24', '<circle cx="12" cy="12" r="8.6" ${_st(_gold, 1.8)}/><path d="M12 7.6l1.2 2.5 2.7.4-2 1.9.5 2.7-2.4-1.3-2.4 1.3.5-2.7-2-1.9 2.7-.4z" ${_st(_gold, 1.3)}/>'),
  'chev':    ('0 0 16 16', '<path d="M6 3.5L10.5 8 6 12.5" ${_st(_ink, 2)}/>'),
  'chevDk':  ('0 0 16 16', '<path d="M6 3.5L10.5 8 6 12.5" fill="none" stroke="#AAAAAA" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'),
  'copy':    ('0 0 16 16', '<rect x="5.5" y="5.5" width="8" height="8" rx="2" ${_st(_mut, 1.6)}/><path d="M10.5 3.5h-6A1.5 1.5 0 003 5v6" ${_st(_mut, 1.6)}/>'),
  'edit':    ('0 0 32 32', '<path d="M17 5H9a5 5 0 00-5 5v13a5 5 0 005 5h13a5 5 0 005-5v-8" ${_st(_ink)}/><path d="M13 19l1-4.5L25.5 3 29 6.5 17.5 18z" ${_st(_ink)}/>'),
  'back':    ('0 0 24 24', '<path d="M15 4.5L7.5 12l7.5 7.5" ${_st(_ink, 2.4)}/>'),
  'clock':   ('0 0 16 16', '<circle cx="8" cy="8" r="6.3" ${_st(_ink, 1.6)}/><path d="M8 4.5V8l2.4 1.5" ${_st(_ink, 1.6)}/>'),
  'lv':      ('0 0 16 16', '<circle cx="8" cy="8" r="6.6" ${_st(_teal, 1.7)}/><path d="M8 4.8L10.6 9 8 11.2 5.4 9z" ${_st(_teal, 1.3)}/>'),
  'hg':      ('0 0 16 16', '<circle cx="8" cy="8" r="6.6" ${_st(_pink, 1.7)}/><path d="M8 11.3C4.9 9.2 4.8 6.9 6.3 6c.9-.5 1.4.1 1.7.7.3-.6.8-1.2 1.7-.7 1.5.9 1.4 3.2-1.7 5.3z" ${_st(_pink, 1.2)}/>'),
  'age':     ('0 0 16 16', '<circle cx="8" cy="8" r="6.3" ${_st(_mut, 1.5)}/><circle cx="5.8" cy="6.8" r=".5" fill="$_mut"/><circle cx="10.2" cy="6.8" r=".5" fill="$_mut"/><path d="M5.5 9.5q2.5 2 5 0" ${_st(_mut, 1.3)}/>'),
  'leaf':    ('0 0 16 16', '<circle cx="8" cy="8" r="6.6" ${_st(_green, 1.7)}/><path d="M4.8 11.2C4.8 7.6 7.6 4.8 11.4 4.8c0 3.8-2.8 6.4-6.6 6.4M4.8 11.2l3.6-3.6" ${_st(_green, 1.3)}/>'),
  'flag':    ('0 0 32 32', '<rect x="3" y="6" width="26" height="20" rx="4" ${_st(_ink, 2)}/><circle cx="13" cy="16" r="4.2" ${_st(_ink, 1.8)}/><circle cx="14.6" cy="16" r="3" fill="#07000F"/><path d="M20.8 13.6l.7 1.5 1.5.7-1.5.7-.7 1.5-.7-1.5-1.5-.7 1.5-.7z" fill="$_ink"/>'),
  'cake':    ('0 0 16 16', '<rect x="2.8" y="8.8" width="10.4" height="5" rx="1.6" ${_st(_pink, 1.5)}/><path d="M2.8 10.6c1.3 1 2.6 1 3.9 0s2.6-1 3.9 0 2.1 1 2.6 0" ${_st(_pink, 1.2)}/><path d="M8 8V6" ${_st(_gold, 1.5)}/><path d="M8 2.6c.8.9.8 1.6 0 2.3-.8-.7-.8-1.4 0-2.3z" ${_st(_gold, 1.2)}/>'),
  'lock':    ('0 0 16 16', '<rect x="3.8" y="7" width="8.4" height="6.5" rx="2" ${_st(_mut, 1.5)}/><path d="M5.6 7V5.6a2.4 2.4 0 014.8 0V7" ${_st(_mut, 1.5)}/>'),
  'play':    ('0 0 16 16', '<path d="M5.8 4.2v7.6l6.4-3.8z" ${_st(_ink, 1.5)}/>'),
  'help':    ('0 0 32 32', '<circle cx="16" cy="16" r="12" ${_st(_ink)}/><path d="M12.4 12.8a3.7 3.7 0 116.8 2c-.9 1.2-2.4 1.7-2.4 3.4" ${_st(_ink)}/><circle cx="16.6" cy="21.8" r="1.4" fill="$_ink"/>'),
  'gift':    ('0 0 64 64', '<rect x="8" y="27" width="48" height="29" rx="5" ${_st(_gold, 3)}/><rect x="4" y="17" width="56" height="10" rx="3" ${_st(_gold, 3)}/><path d="M32 17v39" ${_st(_gold, 3)}/><path d="M32 17c-9-3-17-5-14.5-11.5S28 6.5 32 17zm0 0c9-3 17-5 14.5-11.5S36 6.5 32 17z" ${_st(_gold, 3)}/>'),
  'car':     ('0 0 64 40', '<path d="M4 26c0-3.5 2.6-5.4 7-6.3l10-7.2c2-1.3 4-2 6.5-2h9c3.5 0 6.4 1.3 8.5 3.5l4.5 4.6c3.8.9 6.5 2 6.5 5.4V27c0 1.4-1 2.5-2.5 2.5h-47A2.5 2.5 0 014 27z" ${_st(_mut, 2.4)}/><circle cx="18" cy="30" r="5.5" ${_st(_mut, 2.4)}/><circle cx="47" cy="30" r="5.5" ${_st(_mut, 2.4)}/>'),
  'b1':      ('0 0 48 48', '<path d="M24 3l5.5 3.6 6.5-.9 2.7 6.4 5.6 3.6-1.8 6.3 1.8 6.3-5.6 3.6-2.7 6.4-6.5-.9L24 41l-5.5-3.6-6.5.9-2.7-6.4-5.6-3.6 1.8-6.3-1.8-6.3 5.6-3.6 2.7-6.4 6.5.9z" ${_st(_gold, 2.4)}/><path d="M24 14l8 7-8 11-8-11z" ${_st(_gold, 2)}/>'),
  'b2':      ('0 0 48 48', '<circle cx="24" cy="24" r="15" ${_st(_pink, 2.4)}/><circle cx="24" cy="24" r="8.5" ${_st(_pink, 1.7)}/><path d="M24 20l1.6 3.4 3.7.4-2.7 2.5.7 3.6-3.3-1.8-3.3 1.8.7-3.6-2.7-2.5 3.7-.4z" ${_st(_pink, 1.3)}/><path d="M11 36l-4 8 7-2.6M37 36l4 8-7-2.6" ${_st(_gold, 2)}/>'),
  'family':  ('0 0 32 32', '<circle cx="11" cy="10" r="5" ${_st(_ink)}/><path d="M3 27c0-5 3.4-8 8-8s8 3 8 8" ${_st(_ink)}/><circle cx="22.5" cy="11.5" r="4" ${_st(_mut, 2)}/><path d="M21 19.6c4.2.3 7 3 7 7.4" ${_st(_mut, 2)}/>'),
  'tri':     ('0 0 120 120', '<circle cx="60" cy="60" r="53" ${_st('#37D67A', 3)}/><path d="M60 27l33 56H27z" ${_st('#7DFFB8', 3)}/><path d="M60 49l15 26H45z" ${_st('#7DFFB8', 2)}/>'),
  'podium':  ('0 0 200 56', '<ellipse cx="100" cy="40" rx="96" ry="12" fill="#1C130B"/><ellipse cx="100" cy="34" rx="96" ry="13" fill="#2B1F12"/><ellipse cx="100" cy="34" rx="96" ry="13" ${_st('#C89B62', 2)}/>'),
  'pPlate':  ('0 0 64 64', '<rect x="8" y="18" width="48" height="28" rx="10" ${_st(_gold, 2.6)}/><path d="M6 12l3 4M58 48l-3-4" ${_st(_gold, 2)}/>'),
  'pAura':   ('0 0 64 64', '<circle cx="32" cy="32" r="24" ${_st(_gold, 2)}/><circle cx="32" cy="32" r="16" ${_st(_gold, 2)}/><circle cx="32" cy="32" r="8" ${_st(_gold, 1.6)}/>'),
  'pCrest':  ('0 0 64 64', '<path d="M32 6l20 8v16c0 14-9 22-20 28C21 52 12 44 12 30V14z" fill="none" stroke="#C084FC" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/><path d="M32 16l8 7-8 16-8-16z" ${_st(_gold, 2)}/>'),
  'pRing':   ('0 0 64 64', '<circle cx="32" cy="34" r="19" ${_st(_gold, 4)}/><circle cx="32" cy="10" r="4" ${_st(_gold, 2)}/>'),
  'cal':     ('0 0 32 32', '<rect x="3" y="6" width="26" height="20" rx="4" ${_st(_ink, 2)}/><path d="M8 12h16M8 16h10M8 20h6" ${_st(_mut, 1.8)}/>'),
  'pen':     ('0 0 32 32', '<path d="M17 5H9a5 5 0 00-5 5v13a5 5 0 005 5h13a5 5 0 005-5v-8" ${_st(_ink)}/><path d="M13 19l1-4.5L25.5 3 29 6.5 17.5 18z" ${_st(_ink)}/>'),
  'cam':     ('0 0 32 32', '<path d="M5 9h4l2-3h10l2 3h4a2 2 0 012 2v14a2 2 0 01-2 2H5a2 2 0 01-2-2V11a2 2 0 012-2z" ${_st(_ink)}/><circle cx="16" cy="17" r="5" ${_st(_mut, 2)}/>'),
};

class Ico extends StatelessWidget {
  final String name;
  final double size;
  final double? height;
  final double opacity;
  const Ico(this.name, {super.key, this.size = 24, this.height, this.opacity = 1});
  static final _cache = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final entry = _icons[name];
    if (entry == null) return SizedBox(width: size, height: height ?? size);
    final svg = _cache.putIfAbsent(name, () =>
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${entry.$1}">${entry.$2}</svg>');
    final w = SvgPicture.string(svg, width: size, height: height ?? size, fit: BoxFit.contain);
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

class _Reveal extends StatefulWidget {
  final int delay;
  final Widget child;
  const _Reveal({this.delay = 0, required this.child});
  @override State<_Reveal> createState() => _RevealState();
}
class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: 420 + widget.delay), value: 0)..forward();
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _a, child: widget.child,
      builder: (_, c) => Opacity(opacity: _a.value, child: Transform.translate(offset: Offset(0, 12 * (1 - _a.value)), child: c)));
}

class _Tap extends StatefulWidget {
  final VoidCallback onTap; final Widget child;
  const _Tap({required this.onTap, required this.child});
  @override State<_Tap> createState() => _TapState();
}
class _TapState extends State<_Tap> {
  bool _d = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => setState(() => _d = true),
    onTapCancel: () => setState(() => _d = false),
    onTapUp: (_) { setState(() => _d = false); HapticFeedback.selectionClick(); widget.onTap(); },
    child: AnimatedScale(scale: _d ? .9 : 1, duration: const Duration(milliseconds: 120), child: widget.child),
  );
}

/* ── Avatar widget — URL varsa göstər, yoxsa inisial ── */
class _AvatarWidget extends StatelessWidget {
  final double size;
  final bool online;
  final String? avatarUrl;
  final String initials;
  const _AvatarWidget({required this.size, this.online = false, this.avatarUrl, this.initials = 'V'});

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox(width: size, height: size, child: Stack(children: [
      Container(
        width: size, height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00), kLilac, kPurple, kTeal, Color(0xFFFFD700)]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(3),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(avatarUrl!, fit: BoxFit.cover, width: size - 6, height: size - 6,
                  errorBuilder: (_, __, ___) => _initials(size - 6))
              : _initials(size - 6),
        ),
      ),
      if (online) Positioned(right: 3, bottom: 5,
        child: Container(width: 15, height: 15,
          decoration: BoxDecoration(shape: BoxShape.circle, color: kTeal,
              border: Border.all(color: kBg, width: 2.5),
              boxShadow: const [BoxShadow(color: kTeal, blurRadius: 8)]))),
    ])),
  );

  Widget _initials(double sz) => Container(
    width: sz, height: sz,
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB06BFF), Color(0xFF6A2BE0)])),
    child: Center(child: Text(initials, style: TextStyle(fontSize: sz * .41, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white, shadows: const [Shadow(color: Color(0xFF4A1AA8), offset: Offset(0, 2))]))),
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
    decoration: BoxDecoration(gradient: grad, color: grad == null ? const Color(0x17FFFFFF) : null, borderRadius: BorderRadius.circular(14)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Ico(icon, size: 16), const SizedBox(width: 4), Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: fg))]),
  );
}

class _Aurora extends StatelessWidget {
  const _Aurora();
  Widget _blob(double w, double h, Color c) => Container(width: w, height: h,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c, c.withAlpha(0)])));
  @override
  Widget build(BuildContext context) => IgnorePointer(child: RepaintBoundary(child: Stack(clipBehavior: Clip.hardEdge, children: [
    Positioned(left: -60, top: -80, child: _blob(320, 280, kPurple.withAlpha(150))),
    Positioned(right: -50, top: -60, child: _blob(280, 260, kPink.withAlpha(110))),
    Positioned(left: 90, top: 10,  child: _blob(260, 210, kTeal.withAlpha(70))),
    const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0007000F), kBg], stops: [.35, 1])))),
  ])));
}

/* ═══════════════════════════════════════
   PROFİL EKRANI
═══════════════════════════════════════ */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _svc      = ProfileService();
  final _copied   = ValueNotifier<bool>(false);
  final _left     = ValueNotifier<int>(3 * 86400 + 23 * 3600 + 56 * 60 + 9);
  Timer? _tick;
  bool _loading   = true;
  final _picker   = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.value > 0) _left.value--;
    });
  }

  Future<void> _loadProfile() async {
    await _svc.loadCurrent();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _left.dispose();
    _copied.dispose();
    super.dispose();
  }

  String _fmtTimer(int s) {
    String p(int n) => n.toString().padLeft(2, '0');
    final d = s ~/ 86400, r = s % 86400;
    return '$d gün ${p(r ~/ 3600)}:${p(r % 3600 ~/ 60)}:${p(r % 60)}';
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    HapticFeedback.lightImpact();
    _copied.value = true;
    velvetToast(context, 'ID kopyalandı');
    Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) _copied.value = false; });
  }

  Future<void> _pickAvatar() async {
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xf == null || !mounted) return;
    velvetToast(context, 'Yüklənir...');
    final url = await _svc.uploadAvatar(File(xf.path));
    if (mounted && url != null) velvetToast(context, 'Avatar yeniləndi ✓');
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kTeal)));
    }
    return ValueListenableBuilder<VelvetProfile?>(
      valueListenable: _svc.current,
      builder: (_, profile, __) {
        final p = profile;
        return Scaffold(
          body: Stack(children: [
            const Positioned(top: 0, left: 0, right: 0, height: 340, child: _Aurora()),
            CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: Padding(
                  padding: EdgeInsets.fromLTRB(18, top + 10, 18, 0),
                  child: Align(alignment: Alignment.centerRight,
                    child: _Tap(onTap: () => Navigator.of(context).push(vRoute(const PublicProfileScreen())),
                      child: const Ico('edit', size: 28))),
                )),
                SliverToBoxAdapter(child: _Reveal(child: _header(p))),
                SliverToBoxAdapter(child: _Reveal(delay: 70, child: _stats(p))),
                SliverToBoxAdapter(child: _Reveal(delay: 140, child: _banner())),
                SliverToBoxAdapter(child: _Reveal(delay: 210, child: _card1(p))),
                SliverToBoxAdapter(child: _Reveal(delay: 280, child: _card2())),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ]),
        );
      },
    );
  }

  Widget _header(VelvetProfile? p) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () { HapticFeedback.selectionClick(); Navigator.of(context).push(vRoute(const PublicProfileScreen())); },
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: _AvatarWidget(size: 78, avatarUrl: p?.avatarUrl, initials: (p?.displayName ?? 'V')[0].toUpperCase()),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p?.displayName ?? 'Velvet istifadəçisi', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Tap(
              onTap: () => Navigator.of(context).push(vRoute(const WealthLevelScreen())),
              child: _Chip('lv', p?.wealthLabel ?? 'Sv.1'),
            ),
            const _Chip('hg', 'Aktiv deyil'),
          ]),
          const SizedBox(height: 6),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 4, children: [
            GestureDetector(
              onTap: () => _copyId(p?.id ?? ''),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('ID:${p?.id.substring(0, 8) ?? '--------'}', style: const TextStyle(fontSize: 12, color: kMut)),
                const SizedBox(width: 5),
                ValueListenableBuilder<bool>(valueListenable: _copied,
                  builder: (_, c, __) => AnimatedSwitcher(duration: const Duration(milliseconds: 250),
                    child: Ico(c ? 'lv' : 'copy', key: ValueKey(c), size: 14))),
              ]),
            ),
            Container(width: 1, height: 12, color: const Color(0x26FFFFFF)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Ico('flag', size: 16), const SizedBox(width: 5),
              Text(p?.country ?? 'Azərbaycan', style: const TextStyle(fontSize: 12, color: kMut)),
            ]),
            if (p?.age != null)
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Ico('cake', size: 16), const SizedBox(width: 4),
                Text('${p!.age} yaş', style: const TextStyle(fontSize: 12, color: kMut)),
              ]),
          ]),
        ])),
        const Ico('chev', size: 16, opacity: .4),
      ]),
    ),
  );

  Widget _stats(VelvetProfile? p) {
    Widget s(String ic, String n, String l) => Expanded(child: Column(children: [
      Ico(ic, size: 30), const SizedBox(height: 6),
      Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      Text(l, style: const TextStyle(fontSize: 12, color: kMut)),
    ]));
    Widget d() => Container(width: 1, height: 40, color: const Color(0x1AFFFFFF));
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 22, 10, 0),
      child: Row(children: [
        s('room',   '${p?.roomCount ?? 0}',      'Otaq'),    d(),
        s('visit',  '${p?.visitorCount ?? 0}',   'Ziyarətçi'), d(),
        s('follow', '${p?.followingCount ?? 0}', 'İzlənilən'), d(),
        s('fans',   '${p?.followerCount ?? 0}',  'İzləyici'),
      ]),
    );
  }

  Widget _banner() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 26, 14, 0),
    child: GestureDetector(
      onTap: () => velvetToast(context, 'Məhdud vaxtlı mükafat'),
      child: RepaintBoundary(child: Container(
        height: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x6619D4B4), width: 1.5),
          gradient: const LinearGradient(colors: [Color(0x38FF3EA5), Color(0x477B2FF7), Color(0x3819D4B4)]),
          boxShadow: const [BoxShadow(color: Color(0x407B2FF7), blurRadius: 22)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 6),
            child: Row(children: [
              const Ico('gift', size: 56, height: 56), const SizedBox(width: 12),
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
              const Ico('clock', size: 13), const SizedBox(width: 4),
              ValueListenableBuilder<int>(valueListenable: _left,
                builder: (_, s, __) => Text(_fmtTimer(s), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]))),
            ]),
          ))),
        ]),
      )),
    ),
  );

  Widget _card1(VelvetProfile? p) => _MenuCard(rows: [
    _Item('wallet', 'Pulqabı', () => velvetToast(context, 'Pulqabı'), right: Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 13, 5),
      decoration: BoxDecoration(color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Ico('coin', size: 20), const SizedBox(width: 6),
        Text('${p?.coinBalance ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    )),
    _Item('vip', 'VIP', () => Navigator.of(context).push(vRoute(const VipScreen())),
        text: p != null && p.vipLevel > 0 ? 'VIP ${p.vipLevel}' : 'VIP 0', color: kMut),
    _Item('store',  'Mağaza',   () => velvetToast(context, 'Mağaza')),
    _Item('shirt',  'Aksesuar', () => velvetToast(context, 'Aksesuar')),
  ]);

  Widget _card2() => _MenuCard(rows: [
    _Item('invite', 'Dost dəvət et', () => velvetToast(context, 'Dost dəvət et'), text: 'Jeton qazan', color: const Color(0xFFFFB020)),
    _Item('chat',   'Onlayn müştəri xidməti', () => velvetToast(context, 'Onlayn müştəri xidməti')),
    _Item('fb',     'Problem bildir', () => velvetToast(context, 'Problem bildir')),
    _Item('set',    'Parametrlər', () => Navigator.of(context).push(vRoute(const ParametrlerScreen())),
        text: 'Hesabınız risk altındadır', color: const Color(0xFFFF6B8A)),
  ]);
}

/* ─── Menyu komponentləri ─── */
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
    child: RepaintBoundary(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x24965AF0)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 6))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(22),
        child: Material(type: MaterialType.transparency,
          child: Column(children: [for (final r in rows) _MenuRow(item: r)]))),
    )),
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
    child: SizedBox(height: 64, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Ico(item.icon, size: 32), const SizedBox(width: 14),
        Text(item.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: kInk)),
        Expanded(child: Align(alignment: Alignment.centerRight,
          child: Padding(padding: const EdgeInsets.only(left: 12, right: 8),
            child: item.right ?? (item.text == null ? const SizedBox()
                : Text(item.text!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: item.color)))))),
        const Ico('chev', size: 16, opacity: .4),
      ]),
    )),
  );
}

/* ═══════════════════════════════════════
   ZİYARƏTÇİ PROFİLİ
═══════════════════════════════════════ */
class PublicProfileScreen extends StatefulWidget {
  final String? userId; // null = cari istifadəçi
  const PublicProfileScreen({super.key, this.userId});
  @override State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen>
    with TickerProviderStateMixin {
  final _svc      = ProfileService();
  final _copied   = ValueNotifier<bool>(false);
  final _picker   = ImagePicker();
  VelvetProfile?  _profile;
  bool  _loading  = true;
  bool  _uploading = false;

  // Lokal seçilmiş foto (dərhal göstərilir, arxa planda yüklənir)
  File? _localCover;

  // Animasiya dəyişənləri (default Velvet arxa fon üçün)
  late AnimationController _gradCtrl;
  late Animation<double>    _gradAnim;

  bool get _isOwn => widget.userId == null ||
      widget.userId == Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    // Arxa fon gradient animasiyası — sonsuz, yavaş
    _gradCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _gradAnim = CurvedAnimation(parent: _gradCtrl, curve: Curves.easeInOut);
    _load();
  }

  Future<void> _load() async {
    VelvetProfile? p;
    if (_isOwn) {
      p = _svc.current.value ?? await _svc.loadCurrent();
    } else {
      p = await _svc.loadById(widget.userId!);
    }
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  @override
  void dispose() {
    _gradCtrl.dispose();
    _copied.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    if (!_isOwn) return;
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xf == null || !mounted) return;
    final file = File(xf.path);
    // Dərhal lokaldan göstər
    setState(() { _localCover = file; _uploading = true; });
    // Arxa planda Supabase-ə yüklə
    final url = await _svc.uploadCover(file);
    if (mounted) {
      setState(() {
        _uploading = false;
        if (url != null) _profile = _profile?.copyWith(coverUrl: url);
        // coverUrl gəldikdən sonra lokal faylı saxla (URL yüklənənə qədər)
      });
      if (url != null) velvetToast(context, 'Arxa fon yeniləndi ✓');
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kTeal)));

    final p = _profile;
    final outline = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeJoin = StrokeJoin.round..color = const Color(0xFF8448E8);
    final shadow  = Paint()..style = PaintingStyle.stroke..strokeWidth = 22..strokeJoin = StrokeJoin.round..color = const Color(0x66501AAA);

    // Arxa fon vəziyyəti: lokal > network > default
    final hasCover = _localCover != null ||
        (p?.coverUrl != null && p!.coverUrl!.isNotEmpty);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(fit: StackFit.passthrough, children: [

          // ══ HERO ══════════════════════════════════════════
          SizedBox(
            height: 330,
            child: Stack(alignment: Alignment.center, children: [

              // ── Arxa fon ──────────────────────────────────
              Positioned.fill(child: _buildBackground(p, hasCover)),

              // ── Tünd overlay (şəkil varsa) ─────────────────
              if (hasCover)
                Positioned.fill(child: DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withAlpha(80), Colors.black.withAlpha(160)],
                  )),
                )),

              // ── Animasiyalı "V" (arxa fon yoxdursa) ────────
              if (!hasCover) ...[
                // Hərəkətli parıltı halqaları
                AnimatedBuilder(
                  animation: _gradAnim,
                  builder: (_, __) => Positioned(
                    left: -60 + 40 * _gradAnim.value,
                    top:  -40 + 30 * _gradAnim.value,
                    child: Container(width: 260, height: 260,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF7B2FF7).withAlpha(160),
                          Colors.transparent,
                        ]))),
                  ),
                ),
                AnimatedBuilder(
                  animation: _gradAnim,
                  builder: (_, __) => Positioned(
                    right: -40 + 30 * (1 - _gradAnim.value),
                    bottom: -20 + 25 * _gradAnim.value,
                    child: Container(width: 220, height: 220,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFF19D4B4).withAlpha(130),
                          Colors.transparent,
                        ]))),
                  ),
                ),
                AnimatedBuilder(
                  animation: _gradAnim,
                  builder: (_, __) => Positioned(
                    right: 30 + 20 * _gradAnim.value,
                    top: 20 + 20 * (1 - _gradAnim.value),
                    child: Container(width: 180, height: 180,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFFFF3EA5).withAlpha(110),
                          Colors.transparent,
                        ]))),
                  ),
                ),
                // "V" hərfi — tam ekran genişliyində, kəsilmiş
                ClipRect(child: SizedBox(width: double.infinity, height: 330,
                  child: FittedBox(fit: BoxFit.cover, alignment: Alignment.center,
                    child: Stack(alignment: Alignment.center, children: [
                      // Kölgə
                      Transform.translate(offset: const Offset(6, 12),
                        child: Text('V', style: TextStyle(
                          fontSize: 320, height: 1,
                          fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke..strokeWidth = 28
                            ..strokeJoin = StrokeJoin.round
                            ..color = const Color(0x88501AAA),
                        ))),
                      // Outline
                      Text('V', style: TextStyle(
                        fontSize: 320, height: 1,
                        fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke..strokeWidth = 28
                          ..strokeJoin = StrokeJoin.round
                          ..color = const Color(0xFF8448E8),
                      )),
                      // Əsas ağ
                      const Text('V', style: TextStyle(
                        fontSize: 320, height: 1,
                        fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                        color: Colors.white,
                      )),
                    ]),
                  ),
                )),
                // Alt nöqtə
                Positioned(bottom: 44, child: Container(width: 10, height: 10,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
              ],

              // ── Yükləmə indikatoru ──────────────────────────
              if (_uploading)
                Positioned.fill(child: Container(color: Colors.black54,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    CircularProgressIndicator(color: kTeal, strokeWidth: 3),
                    SizedBox(height: 12),
                    Text('Yüklənir...', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ]))),
            ]),
          ),
          // ══════════════════════════════════════════════════

          // ── Düymələr ──
          Positioned(top: top + 12, left: 14,
            child: _Tap(onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.black.withAlpha(90),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(50))),
                child: const Center(child: Ico('back', size: 22)),
              ))),
          if (_isOwn)
            Positioned(top: top + 12, right: 14,
              child: _Tap(onTap: _pickCover, child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.black.withAlpha(102),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(77))),
                child: const Center(child: Ico('cam', size: 20)),
              ))),

          // ── Alt vərəq ──
          Padding(padding: const EdgeInsets.only(top: 296), child: _sheet(p, top)),
        ]),
      ),
    );
  }

  Widget _bigV(Paint? stroke, {Color? color}) => Text('V', style: TextStyle(
      fontSize: 200, height: 1, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
      color: stroke == null ? color : null, foreground: stroke));

  /// Arxa fon: lokal fayl > network URL > animasiyalı default gradient
  Widget _buildBackground(VelvetProfile? p, bool hasCover) {
    // 1. Lokal seçilmiş fayl (dərhal göstər, yüklənmə gözləmə)
    if (_localCover != null) {
      return Image.file(_localCover!, fit: BoxFit.cover, width: double.infinity, height: 330,
          errorBuilder: (_, __, ___) => _defaultBg());
    }
    // 2. Supabase URL (yüklənmiş, kalıcı)
    if (p?.coverUrl != null && p!.coverUrl!.isNotEmpty) {
      return Image.network(
        p.coverUrl!,
        fit: BoxFit.cover, width: double.infinity, height: 330,
        // Yüklənərkən default göstər
        frameBuilder: (ctx, child, frame, loaded) {
          if (loaded || frame != null) return child;
          return _defaultBg();
        },
        errorBuilder: (_, __, ___) => _defaultBg(),
      );
    }
    // 3. Default animasiyalı gradient
    return _defaultBg();
  }

  Widget _defaultBg() => AnimatedBuilder(
    animation: _gradAnim,
    builder: (_, __) {
      final t = _gradAnim.value;
      return DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF5B1FD4), const Color(0xFF8B3FF7), t)!,
            Color.lerp(const Color(0xFF9B4FF8), const Color(0xFF6B2FD0), t)!,
            Color.lerp(const Color(0xFFD08CFF), const Color(0xFFB06BFF), t)!,
          ],
          stops: const [0, 0.55, 1],
        ),
      ));
    },
  );

  Widget _sheet(VelvetProfile? p, double top) => Stack(clipBehavior: Clip.none, children: [
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Color(0x337B2FF7), blurRadius: 30, offset: Offset(0, -10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Ölkə + ID
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), child: SizedBox(height: 56,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(p?.country ?? 'Azərbaycan', style: const TextStyle(fontSize: 15, color: kMut)),
            const SizedBox(width: 10),
            Container(width: 1, height: 16, color: const Color(0x26FFFFFF)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () { if (p != null) { Clipboard.setData(ClipboardData(text: p.id)); HapticFeedback.lightImpact(); _copied.value = true; velvetToast(context, 'ID kopyalandı'); Future.delayed(const Duration(milliseconds: 1500), () { if (mounted) _copied.value = false; }); } },
              child: Row(children: [
                Text('ID:${p?.id.substring(0, 8) ?? '--------'}', style: const TextStyle(fontSize: 15, color: kMut)),
                const SizedBox(width: 5),
                ValueListenableBuilder<bool>(valueListenable: _copied, builder: (_, c, __) => Ico(c ? 'lv' : 'copy', size: 15)),
              ]),
            ),
          ]),
        )),

        // Ad + chiplar
        Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(p?.displayName ?? 'Velvet istifadəçisi', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            if (p?.age != null) _Chip('age', '${p!.age}', fg: const Color(0xFFCFC6EA)),
            _Chip('leaf', 'Yeni başlayan', grad: const LinearGradient(colors: [Color(0xFF2FD84A), Color(0xFF8BE34A)])),
            _Chip('lv', p?.wealthLabel ?? 'Sv.1', grad: const LinearGradient(colors: [Color(0xFF0FAE5F), Color(0xFF2BD6A0)])),
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Text('${p?.followingCount ?? 0} İzlənilən · ${p?.followerCount ?? 0} İzləyici',
              style: const TextStyle(fontSize: 17, color: kMut))),

        // ── Nişanlarım ──
        const SizedBox(height: 24),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Nişanlarım', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700))),
        const SizedBox(height: 14),

        Container(color: kSheetBg, padding: const EdgeInsets.fromLTRB(14, 14, 14, 6), child: Column(children: [
          Row(children: [
            Expanded(child: _HonorCard(title: 'SVIP', sub: p?.badgeKeys.contains('svip') == true ? 'Əldə edildi' : 'Hələ əldə edilməyib',
                bg: kCardBgWarm, icon: 'b1', isNew: true, onTap: () => velvetToast(context, 'SVIP'))),
            const SizedBox(width: 9),
            Expanded(child: _HonorCard(title: 'VIP', sub: p?.badgeKeys.contains('vip') == true ? 'Əldə edildi' : 'Hələ əldə edilməyib',
                bg: kCardBgWarm, icon: 'b2', isNew: true, onTap: () => velvetToast(context, 'VIP'))),
            const SizedBox(width: 9),
            Expanded(child: _HonorCard(title: 'Ailə', sub: p?.badgeKeys.contains('family') == true ? 'Üzv' : 'Qoşulmayıb',
                bg: kCardBgBlue, icon: 'family', onTap: () => velvetToast(context, 'Ailə'))),
          ]),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: _HonorCard(title: 'Avtomobil',
                sub: p?.badgeKeys.contains('car') == true ? 'Əldə edildi' : 'Hələ əldə edilməyib',
                bg: kCardBg, icon: 'car', iconW: 60, iconH: 38, minH: 84, isNew: true,
                onTap: () => velvetToast(context, 'Avtomobil'))),
            const SizedBox(width: 9),
            Expanded(child: _HonorCard(title: 'Hədiyyə divarı',
                sub: p?.badgeKeys.contains('gift_wall') == true ? 'Tamamlandı' : '0/450',
                bg: kCardBg, icon: 'gift', iconW: 44, iconH: 44, minH: 84,
                onTap: () => velvetToast(context, 'Hədiyyə divarı'))),
          ]),
        ])),

        // Yakın arkadaş + Paylaşımlar
        Container(color: Colors.white, child: Column(children: [
          _LightRow('Yakın arkadaş', 'davet et', () => velvetToast(context, 'Yakın arkadaş')),
          const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
          _LightRow('Paylaşımlar', 'Möhtəşəm anlarını paylaş', () => velvetToast(context, 'Paylaşımlar')),
        ])),
        const SizedBox(height: 8),

        // Şəxsi məlumat
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Şəxsi məlumat', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            _InfoRow('cal', 'Velvet-də bu gün ${p?.daysOnVelvet ?? 1}-ci gün'),
            _InfoRow('pen', p?.bio?.isNotEmpty == true ? p!.bio! : 'Heç bir məlumat qoyulmayıb~'),
          ]),
        ),
        const SizedBox(height: 44),
      ]),
    ),

    // Avatar
    Positioned(left: 18, top: -58, child: _AvatarWidget(size: 88, online: p?.isOnline ?? false,
        avatarUrl: p?.avatarUrl, initials: (p?.displayName ?? 'V')[0].toUpperCase())),
    // Onlayn badge
    Positioned(left: 14, top: 26, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x4019D4B4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle,
            color: p?.isOnline == true ? kTeal : kMut,
            boxShadow: p?.isOnline == true ? const [BoxShadow(color: kTeal, blurRadius: 8)] : null),
            child: SizedBox(width: 9, height: 9)),
        const SizedBox(width: 6),
        Text(p?.isOnline == true ? 'Onlayn' : 'Oflayn',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: p?.isOnline == true ? kTeal : kMut)),
      ]),
    )),
  ]);
}

class _HonorCard extends StatelessWidget {
  final String title, sub, icon;
  final Color bg;
  final double iconW, iconH, minH;
  final bool isNew;
  final VoidCallback onTap;
  const _HonorCard({required this.title, required this.sub, required this.bg, required this.icon,
      this.iconW = 44, this.iconH = 44, this.minH = 90, this.isNew = false, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(constraints: BoxConstraints(minHeight: minH), clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withAlpha(10))),
      child: Stack(children: [
        Padding(padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kCardText)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 12, color: kCardSub)),
          ])),
        Positioned(right: 8, bottom: 8, child: Ico(icon, size: iconW, height: iconH)),
        if (isNew) Positioned(top: 0, right: 0, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF6A5A), Color(0xFFFF3E7E)]),
            borderRadius: BorderRadius.only(topRight: Radius.circular(14), bottomLeft: Radius.circular(9))),
          child: const Text('YENİ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)))),
      ])));
}

class _LightRow extends StatelessWidget {
  final String title, hint; final VoidCallback onTap;
  const _LightRow(this.title, this.hint, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kCardText)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(hint, style: const TextStyle(fontSize: 13, color: kCardSub)),
          const SizedBox(width: 3), const Ico('chevDk', size: 14),
        ]),
      ])));
}

class _InfoRow extends StatelessWidget {
  final String icon, text; const _InfoRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 18),
    child: Row(children: [Ico(icon, size: 28), const SizedBox(width: 14), Expanded(child: Text(text, style: const TextStyle(fontSize: 17)))]));
}

/* ═══════════════════════════════════════
   ZƏNGİNLİK SƏVİYYƏSİ
═══════════════════════════════════════ */
class WealthLevelScreen extends StatelessWidget {
  const WealthLevelScreen({super.key});
  static const _perks = [('İşıltı',51),('Aura',61),('Seçkin',71),('İhtişam',81),('Hüzmə',91),('Prestij',101),('Dastan',111),('Zəfər',121),('Fırtına',131),('Şəfəq',141),('Səltənət',151),('Əfsanə',161)];
  static const _pv = ['pPlate','pAura','pCrest','pRing'];

  Widget _line(bool flip) => Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(
      begin: flip ? Alignment.centerRight : Alignment.centerLeft, end: flip ? Alignment.centerLeft : Alignment.centerRight,
      colors: const [Color(0x00FF7336), kOrange]))));
  Widget _dots() => Row(mainAxisSize: MainAxisSize.min, children: const [
    DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: kOrange), child: SizedBox(width: 7, height: 7)),
    SizedBox(width: 2),
    DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF9A62)), child: SizedBox(width: 4, height: 4)),
  ]);

  @override
  Widget build(BuildContext context) {
    final svc = ProfileService();
    final p   = svc.current.value;
    final top = MediaQuery.of(context).padding.top;
    final hh  = top + 236;
    final wl  = p?.wealthLevel ?? 1;

    return Scaffold(body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
      SliverToBoxAdapter(child: ClipPath(clipper: const _ArcClipper(), child: RepaintBoundary(child: SizedBox(height: hh, child: Stack(children: [
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF131010), Color(0xFF1F1812), Color(0xFF33261A)])))),
        Positioned.fill(child: CustomPaint(painter: _BeamPainter())),
        const Positioned(right: -22, top: 0, child: Padding(padding: EdgeInsets.only(top: 176), child: Ico('podium', size: 200, height: 56))),
        Positioned(right: 34, top: 78, child: SizedBox(width: 98, height: 98, child: Stack(alignment: Alignment.center, children: [
          Container(width: 150, height: 150, decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x5500FF88), Color(0x0000FF88)]))),
          const Ico('tri', size: 98),
        ]))),
        Positioned(top: 6, left: 0, right: 0, height: 48, child: Row(children: [
          _Tap(onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Ico('back', size: 28))),
          const Expanded(child: Text('Zənginlik Səviyyəsi', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          _Tap(onTap: () => velvetToast(context, 'Zənginlik xalı hədiyyə göndərdikcə artır'),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Ico('help', size: 28))),
        ])),
        Positioned(left: 26, top: 78, child: Row(children: [
          _AvatarWidget(size: 46, avatarUrl: p?.avatarUrl, initials: (p?.displayName ?? 'V')[0].toUpperCase()),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cari səviyyə', style: TextStyle(fontSize: 14)),
            Text('Sv.$wl', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
          ]),
        ])),
        Positioned(left: 26, top: 140, width: 205, child: const Text.rich(TextSpan(style: TextStyle(fontSize: 14, height: 1.3), children: [
          TextSpan(text: 'Səviyyə atlamaq üçün '),
          TextSpan(text: '650', style: TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: ' zənginlik xalı lazımdır.'),
        ]))),
        Positioned(left: 26, top: 190, width: 173, height: 6, child: ClipRRect(borderRadius: BorderRadius.circular(3), child: Stack(children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFF3A3A3A))),
          TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: (wl / 161).clamp(0.02, 1.0)),
            duration: const Duration(milliseconds: 1100), curve: Curves.easeOutCubic,
            builder: (_, v, __) => FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: v,
              child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF9A62), Color(0xFFFF5A5A)])),
                  child: SizedBox.expand()))),
        ]))),
      ]))))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
        child: Row(children: [_line(false), const SizedBox(width: 10), _dots(), const SizedBox(width: 10),
          const Text('Səviyyə imtiyazları', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: kOrange)),
          const SizedBox(width: 10), _dots(), const SizedBox(width: 10), _line(true)]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 40), sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .74),
        delegate: SliverChildBuilderDelegate((_, i) => _Reveal(delay: (i%3)*60+(i~/3)*30,
          child: _PerkCard(name: _perks[i].$1, lv: _perks[i].$2, pv: _pv[i%4],
              onTap: () => velvetToast(context, 'Sv${_perks[i].$2} səviyyəsində açılır'))),
          childCount: _perks.length),
      )),
    ]));
  }
}

class _PerkCard extends StatelessWidget {
  final String name, pv; final int lv; final VoidCallback onTap;
  const _PerkCard({required this.name, required this.lv, required this.pv, required this.onTap});
  @override
  Widget build(BuildContext context) => _Tap(onTap: onTap, child: Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1FFF9B6B)),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x33FF9B6B), Color(0x0DFF9B6B)])),
    child: Stack(children: [
      Column(children: [
        Expanded(child: Stack(children: [
          Center(child: Padding(padding: const EdgeInsets.only(top: 14), child: Ico(pv, size: 58, opacity: .9))),
          Positioned(right: 12, bottom: 2, child: Container(width: 20, height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xB3555555)),
            child: const Center(child: Ico('play', size: 11)))),
        ])),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xB3E9E2FF))),
        const SizedBox(height: 2),
        Text('Sv$lv Kilidi aç', maxLines: 1, style: const TextStyle(fontSize: 12.5, color: Color(0x80E9E2FF))),
        const SizedBox(height: 12),
      ]),
      Positioned(left: 8, top: 8, child: Container(width: 24, height: 24,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5B4BF0)),
        child: const Center(child: Ico('lock', size: 12)))),
    ]),
  ));
}

class _ArcClipper extends CustomClipper<Path> {
  const _ArcClipper();
  @override Path getClip(Size s) => Path()..lineTo(s.width,0)..lineTo(s.width,s.height)..quadraticBezierTo(s.width/2,s.height-56,0,s.height)..close();
  @override bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _BeamPainter extends CustomPainter {
  const _BeamPainter();
  @override
  void paint(Canvas c, Size s) {
    void beam(double a, double b, double d, double e, int alpha) {
      final path = Path()..moveTo(s.width*a,0)..lineTo(s.width*b,0)..lineTo(s.width*d,s.height)..lineTo(s.width*e,s.height)..close();
      c.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(alpha), Colors.white.withAlpha(0)]).createShader(Offset.zero & s));
    }
    beam(.58,.78,.30,1.02,40); beam(.66,.72,.50,.96,26);
  }
  @override bool shouldRepaint(covariant _BeamPainter old) => false;
}
