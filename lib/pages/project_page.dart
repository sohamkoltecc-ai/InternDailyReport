import 'package:flutter/material.dart';
import 'projects_details_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<String> projects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  void addProject() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("New Project"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Project Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String projectName = controller.text.trim();

                if (projectName.isEmpty) {
                  return;
                }

                if (projects.contains(projectName)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project already exists")),
                  );
                  return;
                }

                await createProjectFile(projectName);

                await loadProjects();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProject(String projectName) async {
    final dir = await getProjectsDirectory();

    final fileName = projectName.replaceAll(' ', '_');

    final file = File('${dir.path}/$fileName.json');

    if (await file.exists()) {
      await file.delete();
    }

    await loadProjects();
  }

  Future<void> loadProjects() async {
    final dir = await getProjectsDirectory();

    final files = dir.listSync();

    projects.clear();

    for (var file in files) {
      if (file is File && file.path.endsWith(".json")) {
        String name = file.path
            .split(Platform.pathSeparator)
            .last
            .replaceAll(".json", "")
            .replaceAll("_", " ");

        projects.add(name);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: projects.isEmpty
          ? const Center(child: Text("No Projects Found"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),

                  child: ListTile(
                    title: Text(projects[index]),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Project"),
                                content: Text("Delete ${projects[index]} ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete == true) {
                              await deleteProject(projects[index]);
                            }
                          },
                        ),

                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProjectDetailPage(projectName: projects[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<Directory> getProjectsDirectory() async {
  final docsDir = await getApplicationDocumentsDirectory();

  final projectDir = Directory('${docsDir.path}/DailyReportGenerator/projects');

  if (!await projectDir.exists()) {
    await projectDir.create(recursive: true);
  }

  return projectDir;
}

Future<void> createProjectFile(String projectName) async {
  final dir = await getProjectsDirectory();

  final fileName = projectName.replaceAll(" ", "_");

  final file = File('${dir.path}/$fileName.json');

  final data = {"projectName": projectName, "entries": []};

  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

  print("Project Created: ${file.path}");
}
