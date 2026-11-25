import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/inventory_item.dart';

class ItemFormDialog extends StatefulWidget {
  const ItemFormDialog({
    required this.onSave,
    this.item,
    this.onPickImage,
    this.onUploadImage,
    this.onSaveWithImage,
    super.key,
  });

  final InventoryItem? item;
  final Future<void> Function(String name, num quantity) onSave;
  final Future<XFile?> Function()? onPickImage;
  final Future<String> Function(XFile image)? onUploadImage;
  final Future<void> Function(String name, num quantity, String? imageUrl)?
  onSaveWithImage;

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  String? _saveError;
  bool _isSaving = false;
  bool _isPickingImage = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? selectedImageUrl;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = num.tryParse(_quantityController.text.trim());
    if (quantity == null) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      if (!_isEditing && _selectedImage != null) {
        final uploadImage = widget.onUploadImage;
        if (uploadImage == null) {
          throw StateError('Image upload is not configured.');
        }
        selectedImageUrl = (await uploadImage(_selectedImage!)).trim();
        final uri = Uri.tryParse(selectedImageUrl!);
        if (selectedImageUrl!.isEmpty ||
            uri == null ||
            (uri.scheme != 'https' && uri.scheme != 'http') ||
            uri.host.isEmpty) {
          throw StateError('Image upload returned an invalid URL.');
        }
      }
      final name = _nameController.text.trim();
      if (!_isEditing && widget.onSaveWithImage != null) {
        await widget.onSaveWithImage!(name, quantity, selectedImageUrl);
      } else {
        await widget.onSave(name, quantity);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = error.toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickImage = widget.onPickImage;
    if (pickImage == null || _isPickingImage || _isSaving) return;
    setState(() {
      _isPickingImage = true;
      _saveError = null;
    });
    try {
      final image = await pickImage();
      if (!mounted || image == null) return;
      final imageBytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = image;
        selectedImageUrl = null;
        _selectedImageBytes = imageBytes;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saveError = 'Could not select image: $error');
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an item name.';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a quantity.';
    }
    final quantity = num.tryParse(value.trim());
    if (quantity == null || !quantity.isFinite) {
      return 'Enter a valid numeric quantity.';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Item' : 'Add Item';

    return AlertDialog(
      backgroundColor: const Color(0xFFF4EFF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
                validator: _validateName,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateQuantity,
              ),
              if (!_isEditing && widget.onPickImage != null) ...[
                const SizedBox(height: 12),
                if (_selectedImage != null)
                  SizedBox(
                    width: 240,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _selectedImageBytes!,
                        height: 140,
                        width: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('Image preview is unavailable.'),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isPickingImage || _isSaving ? null : _pickImage,
                    icon: _isPickingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image_outlined),
                    label: Text(
                      _selectedImage == null ? 'Choose image' : 'Change image',
                    ),
                  ),
                ),
                if (_isSaving && _selectedImage != null)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Uploading image and saving item…'),
                  ),
              ],
              if (_saveError != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Could not save item: $_saveError',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA000),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Edit' : 'Save'),
        ),
      ],
    );
  }
}
