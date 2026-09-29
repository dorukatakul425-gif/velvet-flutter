// Velvet — Flutter tətbiqi (index.tsx-in tam köçürməsi)
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'common.dart';
import 'home_screen.dart';
import 'room_screen.dart' show RoomScreen;
import 'profile_screen.dart' show ProfileScreen, jetonBalance;

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
    Timer(const Duration(milliseconds: 1800), () { if (mounted) setState(() => _splash = false); });
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
    return AnimatedSwitcher(duration: const Duration(milliseconds: 500), switchInCurve: Curves.easeOut, child: child);
  }
}

/* ─────────── Splash ─────────── */
class _Splash extends StatefulWidget {
  const _Splash({super.key});
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with TickerProviderStateMixin {
  late final _p = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
  late final _f = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  @override
  void dispose() { _p.dispose(); _f.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: Stack(alignment: Alignment.center, children: [
          const Positioned(top: 80, left: -60, child: VGlow(size: 320, color: Color(0x407B2FF7))),
          const Positioned(bottom: 60, right: -60, child: VGlow(size: 280, color: Color(0x33FF3EA5))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(animation: _f, builder: (_, c) => Transform.translate(offset: Offset(0, -8 * Curves.easeInOut.transform(_f.value)), child: c),
                child: const _Logo(size: 120)),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(colors: [Colors.white, kLilac, kPink]).createShader(r),
              child: const Text('VELVET', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8, color: Colors.white)),
            ),
            const SizedBox(height: 44),
            SizedBox(width: 200, height: 4, child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AnimatedBuilder(animation: _p, builder: (_, __) => Stack(children: [
                Container(color: Colors.white.withOpacity(.08)),
                FractionallySizedBox(widthFactor: Curves.easeOut.transform(_p.value), child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPurple, kLilac, kPink])))),
              ])),
            )),
            const SizedBox(height: 16),
            Text('YÜKLƏNİR', style: TextStyle(fontSize: 11, letterSpacing: 3, color: Colors.white.withOpacity(.35))),
          ]),
        ]),
      );
}

class _Logo extends StatelessWidget {
  final double size;
  const _Logo({required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .27),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D0060), Color(0xFF1A0035)]),
          border: Border.all(color: kPurple.withOpacity(.7), width: 2),
          boxShadow: [BoxShadow(color: kPurple.withOpacity(.45), blurRadius: 40)],
        ),
        alignment: Alignment.center,
        child: ShaderMask(
          shaderCallback: (r) => const LinearGradient(colors: [Colors.white, kLilac, kPink]).createShader(r),
          child: Text('V', style: TextStyle(fontSize: size * .55, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
        ),
      );
}

/* ─────────── Giriş / Qeydiyyat ─────────── */
class _Login extends StatefulWidget {
  final bool supabaseReady;
  const _Login({super.key, required this.supabaseReady});
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  late final VideoPlayerController _video;
  bool _videoReady = false;
  String _mode = 'main';
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _user = TextEditingController();
  final _age = TextEditingController();
  bool _busy = false;
  String? _err, _ok;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset('lib/giris.mp4')
      ..initialize().then((_) async {
        await _video.setLooping(true);
        await _video.setVolume(0);
        await _video.play();
        if (mounted) setState(() => _videoReady = true);
      }).catchError((_) {});
  }

  @override
  void dispose() { _video.dispose(); _email.dispose(); _pass.dispose(); _user.dispose(); _age.dispose(); super.dispose(); }

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
        if (_videoReady) Positioned.fill(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: _video.value.size.width, height: _video.value.size.height, child: VideoPlayer(_video)))),
        Positioned.fill(child: Container(color: kBg.withOpacity(_videoReady ? .70 : .96))),
        const Positioned(top: -70, left: -70, child: VGlow(size: 300, color: Color(0x2E7B2FF7))),
        const Positioned(top: 50, right: -60, child: VGlow(size: 240, color: Color(0x1FC084FC))),
        SafeArea(child: LayoutBuilder(builder: (_, box) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Column(children: [
              const SizedBox(height: 24),
              AnimatedScale(scale: main ? 1 : .7, duration: const Duration(milliseconds: 300), child: const _Logo(size: 120)),
              const SizedBox(height: 14),
              const Text('VELVET', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 6)),
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
              const SizedBox(height: 24),
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
  void _profile() => Navigator.of(context).push(vRoute(ProfileScreen(name: widget.name)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      extendBody: true,
      body: IndexedStack(index: _tab == 3 ? 1 : 0, children: [
        ValueListenableBuilder<int>(valueListenable: jetonBalance, builder: (_, j, __) =>
            HomeScreen(name: widget.name, jeton: j, onRoom: _room, onProfile: _profile)),
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
