import 'package:flutter/material.dart';

/// Extra scroll padding above [AppBottomNavigation] on [HomePage] (extendBody).
double homeTabListBottomPadding(BuildContext context) {
  const double gapAboveNav = 10.0;
  const double navBarReserve = 20;
  return gapAboveNav + MediaQuery.paddingOf(context).bottom + navBarReserve;
}
