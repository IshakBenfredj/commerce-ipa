import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleArController;
  late TextEditingController _titleFrController;
  late TextEditingController _descArController;
  late TextEditingController _priceController;
  late TextEditingController _comparePriceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;
  late TextEditingController _newImageUrlController;

  String? _selectedCategory;
  bool _isFeatured = false;
  bool _isActive = true;
  List<String> _images = [];
  List<ProductPack> _packs = [];
  bool _isSaving = false;

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

  void _addImageUrl() {
    final url = _newImageUrlController.text.trim();
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _images.add(url);
        _newImageUrlController.clear();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

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
      compareAtPrice: double.tryParse(_comparePriceController.text),
      stockQuantity: int.tryParse(_stockController.text) ?? 100,
      isActive: _isActive,
      isFeatured: _isFeatured,
      images: _images,
      titleAr: _titleArController.text.trim(),
      titleFr: _titleFrController.text.trim().isNotEmpty
          ? _titleFrController.text.trim()
          : null,
      descriptionAr: _descArController.text.trim(),
      packs: _packs,
    );

    final success = await context.read<ProductsProvider>().saveProduct(product);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'تم تعديل المنتج بنجاح' : 'تم إضافة المنتج بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ المنتج، يرجى المحاولة مرة أخرى'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    if (widget.product == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف المنتج',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
              'هل أنت متأكد من حذف المنتج "${widget.product!.titleAr}"؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('حذف نهائي'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSaving = true);
      final success = await context
          .read<ProductsProvider>()
          .deleteProduct(widget.product!.id);
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم حذف المنتج بنجاح'),
                backgroundColor: AppColors.success),
          );
        }
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
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: AppColors.text),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.text),
          ),
          centerTitle: true,
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(LucideIcons.trash2,
                    size: 20, color: AppColors.danger),
                onPressed: _handleDelete,
                tooltip: 'حذف المنتج',
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
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
                  : (_isEditing ? 'حفظ التعديلات' : 'إضافة المنتج'),
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
                // ── 1. Basic Info Card ─────────────────────────────────────
                _cardWrapper(
                  title: 'المعلومات الأساسية',
                  icon: LucideIcons.fileText,
                  children: [
                    _inputField(
                      controller: _titleArController,
                      label: 'اسم المنتج بالعربية *',
                      hint: 'مثال: ساعة ذكية Ultra Smart Watch',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'يرجى إدخال اسم المنتج'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _titleFrController,
                      label: 'اسم المنتج بالفرنسية (اختياري)',
                      hint: 'مثال: Montre Connectée Ultra',
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _descArController,
                      label: 'وصف المنتج',
                      hint: 'أدخل تفاصيل ومميزات المنتج...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    // Category dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'قسم المنتج',
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
                            label: 'سعر البيع (د.ج) *',
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
                            label: 'السعر قبل الخصم',
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
                            label: 'كمية المخزون',
                            hint: '100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            controller: _skuController,
                            label: 'رمز SKU (اختياري)',
                            hint: 'WAT-001',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 3. Product Images ──────────────────────────────────────
                _cardWrapper(
                  title: 'صور المنتج',
                  icon: LucideIcons.image,
                  children: [
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('إضافة رابط',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _images.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final url = entry.value;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  color: AppColors.primaryBg,
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(LucideIcons.image,
                                          size: 20, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(idx),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.x,
                                        size: 12, color: Colors.white),
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
                  title: 'عروض الكميات المخفضة (Packs)',
                  icon: LucideIcons.tag,
                  children: [
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
                            Expanded(
                              child: Text(
                                '${pack.quantity} قطع بـ ${pack.price.toStringAsFixed(0)} د.ج ${pack.label != null ? "(${pack.label})" : ""}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
                      label: const Text('إضافة حزمة كميات مخفضة',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
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
                  title: 'خيارات العرض والظهور',
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
                      title: const Text('المنتج نشط ومتاح للشراء',
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
