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

import 'package:ef_steroid/localization/localizations.dart';
import 'package:flutter/material.dart';

class EfAddPanelView extends StatelessWidget {
  final VoidCallback? onAddProjectPressed;

  const EfAddPanelView({
    Key? key,
    required this.onAddProjectPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Center(
      child: OutlinedButton(
        onPressed: onAddProjectPressed,
        child: Text(l('AddEfProject')),
      ),
    );
  }
}
