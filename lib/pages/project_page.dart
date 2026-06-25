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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        color: Color(0xFF4F46E5),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "New Project",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Project Name",
                      prefixIcon: const Icon(
                        Icons.drive_file_rename_outline_rounded,
                        color: Color(0xFF4F46E5),
                      ),
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

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            String projectName = controller.text.trim();

                            if (projectName.isEmpty) {
                              return;
                            }

                            if (projects.contains(projectName)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Project already exists"),
                                ),
                              );
                              return;
                            }

                            await createProjectFile(projectName);
                            await loadProjects();

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            "Create Project",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(25),
                child: Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Container(
                constraints: const BoxConstraints(minHeight: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE3F2FD),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: projects.isEmpty
                    ? const Center(child: Text("No Projects Found"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length,
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
                              title: Text(projects[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      bool?
                                      shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.red,
                                            size: 36,
                                          ),

                                          title: const Text(
                                            "Delete Project",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                                    text:
                                                        '"${projects[index]}"',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const TextSpan(text: '?'),
                                                ],
                                              ),
                                            ),
                                          ),

                                          actionsAlignment:
                                              MainAxisAlignment.center,

                                          actions: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              label: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldDelete == true) {
                                        await deleteProject(projects[index]);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailPage(
                                      projectName: projects[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Directory> getProjectsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();

    final projectDir = Directory(
      '${docsDir.path}/DailyReportGenerator/projects',
    );

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
}
