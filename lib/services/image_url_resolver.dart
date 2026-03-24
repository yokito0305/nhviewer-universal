class ImageUrlResolver {
  static const List<String> _thumbnailHosts = <String>[
    't.nhentai.net',
    't1.nhentai.net',
    't2.nhentai.net',
    't3.nhentai.net',
    't4.nhentai.net',
  ];

  static const List<String> _imageHosts = <String>[
    'i.nhentai.net',
    'i1.nhentai.net',
    'i2.nhentai.net',
    'i3.nhentai.net',
    'i4.nhentai.net',
  ];

  const ImageUrlResolver();

  List<String> buildFallbackImageUrls(String originalUrl) {
    final uri = Uri.tryParse(originalUrl);
    if (uri == null) {
      return <String>[originalUrl];
    }

    final hosts = switch (uri.host) {
      't.nhentai.net' ||
      't1.nhentai.net' ||
      't2.nhentai.net' ||
      't3.nhentai.net' ||
      't4.nhentai.net' => _thumbnailHosts,
      'i.nhentai.net' ||
      'i1.nhentai.net' ||
      'i2.nhentai.net' ||
      'i3.nhentai.net' ||
      'i4.nhentai.net' => _imageHosts,
      _ => <String>[uri.host],
    };

    final pathSegments = uri.pathSegments;
    final lastSegment = pathSegments.isEmpty ? '' : pathSegments.last;
    final currentExt =
        lastSegment.contains('.') ? lastSegment.split('.').last : '';
    final extensionCandidates = <String>[
      currentExt,
      'jpg',
      'webp',
      'png',
      'gif',
    ].where((extension) => extension.isNotEmpty).toSet().toList();

    final urls = <String>[originalUrl];
    for (final host in hosts) {
      for (final extension in extensionCandidates) {
        var candidateUri = uri.replace(host: host);
        if (lastSegment.contains('.')) {
          final updatedSegments = <String>[
            ...pathSegments.take(pathSegments.length - 1),
            '${lastSegment.substring(0, lastSegment.lastIndexOf('.'))}.$extension',
          ];
          candidateUri = candidateUri.replace(pathSegments: updatedSegments);
        }
        urls.add(candidateUri.toString());
      }
    }

    return urls.toSet().toList();
  }
}

