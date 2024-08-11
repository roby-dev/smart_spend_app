import 'package:flutter/material.dart';

class RoundedCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const RoundedCheckbox({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        shape: const CircleBorder(),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
