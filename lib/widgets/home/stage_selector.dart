// 시험 진행 중 단계 전환용 세그먼트 버튼 UI를 제공한다.
import 'package:flutter/material.dart';

import '../../core/enums/exam_stage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

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
    Widget stageItem({
      required String text,
      required bool selected,
      required VoidCallback? onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: AppStyles.cardInnerRadius,
            ),
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.primaryTextOn
                          : AppColors.textPrimary,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: AppStyles.softPillDecoration,
      child: Row(
        children: [
          stageItem(
            text: '병력',
            selected: currentStage == ExamStage.historyTaking && enabled,
            onTap: enabled ? () => onStageSelected(0) : null,
          ),
          stageItem(
            text: '진찰',
            selected: currentStage == ExamStage.physicalExam && enabled,
            onTap: enabled ? () => onStageSelected(1) : null,
          ),
          stageItem(
            text: '교육',
            selected: currentStage == ExamStage.patientEducation && enabled,
            onTap: enabled ? () => onStageSelected(2) : null,
          ),
        ],
      ),
    );
  }
}
