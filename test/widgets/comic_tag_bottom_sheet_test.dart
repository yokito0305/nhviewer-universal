import 'package:concept_nhv/models/comic_tag.dart';
import 'package:concept_nhv/widgets/comic_tag_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supports multi-select tag search from the bottom sheet', (tester) async {
    List<String>? selectedQueries;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComicTagBottomSheet(
            title: 'Sample Comic',
            initialTags: <ComicTag>[
              ComicTag(
                id: 1,
                type: 'tag',
                name: 'full color',
                url: '/tag/full-color/',
                count: 1,
              ),
              ComicTag(
                id: 2,
                type: 'language',
                name: 'chinese',
                url: '/language/chinese/',
                count: 1,
              ),
            ],
            onSearchSelected: (queries) => selectedQueries = queries,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('full color'));
    await tester.tap(find.text('chinese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search 2 tags'));
    await tester.pumpAndSettle();

    expect(
      selectedQueries,
      <String>['language:chinese', 'tag:full-color'],
    );
  });
}
