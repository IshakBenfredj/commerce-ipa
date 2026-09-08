import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/banner.dart';
import '../../providers/settings_provider.dart';

class HeroSettingsScreen extends StatefulWidget {
  const HeroSettingsScreen({super.key});

  @override
  State<HeroSettingsScreen> createState() => _HeroSettingsScreenState();
}

class _HeroSettingsScreenState extends State<HeroSettingsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _badgeController;
  late TextEditingController _ctaController;
  late TextEditingController _imageController;

  late String _selectedVariant;
  late List<BannerItem> _banners;

  final List<Map<String, String>> _heroVariants = [
    {
      'id': 'editorial-bento',
      'title': 'بينتو تحريري فاخر (Bento)',
      'desc': 'شبكة كروت عصرية متباينة مع إبراز أقوى المنتجات والعروض',
    },
    {
      'id': 'cinematic-slider',
      'title': 'سلايدر سينمائي متحرك (Slider)',
      'desc': 'صور عريضة متقلبة تلقائياً مع طبقة تدرج نصوص أنيقة',
    },
    {
      'id': 'modern-split',
      'title': 'تصميم منقسم عصري (Split)',
      'desc': 'نصوص ترويجية عريضة على اليمين مع صورة المنتج البارزة',
    },
    {
      'id': 'minimal-clean',
      'title': 'بسيط ونقي (Minimal)',
      'desc': 'مظهر راقي يركز على نقاء العنوان والزر الرئيسي للشراء',
    },
    {
      'id': 'dynamic-grid',
      'title': 'شبكة تفاعلية ذكية (Grid)',
      'desc': 'عرض متناغم للبانرات الإعلانية الترويجية في الصفحة',
    },
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _titleController = TextEditingController(text: s?.heroTitle ?? '');
    _subtitleController = TextEditingController(text: s?.heroSubtitle ?? '');
    _badgeController = TextEditingController(text: s?.heroBadge ?? '');
    _ctaController = TextEditingController(text: s?.heroCtaText ?? 'تسوق الآن');
    _imageController = TextEditingController(text: s?.heroImageUrl ?? '');
    _selectedVariant = s?.heroVariant ?? 'editorial-bento';
    _banners = List.from(s?.banners ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _badgeController.dispose();
    _ctaController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _addBanner() {
    setState(() {
      _banners.add(BannerItem(
        id: 'ban-${DateTime.now().millisecondsSinceEpoch}',
        title: 'عرض ترويجي جديد',
        subtitle: 'تخفيضات حصرية لفترة محدودة',
        badge: 'تخفيض 30%',
        imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=1200&q=80',
        ctaText: 'اكتشف العرض',
      ));
    });
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.heroVariant = _selectedVariant;
      s.heroTitle = _titleController.text.trim();
      s.heroSubtitle = _subtitleController.text.trim();
      s.heroBadge = _badgeController.text.trim();
      s.heroCtaText = _ctaController.text.trim();
      s.heroImageUrl = _imageController.text.trim();
      s.banners = _banners;
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم حفظ إعدادات وقالب الهيرو بنجاح' : 'تعذر الحفظ'),
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
            'نمط وقالب الهيرو والبانرات',
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
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
              // ── 1. Hero Template Selector ────────────────────────────────
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
                        Icon(LucideIcons.layoutTemplate, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('اختيار قالب وقسم الهيرو الرئيسي', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    ..._heroVariants.map((v) {
                      final isSelected = _selectedVariant == v['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBg : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => setState(() => _selectedVariant = v['id']!),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Icon(
                            isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            size: 20,
                          ),
                          title: Text(
                            v['title']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.text,
                            ),
                          ),
                          subtitle: Text(
                            v['desc']!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSub),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Hero Content & Texts ──────────────────────────────────
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
                        Icon(LucideIcons.type, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('نصوص وعناوين الهيرو', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildTextField(_titleController, 'العنوان الرئيسي للهيرو', 'مثال: تسوق أفضل المنتجات بتوصيل 69 ولاية'),
                    const SizedBox(height: 12),
                    _buildTextField(_subtitleController, 'العنوان الفرعي التوضيحي', 'مثال: دفع آمن عند الاستلام وضمان الجودة', maxLines: 2),
                    const SizedBox(height: 12),
                    _buildTextField(_badgeController, 'شارة الهيرو (Badge)', 'مثال: 🔥 عروض وتخفيضات كبرى'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_ctaController, 'نص زر الشراء الرئيسي', 'تسوق الآن')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_imageController, 'رابط الصورة البارزة', 'https://...')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 3. Banners Management ────────────────────────────────────
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.image, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('البانرات والإعلانات الترويجية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                          ],
                        ),
                        IconButton(
                          onPressed: _addBanner,
                          icon: const Icon(LucideIcons.plusCircle, size: 20, color: AppColors.primary),
                          tooltip: 'إضافة بانر جديد',
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    if (_banners.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('لا توجد بانرات مضافة حالياً. اضغط + لإضافة بانر إعلاني.', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                        ),
                      )
                    else
                      ..._banners.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final b = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('بانر #${idx + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                                    onPressed: () => setState(() => _banners.removeAt(idx)),
                                  ),
                                ],
                              ),
                              TextFormField(
                                initialValue: b.title,
                                textDirection: TextDirection.rtl,
                                onChanged: (val) => _banners[idx] = BannerItem(
                                  id: b.id,
                                  title: val,
                                  subtitle: b.subtitle,
                                  badge: b.badge,
                                  imageUrl: b.imageUrl,
                                  linkUrl: b.linkUrl,
                                  ctaText: b.ctaText,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'عنوان البانر',
                                  labelStyle: TextStyle(fontSize: 11),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: b.imageUrl,
                                textDirection: TextDirection.ltr,
                                onChanged: (val) => _banners[idx] = BannerItem(
                                  id: b.id,
                                  title: b.title,
                                  subtitle: b.subtitle,
                                  badge: b.badge,
                                  imageUrl: val,
                                  linkUrl: b.linkUrl,
                                  ctaText: b.ctaText,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'رابط صورة البانر',
                                  labelStyle: TextStyle(fontSize: 11),
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
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
