import 'package:flutter/material';
import 'package:window_manager/window_manager.dart';
import 'days_since_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the window manager package
  await windowManager.ensureInitialized();

  // Configure the window options for a compact, always-on-top corner widget
  WindowOptions windowOptions = const WindowOptions(
    size: Size(380, 320),
    minimumSize: Size(340, 300),
    maximumSize: Size(420, 360),
    center: false, // Do not center; we want it positioned in a specific corner
    title: 'Time Since Counter',
    titleBarStyle: TitleBarStyle.hidden, // Hides native title bar for custom styling
    alwaysOnTop: true, // Forces "Always on Top" overlay behavior on macOS/Windows
    skipTaskbar: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Position the window in the top-right corner of the screen
    final screens = await windowManager.getPrimaryDisplay();
    if (screens != null) {
      final double screenWidth = screens.visibleSize?.width ?? 1920;
      // Position 40 pixels from the right and 40 pixels from the top of the screen
      final double x = screenWidth - 380 - 40;
      final double y = 40;
      await windowManager.setPosition(Offset(x, y));
    }

    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Since Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: Colors.transparent, // Allows a transparent or custom window backing
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: DaysSinceWidget(),
        ),
      ),
    );
  }
}
