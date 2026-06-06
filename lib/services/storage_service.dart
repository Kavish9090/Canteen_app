import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage and return the URL
  Future<String> uploadMenuItemImage(dynamic imageFile) async {
    try {
      final String fileName = "menu_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final Reference ref = _storage.ref().child('menu_items/$fileName');
      
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // For web, imageFile should be Uint8List
        uploadTask = ref.putData(imageFile as Uint8List);
      } else {
        // For mobile, imageFile should be File
        uploadTask = ref.putFile(imageFile as File);
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }
}
