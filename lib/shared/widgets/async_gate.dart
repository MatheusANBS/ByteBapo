import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncGate<T> extends StatelessWidget {
  const AsyncGate({
    required this.value,
    required this.builder,
    super.key,
    this.emptyMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage ?? 'Algo saiu errado. Tente novamente.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
