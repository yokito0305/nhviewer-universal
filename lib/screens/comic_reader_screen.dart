import 'package:concept_nhv/models/image_format.dart';
import 'package:concept_nhv/state/comic_reader_model.dart';
import 'package:concept_nhv/widgets/fallback_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComicReaderScreen extends StatefulWidget {
  const ComicReaderScreen({
    super.key,
    required this.comicId,
  });

  final String comicId;

  @override
  State<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreLastSeenOffset();
    });
  }

  Future<void> _restoreLastSeenOffset() async {
    final readerModel = context.read<ComicReaderModel>();
    final offset = await readerModel.loadLastSeenOffset(widget.comicId);
    if (!mounted || offset == null || !readerModel.scrollController.hasClients) {
      return;
    }

    await readerModel.scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Loaded last seen page'),
        action: SnackBarAction(
          label: 'Back to top',
          onPressed: () => readerModel.scrollController.jumpTo(0),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerModel = context.read<ComicReaderModel>();

    return Scaffold(
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          readerModel.persistLastSeenOffset(widget.comicId);
          return false;
        },
        child: CustomScrollView(
          controller: readerModel.scrollController,
          slivers: <Widget>[
            SliverAppBar(
              forceMaterialTransparency: true,
              pinned: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.black38, Colors.transparent],
                    stops: <double>[0, 1],
                  ),
                ),
              ),
            ),
            Consumer<ComicReaderModel>(
              builder: (context, model, child) {
                final comic = model.currentComic;
                if (comic == null) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const LinearProgressIndicator(),
                      childCount: 1,
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final page = index + 1;
                      final pageImage = comic.images.pages[index];
                      final extension = imageTypeCodeToExtension(pageImage.t);
                      final url =
                          'https://i.nhentai.net/galleries/${comic.mediaId}/$page.$extension';

                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          FallbackCachedNetworkImage(
                            url: url,
                            width: pageImage.w ?? 9,
                            height: pageImage.h ?? 16,
                          ),
                          Text('P$page'),
                        ],
                      );
                    },
                    childCount: comic.numPages,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

