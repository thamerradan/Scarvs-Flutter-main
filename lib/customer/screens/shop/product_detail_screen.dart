// شاشة تفاصيل المنتج بتصميم المتجر المرجعي الأنيق مع الواجهة المنسدلة والعلامة المائية.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/models/product_variant_model.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/size_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/title_text.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_squircle_button.dart';
import 'package:scarvs/core/utils/app_message.dart';

class ProductDetail extends StatefulWidget {
  final ProductDetailsArgs productDetailsArguements;
  const ProductDetail({
    Key? key,
    required this.productDetailsArguements,
  }) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin {
  late Future<ProductItem?> _detailFuture;
  ProductItem? _product;
  bool _initializedSize = false;
  bool _isLiked = false;
  int _selectedImageIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInToLinear,
      ),
    );
    _animationController.forward();

    if (widget.productDetailsArguements.initialProduct != null) {
      _product = widget.productDetailsArguements.initialProduct;
      _initSizeForProduct(_product!);
      // إذا كانت المقاسات متوفرة مسبقاً، نعتمد على المنتج مباشرة دون أي طلب شبكة إضافي
      if (_product!.variants.isNotEmpty) {
        _detailFuture = Future.value(_product);
      } else {
        _detailFuture = _fetchProductDetails();
      }
    } else {
      _detailFuture = _fetchProductDetails();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initSizeForProduct(ProductItem prod) {
    if (!_initializedSize) {
      _initializedSize = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<SizeNotifier>(context, listen: false)
              .initForProduct(prod.variants);
        }
      });
    }
  }

  Future<ProductItem?> _fetchProductDetails() async {
    final notifier = Provider.of<CatalogProvider>(context, listen: false);
    final fetched = await notifier.fetchProductDetail(
      context: context,
      id: widget.productDetailsArguements.id.toString(),
    );

    if (fetched != null && mounted) {
      setState(() {
        _product = fetched;
      });
      _initSizeForProduct(fetched);
    }
    return fetched ?? _product;
  }

  Widget _buildAppBar(BuildContext context, bool themeFlag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع (يشير لليمين في اتجاه اللغة العربية)
          AppSquircleButton(
            icon: Icons.arrow_forward_ios_rounded,
            themeFlag: themeFlag,
            isOutLine: true,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context)
                    .pushReplacementNamed(AppRouter.customerHomeRoute);
              }
            },
          ),

          Row(
            children: [
              if (AuthGuard.isOwner && _product != null) ...[
                AppSquircleButton(
                  icon: Icons.edit_note_rounded,
                  color: themeFlag ? Colors.white : AppColors.rawSienna,
                  themeFlag: themeFlag,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.ownerProductFormRoute,
                      arguments: _product,
                    );
                  },
                ),
                const SizedBox(width: 10),
              ],
              AppSquircleButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.redAccent : Colors.grey.shade600,
                themeFlag: themeFlag,
                onTap: () {
                  setState(() => _isLiked = !_isLiked);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductShowcase(
      ProductItem product, bool themeFlag, List<String> allImages) {
    final currentImage = allImages.isNotEmpty
        ? allImages[_selectedImageIndex.clamp(0, allImages.length - 1)]
        : product.mainImageUrl;

    return Column(
      children: [
        // صورة المنتج مع العلامة المائية الكبيرة خلفه
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // العلامة المائية في الخلفية
              Opacity(
                opacity: themeFlag ? 0.05 : 0.07,
                child: TitleText(
                  text: (product.categoryName != null &&
                          product.categoryName!.isNotEmpty)
                      ? product.categoryName!.toUpperCase()
                      : "..",
                  fontSize: 110,
                  fontWeight: FontWeight.bold,
                  color: themeFlag ? Colors.white : Colors.black,
                ),
              ),

              // صورة المنتج الأساسية
              widget.productDetailsArguements.heroTag != null &&
                      widget.productDetailsArguements.heroTag!.isNotEmpty
                  ? Hero(
                      tag: widget.productDetailsArguements.heroTag!,
                      child: AppNetworkImage.detail(
                        url: currentImage,
                      ),
                    )
                  : AppNetworkImage.detail(
                      url: currentImage,
                    ),
            ],
          ),
        ),

        // شريط الصور المصغرة
        if (allImages.length > 1)
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(allImages.length, (index) {
                final isSelected = _selectedImageIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedImageIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: themeFlag
                          ? (isSelected
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.05))
                          : (isSelected ? Colors.white : Colors.grey.shade100),
                      border: Border.all(
                        color: isSelected
                            ? (themeFlag ? Colors.white : AppColors.rawSienna)
                            : (themeFlag
                                ? Colors.white12
                                : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (themeFlag ? Colors.white : AppColors.rawSienna).withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: AppNetworkImage.thumbnail(
                      url: allImages[index],
                      fit: BoxFit.contain,
                      borderRadius: 9,
                    ),
                  ),
                );
              }),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSizeWidget(ProductVariant variant, bool isSelected,
      SizeNotifier sizeNotifier, bool themeFlag) {
    final isAvailable = variant.inStock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: isAvailable ? () => sizeNotifier.selectVariant(variant) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? (themeFlag ? Colors.white : AppColors.rawSienna)
                  : (!isAvailable
                      ? Colors.grey.shade400
                      : (themeFlag ? Colors.white24 : Colors.grey.shade300)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(13),
            color: isSelected
                ? (themeFlag ? Colors.white : AppColors.rawSienna)
                : (!isAvailable
                    ? (themeFlag ? Colors.white10 : Colors.grey.shade200)
                    : (themeFlag
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.shade50)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (themeFlag ? Colors.white : AppColors.rawSienna).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleText(
                text: variant.size,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (themeFlag ? AppColors.mirage : Colors.white)
                    : (!isAvailable
                        ? Colors.grey
                        : (themeFlag
                            ? AppColors.creamColor
                            : AppColors.mirage)),
              ),
              if (!isAvailable)
                const Text(
                  'نفد',
                  style: TextStyle(fontSize: 9, color: Colors.redAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSheet(
      ProductItem product, bool themeFlag, SizeNotifier sizeNotifier) {
    final bool hasStock = product.inStock;

    return DraggableScrollableSheet(
      maxChildSize: 0.82,
      initialChildSize: 0.48,
      minChildSize: 0.48,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 80),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            color: themeFlag ? AppColors.mirage : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مقبض السحب الأنيق
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // صف العنوان والسعر والتقييم
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleText(
                            text: product.name,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          if (product.categoryName != null &&
                              product.categoryName!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            TitleText(
                              text: product.categoryName!,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeFlag ? AppColors.creamColor : AppColors.rawSienna,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            TitleText(
                              text: '${product.price.toStringAsFixed(0)} ',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: themeFlag ? Colors.white : AppColors.rawSienna,
                            ),
                            TitleText(
                              text: 'ر.س',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: themeFlag ? Colors.white70 : AppColors.rawSienna,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // تقييم النجوم الخمس
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xfffbba01),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // المقاسات المتاحة
                if (product.variants.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TitleText(
                        text: "المقاسات المتاحة",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      Text(
                        hasStock ? 'متوفر بالمخزون' : 'غير متوفر حالياً',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasStock ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: product.variants.map((v) {
                      final isSelected = sizeNotifier.size == v.size;
                      return _buildSizeWidget(
                        v,
                        isSelected,
                        sizeNotifier,
                        themeFlag,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                ],

                // قسم الوصف
                if (product.description.isNotEmpty) ...[
                  const TitleText(
                    text: "تفاصيل ووصف المنتج",
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color:
                          (themeFlag ? AppColors.creamColor : AppColors.mirage)
                              .withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // شريط وضع المعاينة للمالك
                if (AuthGuard.isOwner) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: themeFlag
                          ? Colors.white.withOpacity(0.08)
                          : AppColors.rawSienna.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: themeFlag
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.rawSienna.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 18,
                            color: themeFlag ? Colors.white : AppColors.rawSienna),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'وضع معاينة المتجر (المالك) — الشراء معطل في هذا الوضع',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeFlag ? Colors.white : AppColors.rawSienna,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAddToCart(
      BuildContext context, ProductItem product, SizeNotifier sizeNotifier) {
    if (AuthGuard.isOwner) {
      AppMessage.info(context, 'أنت في وضع معاينة المالك، لا يمكنك إنشاء طلبات');
      return;
    }

    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);

    AuthGuard.requireAuth(
      context: context,
      returnRoute: AppRouter.prodDetailRoute,
      customMessage: 'لإضافة منتجات إلى السلة، يرجى تسجيل الدخول برقم هاتفك',
      onAuthenticated: () {
        cartNotifier
            .addToCart(
          productId: product.id,
          variantId: product.variants.isNotEmpty
              ? sizeNotifier.selectedVariant?.id
              : null,
          productPrice: product.price.toStringAsFixed(0),
          productName: product.name,
          productImage: product.mainImageUrl,
          context: context,
          productSize: product.variants.isNotEmpty ? sizeNotifier.size : '',
        )
            .then((value) {
          if (value) {
            AppMessage.success(context, 'تمت إضافة المنتج إلى السلة بنجاح 🛍️');
          } else {
            AppMessage.error(context, 'حدث خطأ أثناء الإضافة إلى السلة');
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final sizeNotifier = Provider.of<SizeNotifier>(context);

    if (_product == null) {
      return SafeArea(
        child: Scaffold(
          backgroundColor:
              themeFlag ? AppColors.mirage : const Color(0xfffbfbfb),
          body: FutureBuilder<ProductItem?>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: AppLoader(
                    themeFlag: themeFlag,
                    text: 'جاري تحميل تفاصيل المنتج...',
                  ),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLoader(
                        themeFlag: themeFlag,
                        text: 'تعذر تحميل بيانات المنتج',
                        lottieAsset: AppAssets.error,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rawSienna,
                        ),
                        onPressed: () {
                          setState(() {
                            _detailFuture = _fetchProductDetails();
                          });
                        },
                        child: const Text('إعادة المحاولة',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    final product = _product!;
    final allImages = product.images.isNotEmpty
        ? product.images
        : (product.mainImageUrl.isNotEmpty
            ? [product.mainImageUrl]
            : <String>[]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : const Color(0xfffbfbfb),
        floatingActionButton: !AuthGuard.isOwner
            ? FloatingActionButton.extended(
                onPressed: product.inStock
                    ? () => _handleAddToCart(context, product, sizeNotifier)
                    : null,
                backgroundColor: product.inStock
                    ? (themeFlag ? Colors.white : AppColors.rawSienna)
                    : Colors.grey,
                elevation: 6,
                icon: Icon(Icons.shopping_basket_rounded,
                    color: themeFlag ? AppColors.mirage : Colors.white),
                label: Text(
                  product.inStock ? 'إضافة إلى السلة' : 'نفد من المخزون',
                  style: TextStyle(
                    color: themeFlag ? AppColors.mirage : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
            : null,
        body: FadeTransition(
          opacity: _animation,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context, themeFlag),
                  _buildProductShowcase(product, themeFlag, allImages),
                ],
              ),
              _buildDetailSheet(product, themeFlag, sizeNotifier),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailsArgs {
  final dynamic id;
  final ProductItem? initialProduct;
  final String? heroTag;

  const ProductDetailsArgs({
    required this.id,
    this.initialProduct,
    this.heroTag,
  });
}
