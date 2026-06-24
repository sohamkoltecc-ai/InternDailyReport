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

    entries = List<Map<String, dynamic>>.from(week["entries"] ?? []);

    setState(() {});
  }

  Future<void> saveWeekData() async {
    final file = await getProjectFile();

    final jsonData = jsonDecode(await file.readAsString());

    List<dynamic> weeks = jsonData["weeks"];

    int index = weeks.indexWhere((e) => e["week"] == widget.weekNumber);

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
                children: [
                  Text(
                    editIndex == null ? "Add Day Entry" : "Edit Entry",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Date",
                      suffixIcon: Icon(Icons.calendar_month),
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
                    decoration: const InputDecoration(
                      labelText: "Working Hours",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: challengeController,
                    decoration: const InputDecoration(labelText: "Challenges"),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: TextField(
                      controller: descriptionController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
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

  Future<void> deleteEntry(int index) async {
    entries.removeAt(index);

    for (int i = 0; i < entries.length; i++) {
      entries[i]["day"] = i + 1;
    }

    await saveWeekData();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Week ${widget.weekNumber}")),

      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final item = entries[index];

          return Card(
            margin: const EdgeInsets.all(10),
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

                  Text("Date: ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(item["date"]),

                  const SizedBox(height: 8),

                  Text("Hours: ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("${item["hours"]}"),

                  const SizedBox(height: 8),

                  Text("Title: ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(item["title"], style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 8),

                  Text("Challenges: ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("${item["challenges"]}"),

                  const SizedBox(height: 8),

                  Text("Description: ", style: TextStyle(fontWeight: FontWeight.bold),),
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
                          await deleteEntry(index);
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
