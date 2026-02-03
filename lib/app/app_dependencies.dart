import 'package:get_it/get_it.dart';

import '../core/repository/settings_repository.dart';
import '../core/repository/transactions_repository.dart';

final getIt = GetIt.instance;

void setupAppDependencies() {
  // Repositories
  getIt.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );
}
