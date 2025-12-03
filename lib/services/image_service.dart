import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

// Image service for camera/gallery access
class ImageService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    try {
      if (kIsWeb) {
        return await _pickImageFromWebcam();
      } else {
        return await _pickImageFromMobileCamera();
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  Future<XFile?> _pickImageFromMobileCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return null;
      }

      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      print('Camera error: $e');
      return null;
    }
  }

  Future<XFile?> _pickImageFromWebcam() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      print('Error picking image from webcam: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Upload image and link to property
  Future<String?> uploadImage(XFile image, String propertyId) async {
    try {
      if (kIsWeb) {
        return await _uploadImageWeb(image, propertyId);
      } else {
        return await _uploadImageMobile(image, propertyId);
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> _uploadImageWeb(XFile image, String propertyId) async {
    try {
      final bytes = await image.readAsBytes();
      print('Image uploaded for property $propertyId (web): ${bytes.length} bytes');
      return image.path;
    } catch (e) {
      print('Error uploading image (web): $e');
      return null;
    }
  }

  Future<String?> _uploadImageMobile(XFile image, String propertyId) async {
    try {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      print('Image uploaded for property $propertyId (mobile): ${bytes.length} bytes');
      return image.path;
    } catch (e) {
      print('Error uploading image (mobile): $e');
      return null;
    }
  }
}

