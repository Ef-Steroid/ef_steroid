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
import 'package:ef_steroid/localization/localizations.dart';
import 'package:flutter/material.dart';

class ListMigrationBanner extends StatelessWidget {
  final VoidCallback onIgnorePressed;

  const ListMigrationBanner({
    Key? key,
    required this.onIgnorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: ColorConst.warningColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l('RefreshMigrationIndicator'),
            maxLines: 2,
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onIgnorePressed,
            child: Text(
              l('Ignore'),
            ),
          ),
        ],
      ),
    );
  }
}
