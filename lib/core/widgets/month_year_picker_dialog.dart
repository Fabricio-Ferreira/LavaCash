import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Material dialog to pick calendar month + year (day fixed to 1).
Future<DateTime?> showMonthYearPickerDialog({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return _MonthYearPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title ?? 'Selecione o mês',
        confirmLabel: confirmLabel ?? 'OK',
        cancelLabel: cancelLabel ?? 'Cancelar',
      );
    },
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final DateTime i = widget.initialDate;
    _year = i.year.clamp(widget.firstDate.year, widget.lastDate.year);
    _month = i.month;
    _clampMonthToYear();
  }

  List<int> get _yearOptions {
    final int from = widget.firstDate.year;
    final int to = widget.lastDate.year;
    return List<int>.generate(to - from + 1, (int k) => from + k);
  }

  int get _minMonthForYear {
    return _year == widget.firstDate.year ? widget.firstDate.month : 1;
  }

  int get _maxMonthForYear {
    return _year == widget.lastDate.year ? widget.lastDate.month : 12;
  }

  void _clampMonthToYear() {
    final int lo = _minMonthForYear;
    final int hi = _maxMonthForYear;
    if (_month < lo) {
      _month = lo;
    }
    if (_month > hi) {
      _month = hi;
    }
  }

  void _setYear(int? y) {
    if (y == null) {
      return;
    }
    setState(() {
      _year = y;
      _clampMonthToYear();
    });
  }

  void _setMonth(int? m) {
    if (m == null) {
      return;
    }
    setState(() {
      _month = m;
    });
  }

  String _monthLabel(int month) {
    return toBeginningOfSentenceCase(
          DateFormat.MMMM('pt_BR').format(DateTime(2000, month)),
        ) ??
        '$month';
  }

  @override
  Widget build(BuildContext context) {
    final List<int> monthsAvailable = List<int>.generate(
      _maxMonthForYear - _minMonthForYear + 1,
      (int k) => _minMonthForYear + k,
    );
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ano',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _year,
                  items:
                      _yearOptions
                          .map(
                            (int y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text('$y'),
                            ),
                          )
                          .toList(),
                  onChanged: _setYear,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Mês',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value:
                      monthsAvailable.contains(_month)
                          ? _month
                          : monthsAvailable.first,
                  items:
                      monthsAvailable
                          .map(
                            (int m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text(_monthLabel(m)),
                            ),
                          )
                          .toList(),
                  onChanged: _setMonth,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<DateTime>(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop<DateTime>(DateTime(_year, _month, 1));
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
