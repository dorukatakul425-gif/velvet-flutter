// Velvet — ortaq rənglər, köməkçi vidcetlər və vəziyyət
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kImg = 'https://xx-jade.vercel.app/images/images';
const kBg = Color(0xFF07000F);
const kPurple = Color(0xFF7B2FF7);
const kPink = Color(0xFFFF3EA5);
const kLilac = Color(0xFFC084FC);
const kCyan = Color(0xFF00D4FF);
const kGold = Color(0xFFFFD700);

/// Çıxış — main.dart tərəfindən təyin olunur
VoidCallback? appLogout;

String fmtNum(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

Route<T> vRoute<T>(Widget page, {Offset from = const Offset(.08, 0)}) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: from, end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

void vToast(BuildContext context, String text, {Color color = const Color(0xFF241F2E)}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(36, 0, 36, 90),
      duration: const Duration(milliseconds: 1600),
    ));
}

/// Basanda sıxılıb yay kimi açılma
class VPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const VPress({super.key, required this.child, this.onTap, this.scale = .92});
  @override
  State<VPress> createState() => _VPressState();
}

class _VPressState extends State<VPress> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap == null ? null : () { HapticFeedback.selectionClick(); widget.onTap!(); },
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: Duration(milliseconds: _down ? 90 : 380),
          curve: _down ? Curves.easeOut : Curves.elasticOut,
          child: widget.child,
        ),
      );
}

/// Açılışda aşağıdan süzülərək gəlmə
class VEntrance extends StatelessWidget {
  final Widget child;
  final int delay;
  const VEntrance({super.key, required this.child, this.delay = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + delay),
        curve: Interval(delay / (520 + delay), 1, curve: Curves.easeOutCubic),
        builder: (_, t, c) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: c)),
        child: child,
      );
}

class VGlow extends StatelessWidget {
  final double size;
  final Color color;
  const VGlow({super.key, required this.size, required this.color});
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(width: size, height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)]))),
      );
}

Widget netImg(String file, {double? w, double? h, BoxFit fit = BoxFit.cover, Alignment align = Alignment.center, Widget? fallback}) =>
    Image.network('$kImg/$file', width: w, height: h, fit: fit, alignment: align, gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback ?? SizedBox(width: w, height: h));
