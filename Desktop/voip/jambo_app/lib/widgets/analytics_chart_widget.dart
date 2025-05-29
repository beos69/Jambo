import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsChartWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String type; // 'pie', 'bar', ou 'line'

  const AnalyticsChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case 'pie':
        return _buildPieChart();
      case 'bar':
        return _buildBarChart();
      case 'line':
        return _buildLineChart();
      default:
        return const Center(child: Text('Type de graphique non supporté'));
    }
  }

  Widget _buildPieChart() {
    final List<PieChartSectionData> sections = [];
    int index = 0;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          title: '$key\n${value.toString()}',
          color: colors[index % colors.length],
          radius: 50,
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    // Implémentation du graphique en barres
    return BarChart(
      BarChartData(
          // Configuration du graphique en barres
          ),
    );
  }

  Widget _buildLineChart() {
    // Implémentation du graphique en ligne
    return LineChart(
      LineChartData(
          // Configuration du graphique en ligne
          ),
    );
  }
}
