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

import 'package:ef_steroid/views/view_model_base.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MVVMBindingWidget<T extends ViewModelBase> extends StatelessWidget {
  final T viewModel;

  /// {@template provider.consumer.builder}
  /// Build a widget tree based on the value from a [Provider<T>].
  ///
  /// Must not be null.
  /// {@endtemplate}
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  final bool isReuse;

  const MVVMBindingWidget({
    Key? key,
    required this.viewModel,
    required this.builder,
    this.isReuse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReuse) {
      return ChangeNotifierProvider<T>.value(
        value: viewModel,
        child: Consumer<T>(builder: builder),
      );
    }
    viewModel.context = context;
    return ChangeNotifierProvider<T>(
      create: (c) {
        return viewModel;
      },
      child: Consumer<T>(builder: builder),
    );
  }
}
