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
            child: pw.Text(
              settings["companyName"] ?? "",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text("Student Name : ${settings["studentName"] ?? ""}"),

          pw.Text("College Name : ${settings["collegeName"] ?? ""}"),

          pw.Text("Role : ${settings["internshipRole"] ?? ""}"),

          pw.Text("Duration : ${settings["reportDuration"] ?? ""}"),

          pw.Text(
            "Duration : ${settings["startDate"]} to ${settings["endDate"]}",
          ),

          pw.SizedBox(height: 10),

          pw.Divider(),

          pw.SizedBox(height: 10),

          pw.Text(
            widget.projectName,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 20),

          ...weeks.expand((week) {
            final entries = week["entries"] ?? [];

            return [
              pw.Text(
                "Week ${week["week"]}",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ...entries.map<pw.Widget>((entry) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),

                  padding: const pw.EdgeInsets.all(10),

                  decoration: pw.BoxDecoration(border: pw.Border.all()),

                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text(
                        "Day ${entry["day"]}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text("Date : ${entry["date"]}"),

                      pw.Text("Hours : ${entry["hours"]}"),

                      pw.SizedBox(height: 5),

                      pw.Text(
                        entry["title"],
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),

                      pw.SizedBox(height: 5),

                      pw.Text("Challenges"),

                      pw.Text(entry["challenges"]),

                      pw.SizedBox(height: 5),

                      pw.Text("Description"),

                      pw.Text(entry["description"]),
                    ],
                  ),
                );
              }),
            ];
          }),
        ],
      ),
    );

    await savePdf(pdf);
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
                    // Header
                    Center(
                      child: Text(
                        settings["companyName"] ?? "",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text("Student Name : ${settings["studentName"] ?? ""}"),

                    Text("College Name : ${settings["collegeName"] ?? ""}"),

                    Text("Role : ${settings["internshipRole"] ?? ""}"),

                    Text(
                      "Duration : ${settings["startDate"]} to ${settings["endDate"]}",
                    ),

                    const SizedBox(height: 20),

                    const Divider(thickness: 2),

                    const SizedBox(height: 20),

                    Text(
                      widget.projectName,
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
                            "Week ${week["week"]}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ...entries.map<Widget>((entry) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Day ${entry["day"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text("Date: ${entry["date"]}"),

                                    Text("Hours: ${entry["hours"]}"),

                                    const SizedBox(height: 8),

                                    Text(
                                      entry["title"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text("Challenges"),

                                    Text(entry["challenges"]),

                                    const SizedBox(height: 5),

                                    Text("Description"),

                                    Text(entry["description"]),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
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
