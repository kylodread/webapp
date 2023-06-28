import 'dart:ui';

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
  late WebViewController _webViewController;
  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  bool isCameraRequested = false;
  bool _isPopupVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
  }

  Future<void> requestCameraAccess() async {
    setState(() {
      isCameraRequested = true;
    });
    await initializeCamera();
    _webViewController.evaluateJavascript('navigator.mediaDevices.getUserMedia({ video: true })');
  }

  Future<void> invokeMethod(String method) async {
    if (method == 'requestCameraAccess') {
      await requestCameraAccess();
    }
  }

  @override
  void dispose() {
    if (isCameraRequested) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: 'https://events.porschesouthafrica.co.za/',
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              _createJavascriptChannel(),
            },
            onWebViewCreated: (WebViewController controller) {
              _webViewController = controller;
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://events.porschesouthafrica.co.za/')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
          if (_isPopupVisible)
            Stack(
              children: [
                // Blurred background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                // Popup window
                const Align(
                  alignment: Alignment.center,
                  child: PopupWindow(),
                ),
              ],
            ),
        ],
      ),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              _isPopupVisible = !_isPopupVisible;
            });
          },
          child: Image.asset(
            'assets/images/absol.png',
            width: kToolbarHeight,
          ),
        ),
        title: const Text(
          'Porsche Events',
          style: TextStyle(
            fontFamily: 'POR2',
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/images/porsche.png',
              width: 27,
              height: 27,
            ),
          ),
        ],
      ),
    );
  }

  JavascriptChannel _createJavascriptChannel() {
    return JavascriptChannel(
      name: 'CameraChannel',
      onMessageReceived: (JavascriptMessage message) {
        invokeMethod(message.message);
      },
    );
  }
}

class PopupWindow extends StatelessWidget {
  const PopupWindow({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Absol Testing Unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'This is an unofficial testing unit.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
