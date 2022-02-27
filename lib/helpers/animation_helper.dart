/*
 * Copyright 2022-2022 MOK KAH WAI and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
