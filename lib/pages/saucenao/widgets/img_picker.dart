import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImgFilePicker extends StatefulWidget {
  ImgFilePicker({Key? key}) : super(key: key);

  @override
  State<ImgFilePicker> createState() => _ImgFilePickerState();
}

class _ImgFilePickerState extends State<ImgFilePicker> {
  FilePickerResult? result;

  String path = '';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        result = await FilePicker.platform.pickFiles();
        if (result != null) {
          setState(() {
            path = result!.files.first.path!;
          });
        }
      },
      child: Text("Pick a file instead"),
    );
  }
}
