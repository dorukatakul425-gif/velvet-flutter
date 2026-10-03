import 'package:flutter/material.dart';

void main() => runApp(const VelvetApp());

class VelvetApp extends StatelessWidget {
  const VelvetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velvet',
      theme: ThemeData(fontFamily: 'Arial', useMaterial3: true),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const night = Color(0xFF0A0314);
  static const text = Color(0xFFF4EDFF);
  static const muted = Color(0xFF9F94B3);

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.account_balance_wallet_outlined, 'Pulqabı', '40 jeton'),
      (Icons.groups_outlined, 'Ailə', '30 jeton qazan'),
      (Icons.favorite_border, 'Yaxın dost', 'İlk dostunu əlavə et'),
      (Icons.workspace_premium_outlined, 'SVIP', 'Get və aç'),
      (Icons.diamond_outlined, 'VIP', 'VIP 0'),
      (Icons.storefront_outlined, 'Mağaza', ''),
    ];
    return Scaffold(
      backgroundColor: night,
      appBar: AppBar(
        backgroundColor: night,
        foregroundColor: text,
        centerTitle: true,
        title: const Text('Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
        children: [
          const Row(children: [
            CircleAvatar(radius: 39, backgroundColor: Color(0xFFB35CFF), child: Text('V', style: TextStyle(fontSize: 30, color: text, fontWeight: FontWeight.w900))),
            SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Velvet istifadəçisi', style: TextStyle(color: text, fontSize: 19, fontWeight: FontWeight.w800)),
              SizedBox(height: 7), Text('Zənginlik: Sv.1  ·  Aktiv deyil', style: TextStyle(color: Color(0xFF4DE0BF), fontSize: 11)),
              SizedBox(height: 5), Text('ID: 48219037 · Azərbaycan · 22 yaş', style: TextStyle(color: muted, fontSize: 10)),
            ])),
            Icon(Icons.chevron_right, color: muted),
          ]),
          const SizedBox(height: 20),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat(Icons.home_outlined, '2', 'Otaq'), _Stat(Icons.auto_awesome_outlined, '2', 'Ziyarətçi'),
            _Stat(Icons.favorite_border, '1', 'İzlənilən'), _Stat(Icons.people_outline, '0', 'İzləyici'),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0x443DDBBA), Color(0x445F2AAE)]), border: Border.all(color: const Color(0x664DE0BF))),
            child: const Row(children: [Icon(Icons.card_giftcard, color: Color(0xFFFFD05A), size: 38), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Yeni istifadəçiyə özəl mükafat', style: TextStyle(color: text, fontWeight: FontWeight.w800)), Text('1 652 jetona qədər qazan!', style: TextStyle(color: Color(0xFFFF7D74), fontSize: 12))])), Icon(Icons.chevron_right, color: muted)]),
          ),
          const SizedBox(height: 14),
          ...rows.map((row) => _MenuRow(icon: row.$1, label: row.$2, note: row.$3)),
          const SizedBox(height: 14),
          _MenuRow(icon: Icons.forward_to_inbox_outlined, label: 'Dost dəvət et', note: 'Jeton qazan', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvitePage()))),
          const _MenuRow(icon: Icons.support_agent, label: 'Onlayn müştəri xidməti', note: ''),
          const _MenuRow(icon: Icons.settings_outlined, label: 'Parametrlər', note: 'Hesabınızı qoruyun'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label);
  final IconData icon; final String value; final String label;
  @override Widget build(BuildContext context) => Column(children: [Icon(icon, color: ProfilePage.muted), const SizedBox(height: 4), Text(value, style: const TextStyle(color: ProfilePage.text, fontSize: 18, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: ProfilePage.muted, fontSize: 10))]);
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.note, this.onTap});
  final IconData icon; final String label; final String note; final VoidCallback? onTap;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 1),
    decoration: const BoxDecoration(color: Color(0x0DFFFFFF)),
    child: ListTile(onTap: onTap, leading: Icon(icon, color: ProfilePage.muted), title: Text(label, style: const TextStyle(color: ProfilePage.text, fontSize: 15, fontWeight: FontWeight.w600)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (note.isNotEmpty) SizedBox(width: 105, child: Text(note, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFFFBD3F), fontSize: 11))), const Icon(Icons.chevron_right, color: ProfilePage.muted)])),
  );
}

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});
  static const ink = Color(0xFF462233);
  static const pink = Color(0xFFF23882);
  static const coral = Color(0xFFFF7758);
  static const gold = Color(0xFFFFC928);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEB70),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEF75), foregroundColor: ink, centerTitle: true,
        title: const Text('Dostlarını dəvət et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Necə işləyir?'), content: Text('Dəvət linkini paylaş. Dostun qeydiyyatdan keçib mərhələləri tamamladıqca mükafat qazanırsan.'))), icon: const Icon(Icons.help_outline))],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFF28A), Color(0xFFFFE267), Color(0xFFC9F99B)])),
        child: ListView(padding: const EdgeInsets.fromLTRB(14, 10, 14, 30), children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: ink.withValues(alpha: .65), borderRadius: BorderRadius.circular(30)), child: const Text('●  Aysel yeni dost dəvət etdi     +500 ✦', style: TextStyle(color: Colors.white, fontSize: 11))),
          const SizedBox(height: 24),
          const Text('Dəvət et,\nmükafat qazan!', textAlign: TextAlign.center, style: TextStyle(color: pink, fontSize: 39, height: .95, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          const _GiftArt(),
          Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .62), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white)), child: const Text('Hər yeni dostun tapşırıqları tamamladıqca sən xüsusi Velvet mükafatları qazanırsan.', textAlign: TextAlign.center, style: TextStyle(color: ink, fontSize: 13))),
          const SizedBox(height: 22),
          const _RewardsCard(),
          const SizedBox(height: 20),
          const _StrategyCard(),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .6), borderRadius: BorderRadius.circular(12), border: Border.all(color: pink.withValues(alpha: .5))), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('V48219037', style: TextStyle(color: ink, fontWeight: FontWeight.w800)), Icon(Icons.copy, color: pink, size: 19)])),
          const SizedBox(height: 13),
          FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dəvət linki kopyalandı'))), icon: const Icon(Icons.send), label: const Text('Dostlarını dəvət et'), style: FilledButton.styleFrom(backgroundColor: pink, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(55), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        ]),
      ),
    );
  }
}

class _GiftArt extends StatelessWidget {
  const _GiftArt();
  @override Widget build(BuildContext context) => SizedBox(height: 190, child: Stack(alignment: Alignment.center, children: [
    Positioned(left: 35, bottom: 18, child: Transform.rotate(angle: -.18, child: const Icon(Icons.campaign_rounded, size: 82, color: Color(0xFFAE56EC)))),
    Container(width: 170, height: 145, decoration: BoxDecoration(color: InvitePage.pink, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x66F23882), blurRadius: 24, offset: Offset(0, 12))])),
    Container(width: 28, height: 145, color: InvitePage.coral), Container(width: 170, height: 26, color: InvitePage.coral),
    const Positioned(top: 0, child: Icon(Icons.card_giftcard_rounded, size: 92, color: Color(0xFFFF7758))),
    const Positioned(right: 35, top: 12, child: Icon(Icons.star_rounded, size: 42, color: InvitePage.gold)),
    const Positioned(right: 42, bottom: 12, child: Icon(Icons.diamond_rounded, size: 39, color: Color(0xFF62DEC8))),
  ]));
}

class _RewardsCard extends StatelessWidget {
  const _RewardsCard();
  @override Widget build(BuildContext context) {
    final steps = <(String, IconData, String)>[
      ('Qeydiyyatdan keçsin', Icons.workspace_premium, '6 000 + 10 500'),
      ('İlk yükləməni etsin', Icons.auto_awesome, '24 500 + 14 000'),
      ('Ümumi 100 000 jeton yükləsin', Icons.monetization_on, '5 000'),
      ('Ümumi 500 000 jeton yükləsin', Icons.monetization_on, '50 000'),
      ('Ümumi 2 000 000 jeton yükləsin', Icons.monetization_on, '200 000'),
    ];
    return Container(padding: const EdgeInsets.fromLTRB(16, 20, 16, 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white, width: 2)), child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [InvitePage.pink, InvitePage.coral]), borderRadius: BorderRadius.circular(30)), child: const Text('Ümumi dəyər 310 000 jeton', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
      const SizedBox(height: 14),
      ...steps.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [InvitePage.gold.withValues(alpha: .8), Colors.transparent]), borderRadius: BorderRadius.circular(9)), child: Text(s.$1, style: const TextStyle(color: InvitePage.ink, fontWeight: FontWeight.w700))), Container(margin: const EdgeInsets.only(top: 7), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), border: Border.all(color: InvitePage.coral.withValues(alpha: .3)), borderRadius: BorderRadius.circular(13)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(s.$2, color: InvitePage.pink, size: 36), const SizedBox(width: 14), Text('Dəyər ${s.$3} ✦', style: const TextStyle(color: InvitePage.coral, fontWeight: FontWeight.w800))]))]))),
    ]));
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard();
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 2)), child: const Column(children: [Text('✦✦  Dəvət qaydası  ✦✦', style: TextStyle(color: InvitePage.ink, fontSize: 19, fontWeight: FontWeight.w800)), SizedBox(height: 18), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _How(Icons.share, 'Dəvəti paylaş')), Icon(Icons.chevron_right, color: InvitePage.pink), Expanded(child: _How(Icons.download_done, 'Dostun qeydiyyatdan keçsin')), Icon(Icons.chevron_right, color: InvitePage.pink), Expanded(child: _How(Icons.redeem, 'Mükafatı qazan'))]) ]));
}

class _How extends StatelessWidget {
  const _How(this.icon, this.text); final IconData icon; final String text;
  @override Widget build(BuildContext context) => Column(children: [Container(width: 55, height: 55, decoration: BoxDecoration(color: const Color(0xFFFFE5EF), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: InvitePage.pink)), const SizedBox(height: 8), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: InvitePage.ink, fontSize: 10))]);
}