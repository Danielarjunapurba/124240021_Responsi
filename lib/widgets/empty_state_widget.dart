import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'Data tidak ditemukan',
    this.subtitle = 'Coba ubah kata kunci pencarian atau filter yang dipilih.',
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.adaptiveBorder(context)),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.16),
                        colorScheme.secondary.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: colorScheme.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(actionLabel!),
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
