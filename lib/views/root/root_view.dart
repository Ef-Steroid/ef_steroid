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

import 'package:ef_steroid/views/root/root_view_model.dart';
import 'package:ef_steroid/views/view_model_base.dart';
import 'package:ef_steroid/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RootView extends StatefulWidget {
  final Widget child;

  const RootView({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _RootViewState createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  final RootViewModel vm = GetIt.I<RootViewModel>();

  @override
  void initState() {
    super.initState();
    vm.initViewModelAsync(
      initParam: const InitParam(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MVVMBindingWidget<RootViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return widget.child;
      },
    );
  }
}
