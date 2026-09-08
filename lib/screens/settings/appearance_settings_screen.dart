import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/store_settings.dart';
import '../../providers/settings_provider.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  late TextEditingController _primaryHexController;
  late TextEditingController _secondaryHexController;
  late TextEditingController _accentHexController;
  late String _selectedThemeName;

  final List<Map<String, dynamic>> _presetPalettes = [
    {
      'id': 'midnight',
      'name': 'اللافندر والبنفسجي العصري',
      'primary': '#5C6AC4',
      'secondary': '#1E1B4B',
      'accent': '#8B5CF6',
    },
    {
      'id': 'emerald',
      'name': 'الزمرد الملكي والأخضر الفاخر',
      'primary': '#059669',
      'secondary': '#064E3B',
      'accent': '#10B981',
    },
    {
      'id': 'luxury-dark',
      'name': 'الفخامة السوداء والذهب',
      'primary': '#1C1B1F',
      'secondary': '#D97706',
      'accent': '#F59E0B',
    },
    {
      'id': 'ocean-blue',
      'name': 'أزرق المحيط والأكوا',
      'primary': '#2563EB',
      'secondary': '#1E3A8A',
      'accent': '#38BDF8',
    },
    {
      'id': 'rose-crimson',
      'name': 'الوردي والياقوت الجذاب',
      'primary': '#E11D48',
      'secondary': '#881337',
      'accent': '#FB7185',
    },
  ];

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _primaryHexController = TextEditingController(text: s?.customColors.primary ?? '#5C6AC4');
    _secondaryHexController = TextEditingController(text: s?.customColors.secondary ?? '#1E1B4B');
    _accentHexController = TextEditingController(text: s?.customColors.accent ?? '#8B5CF6');
    _selectedThemeName = s?.themeName ?? 'midnight';
  }

  @override
  void dispose() {
    _primaryHexController.dispose();
    _secondaryHexController.dispose();
    _accentHexController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedThemeName = preset['id'];
      _primaryHexController.text = preset['primary'];
      _secondaryHexController.text = preset['secondary'];
      _accentHexController.text = preset['accent'];
    });
  }

  Color _parseColor(String hexString, Color fallback) {
    try {
      final clean = hexString.replaceAll('#', '').replaceAll('0x', '');
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
    } catch (_) {}
    return fallback;
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.themeName = _selectedThemeName;
      s.customColors = CustomColors(
        primary: _primaryHexController.text.trim(),
        secondary: _secondaryHexController.text.trim(),
        accent: _accentHexController.text.trim(),
      );
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم حفظ ألوان ومظهر المتجر بنجاح' : 'تعذر الحفظ'),
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
            'مظهر وألوان المتجر',
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
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ لوحة الألوان', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
              // ── 1. Presets List ──────────────────────────────────────────
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
                        Icon(LucideIcons.palette, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('الباليتات والأنماط الجاهزة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    ..._presetPalettes.map((p) {
                      final isSelected = _selectedThemeName == p['id'];
                      final colorP = _parseColor(p['primary'], Colors.blue);
                      final colorS = _parseColor(p['secondary'], Colors.grey);
                      final colorA = _parseColor(p['accent'], Colors.orange);

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
                          onTap: () => _applyPreset(p),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          title: Text(
                            p['name'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.text,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _colorDot(colorP),
                              const SizedBox(width: 4),
                              _colorDot(colorS),
                              const SizedBox(width: 4),
                              _colorDot(colorA),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Custom Hex Colors ─────────────────────────────────────
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
                        Icon(LucideIcons.sliders, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('تخصيص كود الألوان (Hex)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _hexInputField(_primaryHexController, 'اللون الأساسي (Primary)', '#5C6AC4'),
                    const SizedBox(height: 12),
                    _hexInputField(_secondaryHexController, 'اللون الثانوي (Secondary)', '#1E1B4B'),
                    const SizedBox(height: 12),
                    _hexInputField(_accentHexController, 'لون التمييز (Accent)', '#8B5CF6'),
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

  Widget _colorDot(Color c) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }

  Widget _hexInputField(TextEditingController controller, String label, String hint) {
    final currentColor = _parseColor(controller.text, AppColors.primary);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
