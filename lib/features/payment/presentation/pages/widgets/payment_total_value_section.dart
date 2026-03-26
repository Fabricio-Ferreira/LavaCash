import 'package:flutter/material.dart';

import '../../../../../core/utils/brazilian_real_input_formatter.dart';

class PaymentTotalValueSection extends StatelessWidget {
  const PaymentTotalValueSection({super.key, required this.valorController});

  final TextEditingController valorController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return AnimatedBuilder(
      animation: valorController,
      builder: (BuildContext context, Widget? child) {
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
                      child: TextField(
                        readOnly: true,
                        enabled: false,
                        controller: valorController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          height: 1,
                          fontSize: 86,
                        ),
                        inputFormatters: const <BrazilianRealInputFormatter>[
                          BrazilianRealInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          filled: false,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0,00',
                          hintStyle: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1,
                            fontSize: 86,
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
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
