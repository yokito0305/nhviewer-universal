import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/comic_card_data.dart';
import 'package:concept_nhv/state/comic_feed_model.dart';
import 'package:concept_nhv/state/home_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comic_card.dart';

class ComicGridSliver extends StatelessWidget {
  const ComicGridSliver({
    super.key,
    required this.comics,
    this.pageLoaded,
    this.collectionType,
    this.onCollectionChanged,
  });

  final List<ComicCardData> comics;
  final int? pageLoaded;
  final CollectionType? collectionType;
  final VoidCallback? onCollectionChanged;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 300,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final reachLastItem = index + 1 == comics.length;
        final feedModel = context.read<ComicFeedModel>();
        final homeUiModel = context.read<HomeUiModel>();

        if (pageLoaded != null &&
            reachLastItem &&
            !feedModel.noMorePage &&
            !homeUiModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (homeUiModel.isLoading) {
              return;
            }
            homeUiModel.setLoading(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Loading... page: ${pageLoaded! + 1}, language: ${feedModel.currentLanguage.name}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            await feedModel.fetchNextPage(page: pageLoaded! + 1);
            homeUiModel.setLoading(false);
          });
        }

        return ComicCard(
          comic: comics[index],
          collectionType: collectionType,
          onCollectionChanged: onCollectionChanged,
        );
      }, childCount: comics.length),
    );
  }
}
