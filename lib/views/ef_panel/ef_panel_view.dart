import 'package:fast_dotnet_ef/localization/localizations.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_view_model.dart';
import 'package:fast_dotnet_ef/views/widgets/mvvm_binding_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EfPanelView extends StatefulWidget {
  final Uri fileUri;

  const EfPanelView({
    Key? key,
    required this.fileUri,
  }) : super(key: key);

  @override
  State<EfPanelView> createState() => _EfPanelViewState();
}

class _EfPanelViewState extends State<EfPanelView> {
  final EfPanelViewModel vm = GetIt.I<EfPanelViewModel>();

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return MVVMBindingWidget<EfPanelViewModel>(
      viewModel: vm,
      builder: (context, vm, child) {
        return Column(
          children: [
            const SizedBox(height: 16),
            if (vm.isBusy)
              const CircularProgressIndicator()
            else
              OutlinedButton(
                onPressed: vm.updateDatabaseAsync,
                child: Text(l('UpdateDatabase')),
              ),
            OutlinedButton(
              onPressed: vm.collectLogAsync,
              child: Text(l('CollectLog')),
            ),
          ],
        );
      },
    );
  }
}
