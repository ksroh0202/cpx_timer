import 'package:flutter/material.dart';

import '../core/constants/exam_options.dart';
import '../models/practice_record.dart';
import '../services/practice_statistics_service.dart';
import '../utils/formatters.dart';
import '../widgets/home/glass_card.dart';
import '../widgets/home/stats_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.records,
  });

  final List<PracticeRecord> records;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatisticsRange _selectedRange = StatisticsRange.all;
  String _selectedSubject = statisticsAllLabel;
  String _selectedTopic = statisticsAllLabel;
  int? _selectedTrendIndex;

  @override
  Widget build(BuildContext context) {
    final filteredRecords = PracticeStatisticsService.filterRecords(
      widget.records,
      StatisticsFilter(
        range: _selectedRange,
        subject: _selectedSubject,
        topic: _selectedSubject == statisticsAllLabel ? null : _selectedTopic,
      ),
    );
    final summary = PracticeStatisticsService.summarize(filteredRecords);
    final trendChartData = PracticeStatisticsService.buildTrendChartData(
      filteredRecords,
    );
    final topics = _selectedSubject == statisticsAllLabel
        ? const <String>[statisticsAllLabel]
        : [statisticsAllLabel, ...topicsForSubject(_selectedSubject)];
    final timeManagementTitle = _buildTimeManagementTitle();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SizedBox(
                height: constraints.maxHeight - 14,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '\uD1B5\uACC4',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F3A44),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FilterSection(
                        selectedRange: _selectedRange,
                        selectedSubject: _selectedSubject,
                        selectedTopic: _selectedTopic,
                        topics: topics,
                        onRangeChanged: (range) {
                          setState(() {
                            _selectedRange = range;
                            _selectedTrendIndex = null;
                          });
                        },
                        onSubjectChanged: (subject) {
                          setState(() {
                            _selectedSubject = subject;
                            _selectedTopic = statisticsAllLabel;
                            _selectedTrendIndex = null;
                          });
                        },
                        onTopicChanged: (topic) {
                          setState(() {
                            _selectedTopic = topic;
                            _selectedTrendIndex = null;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: filteredRecords.isEmpty
                            ? const _EmptyStatistics()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _SectionCard(
                                      title: timeManagementTitle,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _MetricCard(
                                                  label:
                                                      '\uD3C9\uADE0 \uC885\uB8CC \uC2DC\uC810',
                                                  value: formatSeconds(
                                                    summary.averageEndSec,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _MetricCard(
                                                  label:
                                                      '\uCDE8\uC57D \uACFC\uBAA9',
                                                  value:
                                                      summary.weakSubjectLabel,
                                                  note:
                                                      '${summary.weakSubjectRate.toStringAsFixed(0)}% \uCD08\uACFC',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _MetricCard(
                                                  label:
                                                      '\uC2DC\uAC04 \uCD08\uACFC\uC728',
                                                  value:
                                                      '${summary.overtimeRate.toStringAsFixed(0)}%',
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _MetricCard(
                                                  label:
                                                      '\uD3C9\uADE0 \uCD08\uACFC \uC2DC\uAC04',
                                                  value: formatSeconds(
                                                    summary.averageOvertimeSec,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _SectionCard(
                                      title:
                                          '\uC885\uB8CC \uC2DC\uC810 \uCD94\uC138',
                                      child: _TrendChartCard(
                                        data: trendChartData,
                                        selectedIndex: _selectedTrendIndex,
                                        onSelect: (index) {
                                          setState(() {
                                            _selectedTrendIndex =
                                                _selectedTrendIndex == index
                                                ? null
                                                : index;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _SectionCard(
                                      title:
                                          '\uB2E8\uACC4\uBCC4 \uC2DC\uAC04 \uD1B5\uACC4',
                                      child: StatsCard(
                                        rows: [
                                          (
                                            label:
                                                '\uBB38\uC9C4 \uD3C9\uADE0',
                                            value: formatSeconds(
                                              summary.averageHistorySec,
                                            ),
                                          ),
                                          (
                                            label:
                                                '\uC2E0\uCCB4\uC9C4\uCC30 \uD3C9\uADE0',
                                            value: formatSeconds(
                                              summary.averagePhysicalSec,
                                            ),
                                          ),
                                          (
                                            label:
                                                '\uD658\uC790\uAD50\uC721 \uD3C9\uADE0',
                                            value: formatSeconds(
                                              summary.averageEducationSec,
                                            ),
                                          ),
                                        ],
                                        totalLabel:
                                            '\uD3C9\uADE0 \uC804\uCCB4 \uC2DC\uAC04',
                                        totalValue: formatSeconds(
                                          summary.averageEndSec,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildTimeManagementTitle() {
    if (_selectedSubject == statisticsAllLabel) {
      return '\uC804\uCCB4 \uC2DC\uAC04 \uAD00\uB9AC \uD1B5\uACC4';
    }

    if (_selectedTopic == statisticsAllLabel) {
      return '$_selectedSubject \uC2DC\uAC04 \uAD00\uB9AC \uD1B5\uACC4';
    }

    return '$_selectedTopic \uC2DC\uAC04 \uAD00\uB9AC \uD1B5\uACC4';
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
  });

  final TrendChartData data;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (data.points.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.65),
            width: 1,
          ),
        ),
        child: const Text(
          '\uD45C\uC2DC\uD560 \uCD94\uC138 \uAE30\uB85D\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E7986),
          ),
        ),
      );
    }

    final selectedPoint = selectedIndex != null &&
            selectedIndex! >= 0 &&
            selectedIndex! < data.points.length
        ? data.points[selectedIndex!]
        : null;
    final baselineLabel = data.baselineSec == null
        ? '\uAE30\uC900'
        : formatSeconds(data.baselineSec!);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              _TrendLegend(
                color: Color(0xFFD45C5C),
                label: '\uAE30\uC900 \uCD08\uACFC',
              ),
              SizedBox(width: 12),
              _TrendLegend(
                color: Color(0xFF4EA66D),
                label: '\uAE30\uC900 \uC774\uC804',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final baselineTop = constraints.maxHeight / 2;
                const barWidth = 20.0;
                const barGap = 8.0;
                const maxBarHeight = 70.0;
                final gapCount = data.points.length > 1
                    ? data.points.length - 1
                    : 0;
                final contentWidth =
                    data.points.length * barWidth + gapCount * barGap;

                return Stack(
                  children: [
                    Positioned(
                      top: baselineTop - 12,
                      left: 0,
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD45C5C),
                        ),
                      ),
                    ),
                    Positioned(
                      top: baselineTop + 2,
                      left: 0,
                      child: const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4EA66D),
                        ),
                      ),
                    ),
                    Positioned(
                      top: baselineTop,
                      left: 22,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: const Color(0xFFB9C5D1),
                      ),
                    ),
                    Positioned(
                      top: baselineTop - 24,
                      left: 28,
                      child: Text(
                        baselineLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A8591),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      left: 22,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: contentWidth,
                          height: constraints.maxHeight,
                          child: Stack(
                            children: [
                              ...List.generate(data.points.length, (index) {
                                final point = data.points[index];
                                final barHeight =
                                    (point.displayDeltaSec.abs() /
                                            data.maxAbsDeltaSec) *
                                        maxBarHeight;
                                final color = point.deltaSec > 0
                                    ? const Color(0xFFD45C5C)
                                    : point.deltaSec < 0
                                    ? const Color(0xFF4EA66D)
                                    : const Color(0xFFB7C3CF);
                                final left = index * (barWidth + barGap);

                                return Positioned(
                                  left: left,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => onSelect(index),
                                    child: SizedBox(
                                      width: barWidth,
                                      height: constraints.maxHeight,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (point.deltaSec == 0)
                                            Positioned(
                                              top: baselineTop - 2,
                                              child: Container(
                                                width: 10,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.circular(999),
                                                ),
                                              ),
                                            )
                                          else
                                            Positioned(
                                              top: point.deltaSec > 0
                                                  ? baselineTop - barHeight
                                                  : baselineTop,
                                              child: Container(
                                                width: 12,
                                                height: barHeight
                                                    .clamp(6.0, maxBarHeight)
                                                    .toDouble(),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      color.withValues(
                                                        alpha: 0.92,
                                                      ),
                                                      color.withValues(
                                                        alpha: 0.62,
                                                      ),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(999),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.55),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: color.withValues(
                                                        alpha: 0.18,
                                                      ),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                    if (selectedIndex == index)
                                                      BoxShadow(
                                                        color: color.withValues(
                                                          alpha: 0.28,
                                                        ),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (selectedIndex == index)
                                            Positioned(
                                              top: 6,
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF2F3A44),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (selectedPoint != null) ...[
            const SizedBox(height: 12),
            _TrendInlineTooltip(
              dateText:
                  '${_formatTooltipDateTime(selectedPoint.date)} / \uAE30\uC900 ${formatSeconds(selectedPoint.plannedDurationSec)}',
              detailText:
                  '\uC885\uB8CC ${formatSeconds(selectedPoint.actualEndSec)} / ${_formatDeltaLabel(selectedPoint.deltaSec)}',
              positive: selectedPoint.deltaSec >= 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendInlineTooltip extends StatelessWidget {
  const _TrendInlineTooltip({
    required this.dateText,
    required this.detailText,
    required this.positive,
  });

  final String dateText;
  final String detailText;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final accentColor = positive
        ? const Color(0xFFD45C5C)
        : const Color(0xFF4EA66D);
    final backgroundColor = accentColor.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF465260),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detailText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2A33),
              height: 1.1,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6E7986),
          ),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.selectedRange,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.topics,
    required this.onRangeChanged,
    required this.onSubjectChanged,
    required this.onTopicChanged,
  });

  final StatisticsRange selectedRange;
  final String selectedSubject;
  final String selectedTopic;
  final List<String> topics;
  final ValueChanged<StatisticsRange> onRangeChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onTopicChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: StatisticsRange.values
              .map(
                (range) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: range == StatisticsRange.last30Days ? 0 : 8,
                    ),
                    child: _ChoiceChipButton(
                      label: _rangeLabel(range),
                      selected: selectedRange == range,
                      onTap: () => onRangeChanged(range),
                      compact: true,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: '\uACFC\uBAA9',
                value: selectedSubject,
                options: [statisticsAllLabel, ...examSubjects],
                onChanged: onSubjectChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: '\uC8FC\uC81C',
                value: selectedTopic,
                options: topics,
                enabled: selectedSubject != statisticsAllLabel,
                onChanged: onTopicChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFE3E8EE) : const Color(0xFFD8DEE5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          dropdownColor: const Color(0xFFF1F4F7),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3A44),
          ),
          onChanged: enabled ? (next) => onChanged(next ?? value) : null,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text('$label: $option'),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 14,
            vertical: compact ? 11 : 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2E6BFF)
                : const Color(0xFFE3E8EE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2E6BFF)
                  : Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF56616D),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '\uC544\uC9C1 \uC5F0\uC2B5 \uAE30\uB85D\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.\n\uC5F0\uC2B5\uC744 \uC2DC\uC791\uD558\uBA74 \uC2DC\uAC04 \uAD00\uB9AC \uD1B5\uACC4\uB97C \uD655\uC778\uD560 \uC218 \uC788\uC2B5\uB2C8\uB2E4.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E7986),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.note,
  });

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7684),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const Spacer(),
          if (note != null)
            Text(
              note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A8591),
              ),
            ),
        ],
      ),
    );
  }
}

String _rangeLabel(StatisticsRange range) {
  switch (range) {
    case StatisticsRange.all:
      return statisticsAllLabel;
    case StatisticsRange.last7Days:
      return '\u0037\uC77C';
    case StatisticsRange.last14Days:
      return '\u0031\u0034\uC77C';
    case StatisticsRange.last30Days:
      return '\u0033\u0030\uC77C';
  }
}

String _formatDeltaLabel(int deltaSec) {
  if (deltaSec == 0) {
    return '\uAE30\uC900\uC120';
  }

  final sign = deltaSec > 0 ? '+' : '-';
  return '$sign${deltaSec.abs()}\uCD08';
}

String _formatTooltipDateTime(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$month.$day $hour:$minute';
}
