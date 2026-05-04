enum DownloadsSortMode {
  latestDownloaded('Latest Downloaded'),
  lastRead('Last Read'),
  mostFavorited('Most Favorited');

  const DownloadsSortMode(this.label);

  final String label;
}

enum DownloadsSortDirection {
  descending('Descending'),
  ascending('Ascending');

  const DownloadsSortDirection(this.label);

  final String label;
}
