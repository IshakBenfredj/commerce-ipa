import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/products_provider.dart';
import '../widgets/product_row_card.dart';
import 'product_form_screen.dart';
import 'categories_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();
    final filteredProducts = productsProvider.filteredProducts;
    final categories = productsProvider.categories;

    return SafeArea(
      child: Column(
        children: [
          // ── Top Header & Add Product Button ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                // Row 1: Title + action buttons
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Text(
                      'إدارة المنتجات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const Spacer(),
                    // ── Manage Categories Button ──
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                        );
                      },
                      icon: const Icon(LucideIcons.layoutGrid, size: 15),
                      label: const Text('الأقسام',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Add Product Button ──
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                        );
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('منتج جديد',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                    onChanged: (val) => productsProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'البحث باسم المنتج أو رمز SKU...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                      suffixIcon: productsProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                              onPressed: () => productsProvider.setSearchQuery(''),
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

          // ── Category Filter Pills ────────────────────────────────────
          if (categories.isNotEmpty) ...[
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true, // RTL
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = productsProvider.selectedCategory == null || productsProvider.selectedCategory == 'all';
                    return ChoiceChip(
                      label: const Text('جميع الأقسام'),
                      selected: isAll,
                      onSelected: (_) => productsProvider.setSelectedCategory('all'),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isAll ? FontWeight.w800 : FontWeight.w600,
                        color: isAll ? Colors.white : AppColors.textSub,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: isAll ? AppColors.primary : AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    );
                  }

                  final cat = categories[index - 1];
                  final isSelected = productsProvider.selectedCategory == cat.id || productsProvider.selectedCategory == cat.slug;

                  return ChoiceChip(
                    label: Text(cat.nameAr),
                    selected: isSelected,
                    onSelected: (_) => productsProvider.setSelectedCategory(cat.id),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSub,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Products List ───────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productsProvider.fetchProductsAndCategories(showLoading: false),
              color: AppColors.primary,
              child: productsProvider.isLoading && productsProvider.products.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : filteredProducts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(LucideIcons.package, size: 48, color: AppColors.textMuted),
                                  SizedBox(height: 12),
                                  Text(
                                    'لا توجد منتجات مطابقة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'أضف منتجات جديدة أو جرب تعديل البحث.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSub),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filteredProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductRowCard(
                              product: product,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductFormScreen(product: product),
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
