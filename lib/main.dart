import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/recurring_materializer.dart';
import 'data/database/app_database.dart';
import 'data/database/demo_seed.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/providers/database_provider.dart';
import 'presentation/providers/onboarding_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.initialize();
  if (AppConfig.demoMode) {
    await DemoSeed.seedIfEmpty(db.db);
  }
  await NotificationService.instance.init();
  await RecurringMaterializer.materializeDue(db.db);
  // Init IAP after Flutter bindings so purchase stream is live before UI.
  await PurchaseService.instance.init();

  final settings = SettingsRepository(db);
  final hasOnboarded = (await settings.get(AppConstants.kHasOnboarded)) == 'true';

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialHasOnboardedProvider.overrideWithValue(hasOnboarded),
      ],
      child: const ExpenseMateApp(),
    ),
  );
}
