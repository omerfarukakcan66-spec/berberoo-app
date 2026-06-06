import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Toast wie im Original: helle Pille, mittig über der Bottom-Nav, 2,2 s sichtbar.
class Toast {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry?.remove();
    final c = context.c;

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: 0,
        right: 0,
        bottom: Dim.navH + 24 + MediaQuery.of(ctx).padding.bottom,
        child: IgnorePointer(
          child: Center(
            child: _ToastBubble(message: message, bg: c.toastBg, fg: c.toastText),
          ),
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }
}

class _ToastBubble extends StatefulWidget {
  final String message;
  final Color bg;
  final Color fg;
  const _ToastBubble({required this.message, required this.bg, required this.fg});

  @override
  State<_ToastBubble> createState() => _ToastBubbleState();
}

class _ToastBubbleState extends State<_ToastBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(fade),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: widget.bg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: Shadows.lg(),
            ),
            child: Text(widget.message,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: widget.fg)),
          ),
        ),
      ),
    );
  }
}
