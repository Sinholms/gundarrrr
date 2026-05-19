import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/food_image.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class MenuCrudScreen extends StatefulWidget {
  const MenuCrudScreen({super.key});

  @override
  State<MenuCrudScreen> createState() => _MenuCrudScreenState();
}

class _MenuCrudScreenState extends State<MenuCrudScreen> {
  static const _categories = ['Semua', 'Makanan', 'Minuman', 'Tambahan'];
  String _activeCategory = 'Semua';
  String _query = '';

  List<Map<String, dynamic>> get _filteredItems {
    return MockData.menuItems.where((item) {
      final matchesCategory =
          _activeCategory == 'Semua' || item['category'] == _activeCategory;
      final matchesSearch = (item['name'] as String).toLowerCase().contains(
        _query.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _nextId {
    return MockData.menuItems.fold<int>(
          0,
          (maxId, item) =>
              (item['id'] as int) > maxId ? item['id'] as int : maxId,
        ) +
        1;
  }

  void _openForm({Map<String, dynamic>? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WessLessTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _MenuFormSheet(
          item: item,
          onSave: (data) {
            setState(() {
              if (item == null) {
                MockData.menuItems.add({
                  'id': _nextId,
                  'sold_today': 0,
                  'predicted': 0,
                  ...data,
                });
              } else {
                final index = MockData.menuItems.indexWhere(
                  (menu) => menu['id'] == item['id'],
                );
                if (index == -1) return;
                MockData.menuItems[index] = {
                  ...MockData.menuItems[index],
                  ...data,
                };
              }
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus menu?'),
        content: Text('${item['name']} akan dihapus dari daftar menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                MockData.menuItems.removeWhere(
                  (menu) => menu['id'] == item['id'],
                );
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WessLessTheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Menu',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Atur daftar menu jualan warung',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Tambah menu',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Cari menu',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: WessLessTheme.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: WessLessTheme.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 0, 8),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    padding: const EdgeInsets.only(right: 20),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final active = category == _activeCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _activeCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? WessLessTheme.primary
                                : WessLessTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? WessLessTheme.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : WessLessTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Menu tidak ditemukan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return _MenuCrudTile(
                    item: item,
                    onEdit: () => _openForm(item: item),
                    onDelete: () => _deleteItem(item),
                  );
                }, childCount: items.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Menu'),
      ),
    );
  }
}

class _MenuCrudTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuCrudTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WessLessTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          FoodImage(
            assetPath: item['icon'],
            size: 56,
            imageBytes: item['image_bytes'] as Uint8List?,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      MockData.formatCurrency(item['price']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: WessLessTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: WessLessTheme.primary.withAlpha(12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['category'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: WessLessTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            color: WessLessTheme.textSecondary,
            tooltip: 'Edit menu',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: WessLessTheme.error,
            tooltip: 'Hapus menu',
          ),
        ],
      ),
    );
  }
}

class _MenuFormSheet extends StatefulWidget {
  final Map<String, dynamic>? item;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _MenuFormSheet({this.item, required this.onSave});

  @override
  State<_MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<_MenuFormSheet> {
  static const _categories = ['Makanan', 'Minuman', 'Tambahan'];
  static const _imageOptions = [
    'assets/images/ayam_geprek.png',
    'assets/images/sambal_matah.png',
    'assets/images/nasi_putih.png',
    'assets/images/es_teh.png',
    'assets/images/es_jeruk.png',
    'assets/images/ayam_mozarella.png',
    'assets/images/tahu_crispy.png',
    'assets/images/tempe_goreng.png',
  ];

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late String _category;
  late String _icon;
  Uint8List? _uploadedImageBytes;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?['name'] ?? '');
    _priceController = TextEditingController(
      text: item == null ? '' : '${item['price']}',
    );
    _category = item?['category'] ?? _categories.first;
    _icon = item?['icon'] ?? _imageOptions.first;
    _uploadedImageBytes = item?['image_bytes'] as Uint8List?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'price': int.parse(_priceController.text.trim()),
      'category': _category,
      'icon': _icon,
      'image_bytes': _uploadedImageBytes,
    });
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _uploadedImageBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEditing ? 'Edit Menu' : 'Tambah Menu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama menu',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama menu wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final price = int.tryParse(value?.trim() ?? '');
                  if (price == null || price <= 0) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Foto menu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FoodImage(
                    assetPath: _icon,
                    size: 74,
                    imageBytes: _uploadedImageBytes,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Upload Foto'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 68,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final option = _imageOptions[index];
                    final selected =
                        option == _icon && _uploadedImageBytes == null;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _icon = option;
                        _uploadedImageBytes = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 66,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selected
                              ? WessLessTheme.primary.withAlpha(16)
                              : WessLessTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? WessLessTheme.primary
                                : Colors.grey.shade200,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: FoodImage(assetPath: option, size: 54),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    _isEditing ? Icons.save_rounded : Icons.add_rounded,
                  ),
                  label: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
