import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key, this.message = 'Memuat data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = AppTheme.adaptiveMutedSurface(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.adaptiveBorder(context)),
                boxShadow: AppTheme.softShadow(context),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        (Theme.of(context).cardTheme.color ??
                                colorScheme.surface)
                            .withValues(alpha: 1 - (index * 0.22)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.adaptiveBorder(context)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: muted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 150,
                              decoration: BoxDecoration(
                                color: muted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 11,
                              width: 110,
                              decoration: BoxDecoration(
                                color: muted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 20,
                              width: 72,
                              decoration: BoxDecoration(
                                color: muted,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
