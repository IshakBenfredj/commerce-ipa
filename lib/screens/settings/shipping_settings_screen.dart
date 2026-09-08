import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/colors.dart';
import '../../models/wilaya_tarif.dart';
import '../../providers/settings_provider.dart';

class ShippingSettingsScreen extends StatefulWidget {
  const ShippingSettingsScreen({super.key});

  @override
  State<ShippingSettingsScreen> createState() => _ShippingSettingsScreenState();
}

class _ShippingSettingsScreenState extends State<ShippingSettingsScreen> {
  late TextEditingController _homeCostController;
  late TextEditingController _deskCostController;
  late TextEditingController _freeThresholdController;
  late TextEditingController _searchController;

  String _searchQuery = '';
  List<WilayaTarif> _wilayas = [];

  // Controllers for adding new wilaya modal
  final _newCodeController = TextEditingController();
  final _newNameArController = TextEditingController();
  final _newNameFrController = TextEditingController();
  final _newHomePriceController = TextEditingController(text: '700');
  final _newDeskPriceController = TextEditingController(text: '400');

  // Controller for JSON paste modal
  final _jsonPasteController = TextEditingController();

  // Controllers for Bulk edit modal
  final _bulkHomePriceController = TextEditingController();
  final _bulkDeskPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _homeCostController = TextEditingController(text: s?.defaultHomeShippingCost?.toStringAsFixed(0) ?? '700');
    _deskCostController = TextEditingController(text: s?.defaultDeskShippingCost?.toStringAsFixed(0) ?? '400');
    _freeThresholdController = TextEditingController(text: s?.freeShippingThreshold?.toStringAsFixed(0) ?? '10000');
    _searchController = TextEditingController();

    _wilayas = List.from(s?.wilayasShipping ?? []);
  }

  @override
  void dispose() {
    _homeCostController.dispose();
    _deskCostController.dispose();
    _freeThresholdController.dispose();
    _searchController.dispose();
    _newCodeController.dispose();
    _newNameArController.dispose();
    _newNameFrController.dispose();
    _newHomePriceController.dispose();
    _newDeskPriceController.dispose();
    _jsonPasteController.dispose();
    _bulkHomePriceController.dispose();
    _bulkDeskPriceController.dispose();
    super.dispose();
  }

  List<WilayaTarif> get _filteredWilayas {
    if (_searchQuery.isEmpty) return _wilayas;
    final q = _searchQuery.toLowerCase();
    return _wilayas.where((w) {
      return w.code.toString().contains(q) ||
          w.nameAr.toLowerCase().contains(q) ||
          w.nameFr.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _handleFileUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String jsonContent = '';
        if (file.bytes != null) {
          jsonContent = utf8.decode(file.bytes!);
        }

        if (!mounted) return;
        if (jsonContent.isNotEmpty) {
          final success = context.read<SettingsProvider>().importWilayasFromJson(jsonContent);
          if (success) {
            setState(() {
              _wilayas = List.from(context.read<SettingsProvider>().settings?.wilayasShipping ?? []);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم استيراد أسعار الولايات من ملف JSON بنجاح'), backgroundColor: AppColors.success),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('صيغة ملف JSON غير صحيحة'), backgroundColor: AppColors.danger),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showJsonPasteDialog();
      }
    }
  }

  void _showJsonPasteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.fileCode, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text('لصق بيانات JSON للولايات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'الصق هنا محتوى ملف JSON الذي يحتوي على مصفوفة الولايات:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSub),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jsonPasteController,
                  maxLines: 8,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: '{\n  "wilayas": [\n    {"code": 1, "name_ar": "أدرار", "tarif_domicile": 1650, "tarif_bureau": 1550}\n  ]\n}',
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _jsonPasteController.text.trim();
                final success = context.read<SettingsProvider>().importWilayasFromJson(text);
                if (success) {
                  setState(() {
                    _wilayas = List.from(context.read<SettingsProvider>().settings?.wilayasShipping ?? []);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استيراد قائمة الولايات بنجاح'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('صيغة JSON غير صحيحة، تأكد من الهيكلة'), backgroundColor: AppColors.danger),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
              child: const Text('استيراد الآن'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWilayaDialog() {
    _newCodeController.clear();
    _newNameArController.clear();
    _newNameFrController.clear();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة ولاية جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم الولاية (Code)', hintText: 'مثال: 59'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newNameArController,
                  decoration: const InputDecoration(labelText: 'اسم الولاية بالعربية', hintText: 'مثال: بني عباس'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newNameFrController,
                  decoration: const InputDecoration(labelText: 'اسم الولاية بالفرنسية', hintText: 'Béni Abbès'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newHomePriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'توصيل للمنزل (د.ج)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _newDeskPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'توصيل للمكتب (د.ج)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                final code = int.tryParse(_newCodeController.text.trim());
                final nameAr = _newNameArController.text.trim();
                if (code != null && nameAr.isNotEmpty) {
                  final newW = WilayaTarif(
                    code: code,
                    nameAr: nameAr,
                    nameFr: _newNameFrController.text.trim().isNotEmpty ? _newNameFrController.text.trim() : nameAr,
                    tarifDomicile: double.tryParse(_newHomePriceController.text) ?? 700,
                    tarifBureau: double.tryParse(_newDeskPriceController.text) ?? 400,
                    active: true,
                  );

                  setState(() {
                    _wilayas.removeWhere((w) => w.code == code);
                    _wilayas.add(newW);
                    _wilayas.sort((a, b) => a.code.compareTo(b.code));
                  });

                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعديل جماعي لأسعار كل الولايات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('سيتم تطبيق هذه الأسعار على جميع الولايات (69 ولاية):', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
              const SizedBox(height: 12),
              TextField(
                controller: _bulkHomePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعر التوصيل للمنزل (د.ج)', hintText: '700'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bulkDeskPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعر التوصيل للمكتب (د.ج)', hintText: '400'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                final home = double.tryParse(_bulkHomePriceController.text);
                final desk = double.tryParse(_bulkDeskPriceController.text);

                if (home != null || desk != null) {
                  setState(() {
                    for (var w in _wilayas) {
                      if (home != null) w.tarifDomicile = home;
                      if (desk != null) w.tarifBureau = desk;
                    }
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تطبيق الأسعار الجماعية على جميع الولايات'), backgroundColor: AppColors.success),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
              child: const Text('تطبيق على الكل'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.defaultHomeShippingCost = double.tryParse(_homeCostController.text) ?? 700;
      s.defaultDeskShippingCost = double.tryParse(_deskCostController.text) ?? 400;
      s.freeShippingThreshold = double.tryParse(_freeThresholdController.text) ?? 10000;
      s.wilayasShipping = _wilayas;
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم حفظ أسعار الشحن والتوصيل لـ 69 ولاية بنجاح' : 'تعذر الحفظ'),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<SettingsProvider>().isSaving;
    final filtered = _filteredWilayas;

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
            'الشحن والتوصيل (69 ولاية)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.slidersHorizontal, size: 19, color: AppColors.primary),
              onPressed: _showBulkEditDialog,
              tooltip: 'تعديل جماعي للأسعار',
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
            onPressed: isSaving ? null : _handleSave,
            icon: isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.save, size: 18),
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ تسعيرة الشحن', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
              // ── 1. Global Thresholds ─────────────────────────────────────
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
                        Icon(LucideIcons.truck, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('الإعدادات العامة للشحن', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallField(_homeCostController, 'الافتراضي للمنزل (د.ج)', '700'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSmallField(_deskCostController, 'الافتراضي للمكتب (د.ج)', '400'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSmallField(_freeThresholdController, 'عتبة الشحن المجاني (د.ج)', '10000'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. JSON Upload / Import / Reset Actions ───────────────────
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
                        Icon(LucideIcons.uploadCloud, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('استيراد وتخصيص ملف JSON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleFileUpload,
                            icon: const Icon(LucideIcons.upload, size: 16),
                            label: const Text('رفع ملف JSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showJsonPasteDialog,
                            icon: const Icon(LucideIcons.fileCode, size: 16),
                            label: const Text('لصق JSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            await context.read<SettingsProvider>().resetWilayasToDefault();
                            if (!context.mounted) return;
                            setState(() {
                              _wilayas = List.from(context.read<SettingsProvider>().settings?.wilayasShipping ?? []);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت استعادة الأسعار الافتراضية لـ 69 ولاية'), backgroundColor: AppColors.success),
                            );
                          },
                          icon: const Icon(LucideIcons.rotateCcw, size: 18, color: AppColors.warning),
                          tooltip: 'استعادة الافتراضي',
                        ),
                        IconButton(
                          onPressed: _showAddWilayaDialog,
                          icon: const Icon(LucideIcons.plus, size: 20, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          tooltip: 'إضافة ولاية',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 3. Wilayas List & Search ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة الولايات (${_wilayas.length} ولاية)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                  Text(
                    '${filtered.length} مطابقة',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'البحث باسم الولاية أو رقمها (مثال: 16 أو الجزائر)...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Wilayas cards list
              ...filtered.map((w) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${w.code}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${w.nameAr} (${w.nameFr})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Switch(
                                value: w.active,
                                onChanged: (val) => setState(() => w.active = val),
                                activeThumbColor: AppColors.success,
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                                onPressed: () {
                                  setState(() => _wilayas.removeWhere((item) => item.code == w.code));
                                },
                                tooltip: 'حذف الولاية',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: w.tarifDomicile.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              onChanged: (v) {
                                w.tarifDomicile = double.tryParse(v) ?? w.tarifDomicile;
                              },
                              decoration: const InputDecoration(
                                labelText: 'سعر المنزل (د.ج)',
                                labelStyle: TextStyle(fontSize: 11),
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: w.tarifBureau.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              onChanged: (v) {
                                w.tarifBureau = double.tryParse(v) ?? w.tarifBureau;
                              },
                              decoration: const InputDecoration(
                                labelText: 'سعر المكتب (د.ج)',
                                labelStyle: TextStyle(fontSize: 11),
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}
