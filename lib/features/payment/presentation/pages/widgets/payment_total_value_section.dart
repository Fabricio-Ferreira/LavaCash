import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class PaymentTotalValueSection extends StatelessWidget {
  const PaymentTotalValueSection({super.key, required this.valorController});

  final TextEditingController valorController;

  static const double _maxFontSize = 86;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle valueStyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineLarge!)
        .copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          height: 1,
          fontSize: _maxFontSize,
        );
    return AnimatedBuilder(
      animation: valorController,
      builder: (BuildContext context, Widget? child) {
        final String displayText =
            valorController.text.isEmpty ? '0,00' : valorController.text;
        final bool isPlaceholder = valorController.text.isEmpty;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'VALOR TOTAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.1 * 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      'R\$',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: AutoSizeText(
                        displayText,
                        minFontSize: 14,
                        maxFontSize: _maxFontSize,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style:
                            isPlaceholder
                                ? valueStyle.copyWith(
                                  color: scheme.onSurfaceVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                )
                                : valueStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
