import 'package:flutter/material.dart';

/// Extra scroll padding above [AppBottomNavigation] on [HomePage] (extendBody).
double homeTabListBottomPadding(BuildContext context) {
  const double gapAboveNav = 10.0;
  const double navBarReserve = 20;
  return gapAboveNav + MediaQuery.paddingOf(context).bottom + navBarReserve;
}

/// Lifts [Scaffold.floatingActionButton] above [AppBottomNavigation]
/// when the tab uses a nested [Scaffold] under [HomePage] (extendBody).
double homeTabFabBottomPadding(BuildContext context) {
  const double barTopPad = 2;
  const double barBottomPad = 2;
  const double rowHeight = 2;
  const double clearance = 4;
  return barTopPad +
      rowHeight +
      barBottomPad +
      MediaQuery.paddingOf(context).bottom +
      clearance;
}
