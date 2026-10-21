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

class _SSDWebViewScreenState extends State<SSDWebViewScreen>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;
  late final AnimationController _shimmerController;

  final String _websiteUrl = 'https://ssdconvent.pages.dev';

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF08162B))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
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
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      final canBack = await _controller.canGoBack();
      setState(() {
        _canGoBack = canBack;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Exit S.S.D. Convent School?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to close the app?',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFD6AD55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
        body: SafeArea(
          child: Stack(
            children: [
              // 1. WebView Container
              RefreshIndicator(
                color: const Color(0xFFD6AD55),
                backgroundColor: const Color(0xFF0A1E38),
                onRefresh: () async {
                  await _controller.reload();
                },
                child: WebViewWidget(controller: _controller),
              ),

              // 2. Native App Skeleton Shimmer (Replaces browser progress lines)
              if (_isLoading)
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      color: const Color(0xFF08162B),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [
                                  _shimmerController.value - 0.3,
                                  _shimmerController.value,
                                  _shimmerController.value + 0.3,
                                ],
                                colors: const [
                                  Color(0xFF0F2442),
                                  Color(0xFF1E3A66),
                                  Color(0xFF0F2442),
                                ],
                              ).createShader(bounds);
                            },
                            child: child,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2442),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F2442),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F2442),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2442),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2442),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 3. Floating Glassmorphic Top Back Button (Appears only on subpages)
              Positioned(
                top: 14,
                left: 14,
                child: AnimatedOpacity(
                  opacity: _canGoBack ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_canGoBack,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleBackPress,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1E38).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFD6AD55).withOpacity(0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Color(0xFFD6AD55),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }
}
