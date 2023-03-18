import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final Widget content;
  final bool isCurrent;
  const DrawerItem({super.key, required this.content, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 8.0),
        decoration: isCurrent
            ? BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.0))
            : null,
        child: Theme(
            data: Theme.of(context).copyWith(
                listTileTheme: Theme.of(context).listTileTheme.copyWith(
                    textColor: isCurrent ? Colors.black : Colors.white,
                    iconColor: isCurrent ? Colors.grey : Colors.white)),
            child: content));
  }
}
