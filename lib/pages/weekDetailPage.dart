import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class WeekDetailPage extends StatefulWidget {
  final String projectName;
  final int weekNumber;

  const WeekDetailPage({
    super.key,
    required this.projectName,
    required this.weekNumber,
  });

  @override
  State<WeekDetailPage> createState() => _WeekDetailPageState();
}

class _WeekDetailPageState extends State<WeekDetailPage> {
  List<Map<String, dynamic>> entries = [];
  String weekTitle = "";
  String weekSummary = "";

  @override
  void initState() {
    super.initState();
    loadWeekData();
  }

  Future<File> getProjectFile() async {
    final docs = await getApplicationDocumentsDirectory();

    final projectDir = Directory('${docs.path}/DailyReportGenerator/projects');

    return File(
      '${projectDir.path}/${widget.projectName.replaceAll(" ", "_")}.json',
    );
  }

  Future<void> loadWeekData() async {
    final file = await getProjectFile();

    if (!await file.exists()) return;

    final jsonData = jsonDecode(await file.readAsString());

    final weeks = List<Map<String, dynamic>>.from(jsonData["weeks"] ?? []);

    final week = weeks.firstWhere(
      (e) => e["week"] == widget.weekNumber,
      orElse: () => {},
    );
    weekTitle = week["title"] ?? "";
    weekSummary = week["weekSummary"] ?? "";

    entries = List<Map<String, dynamic>>.from(week["entries"] ?? []);

    setState(() {});
  }

  Future<void> saveWeekData() async {
    final file = await getProjectFile();

    final jsonData = jsonDecode(await file.readAsString());

    List<dynamic> weeks = jsonData["weeks"];

    int index = weeks.indexWhere((e) => e["week"] == widget.weekNumber);
    weeks[index]["title"] = weekTitle;
    weeks[index]["weekSummary"] = weekSummary;
    weeks[index]["entries"] = entries;

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonData),
    );

    print("Saved Week ${widget.weekNumber}");
  }

  void showEntryDialog({Map<String, dynamic>? entry, int? editIndex}) {
    final dateController = TextEditingController(text: entry?["date"] ?? "");

    final hoursController = TextEditingController(
      text: entry?["hours"]?.toString() ?? "",
    );

    final titleController = TextEditingController(text: entry?["title"] ?? "");

    final challengeController = TextEditingController(
      text: entry?["challenges"] ?? "",
    );

    final descriptionController = TextEditingController(
      text: entry?["description"] ?? "",
    );

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            width: 700,
            height: 600,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          editIndex == null
                              ? Icons.note_add
                              : Icons.edit_note_rounded,
                          color: const Color(0xFF4F46E5),
                          size: 28,
                        ),

                        const SizedBox(width: 12),

                        Text(
                          editIndex == null ? "Add Day Entry" : "Edit Entry",
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Date",
                      prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5),),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        dateController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}-"
                            "${pickedDate.month.toString().padLeft(2, '0')}-"
                            "${pickedDate.year}";
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Working Hours",
                      prefixIcon: const Icon(Icons.schedule_rounded, color: Color(0xFF4F46E5),),
                      suffixText: "hrs",
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Task Title",
                      prefixIcon: const Icon(Icons.task_alt_rounded, color: Color(0xFF4F46E5),),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: challengeController,
                    decoration: InputDecoration(
                      hintText: "Challenges Faced",
                      prefixIcon: const Icon(Icons.warning_amber_rounded, color: Color(0xFF4F46E5),),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: TextField(
                      controller: descriptionController,
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Describe today's work...",

                        prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF4F46E5),),

                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF4F46E5),
                            width: 1.5,
                          ),
                        ),

                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

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
                        if (editIndex == null) {
                          if (entries.length >= 7) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Maximum 7 days allowed"),
                              ),
                            );

                            return;
                          }

                          entries.add({
                            "day": entries.length + 1,

                            "date": dateController.text,

                            "hours": int.tryParse(hoursController.text) ?? 0,

                            "title": titleController.text,

                            "challenges": challengeController.text,

                            "description": descriptionController.text,
                          });
                        } else {
                          entries[editIndex] = {
                            "day": entries[editIndex]["day"],

                            "date": dateController.text,

                            "hours": int.tryParse(hoursController.text) ?? 0,

                            "title": titleController.text,

                            "challenges": challengeController.text,

                            "description": descriptionController.text,
                          };
                        }

                        await saveWeekData();

                        setState(() {});

                        Navigator.pop(context);
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

  Future<void> deleteEntry(int index) async {
    entries.removeAt(index);

    for (int i = 0; i < entries.length; i++) {
      entries[i]["day"] = i + 1;
    }

    await saveWeekData();

    setState(() {});
  }

  Future<void> editWeekTitle() async {
    TextEditingController titleController = TextEditingController(
      text: weekTitle,
    );

    TextEditingController summaryController = TextEditingController(
      text: weekSummary,
    );

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 550,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_view_week_rounded,
                        color: Color(0xFF4F46E5),
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "Week Details",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Week Title",
                      prefixIcon: const Icon(Icons.task_alt_rounded, color: Color(0xFF4F46E5),),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: summaryController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Week Summary",
                      prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF4F46E5),),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 1.5,
                        ),
                      ),

                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        weekTitle = titleController.text;
                        weekSummary = summaryController.text;

                        await saveWeekData();

                        setState(() {});

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        "Save Details",
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
        title: Text(
          weekTitle.trim().isEmpty
              ? "Week ${widget.weekNumber}"
              : "Week ${widget.weekNumber} - $weekTitle",
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: editWeekTitle),
        ],
      ),

      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final item = entries[index];

          return Card(
            margin: const EdgeInsets.all(15),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            shadowColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Day ${item["day"]}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text("Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item["date"]),

                  const SizedBox(height: 8),

                  Text(
                    "Hours: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${item["hours"]}"),

                  const SizedBox(height: 8),

                  Text(
                    "Title: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item["title"], style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 8),

                  Text(
                    "Challenges: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${item["challenges"]}"),

                  const SizedBox(height: 8),

                  Text(
                    "Description: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${item["description"]}"),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showEntryDialog(entry: item, editIndex: index);
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool? shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 36,
                                ),

                                title: const Text(
                                  "Delete Day",
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
                                          text: 'Day ${item["day"]}',
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
                                      Navigator.pop(dialogContext, false);
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
                                      Navigator.pop(dialogContext, true);
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true) {
                            await deleteEntry(index);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showEntryDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
