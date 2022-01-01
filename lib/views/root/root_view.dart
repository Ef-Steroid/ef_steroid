import 'package:fast_dotnet_ef/views/root/root_view_model.dart';
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
    vm.initViewModelAsync();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
