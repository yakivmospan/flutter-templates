import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dao/settings_dao.dart';
import 'dao/transaction_dao.dart';
import 'dto/transaction_dto.dart';


abstract class Storage {
  TransactionDao get transactionDao;
  SettingsDao get settingsDao;

  Future<void> init();
  Future<void> close();
}

class StorageImpl implements Storage {
  TransactionDao? _transactionDao;
  SettingsDao? _settingsDao;

  @override
  TransactionDao get transactionDao {
    if (_transactionDao == null) {
      throw Exception('Storage not initialized. Call init() first.');
    }
    return _transactionDao!;
  }

  @override
  SettingsDao get settingsDao {
    if (_settingsDao == null) {
      throw Exception('Storage not initialized. Call init() first.');
    }
    return _settingsDao!;
  }

  @override
  Future<void> init() async {
    // Initialize Hive
    // Note: Hive.init() should be called in main() before this

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionDtoAdapter());
    }

    // Open boxes
    final transactionBox = await Hive.openBox<TransactionDto>('transactions');
    _transactionDao = TransactionDao(transactionBox);

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _settingsDao = SettingsDao(prefs);
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }
}