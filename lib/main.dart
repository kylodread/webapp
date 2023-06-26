import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MaterialColor primarySwatch = createMaterialColor(Colors.black);

    return MaterialApp(
      title: 'Absol Web App',
      theme: ThemeData(
        primarySwatch: primarySwatch,
      ),
      home: const WebViewPage(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    final List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebView? _webView;
  late List<CameraDescription> cameras;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _webView = const WebView(
      initialUrl: 'https://events.porschesouthafrica.co.za/',
      javascriptMode: JavascriptMode.unrestricted,
    );
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(
          'assets/images/absol.png', // Replace with your image path
          width:
              kToolbarHeight, // Set the width to match the height of the app bar
        ),
        title: const Text(
          'Absol & Porsche Events',
          style: TextStyle(
            fontFamily: 'POR2', // Replace with your custom font name
            fontSize: 13, // Adjust the font size as needed
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/images/porsche.png', // Replace with your second logo image path
              width: 27,
              height: 27,
            ),
          ),
        ],
      ),
      body: _webView,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCamera();
        },
        tooltip: 'Open Camera',
        child: const Icon(Icons.camera),
      ),
    );
  }

  Future<void> openCamera() async {
    await _cameraController.initialize();
    await _cameraController.takePicture();
  }
}
