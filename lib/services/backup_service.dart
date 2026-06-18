import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'google_drive_service.dart';

/// Local SQLite database filename used by StickNotes.
const String stickNotesDatabaseName = 'sticknotes.db';

/// Coordinates local database file access with Google Drive backup operations.
class BackupService {
  BackupService({GoogleDriveService? googleDriveService})
    : _googleDriveService = googleDriveService ?? GoogleDriveService();

  final GoogleDriveService _googleDriveService;

  /// Returns the absolute path used by sqflite for the local database.
  Future<String> getDatabasePath() async {
    final databasesDirectory = await getDatabasesPath();
    return p.join(databasesDirectory, stickNotesDatabaseName);
  }

  /// Uploads the current local SQLite database to Google Drive.
  Future<void> backupNow({bool silentSignIn = false}) async {
    final databasePath = await getDatabasePath();
    await _googleDriveService.uploadDatabaseBackup(
      databaseFile: File(databasePath),
      silentSignIn: silentSignIn,
    );
  }

  /// Downloads the Drive backup and replaces the local SQLite database file.
  Future<void> restoreBackup() async {
    final backupBytes = await _googleDriveService.downloadDatabaseBackup();
    final databasePath = await getDatabasePath();
    final databaseFile = File(databasePath);

    // Close sqflite handles for this path before replacing the file on disk.
    await deleteDatabase(databasePath);

    await databaseFile.parent.create(recursive: true);
    await databaseFile.writeAsBytes(backupBytes, flush: true);
  }
}
