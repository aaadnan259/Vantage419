import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/providers/repository_providers.dart';

class SpinTooltipNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return !(prefs.getBool('hasSpunOnce') ?? false);
  }

  void onSpinStarted() {
    if (state) {
      state = false;
      ref.read(sharedPreferencesProvider).setBool('hasSpunOnce', true);
    }
  }
}

final spinTooltipProvider = NotifierProvider<SpinTooltipNotifier, bool>(
  SpinTooltipNotifier.new,
);
