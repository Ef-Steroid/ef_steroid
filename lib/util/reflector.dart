import 'package:reflectable/reflectable.dart';

class Reflector extends Reflectable {
  const Reflector() : super(invokingCapability);
}

const reflector = Reflector();
