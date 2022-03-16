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

import 'dart:async';

import 'package:ef_steroid/domain/ef_panel.dart';
import 'package:ef_steroid/repository/repository.dart';
import 'package:ef_steroid/repository_cache/repository_cache.dart';
import 'package:ef_steroid/services/cs_project_resolver/cs_project_resolver.dart';
import 'package:ef_steroid/shared/project_ef_type.dart';
import 'package:ef_steroid/util/message_key.dart';
import 'package:ef_steroid/util/messaging_center.dart';
import 'package:ef_steroid/views/ef_panel/ef_project_operation/ef_project_operation_view_model_data.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:get_it/get_it.dart';

class EfProjectOperationViewModel extends ViewModelBase {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();
  final RepositoryCache<EfPanel> _efPanelRepositoryCache =
      GetIt.I<RepositoryCache<EfPanel>>();
  final CsProjectResolver _csProjectResolver;

  late int _efPanelId;

  EfProjectOperationViewModel(
    this._csProjectResolver,
  ) {
    MessagingCenter.subscribe(
      MessageKey.onEfProjectTypeChanged,
      this,
      _onEfProjectTypeChanged,
    );
  }

  void _onEfProjectTypeChanged(MessageData data) {
    notifyListeners();
  }

  @override
  Future<void> initViewModelAsync({
    required InitParam initParam,
  }) async {
    final state = initParam.param;
    if (state is EfProjectOperationViewModelData) {
      _efPanelId = state.efPanelId;
      await _detectProjectTypeAsync();
      return super.initViewModelAsync(initParam: initParam);
    }
    throw StateError('Incorrect state type.');
  }

  Future<void> switchEfProjectTypeAsync({
    required ProjectEfType projectEfType,
  }) async {
    final efPanel = await _efPanelRepositoryCache.getAsync(id: _efPanelId);
    if (efPanel.projectEfType == projectEfType) return;

    if (isBusy) return;
    notifyListeners(isBusy: true);

    try {
      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          projectEfType: projectEfType,
        ),
      );
      _efPanelRepositoryCache.delete(id: _efPanelId);
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      logService.severe(ex, stackTrace);
    } finally {
      notifyListeners(isBusy: false);
    }
  }

  /// Detect the [ProjectEfType] of a [EfPanel].
  ///
  /// We call this method only in the initialization of this view model.
  ///
  /// This method detects the [ProjectEfType] only when [EfPanel.projectEfType]
  /// is null.
  Future<void> _detectProjectTypeAsync() async {
    try {
      final efPanel = await _efPanelRepositoryCache.tryGetAsync(id: _efPanelId);
      if (efPanel == null) {
        throw StateError('EfPanel is not initialized.');
      }

      if (efPanel.projectEfType != null &&
          // Allow ProjectEfType.defaultValue so that in the future when we
          // support it, we are able to detect it.
          efPanel.projectEfType != ProjectEfType.defaultValue) return;

      final projectUri = efPanel.directoryUri;
      final csProjectAsset =
          await _csProjectResolver.getCsProjectAsset(projectUri: projectUri);

      final ef6PackageRegex = RegExp(r'^EntityFramework/6.+');
      final efCorePackageRegex = RegExp(r'^Microsoft.EntityFrameworkCore/.+');

      ProjectEfType? projectEfType;
      csProjectAsset.libraries.forEach((key, value) {
        if (ef6PackageRegex.hasMatch(key)) {
          projectEfType = ProjectEfType.ef6;
          return;
        }

        if (efCorePackageRegex.hasMatch(key)) {
          projectEfType = ProjectEfType.efCore;
          return;
        }
      });

      if (projectEfType == null) {
        return;
      }

      await _efPanelRepository.insertOrUpdateAsync(
        efPanel.copyWith(
          projectEfType: projectEfType,
        ),
      );
    } catch (ex, stackTrace) {
      await dialogService.showErrorDialog(
        context,
        ex,
        stackTrace,
      );
      logService.severe(ex, stackTrace);
    }
  }
}
