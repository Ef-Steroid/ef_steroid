import 'package:fast_dotnet_ef/helpers/theme_helper.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Widget? child;
  final bool isBusy;

  const LoadingWidget({
    Key? key,
    this.child,
    required this.isBusy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: isBusy,
          child: child,
        ),
        if (isBusy)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, .3)),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: ThemeHelper.circularProgressIndicatorColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
