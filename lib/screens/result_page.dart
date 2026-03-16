import 'package:flutter/material.dart';

import '../core/constants/exam_options.dart';
import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../widgets/home/glass_card.dart';
import '../widgets/home/stats_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.record,
    this.onRecordUpdated,
  });

  final PracticeRecord record;
  final Future<void> Function(PracticeRecord record)? onRecordUpdated;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late PracticeRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _editRecord() async {
    final draft = await showModalBottomSheet<_RecordMetadataDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF3F6F9),
      showDragHandle: true,
      builder: (context) => _RecordMetadataSheet(record: _record),
    );
    if (draft == null) {
      return;
    }

    final updatedRecord = _record.copyWith(
      examName: draft.examName,
      subject: draft.subject,
      topic: draft.topic,
    );

    await widget.onRecordUpdated?.call(updatedRecord);
    if (!mounted) {
      return;
    }

    setState(() {
      _record = updatedRecord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF5),
      appBar: AppBar(
        title: const Text(
          '\uACB0\uACFC \uC0C1\uC138',
          style: TextStyle(
            color: Color(0xFF2F3A44),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _editRecord,
            icon: const Icon(Icons.edit_rounded),
            tooltip: '\uAE30\uB85D \uC218\uC815',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF2F3A44),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6EEF5),
              Color(0xFFDCE6EE),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  10,
                  compact ? 8 : 14,
                  10,
                  compact ? 20 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SizedBox(
                        width: double.infinity,
                        height: constraints.maxHeight,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummarySection(record: _record),
                              SizedBox(height: compact ? 14 : 18),
                              StatsCard(
                                rows: [
                                  (
                                    label: '\uBCD1\uB825 \uCCAD\uCDE8',
                                    value: formatSeconds(_record.historySeconds),
                                  ),
                                  (
                                    label: '\uC2E0\uCCB4 \uC9C4\uCC30',
                                    value: formatSeconds(_record.physicalSeconds),
                                  ),
                                  (
                                    label: '\uD658\uC790 \uAD50\uC721',
                                    value: formatSeconds(
                                      _record.educationSeconds,
                                    ),
                                  ),
                                ],
                                totalLabel: '\uCD1D \uC0AC\uC6A9 \uC2DC\uAC04',
                                totalValue: formatSeconds(_record.totalSeconds),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.record});

  final PracticeRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            record.examName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${record.subject} / ${record.topic}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A7481),
            ),
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatSeconds(record.actualEndSec),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w300,
                height: 0.92,
                letterSpacing: -3.0,
                color: Color(0xFF2F3A44),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            record.finishTypeLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatDateTime(record.date),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A8591),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordMetadataDraft {
  const _RecordMetadataDraft({
    required this.examName,
    required this.subject,
    required this.topic,
  });

  final String examName;
  final String subject;
  final String topic;
}

class _SheetPickerField extends StatelessWidget {
  const _SheetPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EEF3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A8591),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F3A44),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                color: Color(0xFF7A8591),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordMetadataSheet extends StatefulWidget {
  const _RecordMetadataSheet({required this.record});

  final PracticeRecord record;

  @override
  State<_RecordMetadataSheet> createState() => _RecordMetadataSheetState();
}

class _RecordMetadataSheetState extends State<_RecordMetadataSheet> {
  late final TextEditingController _examNameController;
  late String _selectedSubject;
  late String _selectedTopic;

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController(
      text: widget.record.examName == defaultExamName ? '' : widget.record.examName,
    );
    _selectedSubject = widget.record.subject;
    _selectedTopic = widget.record.topic;
  }

  @override
  void dispose() {
    _examNameController.dispose();
    super.dispose();
  }

  Future<void> _pickSubject() async {
    final subjectOptions = <String>[
      defaultSubject,
      ...examSubjects.where((subject) => subject != defaultSubject),
    ];
    final selected = await _showOptionPicker(
      title: '\uACFC\uBAA9 \uC120\uD0DD',
      options: subjectOptions,
      currentValue: _selectedSubject,
    );
    if (selected == null) {
      return;
    }

    setState(() {
      _selectedSubject = sanitizeSubject(selected);
      _selectedTopic = defaultTopic;
    });
  }

  Future<void> _pickTopic() async {
    final topicOptions = <String>[
      defaultTopic,
      ...topicsForSubject(_selectedSubject).where((topic) => topic != defaultTopic),
    ];
    final selected = await _showOptionPicker(
      title: '\uC8FC\uC81C \uC120\uD0DD',
      options: topicOptions,
      currentValue: _selectedTopic,
    );
    if (selected == null) {
      return;
    }

    setState(() {
      _selectedTopic = sanitizeTopicForSubject(_selectedSubject, selected);
    });
  }

  Future<String?> _showOptionPicker({
    required String title,
    required List<String> options,
    required String currentValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF3F6F9),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F3A44),
                  ),
                ),
              ),
              for (final option in options)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Material(
                    color: option == currentValue
                        ? const Color(0xFFE3EAF4)
                        : const Color(0xFFE9EEF3),
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontWeight: option == currentValue
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: const Color(0xFF2F3A44),
                        ),
                      ),
                      trailing: option == currentValue
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF2E6BFF),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF9AA6B2),
                            ),
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final topics = <String>[
      defaultTopic,
      ...topicsForSubject(
        _selectedSubject,
      ).where((topic) => topic != defaultTopic),
    ];
    if (![defaultSubject, ...examSubjects].contains(_selectedSubject)) {
      _selectedSubject = defaultSubject;
    }
    if (!topics.contains(_selectedTopic)) {
      _selectedTopic = defaultTopic;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + viewInsets),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '\uAE30\uB85D \uC218\uC815',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F3A44),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _examNameController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F3A44),
              ),
              decoration: InputDecoration(
                labelText: '\uC5F0\uC2B5 \uC774\uB984',
                labelStyle: const TextStyle(
                  color: Color(0xFF697482),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: const Color(0xFFE9EEF3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E6BFF),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SheetPickerField(
              label: '\uACFC\uBAA9',
              value: _selectedSubject,
              onTap: _pickSubject,
            ),
            const SizedBox(height: 12),
            _SheetPickerField(
              label: '\uC8FC\uC81C',
              value: _selectedTopic,
              onTap: _pickTopic,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _RecordMetadataDraft(
                    examName: _examNameController.text,
                    subject: _selectedSubject,
                    topic: _selectedTopic,
                  ),
                );
              },
              child: const Text('\uC800\uC7A5'),
            ),
          ],
        ),
      ),
    );
  }
}
