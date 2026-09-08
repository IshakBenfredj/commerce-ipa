import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/settings_provider.dart';

class IdentitySettingsScreen extends StatefulWidget {
  const IdentitySettingsScreen({super.key});

  @override
  State<IdentitySettingsScreen> createState() => _IdentitySettingsScreenState();
}

class _IdentitySettingsScreenState extends State<IdentitySettingsScreen> {
  late TextEditingController _nameArController;
  late TextEditingController _nameFrController;
  late TextEditingController _descArController;
  late TextEditingController _logoUrlController;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _nameArController = TextEditingController(text: s?.storeNameAr ?? '');
    _nameFrController = TextEditingController(text: s?.storeNameFr ?? '');
    _descArController = TextEditingController(text: s?.storeDescriptionAr ?? '');
    _logoUrlController = TextEditingController(text: s?.logoUrl ?? '');
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameFrController.dispose();
    _descArController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.storeNameAr = _nameArController.text.trim();
      s.storeNameFr = _nameFrController.text.trim().isNotEmpty ? _nameFrController.text.trim() : null;
      s.storeDescriptionAr = _descArController.text.trim().isNotEmpty ? _descArController.text.trim() : null;
      s.logoUrl = _logoUrlController.text.trim().isNotEmpty ? _logoUrlController.text.trim() : null;
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم حفظ بيانات وهوية المتجر بنجاح' : 'تعذر الحفظ'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<SettingsProvider>().isSaving;

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
          title: const Text(
            'بيانات وهوية المتجر والشعار',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _handleSave,
            icon: isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.save, size: 18),
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ هوية المتجر', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Logo Section ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.image, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('شعار المتجر (Logo)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: _logoUrlController.text.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    _logoUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(LucideIcons.store, size: 28, color: AppColors.primary),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(LucideIcons.store, size: 28, color: AppColors.primary),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildTextField(
                            _logoUrlController,
                            'رابط صورة الشعار',
                            'https://...',
                            textDirection: TextDirection.ltr,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Store Names & Descriptions ────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.store, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('بيانات المتجر والاسم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildTextField(_nameArController, 'اسم المتجر بالعربية *', 'مثال: المتجر الجزائري الحديث'),
                    const SizedBox(height: 12),
                    _buildTextField(_nameFrController, 'اسم المتجر بالفرنسية (اختياري)', 'Boutique Algérienne'),
                    const SizedBox(height: 12),
                    _buildTextField(_descArController, 'وصف ونبذة عن المتجر', 'المتجر الأول في الجزائر للمنتجات المميزة...', maxLines: 3),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextDirection textDirection = TextDirection.rtl,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textDirection: textDirection,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
