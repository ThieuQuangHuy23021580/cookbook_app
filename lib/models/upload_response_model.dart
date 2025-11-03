class UploadResponse {
  final bool success;
  final String message;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? contentType;
  UploadResponse({
    required this.success,
    required this.message,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.contentType,
  });
  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'] as int?,
      contentType: json['contentType'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'contentType': contentType,
    };
  }
}
