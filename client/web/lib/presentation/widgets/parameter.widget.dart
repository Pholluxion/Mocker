import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ParameterInputField extends StatelessWidget {
  const ParameterInputField({
    super.key,
    this.onChanged,
    required this.param,
    required this.enabled,
    required this.visible,
  });

  final bool enabled;
  final bool visible;
  final Param param;
  final void Function(Param)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  flex: 1,
                  child: Icon(Icons.tune),
                ),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(param.key),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(hintText: param.value),
                    onChanged: (value) => onChanged!(param.copyWith(value: value)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomParameterInputField extends StatelessWidget {
  const CustomParameterInputField({
    super.key,
    this.onChanged,
    required this.param,
    required this.enabled,
    required this.visible,
    required this.onRemove,
  });

  final bool visible;
  final bool enabled;
  final Param param;
  final void Function(Param)? onChanged;
  final void Function(String id)? onRemove;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: IconButton(
                    tooltip: 'Remove parameter',
                    onPressed: () => onRemove!(param.id),
                    icon: const Icon(Icons.delete_forever),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(hintText: param.key),
                    onChanged: (key) => onChanged!(param.copyWith(key: key)),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(hintText: param.value),
                    onChanged: (value) => onChanged!(param.copyWith(value: value)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParameterCheckBox extends StatelessWidget {
  const ParameterCheckBox({
    super.key,
    this.onChanged,
    required this.enabled,
    required this.value,
    required this.fieldName,
    required this.visible,
  });
  final bool value;
  final bool enabled;
  final bool visible;
  final String fieldName;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(fieldName),
                ),
                Flexible(
                  flex: 2,
                  child: Switch(
                    value: value,
                    onChanged: (v) => onChanged!(v),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
