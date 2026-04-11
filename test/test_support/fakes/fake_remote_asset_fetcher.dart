import 'dart:typed_data';

import 'package:concept_nhv/services/remote_asset_fetcher.dart';

class FakeRemoteAssetFetcher implements RemoteAssetFetcher {
  FakeRemoteAssetFetcher({
    Map<String, Uint8List>? responses,
    this.error,
  }) : responses = responses ?? <String, Uint8List>{};

  final Map<String, Uint8List> responses;
  final Object? error;
  final List<String> requestedUrls = <String>[];

  @override
  Future<Uint8List> fetchBytes(String url) async {
    requestedUrls.add(url);
    if (error != null) {
      throw error!;
    }
    final response = responses[url];
    if (response == null) {
      throw StateError('No fake response for $url');
    }
    return response;
  }
}
