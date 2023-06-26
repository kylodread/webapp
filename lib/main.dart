import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absol Web App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('Absol & Porsche Events'),
        centerTitle: true,
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
