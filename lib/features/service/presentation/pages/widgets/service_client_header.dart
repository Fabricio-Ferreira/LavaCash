import 'package:flutter/material.dart';
import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/services/whatsapp_service.dart';

/// Client name, status label, and plate badge for the active service screen.
class ServiceClientHeader extends StatelessWidget {
  const ServiceClientHeader({
    super.key,
    required this.clientName,
    required this.plateFormatted,
    required this.phone,
  });

  final String clientName;
  final String plateFormatted;
  final String phone;
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CLIENTE EM ATENDIMENTO',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          clientName,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.directions_car_outlined,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    plateFormatted,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                WhatsAppService.openSystemDialer(phoneDigitsOnly: phone);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      (phone.trim().isNotEmpty)
                          ? <Widget>[
                            Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: AppColors.primaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              phone,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ]
                          : <Widget>[],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
