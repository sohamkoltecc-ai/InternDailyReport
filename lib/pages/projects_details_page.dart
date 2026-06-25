import 'dart:convert';
import 'dart:io';

import 'package:dailyreport/pages/weekDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'pdfpreviewpage.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectName;

  const ProjectDetailPage({super.key, required this.projectName});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<Map<String, dynamic>> weeks = [];
  Map<String, dynamic> projectSettings = {
    "companyName": "",
    "studentName": "",
    "collegeName": "",
    "internshipRole": "",
    "reportDuration": "",
  };

  @override
  void initState() {
    super.initState();
    loadProject();
  }

  Future<File> getProjectFile() async {
    final docs = await getApplicationDocumentsDirectory();

    final projectDir = Directory('${docs.path}/DailyReportGenerator/projects');

    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    final fileName = widget.projectName.replaceAll(' ', '_');

    return File('${projectDir.path}/$fileName.json');
  }

  Future<void> loadProject() async {
    final file = await getProjectFile();

    if (!await file.exists()) {
      return;
    }

    final jsonData = jsonDecode(await file.readAsString());

    if (jsonData["weeks"] != null) {
      weeks = List<Map<String, dynamic>>.from(jsonData["weeks"]);
    }
    if (jsonData["settings"] != null) {
      projectSettings = Map<String, dynamic>.from(jsonData["settings"]);
    }

    setState(() {});
  }

  Future<void> saveSettings() async {
    final file = await getProjectFile();

    if (!await file.exists()) {
      return;
    }

    final jsonData = jsonDecode(await file.readAsString());

    jsonData["settings"] = projectSettings;

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonData),
    );

    print("saved setting");
  }

  Future<void> saveProject() async {
    final file = await getProjectFile();

    Map<String, dynamic> data = {
      "projectName": widget.projectName,
      "weeks": weeks,
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> addWeek() async {
    int weekNumber = weeks.length + 1;

    weeks.add({"week": weekNumber, "entries": []});

    await saveProject();

    setState(() {});
  }

  Future<void> deleteWeek(int index) async {
    weeks.removeAt(index);

    for (int i = 0; i < weeks.length; i++) {
      weeks[i]["week"] = i + 1;
    }

    await saveProject();

    setState(() {});
  }

  void showSettingsDialog() {
    final companyController = TextEditingController(
      text: projectSettings["companyName"],
    );

    final studentController = TextEditingController(
      text: projectSettings["studentName"],
    );

    final collegeController = TextEditingController(
      text: projectSettings["collegeName"],
    );

    final roleController = TextEditingController(
      text: projectSettings["internshipRole"],
    );

    final startDateController = TextEditingController(
      text: projectSettings["startDate"] ?? "",
    );

    final endDateController = TextEditingController(
      text: projectSettings["endDate"] ?? "",
    );

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            width: 600,
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Project Settings",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: companyController,
                    decoration: const InputDecoration(
                      labelText: "Company Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: studentController,
                    decoration: const InputDecoration(
                      labelText: "Student Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: collegeController,
                    decoration: const InputDecoration(
                      labelText: "College Name",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: "Internship Role",
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Start Date",
                            suffixIcon: Icon(Icons.calendar_month),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              startDateController.text =
                                  "${picked.day.toString().padLeft(2, '0')}-"
                                  "${picked.month.toString().padLeft(2, '0')}-"
                                  "${picked.year}";
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextField(
                          controller: endDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "End Date",
                            suffixIcon: Icon(Icons.calendar_month),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              endDateController.text =
                                  "${picked.day.toString().padLeft(2, '0')}-"
                                  "${picked.month.toString().padLeft(2, '0')}-"
                                  "${picked.year}";
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () async {
                      projectSettings = {
                        "companyName": companyController.text,

                        "studentName": studentController.text,

                        "collegeName": collegeController.text,

                        "internshipRole": roleController.text,

                        "startDate": startDateController.text,
                        "endDate": endDateController.text,
                      };

                      await saveSettings();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.projectName} Project"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PdfPreviewPage(projectName: widget.projectName),
                ),
              );
            },
          ),
        ],
      ),

      body: weeks.isEmpty
          ? const Center(child: Text("No Weeks Created"))
          : ListView.builder(
              itemCount: weeks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),

                    title: Text("Week ${weeks[index]["week"]}"),

                    subtitle: Text(
                      "${(weeks[index]["entries"] as List).length} Entries",
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await deleteWeek(index);
                      },
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeekDetailPage(
                            projectName: widget.projectName,
                            weekNumber: weeks[index]["week"],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: addWeek,
        child: const Icon(Icons.add),
      ),
    );
  }
}
