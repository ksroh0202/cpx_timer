import 'package:flutter/material.dart';

import '../../core/enums/exam_stage.dart';
import '../glass_widgets.dart';

class StageSelector extends StatelessWidget {
  const StageSelector({
    super.key,
    required this.currentStage,
    required this.enabled,
    required this.onStageSelected,
  });

  final ExamStage? currentStage;
  final bool enabled;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GlassSegmentedControl(
          labels: const ['병력', '진찰', '교육'],
          selectedIndex: currentStage == null
              ? 0
              : ExamStage.values.indexOf(currentStage!),
          onChanged: onStageSelected,
        ),
      ),
    );
  }
}
