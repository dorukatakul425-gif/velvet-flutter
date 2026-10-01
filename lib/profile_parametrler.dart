// Velvet — Parametrlər ekranı (Flutter)
//
// QURAŞDIRMA
//  1) Bu faylı profile_screen.dart ilə eyni qovluqda saxla (lib/profile_parametrler.dart).
//  2) Profil ekranındakı "Parametrlər" sətrinə toxunanda bu səhifə açılır
//     (profile_screen.dart içində artıq bağlanıb).
//  3) İkonlar, rənglər və toast profile_screen.dart-dan götürülür (Ico, kBg, kInk, kMut, velvetToast).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';
import 'profile_dil.dart';
import 'profile_bildiris.dart';

class _SettingsItem {
  final String label;
  final String? right;
  final Color rightColor;
  final bool isLang;
  final Widget? page; // toxunanda açılacaq səhifə (null olsa toast göstərilir)
  const _SettingsItem(this.label, {this.right, this.rightColor = kMut, this.isLang = false, this.page});
}

class ParametrlerScreen extends StatelessWidget {
  const ParametrlerScreen({super.key});

  static const _pink = Color(0xFFFF6B8A);

  static const _items = <_SettingsItem>[
    _SettingsItem('Hesab və təhlükəsizlik', right: 'Bağla', rightColor: _pink),
    _SettingsItem('Şəxsiyyət təsdiqi'),
    _SettingsItem('Bildiriş parametrləri', page: BildirisScreen()),
    _SettingsItem('Çoxdilli dəstək', isLang: true, page: DilScreen()),
    _SettingsItem('Məxfilik parametrləri'),
    _SettingsItem('Rəy bildir'),
    _SettingsItem('İstifadə şərtləri'),
    _SettingsItem('Məxfilik siyasəti'),
    _SettingsItem('Açıq mənbə razılaşması'),
    _SettingsItem('İcma razılaşması'),
    _SettingsItem('Uşaq istismarına qarşı siyasət'),
    _SettingsItem('Keşi təmizlə'),
    _SettingsItem('Haqqında'),
  ];

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
            padding: EdgeInsets.fromLTRB(6, mq.padding.top + 6, 6, 0),
            child: SizedBox(height: 52, child: Stack(alignment: Alignment.center, children: [
              Align(alignment: Alignment.centerLeft, child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: const Padding(padding: EdgeInsets.all(12), child: Ico('back', size: 26)),
              )),
              const Text('Parametrlər', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kInk)),
            ])),
          ),
          Container(height: 1, color: const Color(0x14FFFFFF)),
          Expanded(child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(14, 14, 14, mq.padding.bottom + 28),
            children: [
              VelvetCard(child: Column(children: [
                for (final it in _items)
                  _SettingsRow(item: it, onTap: () => it.page != null ? Navigator.of(context).push(velvetSlide(it.page!)) : velvetToast(context, it.label)),
              ])),
              const SizedBox(height: 14),
              VelvetCard(child: InkWell(
                onTap: () { HapticFeedback.selectionClick(); velvetToast(context, 'Hesabdan çıx'); },
                splashColor: const Color(0x2E7B2FF7),
                highlightColor: const Color(0x147B2FF7),
                child: const SizedBox(height: 66, child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Ico('logout', size: 38),
                  SizedBox(width: 12),
                  Text('Hesabdan çıx', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kInk)),
                ]))),
              )),
            ],
          )),
        ]),
      ]),
    );
  }
}

/// Profil ekranındakı menyu kartı ilə eyni görünüş
class VelvetCard extends StatelessWidget {
  final Widget child;
  const VelvetCard({required this.child});
  @override
  Widget build(BuildContext context) => RepaintBoundary(
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
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      );
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItem item;
  final VoidCallback onTap;
  const _SettingsRow({required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        splashColor: const Color(0x2E7B2FF7),
        highlightColor: const Color(0x147B2FF7),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(children: [
              Flexible(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: kInk))),
              Expanded(child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: item.isLang
                      ? ValueListenableBuilder<String>(
                          valueListenable: appLang,
                          builder: (_, v, __) => Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: item.rightColor)),
                        )
                      : item.right == null
                          ? const SizedBox()
                          : Text(item.right!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: item.rightColor)),
                ),
              )),
              const Ico('chev', size: 16, opacity: .4),
            ]),
          ),
        ),
      );
}

/// Yumşaq üst işıqlanma (profil ekranındakı aurora ilə eyni rənglər). Stack-in uşağı olmalıdır.
class VelvetTopGlow extends StatelessWidget {
  const VelvetTopGlow({super.key});
  @override
  Widget build(BuildContext context) => const Positioned(top: 0, left: 0, right: 0, height: 300, child: IgnorePointer(child: Stack(children: [
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: RadialGradient(center: Alignment(-.8, -1.1), radius: 1.0, colors: [Color(0x667B2FF7), Color(0x007B2FF7)]),
        ))),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: RadialGradient(center: Alignment(.9, -1.2), radius: .9, colors: [Color(0x44FF3EA5), Color(0x00FF3EA5)]),
        ))),
      ])));
}

/// Alt səhifələr üçün ortaq başlıq: geri oxu + ortada başlıq (+ istəyə görə sağda düymə) + ayırıcı xətt
class VelvetPageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const VelvetPageHeader(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(6, MediaQuery.of(context).padding.top + 6, 14, 0),
          child: SizedBox(height: 52, child: Stack(alignment: Alignment.center, children: [
            Align(alignment: Alignment.centerLeft, child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(padding: EdgeInsets.all(12), child: Ico('back', size: 26)),
            )),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kInk)),
            if (trailing != null) Align(alignment: Alignment.centerRight, child: trailing!),
          ])),
        ),
        Container(height: 1, color: const Color(0x14FFFFFF)),
      ]);
}
