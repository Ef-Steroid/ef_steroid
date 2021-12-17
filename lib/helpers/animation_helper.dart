import 'package:flutter/widgets.dart';

class AnimationHelper {
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);

  static const Duration pageViewAnimationDuration = standardAnimationDuration;
  static const Cubic pageViewAnimationCurve = Curves.ease;

  static const Duration carouselAnimationDuration = standardAnimationDuration;
  static const Cubic carouselAnimationCurve = Curves.fastOutSlowIn;

  static const Duration scrollToFringeDuration = Duration(milliseconds: 500);
  static const Cubic scrollToFringeCurve = Curves.easeOut;

  static Widget dialogTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
