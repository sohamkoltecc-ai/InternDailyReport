import 'dart:convert';
import 'dart:io';

import 'package:dailyreport/pages/weekDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'pdfpreviewpage.dart';
import '../widget/modernfeild.dart';

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
    "startDate": "",
    "endDate": "",
    "guideName": "",
    "title": "",
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
      "settings": projectSettings,
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> addWeek() async {
    int weekNumber = weeks.length + 1;

    weeks.add({"week": weekNumber, "title": "",  "weekSummary": "", "entries": []});

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
    final guideController = TextEditingController(
      text: projectSettings["guideName"] ?? "",
    );
    final titleController = TextEditingController(
      text: projectSettings["title"] ?? "",
    );
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          child: SizedBox(
            width: 600,
            height: 600,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: Color(0xFF4F46E5),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Project Settings",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  modernField(
                    controller: companyController,
                    hint: "Company Name",
                    icon: Icons.business_rounded,
                  ),

                  const SizedBox(height: 20),
                  modernField(
                    controller: titleController,
                    hint: "Report Title",
                    icon: Icons.description_rounded,
                  ),

                  const SizedBox(height: 20),
                  modernField(
                    controller: studentController,
                    hint: "Student Name",
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 10),

                  modernField(
                    controller: collegeController,
                    hint: "College Name",
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(height: 10),

                  modernField(
                    controller: roleController,
                    hint: "Internship Role",
                    icon: Icons.work_rounded,
                  ),
                  const SizedBox(height: 10),

                  modernField(
                    controller: guideController,
                    hint: "Guide Name",
                    icon: Icons.supervisor_account_rounded,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: modernField(
                          controller: startDateController,
                          hint: "Start Date",
                          icon: Icons.calendar_today_rounded,
                          readOnly: true,
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
                        child: modernField(
                          controller: endDateController,
                          hint: "End Date",
                          icon: Icons.calendar_today_rounded,
                          readOnly: true,
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

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // save code
                        projectSettings = {
                          "companyName": companyController.text,

                          "studentName": studentController.text,

                          "collegeName": collegeController.text,

                          "internshipRole": roleController.text,

                          "startDate": startDateController.text,
                          "endDate": endDateController.text,
                          "guideName": guideController.text,
                          "title": titleController.text,
                        };

                        await saveSettings();

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
              ),
            ],
          ),
          child: weeks.isEmpty
              ? const Center(child: Text("No Weeks Created"))
              : ListView.builder(
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(15),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black,
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),

                        title: Text("Week ${weeks[index]["week"]}"),

                        subtitle: Text(
                          "${(weeks[index]["entries"] as List).length} Entries",
                        ),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 36,
                                ),

                                title: const Text(
                                  "Delete Week",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                content: SizedBox(
                                  width: 350,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              'Are you sure you want to delete ',
                                        ),
                                        TextSpan(
                                          text: 'Week ${weeks[index]["week"]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const TextSpan(text: '?'),
                                      ],
                                    ),
                                  ),
                                ),

                                actionsAlignment: MainAxisAlignment.center,

                                actions: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              await deleteWeek(index);
                            }
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
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addWeek,
        child: const Icon(Icons.add),
      ),
    );
  }
}
