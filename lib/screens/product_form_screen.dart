import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _titleArController;
  late TextEditingController _titleFrController;
  late TextEditingController _descArController;
  late TextEditingController _priceController;
  late TextEditingController _comparePriceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;
  late TextEditingController _newImageUrlController;

  String? _selectedCategory;
  String _productType = 'normal'; // 'normal' | 'bundle'
  bool _isFeatured = false;
  bool _isActive = true;
  List<String> _images = [];
  List<ProductPack> _packs = [];
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _showUrlInput = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleArController = TextEditingController(text: p?.titleAr ?? '');
    _titleFrController = TextEditingController(text: p?.titleFr ?? '');
    _descArController = TextEditingController(text: p?.descriptionAr ?? '');
    _priceController = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0) : '');
    _comparePriceController = TextEditingController(
        text: p?.compareAtPrice != null
            ? p!.compareAtPrice!.toStringAsFixed(0)
            : '');
    _stockController = TextEditingController(
        text: p != null ? p.stockQuantity.toString() : '100');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _newImageUrlController = TextEditingController();

    _selectedCategory = p?.categoryId;
    _productType = p?.productType ?? 'normal';
    _isFeatured = p?.isFeatured ?? false;
    _isActive = p?.isActive ?? true;
    _images = List.from(p?.images ?? []);
    _packs = List.from(p?.packs ?? []);
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleFrController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _newImageUrlController.dispose();
    super.dispose();
  }

  // ── Image Picking & Uploading ──────────────────────────────────────────────
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() => _isUploadingImage = true);

        int successCount = 0;
        for (final file in pickedFiles) {
          final bytes = await file.readAsBytes();
          final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          final uploadedUrl =
              await ApiService().uploadImageBase64(base64String);

          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            if (mounted) {
              setState(() {
                _images.add(uploadedUrl);
              });
              successCount++;
            }
          }
        }

        if (mounted) {
          setState(() => _isUploadingImage = false);
          if (successCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'تم رفع $successCount صور بنجاح إلى المعرض السحابي ☁️'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تعذر رفع الصور، يرجى التحقق من اتصال الإنترنت'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر اختيار الصور من المعرض: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (photo != null) {
        setState(() => _isUploadingImage = true);
        final bytes = await photo.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        final uploadedUrl =
            await ApiService().uploadImageBase64(base64String);

        if (mounted) {
          setState(() => _isUploadingImage = false);
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            setState(() {
              _images.add(uploadedUrl);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم التقاط الصورة ورفعها بنجاح 📸'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تعذر رفع الصورة الملتقطة، حاول ثانية'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر التقاط الصورة بالكاميرا: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _addImageUrl() {
    final url = _newImageUrlController.text.trim();
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _images.add(url);
        _newImageUrlController.clear();
        _showUrlInput = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _setAsPrimaryImage(int index) {
    if (index > 0 && index < _images.length) {
      setState(() {
        final img = _images.removeAt(index);
        _images.insert(0, img);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعيين الصورة كصورة رئيسية للمنتج ⭐'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  // ── Packs & Bundles ────────────────────────────────────────────────────────
  void _addPack() {
    setState(() {
      final defaultQty = _packs.isEmpty ? 2 : (_packs.length == 1 ? 3 : 4);
      final basePrice = double.tryParse(_priceController.text) ?? 3000;
      final discountedPrice = (basePrice * defaultQty * 0.85).roundToDouble();
      _packs.add(ProductPack(
        quantity: defaultQty,
        price: discountedPrice,
        label: 'عرض $defaultQty قطع',
        isPopular: _packs.length == 1,
      ));
    });
  }

  // ── Save Product ───────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final product = Product(
      id: widget.product?.id ?? '',
      slug: widget.product?.slug ??
          'prod-${DateTime.now().millisecondsSinceEpoch}',
      sku: _skuController.text.trim().isNotEmpty
          ? _skuController.text.trim()
          : null,
      categoryId: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0,
      compareAtPrice: _comparePriceController.text.trim().isNotEmpty
          ? double.tryParse(_comparePriceController.text)
          : null,
      stockQuantity: int.tryParse(_stockController.text) ?? 100,
      trackInventory: true,
      isActive: _isActive,
      isFeatured: _isFeatured,
      productType: _productType,
      images: _images,
      titleAr: _titleArController.text.trim(),
      titleFr: _titleFrController.text.trim().isNotEmpty
          ? _titleFrController.text.trim()
          : null,
      descriptionAr: _descArController.text.trim(),
      descriptionFr: '',
      packs: _packs,
    );

    final productsProvider = context.read<ProductsProvider>();
    final success = await productsProvider.saveProduct(product);

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'تم تحديث المنتج بنجاح 🎉'
                : 'تمت إضافة ${_productType == 'bundle' ? 'الباقة' : 'المنتج'} بنجاح 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productsProvider.errorMessage ?? 'تعذر حفظ المنتج'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    // capture before any async gap
    final productsProvider = context.read<ProductsProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('حذف المنتج',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
          content: Text(
            'هل أنت متأكد من حذف "${_titleArController.text.trim()}"؟\nلا يمكن التراجع عن هذا الإجراء.',
            style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(LucideIcons.trash2, size: 16),
              label: const Text('حذف نهائياً',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && widget.product?.id != null) {
      setState(() => _isSaving = true);
      final ok = await ApiService().deleteProduct(widget.product!.id);
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (ok) {
        productsProvider.fetchProductsAndCategories(showLoading: false);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حذف المنتج، حاول مرة أخرى'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductsProvider>().categories;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(
            _isEditing
                ? 'تعديل ${_productType == 'bundle' ? 'الباقة' : 'المنتج'}'
                : 'إضافة ${_productType == 'bundle' ? 'باقة جديدة' : 'منتج جديد'}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowRight),
            onPressed: () => Navigator.pop(context),
          ),
          // Delete button — only visible in edit mode
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _isSaving ? null : _handleDelete,
                icon: const Icon(LucideIcons.trash2, color: AppColors.danger),
                tooltip: 'حذف المنتج',
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(LucideIcons.save, size: 18),
            label: Text(
              _isSaving
                  ? 'جاري الحفظ...'
                  : (_isEditing
                      ? 'حفظ التعديلات'
                      : (_productType == 'bundle'
                          ? 'إضافة الباقة'
                          : 'إضافة المنتج')),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 0. Product Type Selector (Normal vs Bundle) ───────────
                _cardWrapper(
                  title: 'نوع الإضافة (منتج عادي أو باقة)',
                  icon: LucideIcons.layers,
                  children: [
                    Row(
                      children: [
                        // Option 1: Normal Product
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _productType = 'normal'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _productType == 'normal'
                                    ? AppColors.primaryBg
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _productType == 'normal'
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: _productType == 'normal' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.package,
                                    size: 24,
                                    color: _productType == 'normal'
                                        ? AppColors.primary
                                        : AppColors.textSub,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'منتج عادي (Single)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _productType == 'normal'
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'بيع بالقطعة مع عروض كميات',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Option 2: Bundle / Pack
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _productType = 'bundle'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _productType == 'bundle'
                                    ? AppColors.primaryBg
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _productType == 'bundle'
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: _productType == 'bundle' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.gift,
                                    size: 24,
                                    color: _productType == 'bundle'
                                        ? AppColors.primary
                                        : AppColors.textSub,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'باقة / عرض توفيري (Pack)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _productType == 'bundle'
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'مجموعة منتجات بعرض موحد',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 1. Basic Info Card ─────────────────────────────────────
                _cardWrapper(
                  title: _productType == 'bundle'
                      ? 'معلومات الباقة'
                      : 'المعلومات الأساسية للمنتج',
                  icon: LucideIcons.fileText,
                  children: [
                    _inputField(
                      controller: _titleArController,
                      label: _productType == 'bundle'
                          ? 'اسم الباقة بالعربية *'
                          : 'اسم المنتج بالعربية *',
                      hint: _productType == 'bundle'
                          ? 'مثال: باقة العناية الملكية المتكاملة 3 في 1'
                          : 'مثال: ساعة ذكية Ultra Smart Watch',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'يرجى إدخال الاسم'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _titleFrController,
                      label: _productType == 'bundle'
                          ? 'اسم الباقة بالفرنسية (اختياري)'
                          : 'اسم المنتج بالفرنسية (اختياري)',
                      hint: _productType == 'bundle'
                          ? 'Pack Soin Royal 3 en 1'
                          : 'Montre Connectée Ultra',
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _descArController,
                      label: _productType == 'bundle'
                          ? 'محتويات وتفاصيل الباقة'
                          : 'وصف المنتج ومميزاته',
                      hint: _productType == 'bundle'
                          ? 'اكتب ما تحتويه هذه الباقة (المنتج 1 + المنتج 2 + الهدية...)'
                          : 'أدخل تفاصيل ومميزات المنتج...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    // Category dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'القسم / التصنيف',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              hint: const Text('اختر القسم المناسب',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              items: categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.nameAr,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 2. Pricing & Stock Card ────────────────────────────────
                _cardWrapper(
                  title: 'السعر والمخزون',
                  icon: LucideIcons.dollarSign,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            controller: _priceController,
                            label: _productType == 'bundle'
                                ? 'سعر الباقة (د.ج) *'
                                : 'سعر البيع (د.ج) *',
                            hint: '4900',
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'أدخل السعر'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            controller: _comparePriceController,
                            label: 'السعر الأصلي (شطب)',
                            hint: '6800',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            controller: _stockController,
                            label: _productType == 'bundle'
                                ? 'كمية الباقات المتاحة'
                                : 'كمية المخزون',
                            hint: '100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            controller: _skuController,
                            label: 'رمز SKU (اختياري)',
                            hint: _productType == 'bundle'
                                ? 'PACK-01'
                                : 'WAT-001',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 3. Product Images (Gallery, Camera & Cloud Upload) ─────
                _cardWrapper(
                  title: 'صور ${_productType == 'bundle' ? 'الباقة' : 'المنتج'} (${_images.length} صور)',
                  icon: LucideIcons.image,
                  children: [
                    // Action Buttons (Gallery, Camera, URL)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: _isUploadingImage
                                ? null
                                : _pickImagesFromGallery,
                            icon: const Icon(LucideIcons.images, size: 16),
                            label: const Text('اختيار من المعرض',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: _isUploadingImage
                                ? null
                                : _pickImageFromCamera,
                            icon: const Icon(LucideIcons.camera, size: 16),
                            label: const Text('كاميرا',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(
                              () => _showUrlInput = !_showUrlInput),
                          icon: Icon(
                            _showUrlInput ? LucideIcons.x : LucideIcons.link,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryBg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          tooltip: 'إضافة رابط خارجي',
                        ),
                      ],
                    ),

                    // Progress Loader when uploading to cloud
                    if (_isUploadingImage) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'جاري رفع الصور وضغطها سحابياً Cloudinary...',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // External URL Input (Optional Collapsible)
                    if (_showUrlInput) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newImageUrlController,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: 'https://images.unsplash.com/...',
                                hintStyle: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: AppColors.border),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addImageUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('إضافة'),
                          ),
                        ],
                      ),
                    ],

                    // Images Grid Display
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'اسحب أو اضغط على ⭐ لجعل الصورة رئيسية في المتجر:',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSub),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _images.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final url = entry.value;
                          final isPrimary = idx == 0;

                          return Stack(
                            children: [
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isPrimary
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isPrimary ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Center(
                                      child: Icon(LucideIcons.image,
                                          size: 20, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ),

                              // Primary Badge / Set as Primary button
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _setAsPrimaryImage(idx),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPrimary
                                          ? AppColors.primary
                                          : Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.star,
                                          size: 10,
                                          color: isPrimary
                                              ? Colors.amber
                                              : Colors.white,
                                        ),
                                        if (isPrimary) ...[
                                          const SizedBox(width: 2),
                                          const Text(
                                            'الرئيسية',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Delete Button
                              Positioned(
                                top: 4,
                                left: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(idx),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.trash2,
                                        size: 11, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // ── 4. Quantity Discount Packs ─────────────────────────────
                _cardWrapper(
                  title: _productType == 'bundle'
                      ? 'عروض وتخفيضات الباقة المتعددة (Packs)'
                      : 'عروض الكميات المخفضة (Packs)',
                  icon: LucideIcons.tag,
                  children: [
                    if (_packs.isEmpty) ...[
                      Text(
                        _productType == 'bundle'
                            ? 'يمكنك إضافة خصم عند شراء أكثر من باقة (مثال: باقتين بسعر مخفض).'
                            : 'زيادة المبيعات: أضف خصماً تلقائياً عند شراء قطعتين أو 3 قطع.',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSub),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ..._packs.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final pack = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.package,
                                  size: 16, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${pack.quantity} ${_productType == 'bundle' ? 'باقات' : 'قطع'} بـ ${pack.price.toStringAsFixed(0)} د.ج ${pack.label != null ? "(${pack.label})" : ""}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2,
                                  size: 16, color: AppColors.danger),
                              onPressed: () =>
                                  setState(() => _packs.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: _addPack,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: Text(
                        _productType == 'bundle'
                            ? 'إضافة عرض باقات متعددة'
                            : 'إضافة حزمة كميات مخفضة',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 5. Switches (Featured & Active) ────────────────────────
                _cardWrapper(
                  title: 'خيارات العرض والظهور في المتجر',
                  icon: LucideIcons.eye,
                  children: [
                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                      title: const Text('تمييز المنتج (Featured)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text(
                          'يظهر في قسم العروض المميزة بالصفحة الرئيسية',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSub)),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 12, color: AppColors.divider),
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      title: const Text('المنتج نشط ومتاح للشراء في المتجر',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      activeThumbColor: AppColors.success,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 12, color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
