import 'package:fast_dotnet_ef/views/view_model_base.dart';
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
