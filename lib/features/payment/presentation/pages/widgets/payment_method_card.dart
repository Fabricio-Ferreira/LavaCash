import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../domain/entities/payment_method.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color:
                selected
                    ? scheme.primaryContainer
                    : AppColors.surfaceContainerLowest,
            border:
                selected
                    ? null
                    : Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.15),
                    ),
            boxShadow:
                selected
                    ? <BoxShadow>[
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : null,
          ),
          child: Stack(
            children: <Widget>[
              if (selected)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          method.icon,
                          size: 32,
                          color: selected ? scheme.onPrimary : scheme.primary,
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: scheme.onPrimary.withValues(alpha: 0.7),
                            size: 24,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      paymentMethodDisplayTitle(method),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: selected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            selected
                                ? scheme.onPrimary.withValues(alpha: 0.85)
                                : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String paymentMethodDisplayTitle(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.pix:
      return 'Pix';
    case PaymentMethod.dinheiro:
      return 'Dinheiro';
    case PaymentMethod.debito:
      return 'Débito';
    case PaymentMethod.credito:
      return 'Crédito';
  }
}
