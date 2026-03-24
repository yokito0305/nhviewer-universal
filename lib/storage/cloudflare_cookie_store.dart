import 'package:concept_nhv/models/cloudflare_cookie_pair.dart';
import 'package:concept_nhv/storage/options_store.dart';

class CloudflareCookieStore {
  const CloudflareCookieStore({
    required this.optionsStore,
  });

  final OptionsStore optionsStore;

  Future<void> save(CloudflareCookiePair pair) async {
    await optionsStore.saveOption('userAgent', pair.userAgent);
    await optionsStore.saveOption('token', pair.token);
  }

  Future<CloudflareCookiePair> load() async {
    final userAgent = await optionsStore.loadOption('userAgent');
    final token = await optionsStore.loadOption('token');
    return CloudflareCookiePair(
      userAgent: userAgent,
      token: token,
    );
  }

  Future<int> clear() {
    return optionsStore.deleteOptions(<String>['userAgent', 'token']);
  }
}

