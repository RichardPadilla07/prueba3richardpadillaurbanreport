import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
        backgroundColor: theme.colorScheme.surface,
        strokeWidth: 3.2,
      ),
    );
  }
}
