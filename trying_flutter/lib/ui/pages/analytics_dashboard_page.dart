// Keenan Prusse
// 2025
// Analytics Dashboard for curators

import 'package:flutter/material.dart';
import 'package:trying_flutter/data/analytics_dao.dart';
import 'package:trying_flutter/data/analytics.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  final AnalyticsDao analyticsDao;

  const AnalyticsDashboardPage({
    super.key,
    required this.analyticsDao,
  });

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedTab = 0;

  // Data
  List<DwellTimeStats> _dwellStats = [];
  List<PathSegment> _popularPaths = [];
  List<EntryExitPoint> _entryExitPoints = [];
  List<ExhibitPerformance> _exhibitPerformance = [];
  List<DailyStats> _dailyStats = [];
  List<RoomPopularity> _roomPopularity = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dwellStats = await widget.analyticsDao.getExhibitDwellStats(
        startDate: _startDate,
        endDate: _endDate,
      );

      final popularPaths = await widget.analyticsDao.getPopularPaths(
        startDate: _startDate,
        endDate: _endDate,
      );

      final entryExitPoints = await widget.analyticsDao.getEntryExitPoints(
        startDate: _startDate,
        endDate: _endDate,
      );

      final exhibitPerformance = await widget.analyticsDao.getExhibitPerformance(
        startDate: _startDate,
        endDate: _endDate,
      );

      final dailyStats = await widget.analyticsDao.getDailyStats(
        startDate: _startDate,
        endDate: _endDate,
      );

      final roomPopularity = await widget.analyticsDao.getRoomPopularity(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _dwellStats = dwellStats;
        _popularPaths = popularPaths;
        _entryExitPoints = entryExitPoints;
        _exhibitPerformance = exhibitPerformance;
        _dailyStats = dailyStats;
        _roomPopularity = roomPopularity;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final csv = await widget.analyticsDao.generateCsvExport(
        startDate: _startDate,
        endDate: _endDate,
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/analytics_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported to: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCsv,
            tooltip: 'Export to CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            )
          : Column(
              children: [
                // Date range display
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[900],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_startDate?.toLocal().toString().split(' ')[0] ?? 'All time'} - ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Now'}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  color: Colors.grey[850],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('Overview', 0),
                        _buildTab('Dwell Time', 1),
                        _buildTab('Visitor Flow', 2),
                        _buildTab('Performance', 3),
                        _buildTab('Rooms', 4),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.purple : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildDwellTimeTab();
      case 2:
        return _buildVisitorFlowTab();
      case 3:
        return _buildPerformanceTab();
      case 4:
        return _buildRoomsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab() {
    if (_dailyStats.isEmpty) {
      return const Center(
        child: Text(
          'No data available for this period',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final totalSessions = _dailyStats.fold<int>(0, (sum, stat) => sum + stat.totalSessions);
final totalScans = _dailyStats.fold<int>(0, (sum, stat) => sum + stat.totalScans);

int totalDurationSeconds = 0;
int totalSessionsWithDuration = 0;

for (final stat in _dailyStats) {
  totalDurationSeconds += stat.averageVisitDuration.inSeconds * stat.totalSessions;
  totalSessionsWithDuration += stat.totalSessions;
}

final avgDuration = totalSessionsWithDuration > 0
    ? Duration(seconds: totalDurationSeconds ~/ totalSessionsWithDuration)
    : Duration.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Metric cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Sessions',
                totalSessions.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Scans',
                totalScans.toString(),
                Icons.qr_code_scanner,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Avg Visit Duration',
                '${avgDuration.inMinutes} min',
                Icons.timer,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Active Days',
                _dailyStats.length.toString(),
                Icons.calendar_today,
                Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Top performing exhibits
        const Text(
          'Top Performing Exhibits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ..._exhibitPerformance
            .where((e) => e.performanceCategory == 'high-engagement')
            .take(5)
            .map((exhibit) => _buildExhibitCard(exhibit)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDwellTimeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exhibit Dwell Times',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How long visitors spend at each exhibit',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 24),

        ..._dwellStats.map((stat) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stat.exhibitTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${stat.totalVisits} visits',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem(
                        'Median',
                        '${stat.medianDwell.inMinutes}m ${stat.medianDwell.inSeconds % 60}s',
                        Icons.timer,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        'Average',
                        '${stat.averageDwell.inMinutes}m ${stat.averageDwell.inSeconds % 60}s',
                        Icons.access_time,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        'Rating',
                        stat.averageRating.toStringAsFixed(1),
                        Icons.star,
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildVisitorFlowTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Entry/Exit Points
        const Text(
          'Entry & Exit Points',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ..._entryExitPoints.map((point) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[800]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      point.roomName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.login, color: Colors.green[400], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${point.entryCount}',
                        style: TextStyle(color: Colors.green[400], fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.logout, color: Colors.red[400], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${point.exitCount}',
                        style: TextStyle(color: Colors.red[400], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            )),

        const SizedBox(height: 32),

        // Popular Paths
        const Text(
          'Popular Visitor Paths',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ..._popularPaths.take(10).map((path) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[800]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          path.fromRoomName,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          path.toRoomName,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${path.transitionCount}x',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    // Group by category
    final highEngagement = _exhibitPerformance
        .where((e) => e.performanceCategory == 'high-engagement')
        .toList();
    final confusing = _exhibitPerformance
        .where((e) => e.performanceCategory == 'confusing')
        .toList();
    final lowEngagement = _exhibitPerformance
        .where((e) => e.performanceCategory == 'low-engagement')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exhibit Performance Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Exhibits categorized by engagement patterns',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 24),

        // High Engagement
        if (highEngagement.isNotEmpty) ...[
          _buildCategoryHeader('High Engagement', Colors.green, Icons.trending_up),
          const SizedBox(height: 12),
          ...highEngagement.map((e) => _buildExhibitCard(e)),
          const SizedBox(height: 24),
        ],

        // Confusing (needs attention)
        if (confusing.isNotEmpty) ...[
          _buildCategoryHeader('Needs Attention', Colors.orange, Icons.warning),
          const SizedBox(height: 12),
          ...confusing.map((e) => _buildExhibitCard(e)),
          const SizedBox(height: 24),
        ],

        // Low Engagement
        if (lowEngagement.isNotEmpty) ...[
          _buildCategoryHeader('Low Engagement', Colors.red, Icons.trending_down),
          const SizedBox(height: 12),
          ...lowEngagement.map((e) => _buildExhibitCard(e)),
        ],
      ],
    );
  }

  Widget _buildRoomsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Popularity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ..._roomPopularity.map((room) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.roomName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${room.visitCount} visits',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem(
                        'Avg Dwell',
                        '${room.averageDwell.inMinutes}m',
                        Icons.timer,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        'Exhibits',
                        '${room.exhibitCount}',
                        Icons.museum,
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExhibitCard(ExhibitPerformance exhibit) {
    Color categoryColor;
    switch (exhibit.performanceCategory) {
      case 'high-engagement':
        categoryColor = Colors.green;
        break;
      case 'confusing':
        categoryColor = Colors.orange;
        break;
      case 'low-engagement':
        categoryColor = Colors.red;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exhibit.exhibitTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor),
                ),
                child: Text(
                  exhibit.performanceCategory,
                  style: TextStyle(color: categoryColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                'Dwell',
                '${exhibit.medianDwell.inMinutes}m',
                Icons.timer,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                'Rating',
                exhibit.averageRating.toStringAsFixed(1),
                Icons.star,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                'Visits',
                '${exhibit.totalVisits}',
                Icons.people,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple[300], size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
