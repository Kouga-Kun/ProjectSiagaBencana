import 'package:flutter/material.dart';

import '../siaga_theme.dart';

enum SiagaTone { neutral, info, warning, danger, success }

extension SiagaToneColors on SiagaTone {
  Color get accent => switch (this) {
    SiagaTone.neutral => SiagaColors.muted,
    SiagaTone.info => SiagaColors.primaryBlue,
    SiagaTone.warning => SiagaColors.warning,
    SiagaTone.danger => SiagaColors.danger,
    SiagaTone.success => SiagaColors.safe,
  };

  Color get foreground => switch (this) {
    SiagaTone.neutral => SiagaColors.textSecondary,
    SiagaTone.info => SiagaColors.navy,
    SiagaTone.warning => SiagaColors.warningText,
    SiagaTone.danger => SiagaColors.dangerText,
    SiagaTone.success => SiagaColors.safeText,
  };

  Color get background => switch (this) {
    SiagaTone.neutral => SiagaColors.surfaceMuted,
    SiagaTone.info => SiagaColors.primarySoft,
    SiagaTone.warning => SiagaColors.warningSoft,
    SiagaTone.danger => SiagaColors.dangerSoft,
    SiagaTone.success => SiagaColors.safeSoft,
  };

  Color get border => switch (this) {
    SiagaTone.neutral => SiagaColors.border,
    SiagaTone.info => SiagaColors.primaryBorder,
    SiagaTone.warning => SiagaColors.warningBorder,
    SiagaTone.danger => SiagaColors.dangerBorder,
    SiagaTone.success => SiagaColors.safeBorder,
  };
}

/// Clean bordered surface container for structured content blocks.
class SiagaCard extends StatelessWidget {
  const SiagaCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = SiagaColors.surface,
    this.borderColor = SiagaColors.border,
    this.borderRadius = SiagaRadius.lg,
    this.shadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ? SiagaShadows.subtle : null,
      ),
      child: child,
    );
  }
}

/// Interactive card with subtle hover border and lift micro-interaction.
class SiagaInteractiveCard extends StatefulWidget {
  const SiagaInteractiveCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = SiagaColors.surface,
    this.borderColor = SiagaColors.border,
    this.hoverBorderColor = SiagaColors.primaryBorder,
    this.borderRadius = SiagaRadius.lg,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final double borderRadius;

  @override
  State<SiagaInteractiveCard> createState() => _SiagaInteractiveCardState();
}

class _SiagaInteractiveCardState extends State<SiagaInteractiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final activeHover = _hovered && widget.onTap != null;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: activeHover ? widget.hoverBorderColor : widget.borderColor,
          ),
          boxShadow: activeHover ? SiagaShadows.hover : SiagaShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: SiagaColors.primarySoft.withValues(alpha: 0.35),
            splashColor: SiagaColors.primarySoft,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Editorial page header with restrained typography and optional trailing action.
class SiagaPageHeader extends StatelessWidget {
  const SiagaPageHeader({
    required this.title,
    required this.description,
    this.eyebrow,
    this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final String description;
  final String? eyebrow;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: SiagaColors.primaryBlue),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  eyebrow!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SiagaColors.primaryBlue,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: SiagaColors.muted),
          ),
        ),
      ],
    );

    if (trailing == null) {
      return textBlock;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [textBlock, const SizedBox(height: 14), trailing!],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: textBlock),
            const SizedBox(width: 24),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.48,
                ),
                child: trailing!,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Structured section title bar with subtitle and optional right-side action.
class SiagaSectionHeader extends StatelessWidget {
  const SiagaSectionHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

/// Restrained semantic badge — crisp hairline border, balanced padding.
class SiagaBadge extends StatelessWidget {
  const SiagaBadge({
    required this.label,
    this.tone = SiagaTone.neutral,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final SiagaTone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(SiagaRadius.sm),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 13 : 14, color: tone.foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: tone.foreground,
                fontSize: compact ? 11.5 : 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle inline status dot + text for low-noise metadata indicators.
class SiagaStatusDot extends StatelessWidget {
  const SiagaStatusDot({
    required this.label,
    this.tone = SiagaTone.neutral,
    super.key,
  });

  final String label;
  final SiagaTone tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: tone.accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: tone.foreground,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Crisp left-accented operational alert banner.
class SiagaNotice extends StatelessWidget {
  const SiagaNotice({
    required this.title,
    required this.message,
    this.tone = SiagaTone.info,
    this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final String message;
  final SiagaTone tone;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        border: Border.all(color: tone.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SiagaRadius.md - 1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tone.accent, width: 3.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  icon ?? Icons.info_outline_rounded,
                  color: tone.accent,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: tone.foreground,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SiagaColors.textSecondary,
                        fontSize: 13.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tabular KPI stat tile for real operational metrics.
class SiagaMetricTile extends StatelessWidget {
  const SiagaMetricTile({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.tone = SiagaTone.info,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final SiagaTone tone;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SiagaColors.muted,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, size: 18, color: tone.accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 24,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(caption!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Clean segmented tab bar for sub-module switching without bulky chips.
class SiagaSegmentedTabItem {
  const SiagaSegmentedTabItem({
    required this.label,
    required this.icon,
    this.badgeText,
  });

  final String label;
  final IconData icon;
  final String? badgeText;
}

class SiagaSegmentedTabs extends StatelessWidget {
  const SiagaSegmentedTabs({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<SiagaSegmentedTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: SiagaColors.surfaceMuted,
        borderRadius: BorderRadius.circular(SiagaRadius.lg),
        border: Border.all(color: SiagaColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _SegmentButton(
                item: items[i],
                isSelected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SiagaSegmentedTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SiagaRadius.md),
          onTap: onTap,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? SiagaColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(
                color: isSelected ? SiagaColors.border : Colors.transparent,
              ),
              boxShadow: isSelected ? SiagaShadows.subtle : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 16,
                  color: isSelected ? SiagaColors.navy : SiagaColors.muted,
                ),
                const SizedBox(width: 7),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.2,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? SiagaColors.navy : SiagaColors.muted,
                  ),
                ),
                if (item.badgeText != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? SiagaColors.primarySoft
                          : SiagaColors.border,
                      borderRadius: BorderRadius.circular(SiagaRadius.pill),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? SiagaColors.navy
                            : SiagaColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle skeleton placeholder that respects reduced-motion preferences.
class SiagaSkeletonBox extends StatefulWidget {
  const SiagaSkeletonBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = SiagaRadius.md,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SiagaSkeletonBox> createState() => _SiagaSkeletonBoxState();
}

class _SiagaSkeletonBoxState extends State<SiagaSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: SiagaColors.surfaceMuted,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          SiagaColors.surfaceMuted,
          SiagaColors.border,
          _controller.value * 0.65,
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Calm, actionable empty state block.
class SiagaEmptyState extends StatelessWidget {
  const SiagaEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SiagaIconTile(
                icon: icon,
                size: 52,
                color: SiagaColors.muted,
                backgroundColor: SiagaColors.surfaceMuted,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class SiagaResponsiveGrid extends StatelessWidget {
  const SiagaResponsiveGrid({
    required this.children,
    this.minimumItemWidth = 270,
    this.spacing = 16,
    super.key,
  });

  final List<Widget> children;
  final double minimumItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            ((constraints.maxWidth + spacing) / (minimumItemWidth + spacing))
                .floor()
                .clamp(1, children.length)
                .toInt();
        final itemWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class SiagaIconTile extends StatelessWidget {
  const SiagaIconTile({
    required this.icon,
    this.color = SiagaColors.navy,
    this.backgroundColor = SiagaColors.primarySoft,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class SiagaBullet extends StatelessWidget {
  const SiagaBullet({
    required this.text,
    this.icon = Icons.check_circle_outline_rounded,
    this.color = SiagaColors.safe,
    this.textColor,
    super.key,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor ?? SiagaColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SiagaStepCard extends StatelessWidget {
  const SiagaStepCard({
    required this.number,
    required this.title,
    required this.description,
    this.tone = SiagaTone.info,
    super.key,
  });

  final String number;
  final String title;
  final String description;
  final SiagaTone tone;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(color: tone.border),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: tone.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
