import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key, required this.onImageTake});

  final void Function(File) onImageTake;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final imagePicker = ImagePicker();
  File? takenImage;

  @override
  Widget build(BuildContext context) {
    void takeImage() async {
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
      );

      if (pickedImage == null) {
        return;
      }
      setState(() {
        takenImage = File(pickedImage.path);
      });

      widget.onImageTake(takenImage!);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey,
          foregroundImage: takenImage != null ? FileImage(takenImage!) : null,
        ),
        InkWell(
          onTap: () {
            takeImage();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: takeImage,
                icon: Icon(Icons.image),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                "Take Image",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
