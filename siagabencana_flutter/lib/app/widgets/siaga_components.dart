import 'package:flutter/material.dart';

import '../siaga_theme.dart';

enum SiagaTone { neutral, info, warning, danger, success }

class SiagaCard extends StatelessWidget {
  const SiagaCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.backgroundColor = SiagaColors.surface,
    this.borderColor = SiagaColors.border,
    this.borderRadius = 18,
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
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color(0x08123B63),
                  blurRadius: 22,
                  offset: Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class SiagaPageHeader extends StatelessWidget {
  const SiagaPageHeader({
    required this.title,
    required this.description,
    this.eyebrow,
    this.icon,
    super.key,
  });

  final String title;
  final String description;
  final String? eyebrow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final titleText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: const TextStyle(
              color: SiagaColors.navyHover,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: SiagaColors.muted),
          ),
        ),
      ],
    );

    if (icon == null) {
      return titleText;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return titleText;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleText),
            const SizedBox(width: 24),
            SiagaIconTile(icon: icon!, size: 68),
          ],
        );
      },
    );
  }
}

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
                const SizedBox(height: 5),
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

class SiagaBadge extends StatelessWidget {
  const SiagaBadge({
    required this.label,
    this.tone = SiagaTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final SiagaTone tone;
  final IconData? icon;

  Color get _foreground => switch (tone) {
    SiagaTone.neutral => SiagaColors.muted,
    SiagaTone.info => SiagaColors.navy,
    SiagaTone.warning => const Color(0xFF9A3412),
    SiagaTone.danger => const Color(0xFF991B1B),
    SiagaTone.success => const Color(0xFF065F46),
  };

  Color get _background => switch (tone) {
    SiagaTone.neutral => const Color(0xFFF1F5F9),
    SiagaTone.info => const Color(0xFFEFF6FF),
    SiagaTone.warning => const Color(0xFFFFF7ED),
    SiagaTone.danger => const Color(0xFFFEF2F2),
    SiagaTone.success => const Color(0xFFECFDF5),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 3,
        children: [
          if (icon != null) Icon(icon, size: 15, color: _foreground),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              label,
              softWrap: true,
              style: TextStyle(
                color: _foreground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SiagaNotice extends StatelessWidget {
  const SiagaNotice({
    required this.title,
    required this.message,
    this.tone = SiagaTone.info,
    this.icon,
    super.key,
  });

  final String title;
  final String message;
  final SiagaTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      SiagaTone.neutral => SiagaColors.muted,
      SiagaTone.info => SiagaColors.navy,
      SiagaTone.warning => SiagaColors.warning,
      SiagaTone.danger => SiagaColors.danger,
      SiagaTone.success => SiagaColors.safe,
    };
    final background = switch (tone) {
      SiagaTone.neutral => const Color(0xFFF1F5F9),
      SiagaTone.info => const Color(0xFFEFF6FF),
      SiagaTone.warning => const Color(0xFFFFF7ED),
      SiagaTone.danger => const Color(0xFFFEF2F2),
      SiagaTone.success => const Color(0xFFECFDF5),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: SiagaColors.ink),
                ),
              ],
            ),
          ),
        ],
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
    this.backgroundColor = const Color(0xFFEFF6FF),
    this.size = 48,
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
        borderRadius: BorderRadius.circular(size * 0.28),
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
    super.key,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: SiagaColors.ink),
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
    final color = switch (tone) {
      SiagaTone.neutral => SiagaColors.muted,
      SiagaTone.info => SiagaColors.navyHover,
      SiagaTone.warning => SiagaColors.warning,
      SiagaTone.danger => SiagaColors.danger,
      SiagaTone.success => SiagaColors.safe,
    };

    return SiagaCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
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
