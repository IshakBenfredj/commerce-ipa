import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '213${cleanPhone.substring(1)}';
    }
    final message = Uri.encodeComponent(
        'مرحباً بك من متجرنا بخصوص طلبك رقم ${_order.orderNumber}');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label إلى الحافظة بنجاح'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showStatusUpdateSheet() {
    final statuses = [
      {'key': 'pending', 'label': 'قيد الانتظار', 'color': AppColors.warning},
      {'key': 'confirmed', 'label': 'مؤكدة', 'color': AppColors.info},
      {'key': 'shipped', 'label': 'تم الشحن', 'color': AppColors.purple},
      {'key': 'delivered', 'label': 'تم التوصيل', 'color': AppColors.success},
      {'key': 'cancelled', 'label': 'ملغاة', 'color': AppColors.danger},
      {'key': 'returned', 'label': 'مسترجعة', 'color': AppColors.danger},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تحديث حالة الطلبية',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text),
              ),
              const SizedBox(height: 14),
              ...statuses.map((st) {
                final isCurrent = _order.status == st['key'];
                final color = st['color'] as Color;

                return ListTile(
                  onTap: () async {
                    Navigator.pop(ctx);
                    setState(() => _isUpdating = true);
                    final success =
                        await context.read<OrdersProvider>().updateStatus(
                              _order.id,
                              st['key'] as String,
                            );
                    if (mounted) {
                      setState(() {
                        _isUpdating = false;
                        if (success) _order.status = st['key'] as String;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'تم تحديث حالة الطلب بنجاح'
                              : 'تعذر تحديث الحالة'),
                          backgroundColor:
                              success ? AppColors.success : AppColors.danger,
                        ),
                      );
                    }
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  title: Text(
                    st['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                      color: isCurrent ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  trailing: isCurrent
                      ? const Icon(LucideIcons.check,
                          color: AppColors.primary, size: 20)
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final formattedTotal =
        '${currencyFormatter.format(_order.totalAmount)} د.ج';
    final formattedSubtotal =
        '${currencyFormatter.format(_order.subtotal)} د.ج';
    final formattedShipping =
        '${currencyFormatter.format(_order.shippingCost)} د.ج';
    final dateStr = DateFormat('yyyy/MM/dd - HH:mm').format(_order.createdAt);

    final statusColor = AppColors.getStatusColor(_order.status);
    final statusBg = AppColors.getStatusBgColor(_order.status);
    final statusLabel = AppColors.getStatusLabelAr(_order.status);

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
            'تفاصيل الطلبية ${_order.orderNumber}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.text),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.copy,
                  size: 18, color: AppColors.textSub),
              onPressed: () => _copyToClipboard(
                'الطلبية: ${_order.orderNumber}\nالزبون: ${_order.customerName}\nالهاتف: ${_order.customerPhone}\nالعنوان: ${_order.shippingWilaya} - ${_order.shippingCity} - ${_order.shippingAddress}\nالمجموع: $formattedTotal',
                'معلومات الطلبية',
              ),
              tooltip: 'نسخ ملخص الطلب',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Status Banner Card ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حالة الطلبية الحالية',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSub,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _showStatusUpdateSheet,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.edit3, size: 16),
                      label: const Text('تغيير الحالة',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 2. Customer Info Card with Instant Action Buttons ───────
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
                        Icon(LucideIcons.user,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'بيانات الزبون والتوصيل',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _infoRow('اسم الزبون:', _order.customerName),
                    _infoRow('رقم الهاتف:', _order.customerPhone),
                    if (_order.customerEmail != null &&
                        _order.customerEmail!.isNotEmpty)
                      _infoRow('الهاتف الاحتياطي:', _order.customerEmail!),
                    _infoRow('الولاية والبلدية:',
                        '${_order.shippingWilaya} - ${_order.shippingCity}'),
                    if (_order.shippingAddress.isNotEmpty)
                      _infoRow('العنوان الكامل:', _order.shippingAddress),
                    _infoRow(
                        'نوع التوصيل:',
                        _order.deliveryType == 'desk'
                            ? 'استلام من المكتب'
                            : 'توصيل للمنزل'),
                    _infoRow('تاريخ الطلب:', dateStr),

                    const SizedBox(height: 14),
                    // Action Buttons (Call, WhatsApp, Copy)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _makePhoneCall(_order.customerPhone),
                            icon: const Icon(LucideIcons.phoneCall,
                                size: 16, color: AppColors.success),
                            label: const Text('اتصال مباشر',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.success),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openWhatsApp(_order.customerPhone),
                            icon: const Icon(LucideIcons.messageCircle,
                                size: 16, color: Colors.white),
                            label: const Text('واتساب',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 3. Customer Notes (if any) ──────────────────────────────
              if (_order.customerNotes != null &&
                  _order.customerNotes!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.messageSquare,
                          size: 18, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ملاحظات الزبون:',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _order.customerNotes!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── 4. Order Items List ─────────────────────────────────────
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
                            Icon(LucideIcons.package,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'المنتجات المطلوبة',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text),
                            ),
                          ],
                        ),
                        Text(
                          '${_order.items.length} منتج',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSub),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    ..._order.items.map((item) {
                      final itemTotal =
                          '${currencyFormatter.format(item.totalPrice)} د.ج';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: AppColors.primaryBg,
                                child: item.imageUrl != null
                                    ? Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(LucideIcons.image,
                                              size: 18,
                                              color: AppColors.primary),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(LucideIcons.image,
                                            size: 18, color: AppColors.primary),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productTitle,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.variantTitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'الخيار: ${item.variantTitle}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSub),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.quantity} × ${currencyFormatter.format(item.unitPrice)} د.ج',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              itemTotal,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 5. Payment & Financial Breakdown ────────────────────────
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
                    const Text(
                      'الملخص المالي',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                    const Divider(height: 20, color: AppColors.divider),
                    _summaryRow('سعر المنتجات:', formattedSubtotal),
                    _summaryRow('تكلفة الشحن:', formattedShipping),
                    if (_order.discountAmount > 0)
                      _summaryRow('الخصم:',
                          '- ${currencyFormatter.format(_order.discountAmount)} د.ج',
                          isDiscount: true),
                    const Divider(height: 18, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المبلغ الإجمالي للدفع:',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text),
                        ),
                        Text(
                          formattedTotal,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSub,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSub,
                fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDiscount ? AppColors.danger : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
