import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/store_settings.dart';
import '../../providers/settings_provider.dart';

class ContactSettingsScreen extends StatefulWidget {
  const ContactSettingsScreen({super.key});

  @override
  State<ContactSettingsScreen> createState() => _ContactSettingsScreenState();
}

class _ContactSettingsScreenState extends State<ContactSettingsScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _phoneController = TextEditingController(text: s?.phone ?? '0541790205');
    _whatsappController = TextEditingController(text: s?.whatsappNumber ?? '213541790205');
    _emailController = TextEditingController(text: s?.email ?? 'contact@algerianstore.dz');
    _addressController = TextEditingController(text: s?.address ?? 'الجزائر العاصمة، الجزائر');
    _facebookController = TextEditingController(text: s?.socialLinks.facebook ?? '');
    _instagramController = TextEditingController(text: s?.socialLinks.instagram ?? '');
    _tiktokController = TextEditingController(text: s?.socialLinks.tiktok ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final provider = context.read<SettingsProvider>();
    provider.updateSettings((s) {
      s.phone = _phoneController.text.trim();
      s.whatsappNumber = _whatsappController.text.trim();
      s.email = _emailController.text.trim();
      s.address = _addressController.text.trim();
      s.socialLinks = SocialLinks(
        facebook: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
        instagram: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
        tiktok: _tiktokController.text.trim().isNotEmpty ? _tiktokController.text.trim() : null,
      );
    });

    final success = await provider.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم حفظ أرقام التواصل وروابط الشبكات بنجاح' : 'تعذر الحفظ'),
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
            'أرقام التواصل والشبكات',
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
            label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ بيانات التواصل', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
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
              // ── 1. Direct Contact Details ────────────────────────────────
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
                        Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('معلومات الاتصال المباشر', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildTextField(_phoneController, 'رقم هاتف خدمة العملاء', '0541790205', keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField(_whatsappController, 'رقم الواتساب (مع رمز الدولة)', '213541790205', keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField(_emailController, 'البريد الإلكتروني الرسمي', 'contact@store.dz', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, 'عنوان المتجر / المقر', 'الجزائر العاصمة، الجزائر'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Social Media Links ────────────────────────────────────
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
                        Icon(LucideIcons.globe, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('روابط شبكات التواصل الاجتماعي', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _buildTextField(_facebookController, 'رابط صفحة الفيسبوك', 'https://facebook.com/...', textDirection: TextDirection.ltr),
                    const SizedBox(height: 12),
                    _buildTextField(_instagramController, 'رابط حساب الانستغرام', 'https://instagram.com/...', textDirection: TextDirection.ltr),
                    const SizedBox(height: 12),
                    _buildTextField(_tiktokController, 'رابط حساب التيك توك', 'https://tiktok.com/@...', textDirection: TextDirection.ltr),
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
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
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
