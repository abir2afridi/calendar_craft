import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final complete = await HiveService.getSetting<bool>(
      'onboarding_complete',
      false,
    );
    state = complete ?? false;
  }

  Future<void> completeOnboarding() async {
    await HiveService.saveSetting('onboarding_complete', true);
    state = true;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier();
});
