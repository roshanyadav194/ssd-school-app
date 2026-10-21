// Production-ready Flutter Shell with Floating Glassmorphic Back & Skeleton Transitions
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF071324),
      systemNavigationBarIconBrightness: Brightness.light,
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
          seedColor: const Color(0xFF0A1E38),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071324),
        useMaterial3: true,
      ),
      home: const NativeShellWebView(),
    );
  }
}

class NativeShellWebView extends StatefulWidget {
  const NativeShellWebView({super.key});

  @override
  State createState() => _NativeShellWebViewState();
}

class _NativeShellWebViewState extends State {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;

  final String _schoolPortalUrl = 'https://ssdconvent.pages.dev';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF071324))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            final canBack = await _controller.canGoBack();
            setState(() {
              _isLoading = false;
              _canGoBack = canBack;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            // Handle native app intents (Phone calls, WhatsApp, Maps)
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
      ..loadRequest(Uri.parse(_schoolPortalUrl));
  }

  Future _handleBackPress() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      final canBack = await _controller.canGoBack();
      setState(() => _canGoBack = canBack);
    } else {
      _showExitDialog();
    }
  }

  Future _showExitDialog() async {
    if (!mounted) return;
    final shouldExit = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D223F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit School App?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Do you want to exit S.S.D. Convent School?', style: TextStyle(color: Color(0xFFCBD5E1))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFD6AD55), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: const Color(0xFF071324),
        body: Stack(
          children: [
            // 1. Full Screen Web Content (No Browser Borders)
            SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFD6AD55),
                backgroundColor: const Color(0xFF0D223F),
                onRefresh: () async => await _controller.reload(),
                child: WebViewWidget(controller: _controller),
              ),
            ),

            // 2. AESTHETIC FLOATING TOP BACK BUTTON (Glassmorphic Pill)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              child: AnimatedOpacity(
                opacity: _canGoBack ? 1.0 : 0.85,
                duration: const Duration(milliseconds: 250),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1E38).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD6AD55).withOpacity(0.3), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _handleBackPress,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFFD6AD55)),
                                const SizedBox(width: 6),
                                Text(
                                  _canGoBack ? 'Back' : 'Home',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. NATIVE SKELETON LOAD OVERLAY (Smooth App-feel transition)
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF071324),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFF3D27A), Color(0xFFB88E31)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD6AD55).withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: const Icon(Icons.school_rounded, color: Color(0xFF071324), size: 34),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'S.S.D. CONVENT SCHOOL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            color: Color(0xFFD6AD55),
                            backgroundColor: Color(0xFF0F2646),
                            minHeight: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
