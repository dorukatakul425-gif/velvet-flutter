// Velvet — Bildiriş parametrləri ekranı (Flutter)
//
// QURAŞDIRMA
//  1) Bu faylı profile_screen.dart və profile_parametrler.dart ilə eyni qovluqda saxla.
//  2) Parametrlər ekranında "Bildiriş parametrləri" sətrinə toxunanda açılır.
//  3) Açar vəziyyətləri tətbiq işləyənə qədər yadda qalır (_vals).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';
import 'profile_parametrler.dart' show VelvetCard, VelvetTopGlow, VelvetPageHeader;

class _Opt {
  final String title;
  final String? sub;
  const _Opt(this.title, [this.sub]);
}

class BildirisScreen extends StatefulWidget {
  const BildirisScreen({super.key});
  @override
  State<BildirisScreen> createState() => _BildirisScreenState();
}

class _BildirisScreenState extends State<BildirisScreen> {
  static const _groups = <List<_Opt>>[
    [
      _Opt('Mesaj xatırlatma parametrləri', 'Velvet-i açmadığınız və ya bağlı olduqda dostlarınızdan söhbət bildirişləri ala bilməzsiniz. Zəhmət olmasa açmağa keçin.'),
      _Opt('Narahat etməyin rejimi', 'Aktiv etdikdən sonra 00:00-08:00 saatları arasında mesaj bildirişləri alınmayacaq.'),
      _Opt('Qarşılıqlı əlaqə bildirişi', 'Dinamik bəyənmələr və şərhlər, izləyicilər və ziyarətçi mesajları daxil olmaqla.'),
      _Opt('Tövsiyə olunan mesaj bildirişi', 'İzləyici yenilikləri, ziyarətçi mesajları və s. daxil.'),
      _Opt('Dost mesajı bildirişi'),
    ],
    [
      _Opt('Tətbiqdaxili afişa xatırladıcısı', 'Bu tətbiqdən istifadə edərkən mesajlar afişa şəklində açılacaq.'),
    ],
    [
      _Opt('Xüsusi söhbət qoruması', 'Bu funksiyanı aktiv etdikdə, yad şəxslər (qarşılıqlı izləşmədiyiniz, heç söhbət etmədiyiniz və ya hədiyyə göndərmədiyiniz şəxslər) sizə birbaşa şəxsi mesaj göndərə bilməz.'),
    ],
  ];

  // Hər açarın vəziyyəti (sessiya boyunca saxlanılır)
  static final List<List<bool>> _vals = [
    [true, false, true, true, true],
    [true],
    [false],
  ];

  void _toggle(int g, int i) {
    HapticFeedback.selectionClick();
    setState(() => _vals[g][i] = !_vals[g][i]);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        const VelvetTopGlow(),
        Column(children: [
          const VelvetPageHeader('Bildiriş parametrləri'),
          Expanded(child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(14, 14, 14, mq.padding.bottom + 28),
            children: [
              for (var g = 0; g < _groups.length; g++) ...[
                if (g > 0) const SizedBox(height: 14),
                VelvetCard(child: Column(children: [
                  for (var i = 0; i < _groups[g].length; i++) ...[
                    if (i > 0) const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(height: 1, width: double.infinity, child: ColoredBox(color: Color(0x0FFFFFFF))),
                    ),
                    _row(g, i),
                  ],
                ])),
              ],
            ],
          )),
        ]),
      ]),
    );
  }

  Widget _row(int g, int i) {
    final o = _groups[g][i];
    return InkWell(
      onTap: () => _toggle(g, i),
      splashColor: const Color(0x2E7B2FF7),
      highlightColor: const Color(0x147B2FF7),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 66),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 15, 16, 15),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: kInk)),
              if (o.sub != null) ...[
                const SizedBox(height: 5),
                Text(o.sub!, style: const TextStyle(fontSize: 13.5, height: 1.35, color: kMut)),
              ],
            ])),
            const SizedBox(width: 16),
            _VelvetSwitch(on: _vals[g][i]),
          ]),
        ),
      ),
    );
  }
}

/// Firuzəyi açar (tətbiqin vurğu rəngi ilə)
class _VelvetSwitch extends StatelessWidget {
  final bool on;
  const _VelvetSwitch({required this.on});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 52, height: 30,
        padding: const EdgeInsets.all(3),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: on ? const LinearGradient(colors: [kTeal, Color(0xFF3FE6C8)]) : null,
          color: on ? null : const Color(0x2EFFFFFF),
          boxShadow: on ? const [BoxShadow(color: Color(0x5519D4B4), blurRadius: 12)] : null,
        ),
        child: Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
        ),
      );
}
