import 'package:empower_ananya/main.dart'; // Import for GlassCard
import 'package:empower_ananya/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricsTab extends StatefulWidget {
  const MetricsTab({super.key});

  @override
  State<MetricsTab> createState() => _MetricsTabState();
}

class _MetricsTabState extends State<MetricsTab> {
  final FirestoreService _firestoreService = FirestoreService();
  String _enrollmentFilter = 'All';
  int _touchedPieIndex = -1;

  final List<Color> _chartColors = [
    const Color(0xFF65C7F7),
    const Color(0xFF0052D4),
    const Color(0xFF4364F7),
    const Color(0xFFB41991),
    const Color(0xFFF953C6),
    const Color(0xFF8E2DE2),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Text(
          'Foundation Dashboard',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Scholar Distribution by State', context),
        _buildStateDistributionChart(),
        const SizedBox(height: 24),
        _buildSectionTitle('Top 5 Course Performance', context),
        _buildPerformanceChart(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Enrollment Details', context),
            _buildFilterDropdown(),
          ],
        ),
        _buildEnrollmentList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600, color: Colors.white.withAlpha(230)),
      ),
    );
  }

  Widget _buildStateDistributionChart() {
    return SizedBox(
      height: 250,
      child: GlassCard(
        child: StreamBuilder<Map<String, int>>(
          stream: _firestoreService.getScholarsByState(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final stateData = snapshot.data!;
            final pieChartSections =
                stateData.entries.toList().asMap().entries.map((entry) {
              final isTouched = entry.key == _touchedPieIndex;
              final radius = isTouched ? 70.0 : 60.0;
              final color = _chartColors[entry.key % _chartColors.length];
              return PieChartSectionData(
                color: color,
                value: entry.value.value.toDouble(),
                title: '${entry.value.value}',
                radius: radius,
                titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              );
            }).toList();

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (event is FlPointerHoverEvent &&
                                pieTouchResponse?.touchedSection != null) {
                              _touchedPieIndex = pieTouchResponse!
                                  .touchedSection!.touchedSectionIndex;
                            } else {
                              _touchedPieIndex = -1;
                            }
                          });
                        },
                      ),
                      sections: pieChartSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                _buildLegend(stateData),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> data) {
    return Expanded(
      flex: 1,
      child: ListView(
        shrinkWrap: true,
        children: data.entries.toList().asMap().entries.map((entry) {
          final color = _chartColors[entry.key % _chartColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(width: 16, height: 16, color: color),
                const SizedBox(width: 8),
                Text(entry.value.key),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return SizedBox(
      height: 250,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: StreamBuilder<List<ScholarPerformance>>(
            stream: _firestoreService.getOverallPerformance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final performanceData = snapshot.data!;
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${performanceData[group.x].courseName}\n',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${rod.toY.toStringAsFixed(0)}% Completion',
                              style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => _bottomTitles(
                                value,
                                meta,
                                performanceData
                                    .map((p) => p.courseName)
                                    .toList()),
                            reservedSize: 40)),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) =>
                                Text('${value.toInt()}%'))),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: performanceData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                            toY: entry.value.completionRate * 100,
                            color: _chartColors[0],
                            width: 22,
                            borderRadius: BorderRadius.circular(6))
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _enrollmentFilter,
          dropdownColor: const Color(0xFF0D1117),
          items: ['All', 'Course', 'Internship'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _enrollmentFilter = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEnrollmentList() {
    return StreamBuilder<List<CourseEnrollmentStats>>(
      stream: _firestoreService.getCourseEnrollmentStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final filteredData = snapshot.data!.where((course) {
          if (_enrollmentFilter == 'All') {
            return true;
          }
          return course.type == _enrollmentFilter;
        }).toList();

        if (filteredData.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No programs match the filter.")));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final course = filteredData[index];
            final performingPercentage = (course.enrolled > 0)
                ? (course.performing / course.enrolled)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.courseName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${course.enrolled} Enrolled'),
                          Text('${course.notEnrolled} Not Enrolled'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: performingPercentage,
                                minHeight: 12,
                                backgroundColor: Colors.white.withAlpha(51),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _chartColors[2]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              '${(performingPercentage * 100).toStringAsFixed(0)}% Enrolled'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta, List<String> titles) {
    final int index = value.toInt();
    if (index >= titles.length) {
      return const Text('');
    }
    final String text = titles[index];
    final String shortText =
        (text.length > 15) ? '${text.substring(0, 12)}...' : text;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Transform.rotate(
        angle: -0.5,
        child: Text(shortText, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
