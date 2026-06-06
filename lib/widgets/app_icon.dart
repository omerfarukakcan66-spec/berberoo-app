import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Barberoo — Icons. Die Pfaddaten sind 1:1 aus components/icons.jsx übernommen,
/// damit jedes Icon exakt gleich aussieht. Recoloring über colorFilter.
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final double strokeWidth;
  final Color color;

  const AppIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.strokeWidth = 1.8,
    required this.color,
  });

  static const Map<String, String> _paths = {
    'home':
        '<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V20a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V9.5"/>',
    'calendar':
        '<rect x="3" y="4.5" width="18" height="16" rx="3"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="8" y1="2.5" x2="8" y2="6"/><line x1="16" y1="2.5" x2="16" y2="6"/>',
    'users':
        '<circle cx="9" cy="8" r="3.2"/><path d="M3.5 20c0-3 2.5-5 5.5-5s5.5 2 5.5 5"/><path d="M16 5.2A3 3 0 0 1 16 11"/><path d="M16.5 15.2c2.3.4 4 2.3 4 4.8"/>',
    'scissors':
        '<circle cx="6" cy="7" r="2.6"/><circle cx="6" cy="17" r="2.6"/><line x1="8.3" y1="8.4" x2="20" y2="17"/><line x1="8.3" y1="15.6" x2="20" y2="7"/>',
    'check':
        '<path d="M4 7h11"/><path d="M4 12h8"/><path d="M4 17h6"/><path d="M15.5 16.5 18 19l4-4.5"/>',
    'plus': '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>',
    'search': '<circle cx="11" cy="11" r="7"/><line x1="20" y1="20" x2="16" y2="16"/>',
    'chevron': '<path d="m9 6 6 6-6 6"/>',
    'x': '<line x1="6" y1="6" x2="18" y2="18"/><line x1="18" y1="6" x2="6" y2="18"/>',
    'phone':
        '<path d="M5 4h3l1.5 5-2 1.5a12 12 0 0 0 6 6l1.5-2 5 1.5v3a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2Z"/>',
    'mail':
        '<rect x="3" y="5" width="18" height="14" rx="2.5"/><path d="m3.5 7 8.5 6 8.5-6"/>',
    'trash':
        '<path d="M4 7h16"/><path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/><path d="M6 7l1 13a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-13"/>',
    'edit': '<path d="M4 20h4L19 9l-4-4L4 16v4Z"/><line x1="14" y1="6" x2="18" y2="10"/>',
    'clock': '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
    'gear':
        '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v2.5M12 19v2.5M21.5 12H19M5 12H2.5M18.4 5.6l-1.8 1.8M7.4 16.6l-1.8 1.8M18.4 18.4l-1.8-1.8M7.4 7.4 5.6 5.6"/>',
    'euro':
        '<path d="M16 6.5A6 6 0 1 0 16 17.5"/><line x1="4" y1="10" x2="12" y2="10"/><line x1="4" y1="14" x2="11" y2="14"/>',
    'user': '<circle cx="12" cy="8" r="4"/><path d="M5 20c0-3.5 3-6 7-6s7 2.5 7 6"/>',
    'note':
        '<rect x="4" y="3" width="16" height="18" rx="2.5"/><line x1="8" y1="8" x2="16" y2="8"/><line x1="8" y1="12" x2="16" y2="12"/><line x1="8" y1="16" x2="13" y2="16"/>',
    'arrowL': '<path d="m14 6-6 6 6 6"/>',
    'arrowR': '<path d="m10 6 6 6-6 6"/>',
    'sparkle': '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3Z"/>',
    'sun':
        '<circle cx="12" cy="12" r="4.2"/><path d="M12 2.5v2.6M12 18.9v2.6M21.5 12h-2.6M5.1 12H2.5M18.4 5.6l-1.8 1.8M7.4 16.6l-1.8 1.8M18.4 18.4l-1.8-1.8M7.4 7.4 5.6 5.6"/>',
    'moon': '<path d="M20 13.5A8 8 0 1 1 10.5 4a6.2 6.2 0 0 0 9.5 9.5Z"/>',
    'phone_device':
        '<rect x="6" y="2.5" width="12" height="19" rx="3"/><line x1="10.5" y1="18.5" x2="13.5" y2="18.5"/>',
    'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><path d="M12 7.6v.1"/>',
  };

  @override
  Widget build(BuildContext context) {
    final inner = _paths[name] ?? '';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="$size" height="$size" '
        'fill="none" stroke="#000000" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
