import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'backup_service.dart';

/// Workmanager task name used for the daily Google Drive backup.
const String automaticBackupTaskName = 'sticknotes_daily_drive_backup';

/// SharedPreferences key that stores whether automatic backup is enabled.
const String automaticBackupEnabledKey = 'automatic_backup_enabled';

/// SharedPreferences key that stores the selected backup hour.
const String automaticBackupHourKey = 'automatic_backup_hour';

/// SharedPreferences key that stores the selected backup minute.
const String automaticBackupMinuteKey = 'automatic_backup_minute';

/// Whether Workmanager is available on the current platform.
bool get isAutomaticBackupSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Runs background tasks registered with Workmanager.
///
/// Workmanager starts this function in a background isolate, so it must stay
/// top-level and must initialize Flutter bindings before using plugins.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (taskName != automaticBackupTaskName) {
      return true;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final isEnabled = preferences.getBool(automaticBackupEnabledKey) ?? false;

      if (!isEnabled) {
        return true;
      }

      await BackupService().backupNow(silentSignIn: true);
      return true;
    } catch (_) {
      // Returning false lets Workmanager know the task failed and can be retried
      // according to the platform's background execution policy.
      return false;
    }
  });
}

/// Saves automatic backup settings and registers the daily background task.
class BackupSchedulerService {
  /// Reads whether automatic backup is currently enabled.
  Future<bool> isAutomaticBackupEnabled() async {
    if (!isAutomaticBackupSupported) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(automaticBackupEnabledKey) ?? false;
  }

  /// Reads the saved backup time, defaulting to 09:00.
  Future<TimeOfDay> getScheduledTime() async {
    final preferences = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: preferences.getInt(automaticBackupHourKey) ?? 9,
      minute: preferences.getInt(automaticBackupMinuteKey) ?? 0,
    );
  }

  /// Enables or disables daily automatic backup.
  Future<void> setAutomaticBackupEnabled(bool enabled) async {
    if (enabled && !isAutomaticBackupSupported) {
      throw UnsupportedError(
        'Automatic backup is only available on Android and iOS.',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(automaticBackupEnabledKey, enabled);

    if (enabled) {
      await scheduleDailyBackup(await getScheduledTime());
    } else {
      await cancelDailyBackup();
    }
  }

  /// Stores the selected time and updates the Workmanager registration.
  Future<void> saveScheduledTime(TimeOfDay time) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(automaticBackupHourKey, time.hour);
    await preferences.setInt(automaticBackupMinuteKey, time.minute);

    if (preferences.getBool(automaticBackupEnabledKey) ?? false) {
      await scheduleDailyBackup(time);
    }
  }

  /// Registers a once-per-day task that runs only when the device is connected.
  Future<void> scheduleDailyBackup(TimeOfDay time) async {
    if (!isAutomaticBackupSupported) {
      return;
    }

    await Workmanager().registerPeriodicTask(
      automaticBackupTaskName,
      automaticBackupTaskName,
      frequency: const Duration(days: 1),
      initialDelay: _delayUntilNext(time),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  /// Cancels the daily automatic backup task.
  Future<void> cancelDailyBackup() {
    if (!isAutomaticBackupSupported) {
      return Future.value();
    }

    return Workmanager().cancelByUniqueName(automaticBackupTaskName);
  }

  Duration _delayUntilNext(TimeOfDay time) {
    final now = DateTime.now();
    var nextRun = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (!nextRun.isAfter(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    return nextRun.difference(now);
  }
}
