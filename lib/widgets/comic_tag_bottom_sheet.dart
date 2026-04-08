import 'package:concept_nhv/models/comic_tag.dart';
import 'package:concept_nhv/models/collection_type.dart';
import 'package:concept_nhv/models/tag_type_l10n.dart';
import 'package:flutter/material.dart';

class ComicTagBottomSheet extends StatefulWidget {
  const ComicTagBottomSheet({
    super.key,
    required this.title,
    required this.initialTags,
    required this.onSearchSelected,
    this.loadTags,
    this.collectionType,
    this.onRemoveFromCollection,
  });

  final String title;
  final List<ComicTag> initialTags;
  final Future<List<ComicTag>> Function()? loadTags;
  final ValueChanged<List<String>> onSearchSelected;
  final CollectionType? collectionType;
  final VoidCallback? onRemoveFromCollection;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<ComicTag> tags,
    required ValueChanged<List<String>> onSearchSelected,
    Future<List<ComicTag>> Function()? loadTags,
    CollectionType? collectionType,
    VoidCallback? onRemoveFromCollection,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ComicTagBottomSheet(
        title: title,
        initialTags: tags,
        loadTags: loadTags,
        onSearchSelected: onSearchSelected,
        collectionType: collectionType,
        onRemoveFromCollection: onRemoveFromCollection,
      ),
    );
  }

  @override
  State<ComicTagBottomSheet> createState() => _ComicTagBottomSheetState();
}

class _ComicTagBottomSheetState extends State<ComicTagBottomSheet> {
  List<ComicTag>? _tags;
  String? _errorMessage;
  bool _isLoading = false;
  final Set<String> _selectedQueries = <String>{};

  @override
  void initState() {
    super.initState();
    if (widget.initialTags.isNotEmpty) {
      _tags = widget.initialTags;
      return;
    }
    _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final tags = _tags ?? const <ComicTag>[];
    final grouped = _groupTagsByType(tags);
    final sortedTypes = _sortedTypeKeys(grouped.keys.toList());

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _buildBody(
                context: context,
                locale: locale,
                grouped: grouped,
                sortedTypes: sortedTypes,
                scrollController: scrollController,
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_selectedQueries.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: (_selectedQueries.toList()..sort()).map((query) {
                            return Chip(
                              label: Text(query),
                              onDeleted: () => setState(() {
                                _selectedQueries.remove(query);
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    if (_selectedQueries.isNotEmpty) const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _selectedQueries.isEmpty ? null : _handleSearch,
                        icon: const Icon(Icons.search),
                        label: Text(
                          _selectedQueries.isEmpty
                              ? 'Select tags to search'
                              : 'Search ${_selectedQueries.length} tags',
                        ),
                      ),
                    ),
                    if (widget.collectionType != null &&
                        widget.onRemoveFromCollection != null) ...<Widget>[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: Text(
                            'Remove from ${widget.collectionType!.displayName}',
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onRemoveFromCollection!();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required Locale locale,
    required Map<String, List<ComicTag>> grouped,
    required List<String> sortedTypes,
    required ScrollController scrollController,
  }) {
    if (_isLoading && _tags == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _tags == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(_errorMessage!),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadTags,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if ((_tags ?? const <ComicTag>[]).isEmpty) {
      return const Center(child: Text('No tags'));
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        for (final type in sortedTypes) ...<Widget>[
          _TagTypeSection(
            typeName: TagTypeL10n.localizedName(type, locale),
            tags: grouped[type]!,
            selectedQueries: _selectedQueries,
            onToggleTag: (tag) {
              final query = _buildTagQuery(tag);
              setState(() {
                if (_selectedQueries.contains(query)) {
                  _selectedQueries.remove(query);
                } else {
                  _selectedQueries.add(query);
                }
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _loadTags() async {
    final loadTags = widget.loadTags;
    if (loadTags == null) {
      setState(() {
        _tags = widget.initialTags;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tags = await loadTags();
      if (!mounted) {
        return;
      }
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Failed to load tags.';
        _isLoading = false;
      });
    }
  }

  void _handleSearch() {
    final selected = _selectedQueries.toList()..sort();
    Navigator.of(context).pop();
    widget.onSearchSelected(selected);
  }

  Map<String, List<ComicTag>> _groupTagsByType(List<ComicTag> tags) {
    final result = <String, List<ComicTag>>{};
    for (final tag in tags) {
      final type = tag.type ?? 'tag';
      result.putIfAbsent(type, () => <ComicTag>[]).add(tag);
    }
    return result;
  }

  List<String> _sortedTypeKeys(List<String> keys) {
    const priority = <String>[
      'parody',
      'character',
      'tag',
      'artist',
      'group',
      'language',
      'category',
    ];
    final prioritized = <String>[];
    final rest = <String>[];
    for (final key in keys) {
      if (priority.contains(key)) {
        prioritized.add(key);
      } else {
        rest.add(key);
      }
    }
    prioritized.sort((a, b) => priority.indexOf(a) - priority.indexOf(b));
    rest.sort();
    return <String>[...prioritized, ...rest];
  }

  String _buildTagQuery(ComicTag tag) {
    final type = tag.type ?? 'tag';
    final name = (tag.name ?? '').toLowerCase().replaceAll(' ', '-');
    return '$type:$name';
  }
}

class _TagTypeSection extends StatelessWidget {
  const _TagTypeSection({
    required this.typeName,
    required this.tags,
    required this.selectedQueries,
    required this.onToggleTag,
  });

  final String typeName;
  final List<ComicTag> tags;
  final Set<String> selectedQueries;
  final ValueChanged<ComicTag> onToggleTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          typeName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: tags.map((tag) {
            final query =
                '${tag.type ?? 'tag'}:${(tag.name ?? '').toLowerCase().replaceAll(' ', '-')}';
            return FilterChip(
              label: Text(tag.name ?? ''),
              selected: selectedQueries.contains(query),
              onSelected: (_) => onToggleTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
