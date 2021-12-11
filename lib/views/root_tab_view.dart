import 'package:fast_dotnet_ef/domain/ef_panel.dart';
import 'package:fast_dotnet_ef/repository/repository.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_add_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel.dart';
import 'package:fast_dotnet_ef/views/ef_panel/ef_panel_tab_data.dart';
import 'package:fast_dotnet_ef/views/ef_panel/tab_data_value.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:tabbed_view/tabbed_view.dart';

class RootTabView extends StatefulWidget {
  final TabbedViewController tabbedViewController;

  const RootTabView({
    Key? key,
    required this.tabbedViewController,
  }) : super(key: key);

  @override
  State<RootTabView> createState() => _RootTabViewState();
}

class _RootTabViewState extends State<RootTabView> {
  final Repository<EfPanel> _efPanelRepository = GetIt.I<Repository<EfPanel>>();

  @override
  Widget build(BuildContext context) {
    return TabbedView(
      controller: widget.tabbedViewController,
      contentBuilder: (context, index) {
        final tabDataValue = widget.tabbedViewController.tabs[index].value;
        if (tabDataValue is AddEfPanelTabDataValue) {
          return EfAddPanelView(
            onAddProjectPressed: _addEfProjectAsync,
          );
        }

        if (tabDataValue is EfPanelTabDataValue) {
          return EfPanelView(
            fileUri: tabDataValue.uri,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _addEfProjectAsync() async {
    final filePath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select EF Project',
    );

    if (filePath == null) {
      //TODO: Pop an error dialog here.
      return;
    }

    final fileUri = Uri.tryParse(filePath);

    if (fileUri == null) {
      //TODO: Pop an error dialog here.
      return;
    }

    final value = await _efPanelRepository.insertOrUpdateAsync(EfPanel(
      directoryUrl: Uri.parse(filePath),
    ));
    print(value);

    widget.tabbedViewController.insertTab(
      widget.tabbedViewController.tabs.length - 1,
      EfPanelTabData(
        value: EfPanelTabDataValue(uri: fileUri),
        text: path.basenameWithoutExtension(fileUri.toString()),
      ),
    );
  }
}
