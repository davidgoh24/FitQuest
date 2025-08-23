import 'package:flutter/material.dart';

class PlanCardsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> plans;
  final int selectedPlan;
  final ValueChanged<int> onSelected;
  const PlanCardsWidget({
    Key? key,
    required this.plans,
    required this.selectedPlan,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final highlightColor = colorScheme.primary;
    final highlightBorder = colorScheme.primary;
    final fadedBorder = colorScheme.outlineVariant ?? colorScheme.outline;
    final bestValueBg = colorScheme.secondary;
    final bestValueText = colorScheme.onSecondary;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          bool highlight = selectedPlan == idx;
          bool bestValue = idx == 1;
          return GestureDetector(
            onTap: () => onSelected(idx),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: highlight ? highlightColor : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: highlight ? highlightBorder : fadedBorder,
                  width: highlight ? 2 : 1.3,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plans[idx]['name'],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: highlight ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plans[idx]['price'],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: highlight ? Colors.white : theme.textTheme.titleMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    plans[idx]['period'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 17,
                        color: highlight ? Colors.white : theme.iconTheme.color,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${(plans[idx]['tokens'] as num).toInt()} Tokens',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: highlight ? Colors.white : theme.hintColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (bestValue)
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: bestValueBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Best Value',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: bestValueText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}