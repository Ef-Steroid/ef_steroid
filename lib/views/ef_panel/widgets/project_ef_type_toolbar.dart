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

import 'package:darq/darq.dart';
import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:flutter/material.dart';

class ProjectEfTypeToolbar extends StatefulWidget {
  final ProjectEfType? projectEfType;

  final ValueChanged<ProjectEfType> onProjectEfTypeSaved;

  const ProjectEfTypeToolbar({
    Key? key,
    this.projectEfType,
    required this.onProjectEfTypeSaved,
  }) : super(key: key);

  @override
  _ProjectEfTypeToolbarState createState() => _ProjectEfTypeToolbarState();
}

class _ProjectEfTypeToolbarState extends State<ProjectEfTypeToolbar> {
  static final Iterable<ProjectEfType?> _efProjectTypes = ProjectEfType.values
      .map((e) => e == ProjectEfType.defaultValue ? null : e)
      .orderByDescending((x) => x == null);

  ProjectEfType? _projectEfType;

  bool get hasProjectTypeChanged => widget.projectEfType != _projectEfType;

  @override
  void initState() {
    _projectEfType = widget.projectEfType;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProjectEfTypeToolbar oldWidget) {
    if (widget.projectEfType != oldWidget.projectEfType) {
      _projectEfType = widget.projectEfType;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<ProjectEfType?>(
          value: _projectEfType,
          onChanged: _onProjectTypeChanged,
          items: _efProjectTypes
              .map(
                (efProjectType) => DropdownMenuItem<ProjectEfType?>(
                  value: efProjectType,
                  enabled: efProjectType != null || _projectEfType == null,
                  child: Text(
                    efProjectType == null
                        ? l('PleaseSelectAnEntityFrameworkType')
                        : efProjectType.toDisplayString(),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        if (hasProjectTypeChanged) ...[
          OutlinedButton(
            onPressed: _saveEfProjectTypeAsync,
            child: const Icon(
              Icons.check,
              color: ColorConst.dangerColor,
            ),
          ),
          const SizedBox(width: 8.0),
          OutlinedButton(
            onPressed: _resetEfProjectType,
            child: const Icon(
              Icons.close,
            ),
          ),
        ],
      ],
    );
  }

  void _onProjectTypeChanged(ProjectEfType? value) {
    _projectEfType = value!;
    setState(() {});
  }

  void _saveEfProjectTypeAsync() {
    // By this time, the user should have selected something from DropdownButton.
    widget.onProjectEfTypeSaved(_projectEfType!);
  }

  void _resetEfProjectType() {
    _projectEfType = widget.projectEfType;
    setState(() {});
  }
}
