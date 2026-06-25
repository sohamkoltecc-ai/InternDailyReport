import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPreviewPage extends StatefulWidget {
  final String projectName;

  const PdfPreviewPage({super.key, required this.projectName});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  Map<String, dynamic> projectData = {};

  @override
  void initState() {
    super.initState();
    loadProject();
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    final settings = projectData["settings"] ?? {};

    final weeks = projectData["weeks"] ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) => [
          pw.Center(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "Daily Work Report - ",
                    style: pw.TextStyle(
                      color: PdfColors.blue,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  pw.TextSpan(
                    text: settings["title"] ?? "",
                    style: pw.TextStyle(
                      color: PdfColors.blue,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Divider(color: PdfColors.blue),

          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "Student Name\n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["studentName"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "Company Name\n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["companyName"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 5),

          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "Role \n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["internshipRole"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "Duration \n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["startDate"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: " - ",
                        style: const pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["endDate"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 5),

          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "College Name\n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["collegeName"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Expanded(
                flex: 2,
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      const pw.TextSpan(
                        text: "Guide Name\n",
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: settings["guideName"] ?? "",
                        style: const pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          pw.Divider(),

          pw.SizedBox(height: 5),

          pw.Text(
            "Daily Report",
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          ...weeks.expand((week) {
            final entries = week["entries"] ?? [];

            return [
              pw.Text(
                (week["title"] ?? "").toString().isNotEmpty
                    ? "Week ${week["week"]}  -  Task: ${week["title"]}"
                    : "Week ${week["week"]}",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.blue,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ...entries.map<pw.Widget>((entry) {
                return pw.Container(
                  width: double.infinity,
                  constraints: const pw.BoxConstraints(minHeight: 120),
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),

                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),

                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Day ${entry["day"]} | ${getWeekDay(entry["date"] ?? "")} , ${entry["date"] ?? "-"}",
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              "${entry["hours"] ?? "-"} hrs",
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 4),

                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: "Task: ",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                            pw.TextSpan(
                              text: entry["title"] ?? "-",
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 8),

                      pw.Text(
                        "Challenges",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),

                      pw.SizedBox(height: 2),

                      pw.Text(
                        (entry["challenges"] ?? "").toString().isEmpty
                            ? "-"
                            : entry["challenges"],
                        style: const pw.TextStyle(fontSize: 8),
                      ),

                      pw.SizedBox(height: 12),

                      pw.Text(
                        "Description",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),

                      pw.SizedBox(height: 2),

                      pw.Text(
                        (entry["description"] ?? "").toString().isEmpty
                            ? "-"
                            : entry["description"],
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                );
              }),

              pw.Text(
                "Week Summary : ",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.blue,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Text(
                week["weekSummary"] ?? "",
                style: pw.TextStyle(color: PdfColors.black, fontSize: 12),
              ),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.SizedBox(height: 20),
            ];
          }),
        ],
      ),
    );

    await savePdf(pdf);
  }

  String getWeekDay(String dateString) {
    try {
      final parts = dateString.split('-');

      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }

  Future<void> savePdf(pw.Document pdf) async {
    final docs = await getApplicationDocumentsDirectory();

    final exportDir = Directory('${docs.path}/DailyReportGenerator/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/${widget.projectName}_Report.pdf');

    await file.writeAsBytes(await pdf.save());

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF Saved:\n${file.path}')));
    }
  }

  Future<File> getProjectFile() async {
    final docs = await getApplicationDocumentsDirectory();

    return File(
      '${docs.path}/DailyReportGenerator/projects/${widget.projectName.replaceAll(" ", "_")}.json',
    );
  }

  Future<void> loadProject() async {
    final file = await getProjectFile();

    if (!await file.exists()) return;

    projectData = jsonDecode(await file.readAsString());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = projectData["settings"] ?? {};

    final weeks = projectData["weeks"] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),

      body: projectData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),

              child: Container(
                color: Colors.white,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Daily Work Report - ",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
                              ),
                            ),
                            TextSpan(
                              text: settings["title"] ?? "",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(thickness: 2, color: Colors.blue),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Student Name\n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["studentName"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Company Name\n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["companyName"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Role : \n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["internshipRole"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Duration : \n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["startDate"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: " - ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["endDate"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "College Name\n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["collegeName"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Guide Name\n",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 22,
                                  ),
                                ),
                                TextSpan(
                                  text: settings["guideName"] ?? "",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(thickness: 2),

                    const SizedBox(height: 20),

                    Text(
                      "Daily Report",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...weeks.map<Widget>((week) {
                      final entries = week["entries"] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (week["title"] ?? "").toString().isNotEmpty
                                ? "Week ${week["week"]}  -  Task: ${week["title"]}"
                                : "Week ${week["week"]}",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          ...entries.map<Widget>((entry) {
                            return Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 120),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: const Color.fromARGB(160, 160, 160, 160),
                                border: Border.all(
                                  color: Color.fromARGB(160, 160, 160, 160),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Day ${entry["day"]} | ${getWeekDay(entry["date"] ?? "")} , ${entry["date"] ?? "-"}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          //color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "${entry["hours"] ?? "-"} hrs",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 4),

                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Task: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 22,
                                          ),
                                        ),
                                        TextSpan(
                                          text: entry["title"] ?? "-",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    "Challenges",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),

                                  SizedBox(height: 2),

                                  Text(
                                    (entry["challenges"] ?? "")
                                            .toString()
                                            .isEmpty
                                        ? "-"
                                        : entry["challenges"],
                                    style: const TextStyle(fontSize: 22),
                                  ),

                                  SizedBox(height: 12),

                                  Text(
                                    "Description",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),

                                  SizedBox(height: 2),
                                  Text(
                                    (entry["description"] ?? "")
                                            .toString()
                                            .isEmpty
                                        ? "-"
                                        : entry["description"],
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ],
                              ),
                            );
                          }),

                          Text(
                            "Week Summary : ",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            week["weekSummary"] ?? "",
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),

                          SizedBox(height: 20),

                          Divider(),

                          SizedBox(height: 20),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await generatePdf();
        },

        icon: const Icon(Icons.save),

        label: const Text("Save PDF"),
      ),
    );
  }
}
