import 'package:flutter/material.dart';

class DailyFlowLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const DailyFlowLogo({
    super.key,
    this.size = 30,
    this.showText = true,
    this.fontSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      const Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.28),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: size * 0.65,
                  ),
                ),
              );
            },
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
