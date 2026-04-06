import 'package:cached_network_image/cached_network_image.dart';
import 'package:concept_nhv/application/reader/reader_settings_repository.dart';
import 'package:concept_nhv/services/comic_page_source_resolver.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/widgets/fallback_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---------------------------------------------------------------------------
// Public screen widget
// ---------------------------------------------------------------------------

class ComicReaderScreen extends StatefulWidget {
  const ComicReaderScreen({super.key, required this.comicId});

  final String comicId;

  @override
  State<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreLastSeenPage());
  }

  Future<void> _restoreLastSeenPage() async {
    final model = context.read<ComicReaderModel>();
    final lastPage = await model.loadLastSeenPage(widget.comicId);
    if (!mounted || lastPage == null || lastPage <= 1) return;

    // Wait until the comic is loaded so numPages is known.
    if (model.currentComic == null) return;
    final targetPage = lastPage.clamp(1, model.totalPages);
    model.goToPage(targetPage);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resumed from page $targetPage'),
        action: SnackBarAction(
          label: 'Go to start',
          onPressed: () => model.goToPage(1),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ComicReaderModel>(
        builder: (context, model, _) {
          final comic = model.currentComic;
          if (comic == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // ── Main paged reader ──────────────────────────────────────────
              PageView.builder(
                controller: model.pageController,
                itemCount: comic.numPages,
                onPageChanged: (index) {
                  model.onPageChanged(index, widget.comicId);
                  _prefetchSurroundingPages(context, index + 1);
                },
                itemBuilder: (context, index) {
                  final page = index + 1;
                  final pageImage = comic.images.pages[index];
                  final url = context
                      .read<ComicPageSourceResolver>()
                      .resolvePageUrl(comic: comic, pageNumber: page);

                  return _PageWidget(
                    url: url,
                    width: pageImage.w ?? 9,
                    height: pageImage.h ?? 16,
                    onTapZone: (zone) => _handleTapZone(zone, model),
                  );
                },
              ),

              // ── Top bar (fades in with controls) ──────────────────────────
              // Use Positioned so it never expands beyond its natural height
              // and cannot swallow taps in the centre of the screen.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !model.showControls,
                  child: _AnimatedTopBar(
                    visible: model.showControls,
                    currentPage: model.currentPage,
                    totalPages: model.totalPages,
                  ),
                ),
              ),

              // ── Bottom controls overlay ────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: !model.showControls,
                  child: _AnimatedBottomControls(
                    visible: model.showControls,
                    currentPage: model.currentPage,
                    totalPages: model.totalPages,
                    onPageSliderChanged: (value) => model.goToPage(value.round()),
                    onSettingsTap: () => _showReaderSettings(context, model),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tap zone handler
  // ---------------------------------------------------------------------------

  void _handleTapZone(_TapZone zone, ComicReaderModel model) {
    switch (zone) {
      case _TapZone.left:
        model.goToPage(model.currentPage - 1);
      case _TapZone.right:
        model.goToPage(model.currentPage + 1);
      case _TapZone.center:
        model.toggleControls();
    }
  }

  // ---------------------------------------------------------------------------
  // Pre-fetch surrounding pages
  // ---------------------------------------------------------------------------

  void _prefetchSurroundingPages(BuildContext context, int currentPage) {
    final model = context.read<ComicReaderModel>();
    final comic = model.currentComic;
    if (comic == null) return;

    final resolver = context.read<ComicPageSourceResolver>();
    final headers = model.currentHeaders;
    final range = model.prefetchPageCount;

    final first = (currentPage - range).clamp(1, comic.numPages);
    final last = (currentPage + range).clamp(1, comic.numPages);

    for (int page = first; page <= last; page++) {
      if (page == currentPage) continue;
      final url = resolver.resolvePageUrl(comic: comic, pageNumber: page);
      precacheImage(
        CachedNetworkImageProvider(url, headers: headers),
        context,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reader settings bottom sheet
  // ---------------------------------------------------------------------------

  void _showReaderSettings(BuildContext context, ComicReaderModel model) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return _ReaderSettingsSheet(model: model);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tap zone enum
// ---------------------------------------------------------------------------

enum _TapZone { left, center, right }

// ---------------------------------------------------------------------------
// Single page widget with pinch-to-zoom and tap zones
// ---------------------------------------------------------------------------

class _PageWidget extends StatefulWidget {
  const _PageWidget({
    required this.url,
    required this.width,
    required this.height,
    required this.onTapZone,
  });

  final String url;
  final int width;
  final int height;
  final void Function(_TapZone zone) onTapZone;

  @override
  State<_PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<_PageWidget> {
  final TransformationController _transformController =
      TransformationController();
  bool _isPanEnabled = false;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final panEnabled = scale > 1.01;
    if (panEnabled != _isPanEnabled) {
      setState(() => _isPanEnabled = panEnabled);
    }
  }

  bool get _isZoomed => _isPanEnabled;

  void _handleTapUp(TapUpDetails details) {
    // Tapping while zoomed in should not trigger page navigation, only
    // toggling the controls is allowed via the centre tap.
    if (_isZoomed) return;

    final width = context.size?.width ?? 1;
    final dx = details.localPosition.dx;

    if (dx < width * 0.3) {
      widget.onTapZone(_TapZone.left);
    } else if (dx > width * 0.7) {
      widget.onTapZone(_TapZone.right);
    } else {
      widget.onTapZone(_TapZone.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: _handleTapUp,
      child: InteractiveViewer(
        transformationController: _transformController,
        panEnabled: _isPanEnabled,
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: FallbackCachedNetworkImage(
            url: widget.url,
            width: widget.width,
            height: widget.height,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated top app-bar
// ---------------------------------------------------------------------------

class _AnimatedTopBar extends StatelessWidget {
  const _AnimatedTopBar({
    required this.visible,
    required this.currentPage,
    required this.totalPages,
  });

  final bool visible;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        // Use a plain Container + Row instead of AppBar.
        // AppBar uses Material which, under loose Stack constraints, can
        // expand to fill the entire screen and intercept tap events.
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                  const Spacer(),
                  Text(
                    '$currentPage / $totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated bottom controls (slider + settings)
// ---------------------------------------------------------------------------

class _AnimatedBottomControls extends StatelessWidget {
  const _AnimatedBottomControls({
    required this.visible,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSliderChanged,
    required this.onSettingsTap,
  });

  final bool visible;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double> onPageSliderChanged;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Page indicator
                  Text(
                    '$currentPage',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  // Page slider
                  Expanded(
                    child: Slider(
                      value: totalPages > 1
                          ? currentPage.toDouble().clamp(
                              1.0, totalPages.toDouble())
                          : 1.0,
                      min: 1.0,
                      max: totalPages > 1 ? totalPages.toDouble() : 2.0,
                      divisions: totalPages > 1 ? totalPages - 1 : 1,
                      onChanged: totalPages > 1 ? onPageSliderChanged : null,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                  ),
                  // Total pages
                  Text(
                    '$totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: 'Reader settings',
                    onPressed: onSettingsTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reader settings bottom sheet content
// ---------------------------------------------------------------------------

class _ReaderSettingsSheet extends StatefulWidget {
  const _ReaderSettingsSheet({required this.model});

  final ComicReaderModel model;

  @override
  State<_ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<_ReaderSettingsSheet> {
  late int _prefetchCount;

  @override
  void initState() {
    super.initState();
    _prefetchCount = widget.model.prefetchPageCount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reader Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Pre-fetch pages (before & after)'),
              ),
              Text('$_prefetchCount'),
            ],
          ),
          Slider(
            value: _prefetchCount.toDouble(),
            min: ReaderSettingsRepository.minPrefetchPageCount.toDouble(),
            max: ReaderSettingsRepository.maxPrefetchPageCount.toDouble(),
            divisions: ReaderSettingsRepository.maxPrefetchPageCount -
                ReaderSettingsRepository.minPrefetchPageCount,
            label: '$_prefetchCount',
            onChanged: (value) {
              setState(() => _prefetchCount = value.round());
            },
            onChangeEnd: (value) {
              widget.model.savePrefetchPageCount(value.round());
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Currently caching $_prefetchCount page(s) on each side of the'
            ' current page.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
