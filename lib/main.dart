// Velvet — Flutter tətbiqi (index.tsx-in tam köçürməsi)
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common.dart';
import 'home_screen.dart';
import 'room_screen.dart' show RoomScreen;
import 'profile_screen.dart' show ProfileScreen;

const _supabaseUrl = 'https://jvbilhaajtfxtfljyqoi.supabase.co';
const _supabaseKey = 'sb_publishable_VDPBDt0HFJSLOgnW-jQtyg_ADLj8WuU';
bool _supabaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kBg,
  ));
  try {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseKey);
    _supabaseReady = true;
  } catch (_) {}
  runApp(const VelvetApp());
}

class VelvetApp extends StatelessWidget {
  const VelvetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Velvet',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBg,
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(primary: kPurple, secondary: kPink),
          pageTransitionsTheme: PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()}),
        ),
        home: const _Root(),
      );
}

/* ─────────── Kök: splash → giriş → tətbiq ─────────── */
class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _splash = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    appLogout = _logout;
    Timer(const Duration(milliseconds: 1900), () { if (mounted) setState(() => _splash = false); });
    if (_supabaseReady) {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) { if (mounted) setState(() {}); });
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  Session? get _session => _supabaseReady ? Supabase.instance.client.auth.currentSession : null;

  String get _name {
    final u = _session?.user;
    final n = u?.userMetadata?['full_name'] as String?;
    if (n != null && n.isNotEmpty) return n;
    final e = u?.email;
    if (e != null) return e.split('@').first;
    return 'Velvet istifadəçisi';
  }

  Future<void> _logout() async {
    if (_supabaseReady) { try { await Supabase.instance.client.auth.signOut(); } catch (_) {} }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_splash) {
      child = const _Splash(key: ValueKey('splash'));
    } else if (_session != null) {
      child = _Shell(key: const ValueKey('shell'), name: _name);
    } else {
      child = _Login(key: const ValueKey('login'), supabaseReady: _supabaseReady);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 620),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/* ─────────── Velvet açılış səhnəsi ─────────── */
class _Splash extends StatelessWidget {
  const _Splash({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const _VelvetMark(size: 290),
      const SizedBox(height: 4),
      const _VelvetWordmark(fontSize: 42),
    ])),
  );
}

class _VelvetWordmark extends StatelessWidget {
  final double fontSize;
  const _VelvetWordmark({required this.fontSize});
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (rect) => const LinearGradient(
      colors: [Colors.white, kLilac, kPink],
    ).createShader(rect),
    child: Text('VELVET', style: TextStyle(
      fontSize: fontSize, fontWeight: FontWeight.w900,
      letterSpacing: 6, color: Colors.white,
    )),
  );
}

class _VelvetMark extends StatefulWidget {
  final double size;
  const _VelvetMark({required this.size});
  @override
  State<_VelvetMark> createState() => _VelvetMarkState();
}

class _VelvetMarkState extends State<_VelvetMark> with TickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1050),
  )..forward();
  late final AnimationController _motion = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 4400),
  )..repeat();

  @override
  void dispose() { _reveal.dispose(); _motion.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size,
    child: RepaintBoundary(child: AnimatedBuilder(
      animation: Listenable.merge([_reveal, _motion]),
      builder: (_, __) => CustomPaint(
        painter: _VelvetMarkPainter(
          reveal: Curves.easeOutCubic.transform(_reveal.value),
          phase: _motion.value,
        ),
      ),
    )),
  );
}

class _VelvetMarkPainter extends CustomPainter {
  final double reveal;
  final double phase;
  _VelvetMarkPainter({required this.reveal, required this.phase});

  static const _violet = Color(0xFF7B2FF7);
  static const _rose = Color(0xFFFF3EA5);
  static const _lilac = Color(0xFFC084FC);
  static const _cyan = Color(0xFF00D4FF);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 320);
    final tick = phase * math.pi * 2;
    final float = math.sin(tick) * 3.8;
    final center = Offset(160, 160 + float);

    canvas.drawCircle(center, 119 * reveal, Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x6B7B2FF7), Color(0x1FFF3EA5), Color(0x0007000F),
      ], stops: [0, .57, 1]).createShader(Rect.fromCircle(center: center, radius: 119)));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tick * .11);
    for (final orbit in [0, 1]) {
      final r = orbit == 0 ? 106.0 : 126.0;
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r),
        orbit == 0 ? -.65 : 2.45, orbit == 0 ? 2.25 : 1.45,
        false, Paint()
          ..color = (orbit == 0 ? _lilac : _cyan).withOpacity(.28 * reveal)
          ..style = PaintingStyle.stroke ..strokeWidth = orbit == 0 ? 1.3 : .9
          ..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(math.cos(orbit == 0 ? 1.6 : 3.9) * r,
        math.sin(orbit == 0 ? 1.6 : 3.9) * r), orbit == 0 ? 3.5 : 2.5,
        Paint()..color = (orbit == 0 ? _rose : _cyan).withOpacity(.85 * reveal));
    }
    canvas.restore();

    final motes = <(Offset, double, Color, double)>[
      (const Offset(49, 99), 3.1, _cyan, .0),
      (const Offset(275, 98), 4.4, _rose, 1.2),
      (const Offset(64, 223), 2.6, _lilac, 2.4),
      (const Offset(269, 228), 3.2, _cyan, 3.5),
      (const Offset(143, 22), 2.3, _rose, 4.4),
      (const Offset(209, 290), 2.7, _lilac, 5.2),
    ];
    for (final mote in motes) {
      final c = mote.$1 + Offset(0, math.sin(tick + mote.$4) * 5);
      final p = Paint()..color = mote.$3.withOpacity((.45 + .35 *
        (1 + math.sin(tick + mote.$4)) / 2) * reveal);
      canvas.drawCircle(c, mote.$2 * reveal, p..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(c, mote.$2 * .48 * reveal, Paint()..color = mote.$3.withOpacity(reveal));
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(.76 + .24 * reveal);
    canvas.rotate(math.sin(tick) * .025);
    final tile = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-80, -80, 160, 160), const Radius.circular(39));
    canvas.drawRRect(tile, Paint()
      ..color = _violet.withOpacity(.58)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.drawRRect(tile, Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF5221A0), Color(0xFF250947), Color(0xFF16032C)],
      stops: [0, .46, 1],
    ).createShader(const Rect.fromLTWH(-80, -80, 160, 160)));
    canvas.drawRRect(tile, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = const LinearGradient(
        colors: [Color(0xE6E5CBFF), Color(0x887B2FF7), Color(0xCCFF3EA5)],
      ).createShader(const Rect.fromLTWH(-80, -80, 160, 160)));

    final left = Path()
      ..moveTo(-58, -42)..cubicTo(-51, -52, -26, -53, -19, -39)
      ..lineTo(0, 20)..lineTo(-17, 53)
      ..cubicTo(-22, 57, -30, 53, -34, 45)
      ..close();
    final right = Path()
      ..moveTo(58, -42)..cubicTo(47, -55, 25, -53, 18, -38)
      ..lineTo(-8, 25)..lineTo(8, 54)
      ..cubicTo(14, 59, 25, 55, 29, 45)
      ..close();
    canvas.drawPath(left, Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFF9E8FF), Color(0xFFC084FC), Color(0xFF7B2FF7)],
    ).createShader(const Rect.fromLTWH(-60, -55, 65, 115)));
    canvas.drawPath(right, Paint()..shader = const LinearGradient(
      begin: Alignment.topRight, end: Alignment.bottomLeft,
      colors: [Color(0xFFFFD0E9), Color(0xFFFF3EA5), Color(0xFF8E39D7)],
    ).createShader(const Rect.fromLTWH(-10, -55, 70, 115)));
    canvas.drawPath(Path()..moveTo(-40, -40)..quadraticBezierTo(-23, -44, -19, -30),
      Paint()..color = const Color(0xAAFFFFFF)..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    canvas.drawPath(Path()..moveTo(40, -40)..quadraticBezierTo(29, -42, 24, -29),
      Paint()..color = const Color(0x99FFFFFF)..strokeWidth = 2
        ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
    canvas.drawCircle(const Offset(0, 43), 8, Paint()..color = _rose.withOpacity(.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11));
    canvas.drawCircle(const Offset(0, 43), 2.2, Paint()..color = Colors.white);
    canvas.restore();

    for (var i = 0; i < 5; i++) {
      final h = 9.0 + (i == 2 ? 15 : (i == 1 || i == 3 ? 8 : 0)) +
        math.sin(tick * 2 + i * .8) * 4;
      final x = 113.0 + i * 11;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, 285), width: 3.5, height: h * reveal),
        const Radius.circular(3));
      canvas.drawRRect(rect, Paint()..color = (Color.lerp(_violet, _rose, i / 4) ?? _violet).withOpacity(.7));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VelvetMarkPainter old) =>
    old.reveal != reveal || old.phase != phase;
}

/* ─────────── Giriş / Qeydiyyat ─────────── */
class _Login extends StatefulWidget {
  final bool supabaseReady;
  const _Login({super.key, required this.supabaseReady});
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  String _mode = 'main';
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _user = TextEditingController();
  final _age = TextEditingController();
  bool _busy = false;
  String? _err, _ok;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); _user.dispose(); _age.dispose(); super.dispose(); }

  Future<void> _googleLogin() async {
    if (!widget.supabaseReady) { setState(() => _err = 'Serverə qoşulmaq alınmadı'); return; }
    setState(() { _busy = true; _err = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.velvet.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) setState(() => _err = e is AuthException ? e.message : 'Google ilə giriş alınmadı');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) { setState(() => _err = 'Email və şifrə daxil edin'); return; }
    if (!widget.supabaseReady) { setState(() => _err = 'Serverə qoşulmaq alınmadı'); return; }
    setState(() { _busy = true; _err = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: _email.text.trim(), password: _pass.text);
    } catch (_) {
      if (mounted) setState(() => _err = 'Email və ya şifrə yanlışdır');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _register() async {
    if (_email.text.isEmpty || _pass.text.isEmpty || _user.text.isEmpty) { setState(() => _err = 'Bütün xanaları doldurun'); return; }
    if (_pass.text.length < 6) { setState(() => _err = 'Şifrə ən az 6 simvol olmalıdır'); return; }
    if (!widget.supabaseReady) { setState(() => _err = 'Serverə qoşulmaq alınmadı'); return; }
    setState(() { _busy = true; _err = null; });
    try {
      await Supabase.instance.client.auth.signUp(email: _email.text.trim(), password: _pass.text,
          data: {'full_name': _user.text.trim(), 'age': _age.text.isEmpty ? '18' : _age.text});
      if (mounted) setState(() { _ok = 'Hesab yaradıldı! Email-i yoxlayın.'; _mode = 'login'; });
    } catch (e) {
      if (mounted) setState(() => _err = e is AuthException ? e.message : 'Qeydiyyat alınmadı');
    }
    if (mounted) setState(() => _busy = false);
  }

  InputDecoration _dec(String h) => InputDecoration(
        hintText: h, hintStyle: TextStyle(color: Colors.white.withOpacity(.3)),
        filled: true, fillColor: Colors.white.withOpacity(.07),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: kPurple.withOpacity(.7))),
      );

  Widget _btn(String t, VoidCallback? onTap, {Gradient? g, Color? c, Color fg = Colors.white, IconData? icon}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: VPress(scale: .97, onTap: _busy ? null : onTap, child: Container(
          height: 52, alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: g, color: c,
              border: g == null && c == null ? Border.all(color: Colors.white.withOpacity(.12)) : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 19, color: fg), const SizedBox(width: 10)],
            Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
          ]),
        )),
      );

  Widget _divider(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(.1))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(t, style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white.withOpacity(.3), fontWeight: FontWeight.w600))),
          Expanded(child: Container(height: 1, color: Colors.white.withOpacity(.1))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final main = _mode == 'main';
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        const Positioned(top: -70, left: -70, child: VGlow(size: 300, color: Color(0x2E7B2FF7))),
        const Positioned(top: 50, right: -60, child: VGlow(size: 240, color: Color(0x1FC084FC))),
        SafeArea(child: LayoutBuilder(builder: (_, box) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Column(children: [
              AnimatedSize(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic,
                child: _VelvetMark(size: main ? math.min(255, box.maxHeight * .32) : 130)),
              const _VelvetWordmark(fontSize: 42),
              if (main) ...[
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (final f in const [(Icons.sports_esports_outlined, 'OYUNLAR'), (Icons.mic_none_rounded, 'SƏS'), (Icons.workspace_premium_outlined, 'VIP'), (Icons.chat_bubble_outline_rounded, 'SÖHBƏT')])
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Column(children: [
                      Container(width: 50, height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: kPurple.withOpacity(.2), border: Border.all(color: kPurple.withOpacity(.35))),
                          child: Icon(f.$1, color: kLilac, size: 22)),
                      const SizedBox(height: 7),
                      Text(f.$2, style: TextStyle(fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(.5))),
                    ])),
                ]),
              ],
              const SizedBox(height: 18),
              AnimatedSize(
                duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, 22, 24, math.max(28, MediaQuery.of(context).padding.bottom + 12)),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16003A), Color(0xFF2A0A55), Color(0xFF1A003A)]),
                  ),
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _form()),
                ),
              ),
            ]),
          ),
        ))),
      ]),
    );
  }

  Widget _form() {
    if (_mode == 'main') {
      return Column(key: const ValueKey('m'), children: [
        _btn('Qeydiyyatdan keç', () => setState(() { _mode = 'register'; _err = null; }), g: const LinearGradient(colors: [kPurple, kPink]), icon: Icons.person_add_alt_1_rounded),
        _btn('Daxil ol', () => setState(() { _mode = 'login'; _err = null; }), c: Colors.white.withOpacity(.07), fg: Colors.white70, icon: Icons.login_rounded),
        _divider('YA DA'),
        _btn('Google ilə daxil ol', _googleLogin, c: Colors.white, fg: Colors.black, icon: Icons.g_mobiledata_rounded),
        const SizedBox(height: 6),
        Text('Davam etməklə İstifadə Şərtlərini qəbul edirsiniz', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.3))),
      ]);
    }
    final reg = _mode == 'register';
    return Column(key: ValueKey(_mode), crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: () => setState(() { _mode = 'main'; _err = null; }), child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white.withOpacity(.45)),
        const SizedBox(width: 6),
        Text('Geri', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.45))),
      ])),
      _divider(reg ? 'QEYDİYYAT' : 'DAXİL OL'),
      if (reg) ...[TextField(controller: _user, decoration: _dec('İstifadəçi adı')), const SizedBox(height: 10)],
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _dec('Email ünvanı')),
      const SizedBox(height: 10),
      TextField(controller: _pass, obscureText: true, decoration: _dec(reg ? 'Şifrə (min. 6 simvol)' : 'Şifrə'), onSubmitted: (_) => reg ? _register() : _login()),
      if (reg) ...[const SizedBox(height: 10), TextField(controller: _age, keyboardType: TextInputType.number, decoration: _dec('Yaş'))],
      const SizedBox(height: 12),
      if (_err != null) Center(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_err!, style: const TextStyle(color: Color(0xFFFF6090), fontSize: 12)))),
      if (_ok != null && !reg) Center(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_ok!, style: const TextStyle(color: Color(0xFF50C050), fontSize: 12)))),
      _btn(_busy ? 'Yüklənir…' : (reg ? 'Hesab yarat' : 'Daxil ol'), reg ? _register : _login, g: const LinearGradient(colors: [kPurple, kPink])),
      _btn(reg ? 'Artıq hesabım var → Daxil ol' : 'Hesabım yoxdur → Qeydiyyat', () => setState(() { _mode = reg ? 'login' : 'register'; _err = null; }), c: Colors.white.withOpacity(.07), fg: Colors.white70),
    ]);
  }
}

/* ─────────── Əsas qabıq + alt menyu ─────────── */
class _Shell extends StatefulWidget {
  final String name;
  const _Shell({super.key, required this.name});
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _tab = 0;

  void _room() => Navigator.of(context).push(vRoute(RoomScreen(myName: widget.name.split(' ').first), from: const Offset(0, .06)));
  void _profile() => Navigator.of(context).push(vRoute(const ProfileScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      extendBody: true,
      body: IndexedStack(index: _tab == 3 ? 1 : 0, children: [
        HomeScreen(name: widget.name, jeton: 10000, onRoom: _room, onProfile: _profile),
        const _Messages(),
      ]),
      bottomNavigationBar: _BottomNav(index: _tab, onTap: (i) {
        if (i == 2) { _room(); return; }
        if (i == 4) { _profile(); return; }
        setState(() => _tab = i == 1 ? 0 : i);
      }),
    );
  }
}

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
            decoration: BoxDecoration(color: const Color(0xEB0D001E), border: Border(top: BorderSide(color: Colors.white.withOpacity(.1), width: .5))),
            padding: EdgeInsets.only(bottom: math.max(6, MediaQuery.of(context).padding.bottom)),
            child: SizedBox(height: 56, child: LayoutBuilder(builder: (_, box) {
              final w = box.maxWidth / _items.length;
              return Stack(children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420), curve: Curves.easeOutBack,
                  top: 0, left: w * index + w / 2 - 14,
                  child: Container(width: 28, height: 3, decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)), gradient: LinearGradient(colors: [kPurple, kPink]))),
                ),
                Row(children: [
                  for (final (i, it) in _items.indexed)
                    Expanded(child: VPress(
                      onTap: () => onTap(i),
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack,
                        offset: Offset(0, index == i ? -.04 : 0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Stack(clipBehavior: Clip.none, children: [
                            Icon(index == i ? it.$2 : it.$1, size: 24, color: index == i ? kPurple : const Color(0xFF8E8E93)),
                            if (it.$4 != null) Positioned(top: -4, right: -10, child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                              decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(9), border: Border.all(color: kBg, width: 2)),
                              alignment: Alignment.center,
                              child: Text(it.$4!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                            )),
                          ]),
                          const SizedBox(height: 3),
                          Text(it.$3, style: TextStyle(fontSize: 10, fontWeight: index == i ? FontWeight.w600 : FontWeight.w500, color: index == i ? kPurple : const Color(0xFF8E8E93))),
                        ]),
                      ),
                    )),
                ]),
              ]);
            })),
          ),
        ),
      );
}

/* ─────────── Mesajlar ─────────── */
class _Messages extends StatelessWidget {
  const _Messages();
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, top + 48, 24, 110),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.forum_outlined, size: 48, color: Colors.white.withOpacity(.35)),
        const SizedBox(height: 16),
        const Text('Mesaj yoxdur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Canlı otaqlarda göndərdiyiniz mesajlar həqiqi iştirakçılara dərhal çatır.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(.55), height: 1.45)),
      ])),
    );
  }
}
