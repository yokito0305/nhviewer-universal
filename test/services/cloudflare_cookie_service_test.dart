import 'package:concept_nhv/services/cloudflare_cookie_service.dart';
import 'package:concept_nhv/storage/cloudflare_cookie_store.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/storage/options_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_support/fakes.dart';

void main() {
  late LocalDatabase localDatabase;
  late CloudflareCookieStore cookieStore;

  setUp(() async {
    sqfliteFfiInit();
    localDatabase = LocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePathResolver: () async => inMemoryDatabasePath,
    );
    await localDatabase.initialize();
    cookieStore = CloudflareCookieStore(
      optionsStore: OptionsStore(localDatabase: localDatabase),
    );
  });

  tearDown(() async {
    await localDatabase.resetForTesting();
  });

  test('extractCloudflareToken returns token from raw cookie string', () {
    final service = CloudflareCookieService(
      bridge: FakeCloudflareCookieBridge('cf_clearance=abc123; foo=bar'),
      cookieStore: cookieStore,
      nhentaiGateway: FakeNhentaiGateway(),
    );

    expect(service.extractCloudflareToken('cf_clearance=abc123; foo=bar'), 'abc123');
    expect(service.extractCloudflareToken('foo=bar'), isEmpty);
  });

  test('validateStoredCloudflareCookies clears invalid stored cookies', () async {
    await cookieStore.save(sampleCookiePair());

    final service = CloudflareCookieService(
      bridge: FakeCloudflareCookieBridge(''),
      cookieStore: cookieStore,
      nhentaiGateway: FakeNhentaiGateway(
        pingError: sampleDioException(403),
      ),
    );

    expect(await service.validateStoredCloudflareCookies(), isFalse);
    expect((await cookieStore.load()).isEmpty, isTrue);
  });
}

