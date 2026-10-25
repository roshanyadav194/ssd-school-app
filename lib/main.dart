import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF071324),
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
        // Non-const PageTransitionsTheme to prevent Flutter 3.41+ compile errors
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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
  bool _initialSplashVisible = true;
  bool _hasError = false;
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
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _initialSplashVisible = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only show offline screen if the main frame fails to load
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
                _initialSplashVisible = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            final uri = Uri.parse(url);

            if (uri.scheme == 'tel' ||
                uri.scheme == 'mailto' ||
                uri.scheme == 'whatsapp' ||
                url.contains('wa.me') ||
                url.contains('api.whatsapp.com') ||
                url.contains('maps.app.goo.gl') ||
                url.contains('google.com/maps') ||
                url.endsWith('.pdf')) {
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_websiteUrl));
  }

  Widget _buildSchoolLogo({double size = 96}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFD6AD55), Color(0xFFFDE68A), Color(0xFFB4862F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DD6AD55),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Image.asset(
          'app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF102747),
              child: const Icon(
                Icons.school_rounded,
                color: Color(0xFFD6AD55),
                size: 46,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialSplashOverlay() {
    return AnimatedOpacity(
      opacity: _initialSplashVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: IgnorePointer(
        ignoring: !_initialSplashVisible,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071324), Color(0xFF102747), Color(0xFF08162B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSchoolLogo(size: 110),
              const SizedBox(height: 24),
              const Text(
                'S.S.D. CONVENT SCHOOL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Champapur, Janghai, Prayagraj',
                style: TextStyle(
                  color: Color(0xFFD6AD55),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress > 0.05 ? _progress : null,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFD6AD55),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading Smart Campus Portal... ${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: const Color(0xFF08162B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSchoolLogo(size: 88),
          const SizedBox(height: 22),
          const Text(
            'Connection Unavailable',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your mobile data or Wi-Fi connection to access the S.S.D. Convent School portal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6AD55),
                foregroundColor: const Color(0xFF071324),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Retry Connection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final uri = Uri.parse('tel:+917880884750');
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              icon: const Icon(Icons.call_rounded, size: 18, color: Color(0xFFD6AD55)),
              label: const Text('Call School Office (+91 78808 84750)'),
            ),
          ),
        ],
      ),
    );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0x33D6AD55)),
                ),
                title: Row(
                  children: [
                    _buildSchoolLogo(size: 36),
                    const SizedBox(width: 12),
                    const Text(
                      'Exit App?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Do you want to exit the S.S.D. Convent School app?',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'Stay',
                      style: TextStyle(
                        color: Color(0xFFD6AD55),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
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
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08162B),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_hasError) _buildOfflineScreen(),
              if (_initialSplashVisible) _buildInitialSplashOverlay(),
              if (_isLoading && !_initialSplashVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: const Color(0xFF08162B),
                    color: const Color(0xFFD6AD55),
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
