import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/widgets/share_card_style.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';
import 'package:menfit_app/features/recaps/presentation/widgets/recap_share_sheet.dart';
import 'package:menfit_app/features/recaps/presentation/widgets/recap_slides.dart';

/// Full-screen immersive story carousel for one [MonthRecap] (Task 1.3,
/// `TASKS_TO_DO.md`).
///
/// Reached at `/recap`, pushed by
/// `presentation/widgets/recap_trigger_listener.dart` (automatic, on Home
/// mount) or from the Progress screen's recap history section (manual
/// re-view) — both build the [MonthRecap] first
/// (`recaps_providers.dart#recapForPeriodProvider`) and pass it in, so this
/// screen itself does no data fetching.
///
/// Slides are **tap-navigated only** (no swipe between slides, no
/// auto-advance) — tap the right two-thirds of the screen to advance, the
/// left third to go back, swipe down or tap the close button to dismiss.
/// `AccessibilityPreferences.reduceMotion` (`features/accessibility`)
/// disables the page-turn animation entirely (an instant jump) rather than
/// only shortening it, and there was never an auto-advance timer to
/// disable in the first place — see the class-level dartdoc in
/// `presentation/widgets/recap_slide_scaffold.dart` for why a manual-only
/// carousel was chosen over a timed one.
class RecapStoryScreen extends ConsumerStatefulWidget {
  const RecapStoryScreen({required this.recap, super.key});

  final MonthRecap recap;

  @override
  ConsumerState<RecapStoryScreen> createState() => _RecapStoryScreenState();
}

class _RecapStoryScreenState extends ConsumerState<RecapStoryScreen> {
  late final PageController _pageController;
  late final List<Widget> _slides;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _slides = buildRecapSlides(widget.recap);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0) return;
    if (index >= _slides.length) {
      Navigator.of(context).maybePop();
      return;
    }
    final reduceMotion = ref.read(accessibilityControllerProvider).reduceMotion;
    if (reduceMotion) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = ShareCardStyle.forTheme(ShareCardTheme.signatureOrchid);
    final isLastSlide = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: style.backgroundDecoration,
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 200) {
                    Navigator.of(context).maybePop();
                  }
                },
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < width / 3) {
                    _goTo(_index - 1);
                  } else {
                    _goTo(_index + 1);
                  }
                },
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: _slides,
                ),
              ),
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentedProgressBar(
                        count: _slides.length,
                        index: _index,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              if (isLastSlide)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () =>
                        RecapShareSheet.show(context, recap: widget.recap),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Save recap card'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: i <= index ? 1.0 : 0.0,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
