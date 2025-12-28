import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import '../services/blogger_service.dart';

class PostEditorScreen extends StatefulWidget {
  final BloggerService bloggerService;
  final String blogId;
  final String blogName;

  const PostEditorScreen({
    super.key,
    required this.bloggerService,
    required this.blogId,
    required this.blogName,
  });

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _labelController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<XFile> _selectedImages = [];
  final List<String> _labels = [];
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addLabel() {
    final label = _labelController.text.trim();
    if (label.isNotEmpty && !_labels.contains(label)) {
      setState(() {
        _labels.add(label);
        _labelController.clear();
      });
    }
  }

  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
    });
  }

  Future<void> _publishPost({bool isDraft = false}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // 에디터에서 내용 가져오기
      String content = _contentController.text;

      // 이미지를 본문에 삽입 (Base64 또는 URL 방식)
      // 실제로는 이미지를 먼저 업로드하고 URL을 받아야 함
      // 여기서는 간단한 예시로 처리
      if (_selectedImages.isNotEmpty) {
        String imageHtml = '';
        for (var image in _selectedImages) {
          // TODO: 실제로는 이미지를 Imgur나 다른 호스팅에 업로드
          // 현재는 로컬 경로만 표시
          imageHtml += '<img src="${image.path}" alt="image" style="max-width: 100%; height: auto;"><br>';
        }
        content = imageHtml + content;
      }

      final post = await widget.bloggerService.createPost(
        blogId: widget.blogId,
        title: _titleController.text.trim(),
        content: content,
        labels: _labels.isNotEmpty ? _labels : null,
        isDraft: isDraft,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDraft ? '임시저장 되었습니다' : '포스트가 게시되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('포스트 게시 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blogName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 임시저장
          TextButton.icon(
            onPressed: _isPublishing ? null : () => _publishPost(isDraft: true),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              '임시저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // 게시
          TextButton.icon(
            onPressed: _isPublishing ? null : () => _publishPost(isDraft: false),
            icon: const Icon(Icons.publish, color: Colors.white),
            label: const Text(
              '게시',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '포스트 제목',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 이미지 섹션
                  _buildImageSection(),
                  const SizedBox(height: 16),

                  // 본문 에디터
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요...',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),

                  // 라벨(태그) 섹션
                  _buildLabelSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '이미지',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImages,
              tooltip: '갤러리에서 선택',
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _takePhoto,
              tooltip: '사진 촬영',
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _selectedImages[index].path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 50);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLabelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '라벨 (태그)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  hintText: '라벨 입력',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _addLabel(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addLabel,
              child: const Text('추가'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _labels.map((label) {
            return Chip(
              label: Text(label),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeLabel(label),
            );
          }).toList(),
        ),
      ],
    );
  }
}
