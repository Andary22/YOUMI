// "Daybook" signature components. These replace generic Material widgets
// (NavigationBar, plain Chip, flat stat tiles) with custom-painted pieces
// that give the app its own identity: a ruled-paper texture, a floating
// pill nav, a hero progress ring, and folder-tab style labels.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/style/label_style.dart';

/// Faint horizontal rule lines behind scrollable content, evoking a paper
/// notebook page. Very low contrast so it never fights with content.
class RuledPage extends StatelessWidget {
  final Widget child;

  const RuledPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color lineColor = colorScheme.outline;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceContainerLowest,
            colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
            colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _RulePainter(lineColor: lineColor),
        child: child,
      ),
    );
  }
}

class _RulePainter extends CustomPainter {
  final Color lineColor;

  _RulePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    const double gap = 36;
    double y = 96;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RulePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

/// Floating pill-shaped bottom navigation bar with an animated sliding
/// indicator behind the selected icon, replacing the default NavigationBar.
class PillNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_PillNavItem> items;
  final void Function(int) onTap;

  const PillNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: theme.colorScheme.outline, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double slotWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: slotWidth * currentIndex,
                  top: 0,
                  bottom: 0,
                  width: slotWidth,
                  child: Center(
                    child: Container(
                      width: slotWidth - 8,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.72),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (index) {
                    final bool selected = index == currentIndex;
                    final item = items[index];
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          onTap(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? item.selectedIcon : item.icon,
                              size: 22,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PillNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _PillNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

typedef PillNavItem = _PillNavItem;

/// Hero circular progress ring used on the dashboard, with a percentage
/// and label in the center instead of flat stat tiles.
class ProgressRing extends StatelessWidget {
  final double progress;
  final String centerValue;
  final String centerLabel;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.centerValue,
    required this.centerLabel,
    this.size = 148,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              progressColor: theme.colorScheme.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue, style: theme.textTheme.headlineMedium),
              Text(
                centerLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.09;
    final Rect rect = Offset.zero & size;
    final Offset center = rect.center;
    final double radius = (size.width - strokeWidth) / 2;

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweep = 2 * math.pi * progress.clamp(0, 1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

/// Folder-tab style label chip: a small flag/tab shape with a notch,
/// replacing the generic rounded-pill Chip used elsewhere in Material apps.
class TabChip extends StatelessWidget {
  final TaskLabel label;
  final bool dense;

  const TabChip({super.key, required this.label, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = labelStyleFor(label, scheme);
    final double height = dense ? 22 : 26;
    return ClipPath(
      clipper: _TabClipper(),
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(dense ? 8 : 10, 0, dense ? 12 : 15, 0),
        color: style.color.withValues(alpha: 0.16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: dense ? 11 : 13, color: style.color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                style.displayName,
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,                   
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: style.color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _TabClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double notch = size.height * 0.32;
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - notch, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - notch, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

/// Circular "stamp" checkbox with a hand-drawn-style check stroke,
/// replacing the flat outlined-circle checkbox pattern.
class StampCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final double size;

  const StampCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? theme.colorScheme.primary : Colors.transparent,
          border: Border.all(
            width: 2,
            color: checked ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: checked
            ? CustomPaint(
                size: Size(size * 0.5, size * 0.5),
                painter: _CheckStrokePainter(color: theme.colorScheme.onPrimary),
              )
            : null,
      ),
    );
  }
}

class _CheckStrokePainter extends CustomPainter {
  final Color color;

  _CheckStrokePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path path = Path();
    path.moveTo(0, size.height * 0.55);
    path.lineTo(size.width * 0.4, size.height * 0.95);
    path.lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckStrokePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
