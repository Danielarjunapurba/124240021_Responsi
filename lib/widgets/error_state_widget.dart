import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.28),
              ),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 36,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Koneksi Bermasalah',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
