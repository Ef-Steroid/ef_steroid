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
import 'package:ef_steroid/services/dotnet_ef/model/db_context.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef6_operation/ef6_operation_view_model.dart';
import 'package:ef_steroid/views/ef_panel/ef_operation/ef_operation_view_model_base.dart';
import 'package:flutter/material.dart';

class DbContextSelectorController extends ChangeNotifier {
  DbContext _dbContext;

  DbContext get dbContext => _dbContext;

  set dbContext(DbContext dbContext) {
    if (_dbContext == dbContext) {
      return;
    }
    _dbContext = dbContext;
    notifyListeners();
  }

  DbContextSelectorController({
    DbContext dbContext = const DbContext.dummy(),
  }) : _dbContext = dbContext;
}

class DbContextSelector extends StatelessWidget {
  final EfOperationViewModelBase vm;

  final DbContextSelectorController dbContextSelectorController;

  const DbContextSelector({
    Key? key,
    required this.vm,
    required this.dbContextSelectorController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vm is Ef6OperationViewModel) return const SizedBox.shrink();

    final l = AL.of(context).text;

    final dbContexts = vm.dbContexts;
    final dbContext = dbContextSelectorController.dbContext;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(
                color: ColorConst.primaryColor,
                width: 1.0,
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DbContext>(
              value: dbContext,
              onChanged: dbContexts.isEmpty ? null : _onDbContextChangedAsync,
              items: dbContexts
                  .map(
                    (dbContext) => DropdownMenuItem<DbContext>(
                      value: dbContext,
                      child: Text(
                        dbContext.safeName,
                      ),
                    ),
                  )
                  .prepend(
                    DropdownMenuItem<DbContext>(
                      enabled: false,
                      value: const DbContext.dummy(),
                      child: Text('<${l('NoDbContextSelected')}>'),
                    ),
                  )
                  .toList(growable: false),
              isDense: true,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: l('Refresh'),
          color: ColorConst.primaryColor,
          onPressed: vm.fetchDbContextsAsync,
        ),
      ],
    );
  }

  Future<void> _onDbContextChangedAsync(DbContext? dbContext) {
    if (dbContext == null) {
      throw ArgumentError.notNull('dbContext');
    }

    return vm.configureDbContextAsync(
      dbContext: dbContext,
    );
  }
}
