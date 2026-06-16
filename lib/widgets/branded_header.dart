import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_theme.dart';

class BrandedHeader extends StatelessWidget {
  const BrandedHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null || actions.isNotEmpty)
                Row(
                  children: [
                    if (leading != null) leading!,
                    const Spacer(),
                    ...actions,
                  ],
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(title,
                  style: text.displaySmall?.copyWith(color: AppColors.onPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: text.bodyMedium?.copyWith(color: Colors.white70)),
              ],
              if (bottom != null) ...[
                const SizedBox(height: AppSpacing.md),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BrandedScaffold extends StatelessWidget {
  const BrandedScaffold({
    super.key,
    required this.header,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final BrandedHeader header;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          header,
          Expanded(child: body),
        ],
      ),
    );
  }
}
