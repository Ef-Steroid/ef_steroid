import 'package:fast_dotnet_ef/views/widgets/shake_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:fast_dotnet_ef/models/form/form_field_model.dart';

class TextEditingFormFieldModel extends FormFieldModel {
  final TextEditingController textEditingController;

  TextEditingFormFieldModel()
      : textEditingController = TextEditingController(),
        super(shakeController: ShakeController());

  TextEditingFormFieldModel.fromValue({
    required this.textEditingController,
    ShakeController? shakeController,
  }) : super(shakeController: shakeController ?? ShakeController());

  @override
  void dispose() {
    textEditingController.dispose();
    shakeController.dispose();
  }

  /// Return the [TextEditingController.text].
  String toText() => textEditingController.text;
}
