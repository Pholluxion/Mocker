import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.icon,
    required this.width,
    required this.items,
    required this.tooltip,
  });

  final Widget icon;
  final double width;
  final String tooltip;
  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Tooltip(
          message: tooltip,
          child: icon,
        ),
        items: [
          ...items.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: item.widget,
            ),
          ),
        ],
        onChanged: (value) => value?.onPressed(context),
        dropdownStyleData: DropdownStyleData(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          offset: const Offset(0, 8),
        ),
        menuItemStyleData: MenuItemStyleData(
          customHeights: [
            ...List<double>.filled(items.length, 48),
          ],
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final void Function(BuildContext context) onPressed;

  Widget get widget => Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
}
