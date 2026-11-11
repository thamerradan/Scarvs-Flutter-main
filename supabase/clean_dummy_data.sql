-- ==============================================================================
-- سكريبت حذف الأصناف والمنتجات التجريبية الثابتة من المتجر
-- Scarvs Store - Clean Static & Demo Data
-- ==============================================================================

-- 1. تفريغ عناصر السلة المرتبطة بالمنتجات السابقة
delete from public.cart_items;

-- 2. حذف صور المنتجات الإضافية
delete from public.product_images;

-- 3. حذف المقاسات والمخزون المرتبط بالمنتجات السابقة
delete from public.product_variants;

-- 4. حذف كافة المنتجات السابقة
delete from public.products;

-- 5. حذف كافة التصنيفات (الأصناف) السابقة
delete from public.categories;

-- (ملاحظة اختيارية: إذا كنت ترغب أيضاً في تصفير طلبات وإشعارات التجربة السابقة، يمكنك تشغيل الأسطر التالية):
-- delete from public.order_items;
-- delete from public.orders;
-- delete from public.notifications;

