import 'package:flutter/widgets.dart';

abstract class Disposable with DisposableMixin {}

mixin DisposableMixin {
  @mustCallSuper
  void dispose();
}
