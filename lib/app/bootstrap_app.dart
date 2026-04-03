import 'package:concept_nhv/app/app_router.dart';
import 'package:concept_nhv/app/app_providers.dart';
import 'package:concept_nhv/storage/local_database.dart';
import 'package:concept_nhv/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BootstrapApp extends StatelessWidget {
  const BootstrapApp({super.key, required this.localDatabase});

  final LocalDatabase localDatabase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(localDatabase),
      child: MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: createAppRouter(),
      ),
    );
  }
}
