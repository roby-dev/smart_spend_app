import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/io_client.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/main.dart';

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  () => SessionNotifier(),
);

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    return SessionState();
  }

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<void> _initializeGoogleSignIn() async {
    await googleSignIn.initialize(serverClientId: null);
  }

  Future<void> signInAndExport(BuildContext context) async {
    bool? result = await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Atención',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          content: const Text(
            'Para exportar los datos, primero debe iniciar sesión',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (result == null || result == false) {
      return;
    }

    var user = await signInWithGoogle();
    if (user != null) {
      await exportAndUploadToDrive(context);
    }
  }

  Future<void> exportAndUploadToDrive(BuildContext context) async {
    try {
      final db = ref.read(databaseProvider);

      // Exportar los datos a JSON usando Drift
      String jsonString = await db.exportToJson();

      // Guardar el JSON en un archivo temporal
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/backup.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Usar la fecha en el nombre del archivo
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(now);
      String fileName = "backup-$formattedDate.json";

      // Autenticación con Google Drive - v7 API
      final currentUser = await googleSignIn.authenticate();
      final authorization = await currentUser.authorizationClient
          .authorizeScopes([drive.DriveApi.driveFileScope]);

      final AuthClient authClient = authenticatedClient(
        IOClient(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            authorization.accessToken,
            DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
          null,
          ['https://www.googleapis.com/auth/drive.file'],
        ),
      );

      // Subir el archivo a Google Drive
      var driveApi = drive.DriveApi(authClient);
      var driveFile = drive.File();
      driveFile.name = fileName;

      var response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      print('Uploaded File ID: ${response.id}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup subido a Google Drive')),
        );
      }
    } catch (e) {
      print("Error uploading to Google Drive: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir el backup a Google Drive'),
          ),
        );
      }
    }
  }

  Future<void> importFromDrive(BuildContext context) async {
    try {
      final db = ref.read(databaseProvider);

      // Seleccionar archivo usando FilePicker
      var filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
        final filePath = filePickerResult.files.single.path;

        if (filePath != null) {
          // Leer el contenido del archivo JSON
          String jsonString = await File(filePath).readAsString();

          // Importar los datos usando Drift
          await db.importFromJson(jsonString);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Datos importados exitosamente')),
            );
          }

          ref.read(homeProvider.notifier).loadCompras();
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo acceder al archivo seleccionado'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ningún archivo')),
          );
        }
      }
    } catch (e) {
      print("Error importing from file: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al importar el archivo')),
        );
      }
    }
  }

  Future<void> signOut() async {
    await signOutGoogle();
    state = state.copyWith(displayName: null, photoUrl: null);
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    await _initializeGoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
    if (googleUser == null) return null;

    state = state.copyWith(
      displayName: googleUser.displayName,
      photoUrl: googleUser.photoUrl,
    );

    return googleUser;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.disconnect();
    print("User Signed Out");
  }
}

class SessionState {
  String? displayName;
  String? photoUrl;

  SessionState({this.displayName, this.photoUrl});

  SessionState copyWith({String? displayName, String? photoUrl}) {
    return SessionState(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
