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

import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Widget? child;
  final bool isBusy;

  const LoadingWidget({
    Key? key,
    this.child,
    required this.isBusy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: isBusy,
          child: child,
        ),
        if (isBusy)
          Positioned.fill(
            child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(0, 0, 0, .3)),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: ThemeHelper.circularProgressIndicatorColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
