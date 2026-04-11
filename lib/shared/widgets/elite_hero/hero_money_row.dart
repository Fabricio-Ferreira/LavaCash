import 'package:flutter/material.dart';

/// Label + value row for hero breakdown lines.
class HeroMoneyRow extends StatelessWidget {
  const HeroMoneyRow({
    super.key,
    required this.label,
    required this.valueText,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String valueText;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(valueText, textAlign: TextAlign.right, style: valueStyle),
        ),
      ],
    );
  }
}
