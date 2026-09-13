import 'package:flutter/material.dart';

class DailyFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const DailyFlowLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: size * 0.65,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'DailyFlow',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ],
    );
  }
}
