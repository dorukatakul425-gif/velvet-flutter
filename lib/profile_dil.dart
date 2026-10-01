// Velvet — Çoxdilli dəstək ekranı (Flutter)
//
// QURAŞDIRMA
//  1) Bu faylı profile_screen.dart və profile_parametrler.dart ilə eyni qovluqda saxla.
//  2) Parametrlər ekranında "Çoxdilli dəstək" sətrinə toxunanda açılır.
//  3) Seçilmiş dil `appLang`-da saxlanılır; Parametrlər ekranındakı sətir bunu avtomatik göstərir.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';
import 'profile_parametrler.dart' show VelvetCard, VelvetTopGlow;

/// Hazırda seçilmiş dil (tətbiq üzrə)
final ValueNotifier<String> appLang = ValueNotifier<String>('Azərbaycanca');

class DilScreen extends StatefulWidget {
  const DilScreen({super.key});
  @override
  State<DilScreen> createState() => _DilScreenState();
}

class _DilScreenState extends State<DilScreen> {
  // Türkiyə · Azərbaycan · İngilis · Rusiya (hər dil öz adı ilə)
  static const _langs = ['Türkçe', 'Azərbaycanca', 'English', 'Русский'];
  late String _sel = appLang.value;
  bool get _changed => _sel != appLang.value;

  void _save() {
    if (!_changed) return;
    HapticFeedback.lightImpact();
    appLang.value = _sel;
    velvetToast(context, 'Dil yadda saxlanıldı');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        const VelvetTopGlow(),
        Column(children: [
          // Başlıq
          Padding(
            padding: EdgeInsets.fromLTRB(6, mq.padding.top + 6, 14, 0),
            child: SizedBox(height: 52, child: Stack(alignment: Alignment.center, children: [
              Align(alignment: Alignment.centerLeft, child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: const Padding(padding: EdgeInsets.all(12), child: Ico('back', size: 26)),
              )),
              const Text('Çoxdilli dəstək', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kInk)),
              Align(alignment: Alignment.centerRight, child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _save,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _changed ? const LinearGradient(colors: [kPurple, kPink]) : null,
                    color: _changed ? null : const Color(0x14FFFFFF),
                    boxShadow: _changed ? const [BoxShadow(color: Color(0x667B2FF7), blurRadius: 14)] : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _changed ? Colors.white : kMut),
                    child: const Text('Saxla'),
                  ),
                ),
              )),
            ])),
          ),
          Container(height: 1, color: const Color(0x14FFFFFF)),
          Expanded(child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(14, 14, 14, mq.padding.bottom + 28),
            children: [
              VelvetCard(child: Column(children: [for (final l in _langs) _langRow(l)])),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Text('Dili dəyişdirdikdə bütün tətbiqdə qüvvəyə minəcək.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: kMut)),
              ),
            ],
          )),
        ]),
      ]),
    );
  }

  Widget _langRow(String l) {
    final on = l == _sel;
    return InkWell(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _sel = l); },
      splashColor: const Color(0x2E7B2FF7),
      highlightColor: const Color(0x147B2FF7),
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: [
            Expanded(child: Text(l, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: kInk))),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: on ? const Ico('check', key: ValueKey('on'), size: 22) : const SizedBox(key: ValueKey('off'), width: 22, height: 22),
            ),
          ]),
        ),
      ),
    );
  }
}
