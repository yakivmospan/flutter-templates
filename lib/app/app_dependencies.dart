import 'package:get_it/get_it.dart';

import '../core/repository/settings_repository.dart';
import '../core/repository/transactions_repository.dart';
import '../core/storage/storage.dart';

final getIt = GetIt.instance;

Future<void> setupAppDependencies() async {
  // Storage
  final storage = StorageImpl();
  await storage.init();
  getIt.registerSingleton<Storage>(storage);

  // Repositories
  getIt.registerLazySingleton<TransactionsRepository>(
        () => TransactionsRepositoryImpl(storage: getIt<Storage>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(storage: getIt<Storage>()),
  );
}