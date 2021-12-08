import 'package:flutter/material.dart';

class EfAddPanelView extends StatelessWidget {
  final VoidCallback? onAddProjectPressed;

  const EfAddPanelView({
    Key? key,
    required this.onAddProjectPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: onAddProjectPressed,
        child: const Text('Add EF Project'),
      ),
    );
  }
}
