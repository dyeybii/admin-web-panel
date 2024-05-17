import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BatchUpload extends StatelessWidget {
  final Function(List<Map<String, dynamic>>) onUpload;

  const BatchUpload({Key? key, required this.onUpload}) : super(key: key);

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );

    if (result != null) {
      // Handle file upload logic here
      // For example, parse the file and convert to a list of maps
      List<Map<String, dynamic>> data = await parseFile(result.files.single);
      onUpload(data);
    }
  }

  Future<List<Map<String, dynamic>>> parseFile(PlatformFile file) async {
    // Implement your file parsing logic here
    // This is a placeholder for the actual file parsing implementation
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _pickFile,
      child: const Text('Batch Upload'),
    );
  }
}
