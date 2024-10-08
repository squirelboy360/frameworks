import 'package:direct_native/direct_native.dart';

void main() {
  final app = DNApp(
    rootView: View(
      children: [
        Text('Welcome to Direct Native!', 
          style: {'fontSize': 24, 'color': '#000000'}),
        Button(
          label: 'Click me',
          onPressed: () {
            print('Button clicked!');
          },
          style: {'backgroundColor': '#0000FF', 'color': '#FFFFFF'},
        ),
      ],
      style: {'padding': 16, 'backgroundColor': '#FFFFFF'},
    ),
  );

  app.run();
}