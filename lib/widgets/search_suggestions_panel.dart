import 'package:concept_nhv/application/home/home_shell_controller.dart';
import 'package:concept_nhv/models/search_history_entry.dart';
import 'package:concept_nhv/models/tag_catalog_type.dart';
import 'package:concept_nhv/models/tag_type_l10n.dart';
import 'package:concept_nhv/state/tag_catalog_browser_model.dart';
import 'package:concept_nhv/storage/search_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchSuggestionsPanel extends StatefulWidget {
  const SearchSuggestionsPanel({
    super.key,
    required this.onHistorySelected,
  });

  final ValueChanged<String> onHistorySelected;

  @override
  State<SearchSuggestionsPanel> createState() => _SearchSuggestionsPanelState();
}

class _SearchSuggestionsPanelState extends State<SearchSuggestionsPanel> {
  late Future<List<SearchHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<TagCatalogBrowserModel>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'History'),
              Tab(text: 'Tags'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _buildHistoryTab(context),
                _buildTagsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return FutureBuilder<List<SearchHistoryEntry>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.requireData;
        if (entries.isEmpty) {
          return const Center(child: Text('No search history'));
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(entry.query),
              trailing: Text(entry.createdAt.toString()),
              onTap: () => widget.onHistorySelected(entry.query),
              onLongPress: () async {
                await context.read<SearchHistoryRepository>().remove(
                  entry.query,
                );
                if (!mounted) {
                  return;
                }
                setState(() {
                  _historyFuture = _loadHistory();
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTagsTab(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Consumer<TagCatalogBrowserModel>(
      builder: (context, model, child) {
        final page = model.currentPage;
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: SegmentedButton<TagCatalogType>(
                segments: TagCatalogType.values.map((type) {
                  return ButtonSegment<TagCatalogType>(
                    value: type,
                    label: Text(
                      TagTypeL10n.localizedName(type.apiValue, locale),
                    ),
                  );
                }).toList(),
                selected: <TagCatalogType>{model.type},
                onSelectionChanged: (selection) {
                  model.setType(selection.first);
                },
              ),
            ),
            if (model.selectedQueries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: model.selectedQueries.map((query) {
                      return Chip(
                        label: Text(query),
                        onDeleted: () => model.removeSelection(query),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (model.selectedQueries.isNotEmpty) const SizedBox(height: 8),
            if (model.isLoading && page == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (model.errorMessage != null && page == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(model.errorMessage!),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => model.loadPage(page?.page ?? 1),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  children: <Widget>[
                    if (model.isLoading) const LinearProgressIndicator(),
                    if (page != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: page.result.map((item) {
                          return FilterChip(
                            label: Text('${item.name} (${item.count})'),
                            selected: model.isSelected(item),
                            onSelected: (_) => model.toggleSelection(item),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: page == null || page.page <= 1
                        ? null
                        : () => model.loadPage(page.page - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      page == null
                          ? 'Page -'
                          : 'Page ${page.page} / ${page.numPages}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: page == null || page.page >= page.numPages
                        ? null
                        : () => model.loadPage(page.page + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: model.selectedQueries.isEmpty
                        ? null
                        : () async {
                            await context
                                .read<HomeShellController>()
                                .submitTagSearch(model.selectedQueries);
                            if (!mounted) {
                              return;
                            }
                            model.clearSelection();
                          },
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<SearchHistoryEntry>> _loadHistory() {
    return context.read<SearchHistoryRepository>().load();
  }
}
