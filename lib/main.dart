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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF102747),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF08162B),
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
  bool _canGoBack = false;
  bool _canGoForward = false;

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
          onPageFinished: (String url) async {
            final canBack = await _controller.canGoBack();
            final canForward = await _controller.canGoForward();
            setState(() {
              _isLoading = false;
              _canGoBack = canBack;
              _canGoForward = canForward;
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

  Future<void> _handleBackPress() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      final canBack = await _controller.canGoBack();
      final canForward = await _controller.canGoForward();
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canForward;
      });
    } else {
      _showExitDialog();
    }
  }

  Future<void> _showExitDialog() async {
    if (!mounted) return;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1E38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit S.S.D. Convent School?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to close the application?',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFD6AD55), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08162B),
        // 1. TOP TOOLBAR
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A1E38),
          elevation: 2,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _canGoBack ? const Color(0xFFD6AD55) : Colors.white38,
            ),
            tooltip: 'Go Back',
            onPressed: _handleBackPress,
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/icon/app_logo.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school,
                    color: Color(0xFFD6AD55),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'S.S.D. Convent School',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD6AD55)),
              tooltip: 'Refresh',
              onPressed: () => _controller.reload(),
            ),
          ],
        ),

        // 2. MAIN WEBVIEW BODY
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFFD6AD55),
                backgroundColor: const Color(0xFF0A1E38),
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

        // 3. BOTTOM NAVIGATION BAR (WITH BACK BUTTON)
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A1E38),
            border: Border(top: BorderSide(color: Color(0xFF162D4A), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bottom Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: _canGoBack ? const Color(0xFFD6AD55) : Colors.white24,
                iconSize: 26,
                tooltip: 'Back',
                onPressed: _handleBackPress,
              ),
              // Bottom Home Button
              IconButton(
                icon: const Icon(Icons.home_rounded),
                color: const Color(0xFFD6AD55),
                iconSize: 26,
                tooltip: 'Home',
                onPressed: () => _controller.loadRequest(Uri.parse(_websiteUrl)),
              ),
              // Bottom Reload Button
              IconButton(
                icon: const Icon(Icons.replay_rounded),
                color: const Color(0xFFD6AD55),
                iconSize: 26,
                tooltip: 'Reload',
                onPressed: () => _controller.reload(),
              ),
              // Bottom Forward Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                color: _canGoForward ? const Color(0xFFD6AD55) : Colors.white24,
                iconSize: 26,
                tooltip: 'Forward',
                onPressed: () async {
                  if (await _controller.canGoForward()) {
                    await _controller.goForward();
                    final canBack = await _controller.canGoBack();
                    final canForward = await _controller.canGoForward();
                    setState(() {
                      _canGoBack = canBack;
                      _canGoForward = canForward;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
