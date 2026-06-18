import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Name used for the backup file stored in Google Drive.
const String driveBackupFileName = 'sticknotes_backup.db';

/// Handles Google authentication and all Google Drive file operations.
class GoogleDriveService {
  GoogleDriveService({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(scopes: <String>[drive.DriveApi.driveFileScope]);

  final GoogleSignIn _googleSignIn;

  /// Opens the Google account picker and returns a Drive API client.
  Future<drive.DriveApi> signInAndCreateDriveApi() async {
    final account = await _googleSignIn.signIn();

    if (account == null) {
      throw const GoogleDriveException('Google login was cancelled.');
    }

    return _createDriveApi(account);
  }

  /// Tries to reuse the previous Google account without showing UI.
  ///
  /// This is used by the background backup task because background isolates
  /// cannot ask the user to choose a Google account.
  Future<drive.DriveApi> signInSilentlyAndCreateDriveApi() async {
    final account = await _googleSignIn.signInSilently();

    if (account == null) {
      throw const GoogleDriveException(
        'Google login is required before automatic backup can run.',
      );
    }

    return _createDriveApi(account);
  }

  /// Uploads the local database and updates the existing backup when present.
  Future<void> uploadDatabaseBackup({
    required File databaseFile,
    bool silentSignIn = false,
  }) async {
    if (!databaseFile.existsSync()) {
      throw GoogleDriveException(
        'Database file not found at ${databaseFile.path}.',
      );
    }

    final driveApi = silentSignIn
        ? await signInSilentlyAndCreateDriveApi()
        : await signInAndCreateDriveApi();

    final existingFileId = await _findBackupFileId(driveApi);
    final media = drive.Media(
      databaseFile.openRead(),
      await databaseFile.length(),
      contentType: 'application/x-sqlite3',
    );

    if (existingFileId == null) {
      final metadata = drive.File()..name = driveBackupFileName;
      await driveApi.files.create(
        metadata,
        uploadMedia: media,
        $fields: 'id,name',
      );
      return;
    }

    await driveApi.files.update(
      drive.File()..name = driveBackupFileName,
      existingFileId,
      uploadMedia: media,
      $fields: 'id,name,modifiedTime',
    );
  }

  /// Downloads the backup database file from Google Drive.
  Future<List<int>> downloadDatabaseBackup() async {
    final driveApi = await signInAndCreateDriveApi();
    final backupFileId = await _findBackupFileId(driveApi);

    if (backupFileId == null) {
      throw const GoogleDriveException(
        'No Google Drive backup named $driveBackupFileName was found.',
      );
    }

    final response = await driveApi.files.get(
      backupFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );

    if (response is! drive.Media) {
      throw const GoogleDriveException('Could not download the backup file.');
    }

    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }

    return bytes;
  }

  /// Searches Drive for the first non-trashed backup file with the expected name.
  Future<String?> _findBackupFileId(drive.DriveApi driveApi) async {
    final result = await driveApi.files.list(
      q: "name = '$driveBackupFileName' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id,name,modifiedTime)',
      orderBy: 'modifiedTime desc',
      pageSize: 1,
    );

    final files = result.files;
    if (files == null || files.isEmpty) {
      return null;
    }

    return files.first.id;
  }

  Future<drive.DriveApi> _createDriveApi(GoogleSignInAccount account) async {
    final headers = await account.authHeaders;
    return drive.DriveApi(_GoogleAuthClient(headers));
  }
}

/// Adds Google auth headers to every Drive API request.
class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

/// User-readable exception for backup and restore failures.
class GoogleDriveException implements Exception {
  const GoogleDriveException(this.message);

  final String message;

  @override
  String toString() => message;
}
