import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  // --- STREAK SYSTEM STATE ENGINE ---
  int _currentStreak = 0;
  DateTime? _lastAttendanceDate;
  bool _isAttendanceMarkedToday = false;

  // --- LIVE INTERACTIVE METRICS ---
  int _totalProjects = 0;
  int _totalHours = 0;
  int _totalTasks = 0;
  
  // Chart & Timeline Data
  List<Map<String, dynamic>> _projectChartData = []; 
  List<Map<String, dynamic>> _recentActivityTimeline = []; 

  // Hardcoded goal for the new Productivity Feature
  final int _weeklyHoursGoal = 40; 

  @override
  void initState() {
    super.initState();
    _refreshDashboardWorkspace();
  }

  Future<void> _refreshDashboardWorkspace() async {
    await _loadStreakSystemData();
    await _compileProjectFileSystemStatistics();
  }

  // --- PERSISTENT STREAK ENGINE ---
  Future<File> _getStreakConfigurationFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final systemFolder = Directory('${directory.path}/DailyReportGenerator/system');
    if (!await systemFolder.exists()) {
      await systemFolder.create(recursive: true);
    }
    return File('${systemFolder.path}/streak.json');
  }

  Future<void> _loadStreakSystemData() async {
    try {
      final file = await _getStreakConfigurationFile();
      if (!await file.exists()) {
        _verifyStreakTimelineConsistency();
        return;
      }
      final rawData = jsonDecode(await file.readAsString());
      _currentStreak = rawData['currentStreak'] ?? 0;
      if (rawData['lastAttendanceDate'] != null) {
        _lastAttendanceDate = DateTime.parse(rawData['lastAttendanceDate']);
      }
      _verifyStreakTimelineConsistency();
    } catch (e) {
      debugPrint("Error parsing streak tracking: $e");
    }
  }

  void _verifyStreakTimelineConsistency() {
    if (_lastAttendanceDate != null) {
      final rightNow = DateTime.now();
      final atomicToday = DateTime(rightNow.year, rightNow.month, rightNow.day);
      final atomicLastLogged = DateTime(_lastAttendanceDate!.year, _lastAttendanceDate!.month, _lastAttendanceDate!.day);
      final daysDelta = atomicToday.difference(atomicLastLogged).inDays;

      if (daysDelta == 0) {
        setState(() => _isAttendanceMarkedToday = true);
      } else if (daysDelta > 1) {
        setState(() => _currentStreak = 0); 
        _saveStreakSystemData();
      } else {
        setState(() => _isAttendanceMarkedToday = false);
      }
    } else {
      setState(() => _currentStreak = 0);
    }
  }

  Future<void> _saveStreakSystemData() async {
    final file = await _getStreakConfigurationFile();
    final schema = {
      'currentStreak': _currentStreak,
      'lastAttendanceDate': _lastAttendanceDate?.toIso8601String(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(schema));
  }

  void _processDailyAttendanceLog() async {
    if (_isAttendanceMarkedToday) return;

    setState(() {
      _currentStreak++;
      _lastAttendanceDate = DateTime.now();
      _isAttendanceMarkedToday = true;
    });

    await _saveStreakSystemData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance registered! Streak advanced. ⚡'),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper to parse DD-MM-YYYY to real DateTime for sorting timeline
  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      // ignore
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // --- DYNAMIC DEEP DATA EXTRACTION ---
  Future<void> _compileProjectFileSystemStatistics() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetsDirectory = Directory('${docsDir.path}/DailyReportGenerator/projects');

    if (!await targetsDirectory.exists()) return;

    int computedProjectsCount = 0;
    int computedAggregateHours = 0;
    int computedTasksCount = 0;
    
    List<Map<String, dynamic>> chartBuffer = [];
    List<Map<String, dynamic>> timelineBuffer = [];

    final systemFilesList = targetsDirectory.listSync();

    for (var entity in systemFilesList) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          computedProjectsCount++;
          final fileContent = jsonDecode(await entity.readAsString());
          final String currentProjName = fileContent['projectName'] ?? 'Unnamed Asset';
          int contextualProjectHours = 0;

          if (fileContent['weeks'] != null) {
            final arrayWeeks = List<dynamic>.from(fileContent['weeks']);
            for (var weekObject in arrayWeeks) {
              if (weekObject['entries'] != null) {
                final entryRecords = List<dynamic>.from(weekObject['entries']);
                computedTasksCount += entryRecords.length;
                
                for (var individualEntry in entryRecords) {
                  int entryHoursParsed = individualEntry['hours'] ?? 0;
                  computedAggregateHours += entryHoursParsed;
                  contextualProjectHours += entryHoursParsed;

                  // Extract deep task data for the new timeline feature
                  timelineBuffer.add({
                    'projectName': currentProjName,
                    'taskTitle': individualEntry['title'] ?? 'Untitled Task',
                    'dateStr': individualEntry['date'] ?? 'No Date',
                    'dateObj': _parseDate(individualEntry['date'] ?? ''),
                    'hours': entryHoursParsed,
                  });
                }
              }
            }
          }

          if (contextualProjectHours > 0) {
            chartBuffer.add({
              'label': currentProjName,
              'value': contextualProjectHours.toDouble(),
            });
          }
        } catch (error) {
          debugPrint("Skipping corrupted node: $error");
        }
      }
    }

    // Sort timeline by newest date first
    timelineBuffer.sort((a, b) => (b['dateObj'] as DateTime).compareTo(a['dateObj'] as DateTime));

    if (mounted) {
      setState(() {
        _totalProjects = computedProjectsCount;
        _totalHours = computedAggregateHours;
        _totalTasks = computedTasksCount;
        _projectChartData = chartBuffer;
        _recentActivityTimeline = timelineBuffer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER ROW SYSTEM
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1), 
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isAttendanceMarkedToday ? null : _processDailyAttendanceLog,
                    icon: Icon(
                      _isAttendanceMarkedToday ? Icons.task_alt_rounded : Icons.offline_bolt_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _isAttendanceMarkedToday ? 'Attendance Logged' : 'Mark Attendance',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAttendanceMarkedToday ? const Color(0xFFE3F2FD) : const Color(0xFF0D47A1),
                      foregroundColor: _isAttendanceMarkedToday ? const Color(0xFF0D47A1) : Colors.white,
                      disabledBackgroundColor: const Color(0xFFE3F2FD),
                      disabledForegroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // 2. PERFORMANCE STATS GRID
              Row(
                children: [
                  _buildAnalyticalCard('Current Streak', '$_currentStreak Days', Icons.bolt_rounded, const Color(0xFF0D47A1)),
                  const SizedBox(width: 20),
                  _buildAnalyticalCard('Total Hours', '$_totalHours Hrs', Icons.hourglass_empty_rounded, const Color(0xFF0D47A1)),
                  const SizedBox(width: 20),
                  _buildAnalyticalCard('Tasks Completed', '$_totalTasks', Icons.assignment_turned_in_rounded, const Color(0xFF0D47A1)),
                  const SizedBox(width: 20),
                  _buildAnalyticalCard('Total Projects', '$_totalProjects', Icons.grid_view_rounded, const Color(0xFF0D47A1)),
                ],
              ),
              const SizedBox(height: 36),

              // 3. NEW FEATURE: ADVANCED ANALYTICS ROW (Circular Graph + Progress)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Circular Donut Graph
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0D47A1).withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hours Distribution',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                          ),
                          const SizedBox(height: 32),
                          _projectChartData.isEmpty 
                            ? const SizedBox(
                                height: 200, 
                                child: Center(child: Text("No data to visualize.", style: TextStyle(color: Colors.grey)))
                              )
                            : Row(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: 180,
                                    child: CustomPaint(
                                      painter: _DonutChartPainter(
                                        dataset: _projectChartData,
                                        totalValue: _totalHours.toDouble(),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$_totalHours',
                                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                            ),
                                            const Text(
                                              'Total Hrs',
                                              style: TextStyle(fontSize: 12, color: Color(0xFF78909C), fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  // Graph Legend
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: List.generate(_projectChartData.length, (index) {
                                        final data = _projectChartData[index];
                                        final colors = [const Color(0xFF0D47A1), const Color(0xFF1976D2), const Color(0xFF42A5F5), const Color(0xFF90CAF9), const Color(0xFFB3E5FC)];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12, height: 12,
                                                decoration: BoxDecoration(color: colors[index % colors.length], shape: BoxShape.circle),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  data['label'],
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 14, color: Color(0xFF546E7A), fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              Text(
                                                "${data['value'].toInt()}h",
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Right Side: Productivity Goal Feature
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 280, // Match visual height roughly
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1), // Deep Blue Card
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0D47A1).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 32),
                          const Spacer(),
                          const Text(
                            'Productivity Goal',
                            style: TextStyle(fontSize: 18, color: Color(0xFF90CAF9), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$_totalHours',
                                style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold, height: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                                child: Text(
                                  '/ $_weeklyHoursGoal Hrs',
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF90CAF9), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Linear Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_totalHours / _weeklyHoursGoal).clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _totalHours >= _weeklyHoursGoal ? "Goal Achieved! Amazing work. 🎉" : "Keep logging to reach your milestone.",
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // 4. NEW FEATURE: DEEP TASK TIMELINE
              const Text(
                'Recent Activity Timeline',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 16),

              _recentActivityTimeline.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3F2FD)),
                      ),
                      child: const Center(
                        child: Text(
                          "No task entries found. Open a project and add entries to see them here.",
                          style: TextStyle(color: Color(0xFF78909C), fontSize: 14),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(_recentActivityTimeline.length, 6), // Show top 6 latest tasks
                      itemBuilder: (context, index) {
                        final task = _recentActivityTimeline[index];
                        return _buildTimelineRow(
                          task['taskTitle'], 
                          task['projectName'], 
                          task['dateStr'], 
                          task['hours']
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Card UI Factory
  Widget _buildAnalyticalCard(String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF78909C), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Detailed Timeline Row UI Factory
  Widget _buildTimelineRow(String title, String project, String date, int hours) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3F2FD), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFFF0F8FF), shape: BoxShape.circle),
          child: const Icon(Icons.commit_rounded, color: Color(0xFF1976D2), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(project, style: const TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
              const Text("  •  ", style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(date, style: const TextStyle(fontSize: 13, color: Color(0xFF78909C))),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
          child: Text(
            "+$hours Hrs", 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), fontSize: 13)
          ),
        ),
      ),
    );
  }
}

// --- NATIVE FLUTTER DONUT CHART ENGINE ---
class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> dataset;
  final double totalValue;

  _DonutChartPainter({required this.dataset, required this.totalValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (totalValue == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    
    // Strict White/Blue progression palette
    final colors = [
      const Color(0xFF0D47A1), 
      const Color(0xFF1976D2), 
      const Color(0xFF42A5F5), 
      const Color(0xFF90CAF9), 
      const Color(0xFFB3E5FC)
    ];

    double startAngle = -pi / 2; // Start at 12 o'clock

    for (int i = 0; i < dataset.length; i++) {
      final sweepAngle = (dataset[i]['value'] / totalValue) * 2 * pi;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round; // Rounded edges for a modern look

      // Draw standard arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05, // Slight gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}