import 'package:ef_steroid/services/log/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:async/async.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final ShakeController shakeController;

  const ShakeWidget({
    Key? key,
    required this.child,
    required this.shakeController,
  }) : super(key: key);

  @override
  _ShakeWidgetState createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  CancelableOperation? _cancelableShake;
  final LogService _logService = GetIt.I<LogService>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    widget.shakeController.addListener(_shake);
  }

  @override
  void dispose() {
    widget.shakeController.removeListener(_shake);
    _controller.dispose();
    _cancelableShake?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offsetAnimation = Tween(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.linear))
        .animate(_controller);

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value, 0.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  void _shake() {
    if (widget.shakeController.enabled == false) return;
    widget.shakeController.isShaking = true;
    try {
      final tickerFuture = _controller.repeat(reverse: true);
      _cancelableShake?.cancel();
      _cancelableShake = CancelableOperation.fromFuture(
        tickerFuture.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            _controller.forward(from: 0);
            _controller.stop(canceled: true);
            widget.shakeController.enabled = false;
            widget.shakeController.isShaking = false;
          },
        ),
      );
    } catch (ex, stackTrace) {
      _logService.severe(ex, stackTrace);
    }
  }
}

class ShakeController extends ValueNotifier<ShakeValue> {
  bool isShaking = false;

  ShakeController({bool enabled = false}) : super(ShakeValue(enabled));

  bool get enabled => value.enabled;

  @protected
  set enabled(bool newValue) {
    if (isShaking) return;
    value = value.copyWith(enabled: newValue);
  }

  void shake() {
    enabled = true;
  }
}

class ShakeValue {
  final bool enabled;

  ShakeValue(this.enabled);

  ShakeValue copyWith({required bool enabled}) => ShakeValue(enabled);
}
