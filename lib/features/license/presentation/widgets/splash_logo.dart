import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'splash_assets.dart';
import 'splash_palette.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: SplashPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SvgPicture.asset(
          SplashAssets.logo,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          semanticsLabel: 'LavaCash logo',
        ),
      ),
    );
  }
}
