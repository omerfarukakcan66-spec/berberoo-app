import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/store.dart';
import '../data/date_utils.dart';
import '../widgets/common.dart';
import '../widgets/rows.dart';
import '../widgets/app_icon.dart';
import '../forms/open_forms.dart';

class ServicesScreen extends StatelessWidget {
  final AppStore store;
  const ServicesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final list = store.services.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelText('${list.length} ${list.length == 1 ? 'Leistung' : 'Leistungen'}',
            margin: const EdgeInsets.fromLTRB(2, 2, 2, 12)),
        if (list.isEmpty)
          const EmptyState(icon: 'scissors', text: 'Noch keine Leistungen. Tippe auf + zum Anlegen.')
        else
          Column(
            children: [
              for (final s in list) ...[
                ListRow(
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AppIcon('scissors', size: 20, color: c.text2),
                  ),
                  title: s.name,
                  subtitle: '${s.duration} min',
                  trailing: Text('${D.euro(s.price)} €',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.text)),
                  onTap: () => openServiceForm(context, store, initial: s),
                ),
                if (s != list.last) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}
