import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final List<TextEditingController> _ingredientCtrls = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _stepCtrls = List.generate(3, (_) => TextEditingController());
  final List<String> _images = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _ingredientCtrls) c.dispose();
    for (final c in _stepCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng món mới'),
        backgroundColor: const Color(0xFFEF3A16),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              _imagePickerSection(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Tên món', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              const Text('Nguyên liệu (tối thiểu 3)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._ingredientCtrls.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: e.value,
                            decoration: InputDecoration(
                              labelText: 'Nguyên liệu ${e.key + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _ingredientCtrls.length > 3
                              ? () => setState(() => _ingredientCtrls.removeAt(e.key))
                              : null,
                        )
                      ],
                    ),
                  )),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _ingredientCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm nguyên liệu'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Các bước (tối thiểu 3)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._stepCtrls.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: e.value,
                            decoration: InputDecoration(
                              labelText: 'Bước ${e.key + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _stepCtrls.length > 3
                              ? () => setState(() => _stepCtrls.removeAt(e.key))
                              : null,
                        )
                      ],
                    ),
                  )),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _stepCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm bước'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateAll()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng bài thành công (mock)')));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF3A16), foregroundColor: Colors.white),
                  child: const Text('Đăng bài'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hình ảnh (tối thiểu 1)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () {
                setState(() => _images.add('placeholder'));
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Thêm ảnh'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_images.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('Chưa có ảnh')), 
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => Stack(
                children: [
                  Container(
                    width: 140,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, color: Colors.white70, size: 36),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => setState(() => _images.removeAt(i)),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  bool _validateAll() {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return false;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 1 ảnh')));
      return false;
    }
    if (_ingredientCtrls.take(3).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 3 nguyên liệu')));
      return false;
    }
    if (_stepCtrls.take(3).any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cần ít nhất 3 bước')));
      return false;
    }
    return true;
  }
}


