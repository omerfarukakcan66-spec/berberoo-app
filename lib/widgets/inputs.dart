import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'press_scale.dart';

/// .field — Label über Inhalt
class AppField extends StatelessWidget {
  final String? label;
  final Widget child;
  const AppField({super.key, this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Text(label!,
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: context.c.text2)),
            ),
          child,
        ],
      ),
    );
  }
}

/// .input / .textarea
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.formatters,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final radius = BorderRadius.circular(13);
    OutlineInputBorder border(Color col) =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: col));
    return TextField(
      controller: controller,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: c.accent,
      style: TextStyle(fontSize: 16, color: c.text, height: 1.5),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: c.surface2,
        hintText: hint,
        hintStyle: TextStyle(color: c.text3, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: border(c.line),
        focusedBorder: border(c.accentLine),
        border: border(c.line),
      ),
    );
  }
}

/// .search
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Suchen …',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          AppIcon('search', size: 19, color: c.text3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: c.accent,
              style: TextStyle(fontSize: 16, color: c.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: c.text3, fontSize: 16),
              ),
            ),
          ),
          if (onClear != null && controller.text.isNotEmpty)
            PressScale(
              onTap: onClear,
              child: AppIcon('x', size: 18, color: c.text3),
            ),
        ],
      ),
    );
  }
}

/// .segmented — Auswahl-Schalter
class Segmented extends StatelessWidget {
  final List<MapEntry<String, String>> options; // key -> label
  final String value;
  final ValueChanged<String> onChanged;
  const Segmented({super.key, required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: PressScale(
                onTap: () => onChanged(o.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: value == o.key ? c.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    o.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: value == o.key ? Colors.white : c.text2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// .chip — Auswahl-Chip mit optionalem Untertext
class ChoiceChipX extends StatelessWidget {
  final String label;
  final String? sub;
  final bool active;
  final VoidCallback onTap;
  const ChoiceChipX({
    super.key,
    required this.label,
    this.sub,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? c.accentSoft : c.surface2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: active ? c.accentLine : c.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? c.accentBright : c.text2)),
            if (sub != null) ...[
              const SizedBox(width: 6),
              Text(sub!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: active ? c.accentBright.withOpacity(0.8) : c.text3)),
            ],
          ],
        ),
      ),
    );
  }
}
