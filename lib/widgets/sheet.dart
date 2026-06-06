import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'common.dart';
import 'press_scale.dart';

/// Öffnet ein Bottom-Sheet im Barberoo-Stil (.scrim + .sheet).
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  Widget? headRight,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000), // rgba(0,0,0,.55)
    builder: (ctx) => _SheetShell(title: title, headRight: headRight, child: builder(ctx)),
  );
}

class _SheetShell extends StatelessWidget {
  final String title;
  final Widget? headRight;
  final Widget child;
  const _SheetShell({required this.title, required this.child, this.headRight});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.92;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Dim.appMax),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(R.xl)),
            border: Border(top: BorderSide(color: c.line2)),
          ),
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 8,
            bottom: 24 + media.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Griff
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.fromLTRB(0, 6, 0, 14),
                decoration:
                    BoxDecoration(color: c.line2, borderRadius: BorderRadius.circular(3)),
              ),
              // Kopf
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.01 * 21,
                              color: c.text)),
                    ),
                    if (headRight != null) ...[headRight!, const SizedBox(width: 8)],
                    PressScale(
                      onTap: () => Navigator.of(context).pop(),
                      scale: 0.92,
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: c.surface2, shape: BoxShape.circle),
                        child: AppIcon('x', size: 19, color: c.text2),
                      ),
                    ),
                  ],
                ),
              ),
              // Inhalt
              Flexible(
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bestätigungs-Sheet (Confirm)
Future<void> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Löschen',
  bool danger = true,
  required VoidCallback onConfirm,
}) {
  return showAppSheet(
    context: context,
    title: title,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(message,
              style: TextStyle(fontSize: 15, color: ctx.c.text2, height: 1.45)),
        ),
        AppButton(
          confirmLabel,
          variant: danger ? BtnVariant.danger : BtnVariant.primary,
          onTap: () {
            onConfirm();
            Navigator.of(ctx).pop();
          },
        ),
        const SizedBox(height: 10),
        AppButton('Abbrechen', variant: BtnVariant.ghost, onTap: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}
