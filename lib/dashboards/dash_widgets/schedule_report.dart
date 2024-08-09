import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';
import 'package:inmateschedular_pro/services/user_model.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SchedulePdfReport {
  final List<ScheduleModel> schedules;
  final List<OfficerModel> officers;
  final BuildContext context;
  final String appName;
  final String appLogoPath;

  SchedulePdfReport({
    required this.schedules,
    required this.officers,
    required this.context,
    required this.appName,
    required this.appLogoPath,
  });

  Future<Uint8List> generatePdf() async {
    PdfDocument? document;
    try {
      document = PdfDocument();

      // Add a page to the document
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;

      // Load fonts
      final ByteData fontData = await rootBundle.load('fonts/OpenSans-Regular.ttf');
      final PdfFont font = PdfTrueTypeFont(fontData.buffer.asUint8List(), 9);
      final PdfFont reportFont = PdfTrueTypeFont(fontData.buffer.asUint8List(), 16, style: PdfFontStyle.bold);
      final PdfFont boldFont = PdfTrueTypeFont(fontData.buffer.asUint8List(), 10, style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 26, style: PdfFontStyle.bold);

      // Load the app logo
      final ByteData logoData = await rootBundle.load(appLogoPath);
      final PdfBitmap logo = PdfBitmap(logoData.buffer.asUint8List());

      // Draw the app logo and name as the header
      graphics.drawImage(logo, Rect.fromLTWH(0, 0, 50, 50));
      graphics.drawString(
        appName,
        headerFont,
        bounds: const Rect.fromLTWH(60, 0, 500, 50),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.bottom)
      );
      // Add title
      graphics.drawString('Report of Schedules', reportFont, bounds: Rect.fromLTWH(0, 60, page.getClientSize().width, 40));

      // Add date
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      graphics.drawString('Date: $currentDate', boldFont, bounds: Rect.fromLTWH(0, 100, page.getClientSize().width, 20));

      // Add summary information
      final int totalSchedules = schedules.length;
      final int upcomingSchedules = schedules.where((s) => _getScheduleStatus(s) == 'Upcoming').length;
      final int ongoingSchedules = schedules.where((s) => _getScheduleStatus(s) == 'Ongoing').length;
      final int completedSchedules = schedules.where((s) => _getScheduleStatus(s) == 'Completed').length;

      graphics.drawString('Total Schedules: $totalSchedules', font, bounds: Rect.fromLTWH(0, 120, page.getClientSize().width, 20));
      graphics.drawString('Upcoming Schedules: $upcomingSchedules', font, bounds: Rect.fromLTWH(0, 140, page.getClientSize().width, 20));
      graphics.drawString('Ongoing Schedules: $ongoingSchedules', font, bounds: Rect.fromLTWH(0, 160, page.getClientSize().width, 20));
      graphics.drawString('Completed Schedules: $completedSchedules', font, bounds: Rect.fromLTWH(0, 180, page.getClientSize().width, 20));

      // Add watermark
      graphics.save();
      graphics.setTransparency(0.1);
      graphics.drawString(
        'Confidential',
        PdfStandardFont(PdfFontFamily.helvetica, 40),
        bounds: Rect.fromLTWH(page.getClientSize().width / 4, page.getClientSize().height / 2, page.getClientSize().width, 50),
      );
      graphics.restore();

      // Create a PDF layout
      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 6);
      grid.headers.add(1);
      final PdfGridRow header = grid.headers[0];
      header.cells[0].value = 'Activity';
      header.cells[1].value = 'Supervisors';
      header.cells[2].value = 'No. of Inmates';
      header.cells[3].value = 'Start Time';
      header.cells[4].value = 'End Time';
      header.cells[5].value = 'Status';

      header.style = PdfGridCellStyle(
        font: boldFont,
        backgroundBrush: PdfBrushes.lightGray,
        borders: PdfBorders(
          left: PdfPen(PdfColor(0, 0, 0, 255)),
          top: PdfPen(PdfColor(0, 0, 0, 255)),
          right: PdfPen(PdfColor(0, 0, 0, 255)),
          bottom: PdfPen(PdfColor(0, 0, 0, 255)),
        ),
      );

      for (var schedule in schedules) {
        final List<String> supervisorNames = schedule.supervisors?.map((id) {
          var officer = officers.firstWhere((officer) => officer.id == id, orElse: () => OfficerModel(name: 'Unknown'));
          return officer.name ?? 'Unknown';
        }).toList() ?? [];
        final bool isAllOfficers = schedule.supervisors?.length == officers.length;

        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = schedule.activity ?? 'No activity';
        row.cells[1].value = isAllOfficers ? 'All Officers' : supervisorNames.join(', ');
        row.cells[5].value = schedule.inmates?.length.toString() ?? '0';
        row.cells[3].value = schedule.startTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(schedule.startTime!)
            : 'N/A';
        row.cells[4].value = schedule.endTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(schedule.endTime!)
            : 'N/A';
        row.cells[5].value = _getScheduleStatus(schedule);
      

        // Apply style to the row
        row.style = PdfGridCellStyle(
          font: font,
          borders: PdfBorders(
            left: PdfPen(PdfColor(0, 0, 0, 255)),
            top: PdfPen(PdfColor(0, 0, 0, 255)),
            right: PdfPen(PdfColor(0, 0, 0, 255)),
            bottom: PdfPen(PdfColor(0, 0, 0, 255)),
          ),
        );
      }

      // Draw the grid on the page
      grid.draw(page: page, bounds: Rect.fromLTWH(0, 200, page.getClientSize().width, page.getClientSize().height - 200));

      // Add page number at the footer
      for (int i = 0; i < document.pages.count; i++) {
        final PdfPage currentPage = document.pages[i];
        final PdfGraphics pageGraphics = currentPage.graphics;
        final Size pageSize = currentPage.getClientSize();
        pageGraphics.drawString(
          'Page ${i + 1} of ${document.pages.count}',
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(pageSize.width - 100, pageSize.height - 30, 100, 20),
        );
      }

      // Save the document and return the bytes
      final List<int> bytes = document.saveSync();
      return Uint8List.fromList(bytes);
    } catch (e) {
      debugPrint('Failed to generate PDF Report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF Report: $e')),
      );
      return Uint8List(0);
    } finally {
      // Dispose of the document
      document?.dispose();
    }
  }

  String _getScheduleStatus(ScheduleModel schedule) {
    final now = DateTime.now();
    if (schedule.startTime == null || schedule.endTime == null) return 'Unknown';
    if (now.isBefore(schedule.startTime!)) return 'Upcoming';
    if (now.isAfter(schedule.endTime!)) return 'Completed';
    return 'Ongoing';
  }
}

class SchedulePdfPreview extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final List<OfficerModel> officers;
  final String appName;
  final String appLogoPath;

  SchedulePdfPreview({
    required this.schedules,
    required this.appName,
    required this.appLogoPath,
    required BuildContext context,
    required this.officers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Uint8List>(
        future: SchedulePdfReport(
          schedules: schedules,
          context: context,
          appName: appName,
          appLogoPath: appLogoPath,
          officers: officers,
        ).generatePdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Failed to generate PDF Report'));
          } else {
            return PdfPreview(
              build: (format) => snapshot.data!,
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: true,
              canDebug: false,
              canChangePageFormat: true,
              onError: (context, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to display PDF: $error')),
                );
                return const Center(child: Text('Failed to display PDF'));
              },
            );
          }
        },
      ),
    );
  }
}
