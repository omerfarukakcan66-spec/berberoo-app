import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/store.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';
import '../widgets/inputs.dart';
import '../widgets/press_scale.dart';

class TodosScreen extends StatefulWidget {
  final AppStore store;
  const TodosScreen({super.key, required this.store});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _text = TextEditingController();

  AppStore get store => widget.store;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add() {
    if (_text.text.trim().isNotEmpty) {
      store.addTodo(_text.text.trim());
      _text.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = store.todos.where((t) => !t.done).toList();
    final done = store.todos.where((t) => t.done).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Eingabe
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _text,
                  hint: 'Neue Aufgabe …',
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 10),
              PressScale(
                onTap: _add,
                scale: 0.92,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppIcon('plus', size: 24, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (open.isEmpty && done.isEmpty)
          const EmptyState(icon: 'check', text: 'Keine Aufgaben. Alles erledigt!'),
        if (open.isNotEmpty) ...[
          LabelText('Offen · ${open.length}', margin: const EdgeInsets.fromLTRB(2, 2, 2, 10)),
          Column(
            children: [
              for (final t in open) ...[
                _TodoItem(store: store, todo: t, onChanged: () => setState(() {})),
                if (t != open.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
        if (done.isNotEmpty) ...[
          SectionTitle('Erledigt',
              trailing: LinkButton('Aufräumen', onTap: () {
                store.clearDoneTodos();
                setState(() {});
              })),
          Column(
            children: [
              for (final t in done) ...[
                _TodoItem(store: store, todo: t, onChanged: () => setState(() {})),
                if (t != done.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _TodoItem extends StatelessWidget {
  final AppStore store;
  final Todo todo;
  final VoidCallback onChanged;
  const _TodoItem({required this.store, required this.todo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      scale: 0.99,
      onTap: () {
        store.toggleTodo(todo.id);
        onChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: todo.done ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: todo.done ? c.accent : c.line2, width: 2),
              ),
              child: todo.done
                  ? AppIcon('check', size: 16, strokeWidth: 2.6, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                todo.text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: todo.done ? c.text3 : c.text,
                  decoration: todo.done ? TextDecoration.lineThrough : null,
                  decorationColor: c.text3,
                ),
              ),
            ),
            PressScale(
              onTap: () {
                store.deleteTodo(todo.id);
                onChanged();
              },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: AppIcon('trash', size: 18, color: c.text3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
