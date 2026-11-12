-- ==============================================================================
-- تفعيل البث اللحظي (Supabase Realtime) لجداول المنتجات والأصناف والمقاسات
-- ==============================================================================

-- تفعيل Realtime لجدول المنتجات (products)
alter publication supabase_realtime add table public.products;

-- تفعيل Realtime لجدول التصنيفات (categories)
alter publication supabase_realtime add table public.categories;

-- تفعيل Realtime لجدول مقاسات المنتجات والمخزون (product_variants)
alter publication supabase_realtime add table public.product_variants;

-- تفعيل Realtime لجدول صور المنتجات (product_images)
alter publication supabase_realtime add table public.product_images;

