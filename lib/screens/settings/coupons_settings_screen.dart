import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../constants/colors.dart';
import '../../models/coupon.dart';
import '../../services/api_service.dart';

class CouponsSettingsScreen extends StatefulWidget {
  const CouponsSettingsScreen({super.key});

  @override
  State<CouponsSettingsScreen> createState() => _CouponsSettingsScreenState();
}

class _CouponsSettingsScreenState extends State<CouponsSettingsScreen> {
  final ApiService _apiService = ApiService();
  List<Coupon> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    final coupons = await _apiService.getCoupons();
    if (mounted) {
      setState(() {
        _coupons = coupons;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCoupon(Coupon coupon, bool newValue) async {
    final success = await _apiService.toggleCouponActive(coupon.id, newValue);
    if (success) {
      setState(() {
        final idx = _coupons.indexWhere((c) => c.id == coupon.id);
        if (idx != -1) {
          _coupons[idx] = coupon.copyWith(isActive: newValue);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newValue ? 'تم تفعيل الكوبون بنجاح' : 'تم تعطيل الكوبون'),
            backgroundColor: newValue ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحديث حالة الكوبون'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _deleteCoupon(Coupon coupon) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف الكوبون', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text('هل أنت متأكد من رغبتك في حذف الكوبون "${coupon.code}"؟ لن يتمكن الزبائن من استخدامه بعد الحذف.'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف الكوبون'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteCoupon(coupon.id);
      if (success) {
        setState(() {
          _coupons.removeWhere((c) => c.id == coupon.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الكوبون بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في حذف الكوبون'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _openAddCouponSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCouponBottomSheet(
        onCouponCreated: (newCoupon) {
          setState(() {
            _coupons.insert(0, newCoupon);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إضافة الكوبون "${newCoupon.code}" بنجاح!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _coupons.where((c) => c.isActive && !c.isExpired).length;
    final totalUses = _coupons.fold<int>(0, (sum, c) => sum + c.timesUsed);

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
            'كوبونات وقسائم التخفيض',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
              tooltip: 'إضافة كوبون جديد',
              onPressed: _openAddCouponSheet,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddCouponSheet,
          backgroundColor: AppColors.primary,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text(
            'إضافة كوبون جديد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadCoupons,
          color: AppColors.primary,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Top Stats Cards ─────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'إجمالي الكوبونات',
                              value: '${_coupons.length}',
                              icon: LucideIcons.ticket,
                              color: AppColors.primary,
                              bgColor: AppColors.primaryBg,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              title: 'الكوبونات النشطة',
                              value: '$activeCount',
                              icon: LucideIcons.checkCircle2,
                              color: AppColors.success,
                              bgColor: AppColors.successBg,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              title: 'مرات الاستخدام',
                              value: '$totalUses',
                              icon: LucideIcons.shoppingBag,
                              color: AppColors.purple,
                              bgColor: AppColors.purpleBg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Coupons List Header ─────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'قائمة الكوبونات المتاحة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${_coupons.length} كوبون',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Coupons Cards ───────────────────────────────────────
                      if (_coupons.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.ticket, size: 36, color: AppColors.primary),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'لا توجد كوبونات خصم حتى الآن',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'أنشئ كوبونات خصم لجذب الزبائن وزيادة مبيعات متجرك',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.textSub),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _openAddCouponSheet,
                                icon: const Icon(LucideIcons.plus, size: 18),
                                label: const Text('إنشاء أول كوبون خصم'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _coupons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final coupon = _coupons[index];
                            return _CouponItemCard(
                              coupon: coupon,
                              onToggle: (val) => _toggleCoupon(coupon, val),
                              onDelete: () => _deleteCoupon(coupon),
                            );
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Stat Card Component ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Coupon Item Card ─────────────────────────────────────────────────────────
class _CouponItemCard extends StatelessWidget {
  final Coupon coupon;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _CouponItemCard({
    required this.coupon,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = coupon.isExpired;
    final isEffectiveActive = coupon.isActive && !isExpired;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEffectiveActive ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border,
          width: isEffectiveActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Code Badge + Active Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Code chip with copy action
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: coupon.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ كود الكوبون: ${coupon.code}'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.ticket, size: 15, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        coupon.code,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.copy, size: 12, color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),

              // Status Toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'منتهي الصلاحية',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                    )
                  else
                    Switch(
                      value: coupon.isActive,
                      activeThumbColor: AppColors.success,
                      onChanged: onToggle,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Discount Details Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: coupon.isPercentage ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: coupon.isPercentage ? const Color(0xFF93C5FD) : const Color(0xFF86EFAC),
                  ),
                ),
                child: Text(
                  coupon.isPercentage ? 'خصم ${coupon.formattedDiscount}' : 'خصم ${coupon.formattedDiscount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: coupon.isPercentage ? const Color(0xFF1D4ED8) : const Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (coupon.minOrderAmount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'الحد الأدنى: ${coupon.minOrderAmount.toStringAsFixed(0)} دج',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub),
                  ),
                ),
            ],
          ),

          if (coupon.maxDiscountAmount != null && coupon.maxDiscountAmount! > 0) ...[
            const SizedBox(height: 6),
            Text(
              '• أقصى قيمة للخصم: ${coupon.maxDiscountAmount!.toStringAsFixed(0)} دج',
              style: const TextStyle(fontSize: 11, color: AppColors.textSub),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // Footer: Usage stats and Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'تم الاستخدام: ${coupon.timesUsed} ${coupon.usageLimit != null ? '/ ${coupon.usageLimit}' : 'مرة'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSub),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
                tooltip: 'حذف الكوبون',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Coupon Bottom Sheet ───────────────────────────────────────────────────
class _AddCouponBottomSheet extends StatefulWidget {
  final ValueChanged<Coupon> onCouponCreated;

  const _AddCouponBottomSheet({required this.onCouponCreated});

  @override
  State<_AddCouponBottomSheet> createState() => _AddCouponBottomSheetState();
}

class _AddCouponBottomSheetState extends State<_AddCouponBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();

  String _discountType = 'percentage'; // 'percentage' or 'fixed'
  bool _isActive = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = {
      'code': _codeController.text.trim().toUpperCase(),
      'discount_type': _discountType,
      'discount_value': double.tryParse(_discountValueController.text.trim()) ?? 0.0,
      'min_order_amount': double.tryParse(_minOrderController.text.trim()) ?? 0.0,
      if (_maxDiscountController.text.trim().isNotEmpty)
        'max_discount_amount': double.tryParse(_maxDiscountController.text.trim()),
      if (_usageLimitController.text.trim().isNotEmpty)
        'usage_limit': int.tryParse(_usageLimitController.text.trim()),
      'is_active': _isActive,
    };

    final result = await _apiService.createCoupon(payload);

    if (result['success'] == true && result['data'] != null) {
      if (mounted) {
        Navigator.pop(context);
        widget.onCouponCreated(result['data'] as Coupon);
      }
    } else {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = result['error'] ?? 'حدث خطأ أثناء إنشاء الكوبون';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إنشاء كوبون تخفيض جديد',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSub),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, size: 18, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Coupon Code Input
                const Text(
                  'رمز الكوبون *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'مثال: RAMADAN20 أو SUMMER500',
                    prefixIcon: const Icon(LucideIcons.ticket, size: 18, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'يرجى إدخال رمز الكوبون';
                    if (val.trim().length < 3) return 'يجب ألا يقل الكود عن 3 أحرف';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Discount Type (Percentage vs Fixed)
                const Text(
                  'نوع الخصم *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _discountType = 'percentage'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _discountType == 'percentage' ? AppColors.primaryBg : AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _discountType == 'percentage' ? AppColors.primary : AppColors.border,
                              width: _discountType == 'percentage' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.percent,
                                size: 18,
                                color: _discountType == 'percentage' ? AppColors.primary : AppColors.textSub,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'نسبة مئوية (%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _discountType == 'percentage' ? AppColors.primary : AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _discountType = 'fixed'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _discountType == 'fixed' ? AppColors.primaryBg : AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _discountType == 'fixed' ? AppColors.primary : AppColors.border,
                              width: _discountType == 'fixed' ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.banknote,
                                size: 18,
                                color: _discountType == 'fixed' ? AppColors.primary : AppColors.textSub,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'مبلغ ثابت (دج)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _discountType == 'fixed' ? AppColors.primary : AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Discount Value
                Text(
                  _discountType == 'percentage' ? 'نسبة الخصم (%) *' : 'قيمة الخصم (دج) *',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _discountValueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: _discountType == 'percentage' ? 'مثال: 15' : 'مثال: 500',
                    prefixIcon: Icon(
                      _discountType == 'percentage' ? LucideIcons.percent : LucideIcons.coins,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'يرجى إدخال قيمة الخصم';
                    final numVal = double.tryParse(val.trim());
                    if (numVal == null || numVal <= 0) return 'يرجى إدخال رقم صحيح أكبر من 0';
                    if (_discountType == 'percentage' && numVal > 100) return 'لا يمكن أن تتجاوز النسبة 100%';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. Min Order Amount
                const Text(
                  'الحد الأدنى للطلب (دج) - اختياري',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _minOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مثال: 3000 (اتركه 0 إذا لم يكن هناك حد أدنى)',
                    prefixIcon: const Icon(LucideIcons.shoppingCart, size: 18, color: AppColors.textSub),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Max Discount (if percentage)
                if (_discountType == 'percentage') ...[
                  const Text(
                    'الحد الأقصى للخصم (دج) - اختياري',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _maxDiscountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'مثال: 2000 (أقصى مبلغ يخصم من السلة)',
                      prefixIcon: const Icon(LucideIcons.shieldAlert, size: 18, color: AppColors.textSub),
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 6. Usage Limit
                const Text(
                  'الحد الأقصى لعدد مرات الاستخدام - اختياري',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usageLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'مثال: 100 (اتركه فارغاً للاستخدام غير المحدود)',
                    prefixIcon: const Icon(LucideIcons.hash, size: 18, color: AppColors.textSub),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Active status switch
                SwitchListTile(
                  title: const Text(
                    'تفعيل الكوبون فوراً',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  subtitle: const Text(
                    'سيكون الكوبون جاهزاً للاستخدام من قبل الزبائن مباشرة',
                    style: TextStyle(fontSize: 12, color: AppColors.textSub),
                  ),
                  value: _isActive,
                  activeThumbColor: AppColors.success,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'حفظ وإنشاء الكوبون',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
