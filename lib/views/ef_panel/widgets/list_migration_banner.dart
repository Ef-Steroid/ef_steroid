import 'package:ef_steroid/helpers/theme_helper.dart';
import 'package:ef_steroid/localization/localizations.dart';
import 'package:flutter/material.dart';

class ListMigrationBanner extends StatelessWidget {
  final VoidCallback onIgnorePressed;

  const ListMigrationBanner({
    Key? key,
    required this.onIgnorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AL.of(context).text;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: ColorConst.warningColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l('RefreshMigrationIndicator'),
            maxLines: 2,
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onIgnorePressed,
            child: Text(
              l('Ignore'),
            ),
          ),
        ],
      ),
    );
  }
}
