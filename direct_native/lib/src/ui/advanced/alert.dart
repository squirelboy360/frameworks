import '../primitives/view.dart';
import '../primitives/text.dart';
import '../primitives/button.dart';
import 'modal.dart';

class Alert extends Modal {
  Alert({
    required String title,
    required String message,
    required Function onConfirm,
    Function? onCancel,
    bool isVisible = false,
    Map<String, dynamic> style = const {},
  }) : super(
          content: View(
            children: [
              Text(title, style: {'fontSize': 18, 'fontWeight': 'bold'}),
              Text(message),
              View(
                children: [
                  Button(
                    label: 'OK',
                    onPressed: onConfirm,
                    style: {'backgroundColor': '#007AFF', 'color': '#FFFFFF'},
                  ),
                  if (onCancel != null)
                    Button(
                      label: 'Cancel',
                      onPressed: onCancel,
                      style: {'backgroundColor': '#FF3B30', 'color': '#FFFFFF'},
                    ),
                ],
                style: {'flexDirection': 'row', 'justifyContent': 'space-around'},
              ),
            ],
            style: {
              'backgroundColor': '#FFFFFF',
              'borderRadius': 10,
              'padding': 20,
              'width': '80%',
              'maxWidth': 300,
            },
          ),
          isVisible: isVisible,
          style: style,
        );
}