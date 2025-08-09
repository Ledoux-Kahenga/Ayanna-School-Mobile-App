import 'package:flutter/material.dart';
import '../ayanna_theme.dart';

class AyannaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const AyannaAppBar({
    required this.title,
    this.actions,
    this.centerTitle = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: AyannaTheme.primary,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
