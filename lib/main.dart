import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF071324),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SSDConventApp());
}

class SSDConventApp extends StatelessWidget {
  const SSDConventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S.S.D. Convent School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF102747)),
        useMaterial3: true,
      ),
      home: const SSDWebViewScreen(),
    );
  }
}

class SSDWebViewScreen extends StatefulWidget {
  const SSDWebViewScreen({super.key});

  @override
  State<SSDWebViewScreen> createState() => _SSDWebViewScreenState();
}

class _SSDWebViewScreenState extends State<SSDWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  final String _websiteUrl = 'https://ssdconvent.pages.dev';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF08162B))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            if (uri.scheme == 'tel' ||
                uri.scheme == 'mailto' ||
                request.url.contains('wa.me') ||
                request.url.contains('maps.app.goo.gl') ||
                request.url.contains('google.com/maps')) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_websiteUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF08162B),
                title: const Text(
                  'Exit App?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Do you want to exit S.S.D. Convent School app?',
                  style: TextStyle(color: Color(0xFFCBD5E1)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFD6AD55))),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Exit', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
            if (shouldExit == true) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08162B),
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFFD6AD55),
                backgroundColor: const Color(0xFF08162B),
                onRefresh: () async {
                  await _controller.reload();
                },
                child: WebViewWidget(controller: _controller),
              ),
              if (_isLoading)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: const Color(0xFF08162B),
                  color: const Color(0xFFD6AD55),
                  minHeight: 3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
