import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final cats = await ApiService().getCategories();
    if (mounted) setState(() { _categories = cats; _isLoading = false; });
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final nameArCtrl  = TextEditingController(text: category?.nameAr ?? '');
    final nameFrCtrl  = TextEditingController(text: category?.nameFr ?? '');
    final slugCtrl    = TextEditingController(text: category?.slug ?? '');
    bool isActive     = category?.isActive ?? true;
    bool isSaving     = false;
    bool isUploading  = false;
    String? imageUrl  = category?.imageUrl;
    final formKey     = GlobalKey<FormState>();
    final picker      = ImagePicker();

    void generateSlug(String arabic) {
      slugCtrl.text = _slugify(arabic);
    }

    Future<void> pickImage(ImageSource source, StateSetter setModalState) async {
      try {
        final XFile? file = await picker.pickImage(
          source: source, imageQuality: 85, maxWidth: 800);
        if (file == null) return;
        setModalState(() => isUploading = true);
        final bytes = await file.readAsBytes();
        final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        final url = await ApiService().uploadImageBase64(b64, folder: 'categories');
        setModalState(() { isUploading = false; if (url != null) imageUrl = url; });
      } catch (_) {
        setModalState(() => isUploading = false);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20, 20, 20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            category == null ? LucideIcons.folderPlus : LucideIcons.folderEdit,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category == null ? 'إضافة قسم جديد' : 'تعديل القسم',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('اسم القسم بالعربية *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSub)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameArCtrl,
                      textDirection: TextDirection.rtl,
                      onChanged: generateSlug,
                      decoration: _inputDeco(context, 'مثال: إلكترونيات'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    const Text('اسم القسم بالفرنسية (اختياري)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSub)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameFrCtrl,
                      textDirection: TextDirection.ltr,
                      decoration: _inputDeco(context, 'مثال: Électronique'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    const Text('رمز URL (Slug) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSub)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: slugCtrl,
                      textDirection: TextDirection.ltr,
                      decoration: _inputDeco(context, 'electronique'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bgOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderOf(context)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.eye, size: 18, color: AppColors.textSub),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('القسم مرئي في المتجر',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (v) => setModalState(() => isActive = v),
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Category Image ────────────────────────────────────
                    const Text('صورة القسم (اختياري)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSub)),
                    const SizedBox(height: 8),
                    if (isUploading)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.bgOf(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderOf(context)),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                              SizedBox(height: 8),
                              Text('جاري رفع الصورة...', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                            ],
                          ),
                        ),
                      )
                    else if (imageUrl != null && imageUrl!.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl!,
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 110,
                                color: AppColors.bgOf(context),
                                child: const Center(child: Icon(LucideIcons.imageOff, color: AppColors.textMuted)),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6, left: 6,
                            child: Row(
                              children: [
                                _imgActionBtn(
                                  icon: LucideIcons.images,
                                  label: 'تغيير',
                                  onTap: () => pickImage(ImageSource.gallery, setModalState),
                                ),
                                const SizedBox(width: 6),
                                _imgActionBtn(
                                  icon: LucideIcons.trash2,
                                  label: 'حذف',
                                  color: AppColors.danger,
                                  onTap: () => setModalState(() => imageUrl = null),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => pickImage(ImageSource.gallery, setModalState),
                              icon: const Icon(LucideIcons.images, size: 16),
                              label: const Text('من المعرض', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => pickImage(ImageSource.camera, setModalState),
                              icon: const Icon(LucideIcons.camera, size: 16),
                              label: const Text('كاميرا', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSub,
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSaving = true);
                                final updated = Category(
                                  id: category?.id ?? '',
                                  nameAr: nameArCtrl.text.trim(),
                                  nameFr: nameFrCtrl.text.trim().isEmpty
                                      ? null
                                      : nameFrCtrl.text.trim(),
                                  slug: slugCtrl.text.trim().toLowerCase(),
                                  isActive: isActive,
                                  sortOrder: category?.sortOrder ?? 1,
                                  imageUrl: imageUrl,
                                );
                                final ok = await ApiService().saveCategory(updated);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                                if (ok) {
                                  if (mounted) await _loadCategories();
                                  _snack(category == null
                                      ? 'تم إضافة القسم بنجاح ✅'
                                      : 'تم تعديل القسم بنجاح ✅',
                                    AppColors.success);
                                } else {
                                  _snack('تعذر حفظ القسم، حاول مرة أخرى', AppColors.danger);
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(LucideIcons.save, size: 17),
                        label: Text(
                          isSaving ? 'جاري الحفظ...' : (category == null ? 'إضافة القسم' : 'حفظ التعديلات'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceOf(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('حذف القسم', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text(
            'هل أنت متأكد من حذف هذا القسم؟',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && category.id.isNotEmpty) {
      final ok = await ApiService().deleteCategory(category.id);
      if (ok) {
        await _loadCategories();
        _snack('تم حذف القسم بنجاح 🗑️', AppColors.warning);
      } else {
        _snack('تعذر حذف القسم', AppColors.danger);
      }
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  String _slugify(String text) {
    const Map<String, String> ar = {
      'ا':'a','أ':'a','إ':'a','آ':'a','ب':'b','ت':'t','ث':'th','ج':'j','ح':'h',
      'خ':'kh','د':'d','ذ':'dh','ر':'r','ز':'z','س':'s','ش':'sh','ص':'s',
      'ض':'d','ط':'t','ظ':'dh','ع':'a','غ':'gh','ف':'f','ق':'q','ك':'k',
      'ل':'l','م':'m','ن':'n','ه':'h','و':'w','ي':'y','ى':'a','ة':'a',
      'ء':'','ئ':'y','ؤ':'w',' ':'-',
    };
    final result = text.runes.map((r) {
      final c = String.fromCharCode(r);
      return ar[c] ?? (RegExp(r'[a-zA-Z0-9\-]').hasMatch(c) ? c.toLowerCase() : '');
    }).join();
    return result.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  }

  static InputDecoration _inputDeco(BuildContext context, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgOf(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderOf(context))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderOf(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  static Widget _imgActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgOf(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceOf(context),
          elevation: 0,
          title: const Text('إدارة الأقسام',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowRight, color: AppColors.text),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.borderOf(context)),
          ),
          actions: [
            IconButton(
              onPressed: _loadCategories,
              icon: const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.textSub),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCategoryDialog(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.folderPlus, size: 20),
          label: const Text('إضافة قسم',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBg, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.folderOpen,
                              size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text('لا توجد أقسام بعد',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        const Text('اضغط "إضافة قسم" لإنشاء أول قسم في متجرك.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSub)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCategories,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return _CategoryCard(
                          category: cat,
                          index: index + 1,
                          onEdit: () => _showCategoryDialog(category: cat),
                          onDelete: () => _confirmDelete(cat),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Thumbnail: image if exists, else index circle ──
            if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  category.imageUrl!,
                  width: 48, height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _indexCircle(context),
                ),
              )
            else
              _indexCircle(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row — use Flexible so long names truncate
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          category.nameAr,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text),
                        ),
                      ),
                      if (!category.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('مخفي',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                  color: AppColors.danger)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Slug row — truncate with ellipsis
                  Row(
                    children: [
                      if (category.nameFr != null && category.nameFr!.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            category.nameFr!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                          ),
                        ),
                        const Text(' · ',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                      Flexible(
                        child: Text(
                          '/${category.slug}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil, size: 18, color: AppColors.primary),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _indexCircle(BuildContext context) => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(
      color: category.isActive ? AppColors.primaryBg : AppColors.bgOf(context),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: category.isActive ? AppColors.primary : AppColors.borderOf(context)),
    ),
    child: Center(
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: category.isActive ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    ),
  );
}
