import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'days_since_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the window manager package
  await windowManager.ensureInitialized();

  // Configure the window options for a tiny, ultra-compact always-on-top corner widget (half the previous size)
  WindowOptions windowOptions = const WindowOptions(
    size: Size(180, 36),
    minimumSize: Size(120, 28),
    maximumSize: Size(380, 80),
    center: false, // Do not center; we want it positioned in a specific corner
    title: 'Time Since',
    titleBarStyle: TitleBarStyle.hidden, // Hides native title bar for custom styling
    alwaysOnTop: true, // Forces "Always on Top" overlay behavior on macOS/Windows
    skipTaskbar: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Make the native window background completely transparent
    await windowManager.setBackgroundColor(Colors.transparent);
    
    // Position the window in the top-right corner of the screen
    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final double screenWidth = primaryDisplay.visibleSize?.width ?? 1920;
    // Position 40 pixels from the right and 40 pixels from the top of the screen
    final double x = screenWidth - 180 - 40;
    final double y = 40;
    
    await windowManager.setPosition(Offset(x, y));
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'), // Forces DD/MM/YYYY formatting
      ],
      locale: const Locale('en', 'GB'),
      home: Scaffold(
        backgroundColor: Colors.transparent, // Completely transparent backing
        body: ClipRect( // Clips any child overflow to prevent rendering artifacts
          child: Padding(
            padding: EdgeInsets.zero, // Zero padding so only the capsule is drawn
            child: DaysSinceWidget(),
          ),
        ),
      ),
    );
  }
}
