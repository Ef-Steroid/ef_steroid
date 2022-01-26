import 'package:ef_steroid/localization/localizations.dart';
import 'package:flutter/material.dart';

class EfAddPanelView extends StatelessWidget {
  final VoidCallback? onAddProjectPressed;

  const EfAddPanelView({
    Key? key,
    required this.onAddProjectPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Center(
      child: OutlinedButton(
        onPressed: onAddProjectPressed,
        child: Text(l('AddEfProject')),
      ),
    );
  }
}
