

# Refresh On Drag Indicator

This package integrate a drag funcionality at the bottom and top of a ScrollView having a Callback when the drag is completed 

## Installation 

1. Add the latest version of package to your pubspec.yaml (and run`dart pub get`):
```yaml
dependencies:
  refresh_on_drag_indicator:^0.0.8
```

2. Import the package and use it in your Flutter App.
```dart
import 'package:refresh_on_drag_indicator/refresh_on_drag_indicator.dart';
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:refresh_on_drag_indicator/refresh_on_drag_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Refresh on drag Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: ExampleView());
  }
}

class ExampleView extends StatefulWidget {
  const ExampleView({super.key});

  @override
  State<ExampleView> createState() => _ExampleViewState();
}

class _ExampleViewState extends State<ExampleView> {
  final content = [1, 2, 3, 4, 5];
  Widget loader = RefreshLoader();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Refresh on drag"),
      ),
      body: RefreshOnDragIndicator(
        refreshDragType: RefreshDragEnum.both,
        onTopRequestedLoad: () async {
          await Future.delayed(Duration(seconds: 2));
        },
        onBottomRequestedLoad: () async {
          await Future.delayed(Duration(seconds: 2));
        },
        topLoaderWidget: loader,
        bottomEndPosition: 200,
        topEndPosition: 300,
        child: ListView.builder(
          itemCount: content.length,
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              height: 150,
              margin: EdgeInsets.all(8),
              color: Colors.primaries[Colors.primaries.length % (index + 1)],
            );
          },
        ),
      ),
    );
  }
}



```

