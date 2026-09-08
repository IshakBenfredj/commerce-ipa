import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_row_card.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final filteredOrders = ordersProvider.filteredOrders;

    final filterTabs = [
      {'id': 'all', 'label': 'الكل'},
      {'id': 'pending', 'label': 'قيد الانتظار'},
      {'id': 'confirmed', 'label': 'مؤكدة'},
      {'id': 'shipped', 'label': 'تم الشحن'},
      {'id': 'delivered', 'label': 'تم التوصيل'},
      {'id': 'cancelled', 'label': 'ملغاة'},
    ];

    return SafeArea(
      child: Column(
        children: [
          // ── Top Header & Search ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إدارة الطلبيات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredOrders.length} طلبية',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    onChanged: (val) => ordersProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'البحث بالاسم، الهاتف، الولاية، أو رقم الطلب...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                      suffixIcon: ordersProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                              onPressed: () => ordersProvider.setSearchQuery(''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Horizontal Filter Status Pills ───────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL scrolling
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filterTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = filterTabs[index];
                final isSelected = ordersProvider.selectedStatus == tab['id'];

                return ChoiceChip(
                  label: Text(tab['label']!),
                  selected: isSelected,
                  onSelected: (_) => ordersProvider.setFilterStatus(tab['id']!),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSub,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // ── Orders List with Pull-to-Refresh ─────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ordersProvider.fetchOrders(showLoading: false),
              color: AppColors.primary,
              child: ordersProvider.isLoading && ordersProvider.orders.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : filteredOrders.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(LucideIcons.shoppingBag, size: 48, color: AppColors.textMuted),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد طلبيات مطابقة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'جرب تغيير فلتر الحالة أو كلمة البحث.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSub),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return OrderRowCard(
                              order: order,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailsScreen(order: order),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
