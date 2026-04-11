import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Stateless PDF builder for daily / monthly reports (share + print via
/// [Printing]).
class ReportPdfService {
  Future<Uint8List> generateDailyReportPdf({
    required String companyName,
    required DateTime reportDate,
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> attendances,
    required List<Map<String, dynamic>> expenses,
    String? appVersionLabel,
  }) async {
    final pw.Font base = await PdfGoogleFonts.notoSansRegular();
    final pw.Font bold = await PdfGoogleFonts.notoSansBold();
    final NumberFormat currency = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    );
    final DateFormat dayFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final DateFormat timeFmt = DateFormat('HH:mm', 'pt_BR');
    final DateFormat dtFmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: base, bold: bold),
        build: (pw.Context ctx) => <pw.Widget>[
          _pdfHeader(
            title: 'Relatório diário',
            subtitle: dayFmt.format(reportDate),
            companyName: companyName,
            bold: bold,
            base: base,
            dtFmt: dtFmt,
          ),
          pw.SizedBox(height: 16),
          _summaryBlock(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
            title: 'Resumo do dia',
          ),
          pw.SizedBox(height: 16),
          _paymentMethodsTable(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Atendimentos', bold),
          pw.SizedBox(height: 8),
          _attendanceTable(
            attendances: attendances,
            currency: currency,
            bold: bold,
            base: base,
            timeFmt: timeFmt,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Despesas', bold),
          pw.SizedBox(height: 8),
          _expenseTable(
            expenses: expenses,
            currency: currency,
            bold: bold,
            base: base,
            dtFmt: dtFmt,
          ),
          pw.SizedBox(height: 16),
          _pdfFooter(appVersionLabel: appVersionLabel, base: base),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> generateMonthlyReportPdf({
    required String companyName,
    required DateTime referenceMonth,
    required Map<String, dynamic> summary,
    required List<WeeklyReport> weeklyReports,
    BestWeekdayReport? bestWeekday,
    String? appVersionLabel,
  }) async {
    final pw.Font base = await PdfGoogleFonts.notoSansRegular();
    final pw.Font bold = await PdfGoogleFonts.notoSansBold();
    final NumberFormat currency = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    );
    final DateFormat monthFmt = DateFormat('MMMM yyyy', 'pt_BR');
    final DateFormat dtFmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: base, bold: bold),
        build: (pw.Context ctx) => <pw.Widget>[
          _pdfHeader(
            title: 'Relatório mensal',
            subtitle: monthFmt.format(referenceMonth),
            companyName: companyName,
            bold: bold,
            base: base,
            dtFmt: dtFmt,
          ),
          pw.SizedBox(height: 16),
          _summaryBlock(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
            title: 'Resumo do mês',
          ),
          pw.SizedBox(height: 16),
          _paymentMethodsTable(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
          ),
          pw.SizedBox(height: 16),
          _sectionTitle('Desempenho por semana do mês', bold),
          pw.SizedBox(height: 8),
          _weeklyTable(
            weeklyReports: weeklyReports,
            currency: currency,
            bold: bold,
            base: base,
          ),
          pw.SizedBox(height: 12),
          if (bestWeekday != null)
            pw.Text(
              'Melhor dia da semana: ${bestWeekday.diaSemana} '
              '(${currency.format(bestWeekday.faturamento)})',
              style: pw.TextStyle(font: base, fontSize: 10),
            ),
          pw.SizedBox(height: 16),
          _pdfFooter(appVersionLabel: appVersionLabel, base: base),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> generateIntervalReportPdf({
    required String companyName,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required Map<String, dynamic> summary,
    required List<Map<String, dynamic>> attendances,
    required List<Map<String, dynamic>> expenses,
    String? appVersionLabel,
  }) async {
    final pw.Font base = await PdfGoogleFonts.notoSansRegular();
    final pw.Font bold = await PdfGoogleFonts.notoSansBold();
    final NumberFormat currency = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
    );
    final DateFormat dayFmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final DateFormat timeFmt = DateFormat('HH:mm', 'pt_BR');
    final DateFormat dtFmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    final pw.Document doc = pw.Document();
    final String periodSubtitle =
        '${dayFmt.format(rangeStart)} – ${dayFmt.format(rangeEnd)}';
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: base, bold: bold),
        build: (pw.Context ctx) => <pw.Widget>[
          _pdfHeader(
            title: 'Relatório por período',
            subtitle: periodSubtitle,
            companyName: companyName,
            bold: bold,
            base: base,
            dtFmt: dtFmt,
          ),
          pw.SizedBox(height: 16),
          _summaryBlock(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
            title: 'Resumo do período',
          ),
          pw.SizedBox(height: 16),
          _paymentMethodsTable(
            currency: currency,
            bold: bold,
            base: base,
            summary: summary,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Atendimentos', bold),
          pw.SizedBox(height: 8),
          _attendanceTableInterval(
            attendances: attendances,
            currency: currency,
            bold: bold,
            base: base,
            timeFmt: timeFmt,
            dayFmt: dayFmt,
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Despesas', bold),
          pw.SizedBox(height: 8),
          _expenseTableInterval(
            expenses: expenses,
            currency: currency,
            bold: bold,
            base: base,
            dtFmt: dtFmt,
            dayFmt: dayFmt,
          ),
          pw.SizedBox(height: 16),
          _pdfFooter(appVersionLabel: appVersionLabel, base: base),
        ],
      ),
    );
    return doc.save();
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  Future<void> sharePdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  pw.Widget _pdfHeader({
    required String title,
    required String subtitle,
    required String companyName,
    required pw.Font bold,
    required pw.Font base,
    required DateFormat dtFmt,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#0B7A33'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'LavaCash',
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 20,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  font: base,
                  fontSize: 11,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              pw.Text(
                companyName.isEmpty ? '—' : companyName,
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Gerado em ${dtFmt.format(DateTime.now())}',
                style: pw.TextStyle(
                  font: base,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryBlock({
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required Map<String, dynamic> summary,
    required String title,
  }) {
    final double entradas = _toDouble(summary['total_entradas']);
    final double saidas = _toDouble(summary['total_saidas']);
    final double saldo = _toDouble(summary['saldo_liquido']);
    final double ticket = _toDouble(summary['ticket_medio']);
    final int lavagens = _toInt(summary['total_lavagens']);
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: pw.TextStyle(font: bold, fontSize: 13),
          ),
          pw.SizedBox(height: 10),
          _kvRow(
            'Total de entradas',
            currency.format(entradas),
            bold,
            base,
          ),
          _kvRow('Total de saídas', currency.format(saidas), bold, base),
          _kvRow('Saldo líquido', currency.format(saldo), bold, base),
          _kvRow('Lavagens finalizadas', '$lavagens', bold, base),
          _kvRow('Ticket médio', currency.format(ticket), bold, base),
        ],
      ),
    );
  }

  pw.Widget _kvRow(
    String k,
    String v,
    pw.Font bold,
    pw.Font base,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(k, style: pw.TextStyle(font: base, fontSize: 10)),
          ),
          pw.Text(v, style: pw.TextStyle(font: bold, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _paymentMethodsTable({
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required Map<String, dynamic> summary,
  }) {
    final double d = _toDouble(summary['total_dinheiro']);
    final double p = _toDouble(summary['total_pix']);
    final double db = _toDouble(summary['total_debito']);
    final double cr = _toDouble(summary['total_credito']);
    final double lk = _toDouble(summary['total_link']);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _sectionTitle('Formas de pagamento', bold),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: <int, pw.TableColumnWidth>{
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: <pw.TableRow>[
            _headerRow(<String>['Forma', 'Valor'], bold, base),
            _dataRow(<String>['Dinheiro', currency.format(d)], base),
            _dataRow(<String>['Pix', currency.format(p)], base),
            _dataRow(<String>['Débito', currency.format(db)], base),
            _dataRow(<String>['Crédito', currency.format(cr)], base),
            if (lk > 0.009)
              _dataRow(<String>['Link', currency.format(lk)], base),
          ],
        ),
      ],
    );
  }

  pw.Widget _sectionTitle(String text, pw.Font bold) {
    return pw.Text(
      text,
      style: pw.TextStyle(font: bold, fontSize: 12),
    );
  }

  pw.TableRow _headerRow(List<String> cells, pw.Font bold, pw.Font base) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: cells
          .map(
            (String c) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                c,
                style: pw.TextStyle(font: bold, fontSize: 9),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.TableRow _dataRow(List<String> cells, pw.Font base) {
    return pw.TableRow(
      children: cells
          .map(
            (String c) => pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                c,
                style: pw.TextStyle(font: base, fontSize: 9),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _attendanceTable({
    required List<Map<String, dynamic>> attendances,
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required DateFormat timeFmt,
  }) {
    if (attendances.isEmpty) {
      return _emptyBox('Nenhum atendimento neste dia.', base);
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1),
      },
      children: <pw.TableRow>[
        _headerRow(
          <String>['Cliente', 'Placa', 'Entrada', 'Valor', 'Pagamento', 'Status'],
          bold,
          base,
        ),
        ...attendances.map((Map<String, dynamic> row) {
          final DateTime? t = _parseTs(row['hora_entrada_local']);
          final String entrada =
              t != null ? timeFmt.format(t.toLocal()) : '—';
          return _dataRow(
            <String>[
              _str(row['cliente_nome']),
              _str(row['placa']),
              entrada,
              currency.format(_toDouble(row['valor_total'])),
              _str(row['forma_pagamento']),
              _str(row['status']),
            ],
            base,
          );
        }),
      ],
    );
  }

  pw.Widget _expenseTable({
    required List<Map<String, dynamic>> expenses,
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required DateFormat dtFmt,
  }) {
    if (expenses.isEmpty) {
      return _emptyBox('Nenhuma despesa neste dia.', base);
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(2.2),
        1: const pw.FlexColumnWidth(1.3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: <pw.TableRow>[
        _headerRow(
          <String>['Descrição', 'Categoria', 'Registrado em', 'Valor'],
          bold,
          base,
        ),
        ...expenses.map((Map<String, dynamic> row) {
          final DateTime? reg = _parseTs(row['registrado_em']);
          final String when =
              reg != null ? dtFmt.format(reg.toLocal()) : '—';
          return _dataRow(
            <String>[
              _str(row['descricao']),
              _str(row['categoria']),
              when,
              currency.format(_toDouble(row['valor'])),
            ],
            base,
          );
        }),
      ],
    );
  }

  pw.Widget _attendanceTableInterval({
    required List<Map<String, dynamic>> attendances,
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required DateFormat timeFmt,
    required DateFormat dayFmt,
  }) {
    if (attendances.isEmpty) {
      return _emptyBox('Nenhum atendimento neste período.', base);
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(1.1),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(0.9),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(0.9),
      },
      children: <pw.TableRow>[
        _headerRow(
          <String>[
            'Data',
            'Cliente',
            'Placa',
            'Entrada',
            'Valor',
            'Pagamento',
            'Status',
          ],
          bold,
          base,
        ),
        ...attendances.map((Map<String, dynamic> row) {
          final DateTime? t = _parseTs(row['hora_entrada_local']);
          final String entrada =
              t != null ? timeFmt.format(t.toLocal()) : '—';
          return _dataRow(
            <String>[
              _formatDataRefForPdf(row['data_ref'], dayFmt),
              _str(row['cliente_nome']),
              _str(row['placa']),
              entrada,
              currency.format(_toDouble(row['valor_total'])),
              _str(row['forma_pagamento']),
              _str(row['status']),
            ],
            base,
          );
        }),
      ],
    );
  }

  pw.Widget _expenseTableInterval({
    required List<Map<String, dynamic>> expenses,
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
    required DateFormat dtFmt,
    required DateFormat dayFmt,
  }) {
    if (expenses.isEmpty) {
      return _emptyBox('Nenhuma despesa neste período.', base);
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(1.1),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(1.1),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: <pw.TableRow>[
        _headerRow(
          <String>[
            'Data ref.',
            'Descrição',
            'Categoria',
            'Registrado em',
            'Valor',
          ],
          bold,
          base,
        ),
        ...expenses.map((Map<String, dynamic> row) {
          final DateTime? reg = _parseTs(row['registrado_em']);
          final String when =
              reg != null ? dtFmt.format(reg.toLocal()) : '—';
          return _dataRow(
            <String>[
              _formatDataRefForPdf(row['data_ref'], dayFmt),
              _str(row['descricao']),
              _str(row['categoria']),
              when,
              currency.format(_toDouble(row['valor'])),
            ],
            base,
          );
        }),
      ],
    );
  }

  String _formatDataRefForPdf(dynamic v, DateFormat dayFmt) {
    if (v == null) {
      return '—';
    }
    if (v is DateTime) {
      return dayFmt.format(v.toLocal());
    }
    final DateTime? parsed = DateTime.tryParse(v.toString());
    if (parsed != null) {
      return dayFmt.format(parsed.toLocal());
    }
    return v.toString();
  }

  pw.Widget _weeklyTable({
    required List<WeeklyReport> weeklyReports,
    required NumberFormat currency,
    required pw.Font bold,
    required pw.Font base,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
      },
      children: <pw.TableRow>[
        _headerRow(<String>['Semana', 'Atendimentos', 'Faturamento'], bold, base),
        ...weeklyReports.map(
          (WeeklyReport w) => _dataRow(
            <String>[
              '${w.semana}ª',
              '${w.totalAtendimentos}',
              currency.format(w.faturamento),
            ],
            base,
          ),
        ),
      ],
    );
  }

  pw.Widget _emptyBox(String text, pw.Font base) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: base, fontSize: 9),
      ),
    );
  }

  pw.Widget _pdfFooter({
    required pw.Font base,
    String? appVersionLabel,
  }) {
    final String extra =
        appVersionLabel == null || appVersionLabel.isEmpty
            ? ''
            : ' · $appVersionLabel';
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'LavaCash$extra',
        style: pw.TextStyle(font: base, fontSize: 8, color: PdfColors.grey700),
      ),
    );
  }

  double _toDouble(dynamic v) {
    if (v == null) {
      return 0;
    }
    if (v is num) {
      return v.toDouble();
    }
    return double.tryParse(v.toString()) ?? 0;
  }

  int _toInt(dynamic v) {
    if (v == null) {
      return 0;
    }
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return int.tryParse(v.toString()) ?? 0;
  }

  String _str(dynamic v) {
    if (v == null) {
      return '—';
    }
    final String s = v.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  DateTime? _parseTs(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is DateTime) {
      return v;
    }
    return DateTime.tryParse(v.toString());
  }
}
