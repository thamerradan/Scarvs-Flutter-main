// يرسم معلومات المنتج وخيارات المقاس وإجراء إضافته للسلة مع معرض صور متعددة فائق الأناقة.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/size_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';
import 'package:scarvs/customer/widgets/select_size.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

Widget productUI({
  required BuildContext context,
  required bool themeFlag,
  required ProductItem snapshot,
}) {
  final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
  final userNotifier = Provider.of<UserProvider>(context, listen: false);
  final sizeNotifier = Provider.of<SizeNotifier>(context);

  final bool hasStock = snapshot.inStock;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Text(
          snapshot.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
          ),
        ),
      ),
      if (snapshot.categoryName != null && snapshot.categoryName!.isNotEmpty)
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              snapshot.categoryName!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.rawSienna,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      vSizedBox2,

      // ==========================================
      // معرض الصور التفاعلي الحديث للمنتج
      // ==========================================
      ProductImageGallery(
        images: snapshot.images.isNotEmpty
            ? snapshot.images
            : (snapshot.mainImageUrl.isNotEmpty ? [snapshot.mainImageUrl] : []),
        themeFlag: themeFlag,
        productId: snapshot.id,
        hasDiscount: snapshot.hasDiscount,
        discountPercentage: snapshot.discountPercentage,
      ),

      vSizedBox2,
      if (snapshot.description.isNotEmpty) ...[
        Text(
          'الوصف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          snapshot.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                .withOpacity(0.8),
          ),
        ),
        vSizedBox2,
      ],
      if (snapshot.variants.isNotEmpty) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'اختر المقاس',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
              ),
            ),
            Text(
              snapshot.inStock ? 'متوفر' : 'غير متوفر',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: snapshot.inStock ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          width: MediaQuery.of(context).size.width,
          child: selectSize(
            context: context,
            themeFlag: themeFlag,
            variants: snapshot.variants,
          ),
        ),
        vSizedBox3,
      ],
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: themeFlag ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'السعر الإجمالي',
                    style: TextStyle(
                      fontSize: 12,
                      color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${snapshot.price.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.rawSienna,
                          ),
                        ),
                        if (snapshot.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${snapshot.oldPrice!.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (AuthGuard.isOwner)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.rawSienna.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rawSienna.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.visibility_outlined, size: 18, color: AppColors.rawSienna),
                    SizedBox(width: 6),
                    Text(
                      'معاينة (المالك)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rawSienna,
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasStock ? AppColors.rawSienna : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: !hasStock
                    ? null
                    : () {
                        AuthGuard.requireAuth(
                          context: context,
                          returnRoute: AppRouter.prodDetailRoute,
                          customMessage:
                              'لإضافة منتجات إلى السلة، يرجى تسجيل الدخول برقم هاتفك',
                          onAuthenticated: () {
                            cartNotifier
                                .addToCart(
                              productId: snapshot.id,
                              variantId: snapshot.variants.isNotEmpty
                                  ? sizeNotifier.selectedVariant?.id
                                  : null,
                              useremail: userNotifier.getUserEmail ?? '',
                              productPrice: snapshot.price.toStringAsFixed(0),
                              productName: snapshot.name,
                              productCategory: snapshot.categoryName ?? '',
                              productImage: snapshot.mainImageUrl,
                              context: context,
                              productSize: snapshot.variants.isNotEmpty
                                  ? sizeNotifier.size
                                  : '',
                            )
                                .then((value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackUtil.stylishSnackBar(
                                    text: 'تمت إضافة المنتج إلى السلة بنجاح 🛍️',
                                    context: context,
                                  ),
                                );
                                Navigator.of(context).pushNamed(AppRouter.homeRoute);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackUtil.stylishSnackBar(
                                    text: 'حدث خطأ أثناء الإضافة إلى السلة',
                                    context: context,
                                  ),
                                );
                              }
                            });
                          },
                        );
                      },
                child: Text(
                  hasStock ? 'إضافة إلى السلة 🛒' : 'غير متوفر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      vSizedBox3,
    ],
  );
}

/// ودجت معرض صور المنتج التفاعلي الممتاز
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final bool themeFlag;
  final String productId;
  final bool hasDiscount;
  final int? discountPercentage;

  const ProductImageGallery({
    Key? key,
    required this.images,
    required this.themeFlag,
    required this.productId,
    this.hasDiscount = false,
    this.discountPercentage,
  }) : super(key: key);

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenViewer(int initialIndex) {
    if (widget.images.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _FullScreenImageViewer(
          images: widget.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.images;

    if (list.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: widget.themeFlag ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // السلايدر الرئيسي
        Stack(
          children: [
            Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.themeFlag ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: list.length,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemBuilder: (context, index) {
                    final imgUrl = list[index];

                    return GestureDetector(
                      onTap: () => _openFullScreenViewer(index),
                      child: Hero(
                        tag: index == 0 ? 'prod_${widget.productId}' : 'prod_${widget.productId}_$index',
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.network(
                            imgUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // شارة الخصم
            if (widget.hasDiscount && widget.discountPercentage != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '-${widget.discountPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // عداد الصور (1 / 4)
            if (list.length > 1)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentIndex + 1} / ${list.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // زر تكبير الصورة في الزاوية
            Positioned(
              bottom: 10,
              left: 10,
              child: InkWell(
                onTap: () => _openFullScreenViewer(_currentIndex),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // مؤشرات النقاط وشريط الصور المصغرة (فقط إذا كان هناك أكثر من صورة)
        if (list.length > 1) ...[
          // مؤشر النقاط الناعم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(list.length, (idx) {
              final isSelected = idx == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.rawSienna
                      : (widget.themeFlag ? Colors.white30 : Colors.black26),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // شريط الصور المصغرة التفاعلي (Thumbnails Strip)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.themeFlag ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.rawSienna : Colors.transparent,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.rawSienna.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.6,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.network(
                            list[index],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// شاشة المعاينة والتكبير التفاعلية بكامل الشاشة (Full-Screen Lightbox)
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            // شريط علوي
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
