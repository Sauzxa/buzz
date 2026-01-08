import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/colors.dart';

class FileUploadWidget extends StatefulWidget {
  final List<File> uploadedFiles;
  final Function(List<File>) onFilesChanged;

  const FileUploadWidget({
    Key? key,
    required this.uploadedFiles,
    required this.onFilesChanged,
  }) : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isDragging = false;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'zip'],
      );

      if (result != null) {
        final newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        final updatedFiles = [...widget.uploadedFiles, ...newFiles];
        widget.onFilesChanged(updatedFiles);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newFiles.length} file(s) uploaded successfully'),
              backgroundColor: AppColors.greenColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    final updatedFiles = List<File>.from(widget.uploadedFiles);
    updatedFiles.removeAt(index);
    widget.onFilesChanged(updatedFiles);
  }

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Upload Area
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _isDragging
                  ? AppColors.greenColor.withOpacity(0.1)
                  : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDragging ? AppColors.greenColor : Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.greenColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 30,
                    color: AppColors.greenColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop your file here',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Or choose files',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, DOC, JPG, PNG, ZIP (Max 10MB)',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Uploaded Files List
        if (widget.uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Uploaded Files (${widget.uploadedFiles.length})',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.uploadedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file,
                      size: 20,
                      color: AppColors.greenColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFileName(file),
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFileSize(file),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.grey[600],
                    onPressed: () => _removeFile(index),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}
