import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:menfit_app/features/onboarding/presentation/onboarding_steps.dart';

/// The one-time onboarding flow: welcome -> about you -> privacy.
///
/// Lives outside the main navigation shell (no bottom nav/rail) so
/// first-run setup reads as its own moment - see the redirect in
/// `app/router/router.dart`, which sends the user here until onboarding
/// completes and away from here once it has.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return PopScope(
      canPop: state.isFirstStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.isFirstStep) {
          controller.back();
        }
      },
      child: Scaffold(
        body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingLg,
                vertical: tokens.spacingMd,
              ),
              child: Column(
                children: [
                  _StepProgress(
                    stepIndex: state.stepIndex,
                    stepCount: onboardingStepCount,
                  ),
                  SizedBox(height: tokens.spacingLg),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: KeyedSubtree(
                        key: ValueKey(state.stepIndex),
                        child: _stepFor(state.stepIndex),
                      ),
                    ),
                  ),
                  if (state.submitError != null) ...[
                    SizedBox(height: tokens.spacingMd),
                    Text(
                      state.submitError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  SizedBox(height: tokens.spacingLg),
                  _NavigationButtons(
                    state: state,
                    onBack: controller.back,
                    onContinue: controller.continueFromCurrentStep,
                    onFinish: controller.finish,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _stepFor(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return const WelcomeStep();
      case 1:
        return const AboutYouStep();
      case 2:
        return const MoreAboutYouStep();
      default:
        return const PrivacyStep();
    }
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.stepIndex, required this.stepCount});

  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < stepCount; i++) ...[
          if (i > 0) SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= stepIndex
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons({
    required this.state,
    required this.onBack,
    required this.onContinue,
    required this.onFinish,
  });

  final OnboardingState state;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final isOptionalStep = state.stepIndex == moreAboutYouStepIndex;

    return Row(
      children: [
        if (!state.isFirstStep)
          TextButton(onPressed: onBack, child: const Text('Back')),
        const Spacer(),
        // The optional "Tell us a little more" step gets a dedicated "Skip"
        // affordance alongside "Continue" - nothing on this step is
        // required to advance either way, but a visible Skip makes that
        // obvious rather than relying on the user to notice Continue works
        // with nothing chosen (`knowledge/product/stage1_audit.md` §5.1).
        if (isOptionalStep && !state.isSubmitting) ...[
          TextButton(onPressed: onContinue, child: const Text('Skip')),
          SizedBox(width: tokens.spacingSm),
        ],
        FilledButton(
          onPressed: state.isSubmitting
              ? null
              : (state.isLastStep ? onFinish : onContinue),
          child: state.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(state.isLastStep ? 'Finish' : 'Continue'),
        ),
      ],
    );
  }
}
