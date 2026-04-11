import 'package:flutter/material.dart';

import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'elite_hero_dashboard_card.dart';
import 'elite_hero_daily_report_card.dart';
import 'elite_hero_interval_report_card.dart';
import 'elite_hero_monthly_card.dart';

/// Green gradient hero card shared by dashboard, daily report, and monthly report.
abstract final class EliteHeroCard {
  EliteHeroCard._();

  static Widget dashboard({
    required bool isLoading,
    required double totalRecebido,
    required double totalDespesas,
  }) {
    return EliteHeroDashboardCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
      totalDespesas: totalDespesas,
    );
  }

  static Widget dailyReport({
    required bool isLoading,
    required double totalRecebido,
    required double totalDespesas,
  }) {
    return EliteHeroDailyReportCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
      totalDespesas: totalDespesas,
    );
  }

  static Widget intervalReport({
    required bool isLoading,
    required double totalRecebido,
  }) {
    return EliteHeroIntervalReportCard(
      isLoading: isLoading,
      totalRecebido: totalRecebido,
    );
  }

  static Widget monthly({
    required MonthlyReport? highlight,
    double? growthPercentVsPrevious,
  }) {
    return EliteHeroMonthlyCard(
      highlight: highlight,
      growthPercentVsPrevious: growthPercentVsPrevious,
    );
  }
}
