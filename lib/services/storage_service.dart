import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseService _firebase = FirebaseService();

  // Upload exercise image
  Future<String> uploadExerciseImage(XFile image, String exerciseId) async {
    try {
      print('DEBUG: Iniciando upload de imagem do exercício');
      print('DEBUG: ExerciseId: $exerciseId');
      print('DEBUG: Image path: ${image.path}');
      
      final fileName = '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('DEBUG: Nome do arquivo: $fileName');
      
      final ref = _firebase.storage.ref().child('exercise_images/$fileName');
      print('DEBUG: Referência criada: exercise_images/$fileName');
      
      final bytes = await image.readAsBytes();
      print('DEBUG: Bytes lidos: ${bytes.length} bytes');
      
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      
      print('DEBUG: Iniciando putData...');
      final uploadTask = ref.putData(bytes, metadata);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('DEBUG: Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });
      
      await uploadTask;
      print('DEBUG: Upload concluído');
      
      final downloadUrl = await ref.getDownloadURL();
      print('DEBUG: URL de download: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao fazer upload da imagem: $e');
      print('DEBUG: Stack trace: $stackTrace');
      throw 'Erro ao fazer upload da imagem: $e';
    }
  }

  // Delete exercise image
  Future<void> deleteExerciseImage(String imageUrl) async {
    try {
      final ref = _firebase.storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting (file might not exist or invalid URL)
      print('Erro ao deletar imagem: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(XFile image, String userId) async {
    try {
      print('DEBUG: Iniciando upload de imagem de perfil');
      print('DEBUG: UserId: $userId');
      print('DEBUG: Image path: ${image.path}');
      
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('DEBUG: Nome do arquivo: $fileName');
      
      final ref = _firebase.storage.ref().child('profile_images/$fileName');
      print('DEBUG: Referência criada: profile_images/$fileName');
      
      final bytes = await image.readAsBytes();
      print('DEBUG: Bytes lidos: ${bytes.length} bytes');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      print('DEBUG: Iniciando putData...');
      final uploadTask = ref.putData(bytes, metadata);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('DEBUG: Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });
      
      await uploadTask;
      print('DEBUG: Upload concluído');
      
      final downloadUrl = await ref.getDownloadURL();
      print('DEBUG: URL de download: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao fazer upload da imagem de perfil: $e');
      print('DEBUG: Stack trace: $stackTrace');
      throw 'Erro ao fazer upload da imagem de perfil: $e';
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _firebase.storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting
      print('Erro ao deletar imagem de perfil: $e');
    }
  }
}
