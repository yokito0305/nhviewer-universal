import 'package:concept_nhv/services/cloudflare_cookie_service.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef BootstrapWebViewBuilder = Widget Function(WebViewController controller);
typedef BootstrapWebViewControllerFactory = WebViewController Function();

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({
    super.key,
    this.webViewBuilder,
    this.webViewControllerFactory,
    this.verificationView,
  });

  final BootstrapWebViewBuilder? webViewBuilder;
  final BootstrapWebViewControllerFactory? webViewControllerFactory;
  final Widget? verificationView;

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  WebViewController? _controller;
  late final Future<bool> _validationFuture;
  bool _requestedVerificationPage = false;
  bool _isCapturing = false;
  bool _hasScheduledNavigation = false;

  @override
  void initState() {
    super.initState();
    _validationFuture = _validateCookies();
  }

  Future<bool> _validateCookies() {
    return context.read<CloudflareCookieService>().validateStoredCloudflareCookies();
  }

  Future<void> _handleVerificationPageFinished() async {
    if (_isCapturing) {
      return;
    }
    _isCapturing = true;

    final homeUiModel = context.read<HomeUiModel>();
    homeUiModel.setLoading(true);

    final cookieService = context.read<CloudflareCookieService>();
    final pair =
        await cookieService.captureAndPersistCloudflareCookies(_controller!);
    final isValid = !pair.isEmpty && await cookieService.validateStoredCloudflareCookies();

    if (!mounted || !isValid) {
      homeUiModel.setLoading(false);
      _isCapturing = false;
      return;
    }

    await _loadHomeFeedAndNavigate();
    _isCapturing = false;
  }

  Future<void> _loadHomeFeedAndNavigate() async {
    if (_hasScheduledNavigation) {
      return;
    }
    _hasScheduledNavigation = true;

    final homeUiModel = context.read<HomeUiModel>();
    homeUiModel.setLoading(true);
    await context.read<ComicFeedModel>().loadHomeFeed();
    if (!mounted) {
      return;
    }
    homeUiModel.setLoading(false);
    context.go('/index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _validationFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _BootstrapLoadingState(label: 'Loading...');
          }

          if (snapshot.data == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadHomeFeedAndNavigate();
            });
            return const _BootstrapLoadingState(label: 'Loading index...');
          }

          if (!_requestedVerificationPage) {
            _requestedVerificationPage = true;
            if (widget.verificationView == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _ensureController().loadRequest(Uri.parse('https://nhentai.net'));
              });
            }
          }

          return SafeArea(
            child: Scaffold(
              body: Center(
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Passing Cloudflare checking, please wait and click "I am human" checkbox if any...',
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: widget.verificationView ??
                            (widget.webViewBuilder ?? WebViewWidget.new)(
                              _ensureController(),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  WebViewController _ensureController() {
    return _controller ??= (widget.webViewControllerFactory ?? _createController).call();
  }

  WebViewController _createController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _handleVerificationPageFinished(),
        ),
      );
  }
}

class _BootstrapLoadingState extends StatelessWidget {
  const _BootstrapLoadingState({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          Text(label),
        ],
      ),
    );
  }
}
