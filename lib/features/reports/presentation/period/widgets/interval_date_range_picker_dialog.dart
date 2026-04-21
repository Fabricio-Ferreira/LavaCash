import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/domain/reports/attendance_history_range_validation.dart';
import '../../../../../core/utils/brazilian_date_input_formatter.dart';
import '../../../../../core/utils/formatters.dart';

/// Dialog with masked [dd/MM/yyyy] fields + optional full calendar (range).
Future<DateTimeRange?> showIntervalDateRangePickerDialog({
  required BuildContext context,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext ctx) {
      return _IntervalDateRangeDialog(
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
  );
}

class _IntervalDateRangeDialog extends StatefulWidget {
  const _IntervalDateRangeDialog({
    required this.rangeStart,
    required this.rangeEnd,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_IntervalDateRangeDialog> createState() =>
      _IntervalDateRangeDialogState();
}

class _IntervalDateRangeDialogState extends State<_IntervalDateRangeDialog> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  String? _errorMessage;

  String _formatDay(DateTime d) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(d);
  }

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: _formatDay(widget.rangeStart),
    );
    _endController = TextEditingController(text: _formatDay(widget.rangeEnd));
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _openCalendarOnly() async {
    final ThemeData base = Theme.of(context);
    final DateTime? startParsed = AppFormatters.tryParseBrazilianDateDdMmYyyy(
      _startController.text,
    );
    final DateTime? endParsed = AppFormatters.tryParseBrazilianDateDdMmYyyy(
      _endController.text,
    );
    final DateTimeRange initial = DateTimeRange(
      start: startParsed ?? widget.rangeStart,
      end: endParsed ?? widget.rangeEnd,
    );
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      locale: const Locale('pt', 'BR'),
      helpText: 'Período do relatório',
      cancelText: 'Cancelar',
      confirmText: 'Salvar',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Theme(
          data: AppTheme.dateRangePickerOverlay(base),
          child: child,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _errorMessage = null;
        _startController.text = _formatDay(picked.start);
        _endController.text = _formatDay(picked.end);
      });
    }
  }

  void _setEndDateToToday() {
    final DateTime now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day);
    final DateTime firstD = DateTime(
      widget.firstDate.year,
      widget.firstDate.month,
      widget.firstDate.day,
    );
    final DateTime lastD = DateTime(
      widget.lastDate.year,
      widget.lastDate.month,
      widget.lastDate.day,
    );
    if (day.isBefore(firstD)) {
      day = firstD;
    }
    if (day.isAfter(lastD)) {
      day = lastD;
    }
    setState(() {
      _errorMessage = null;
      _endController.text = _formatDay(day);
    });
  }

  void _submit() {
    setState(() {
      _errorMessage = null;
    });
    final DateTime? start = AppFormatters.tryParseBrazilianDateDdMmYyyy(
      _startController.text,
    );
    final DateTime? end = AppFormatters.tryParseBrazilianDateDdMmYyyy(
      _endController.text,
    );
    if (start == null) {
      setState(() {
        _errorMessage = 'Data de início inválida. Use dd/MM/aaaa.';
      });
      return;
    }
    if (end == null) {
      setState(() {
        _errorMessage = 'Data de término inválida. Use dd/MM/aaaa.';
      });
      return;
    }
    DateTime s = DateTime(start.year, start.month, start.day);
    DateTime e = DateTime(end.year, end.month, end.day);
    if (s.isBefore(widget.firstDate)) {
      s = DateTime(
        widget.firstDate.year,
        widget.firstDate.month,
        widget.firstDate.day,
      );
    }
    if (e.isAfter(widget.lastDate)) {
      e = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    }
    if (s.isAfter(e)) {
      setState(() {
        _errorMessage = 'A data inicial não pode ser depois da final.';
      });
      return;
    }
    final String? spanError = AttendanceHistoryRangeValidation.validate(s, e);
    if (spanError != null) {
      setState(() {
        _errorMessage = spanError;
      });
      return;
    }
    Navigator.of(context).pop<DateTimeRange>(DateTimeRange(start: s, end: e));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        'Período do relatório',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _startController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                BrazilianDateInputFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Data de início',
                hintText: 'dd/MM/aaaa',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _endController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      BrazilianDateInputFormatter(),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Data de término',
                      hintText: 'dd/MM/aaaa',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _setEndDateToToday,
                  child: const Text('Hoje'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openCalendarOnly,
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              label: const Text('Escolher no calendário'),
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              SelectableText.rich(
                TextSpan(
                  text: _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<DateTimeRange>(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
