import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/io_client.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/main.dart';

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
    (ref) => SessionNotifier(ref));

final FirebaseAuth _auth = FirebaseAuth.instance;

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this.ref) : super(SessionState());

  final StateNotifierProviderRef ref;

  AppDatabase get _db => ref.read(databaseProvider);

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  signInAndExport(BuildContext context) async {
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
        });

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

      // Autenticación con Google Drive
      final GoogleSignInAuthentication googleAuth =
          await googleSignIn.currentUser!.authentication;

      final AuthClient authClient = authenticatedClient(
        IOClient(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            googleAuth.accessToken!,
            DateTime.now().toUtc().add(Duration(hours: 1)),
          ),
          googleAuth.idToken,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup subido a Google Drive')),
      );
    } catch (e) {
      print("Error uploading to Google Drive: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el backup a Google Drive')),
      );
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Datos importados exitosamente')),
          );

          ref.read(homeProvider.notifier).loadCompras();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No se pudo acceder al archivo seleccionado')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
      }
    } catch (e) {
      print("Error importing from file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar el archivo')),
      );
    }
  }

  signOut() async {
    await signOutGoogle();
    state = state.copyWith(user: null);
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    state = state.copyWith(
      user: user,
    );

    return user;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Signed Out");
  }
}

class SessionState {
  User? user;

  SessionState({this.user});

  SessionState copyWith({User? user, GoogleSignInAccount? googleUser}) {
    return SessionState(user: user);
  }
}
