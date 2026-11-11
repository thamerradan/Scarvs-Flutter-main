-- ==============================================================================
-- بذر بيانات تجريبية باللغة العربية (تصنيفات + منتجات + مقاسات ومخزون)
-- المتجر: Scarvs Store
-- ==============================================================================

do $$
declare
  v_cat_jordan uuid;
  v_cat_nike uuid;
  v_cat_adidas uuid;
  v_cat_puma uuid;
  v_cat_reebok uuid;

  v_p1 uuid;
  v_p2 uuid;
  v_p3 uuid;
  v_p4 uuid;
  v_p5 uuid;
  v_p6 uuid;
begin
  -- 1. إضافة التصنيفات الأساسية
  insert into public.categories (name, image_url, is_active, sort_order)
  values ('جوردان', 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500', true, 1)
  returning id into v_cat_jordan;

  insert into public.categories (name, image_url, is_active, sort_order)
  values ('نايكي', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500', true, 2)
  returning id into v_cat_nike;

  insert into public.categories (name, image_url, is_active, sort_order)
  values ('أديداس', 'https://images.unsplash.com/photo-1518002171953-a080ee817e1f?w=500', true, 3)
  returning id into v_cat_adidas;

  insert into public.categories (name, image_url, is_active, sort_order)
  values ('بوما', 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500', true, 4)
  returning id into v_cat_puma;

  insert into public.categories (name, image_url, is_active, sort_order)
  values ('ريبوك', 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=500', true, 5)
  returning id into v_cat_reebok;

  -- 2. المنتجات والمقاسات والمخزون

  -- منتج 1: إير جوردان 1 ريترو هاي
  insert into public.products (name, description, price, old_price, category_id, main_image_url, is_active, is_featured)
  values (
    'إير جوردان 1 ريترو هاي شيكاغو',
    'الحذاء الأيقوني الأكثر شهرة في تاريخ كرة السلة والموضة. مصنوع من الجلد الطبيعي الفاخر بتطريز متقن ووسادة هوائية Nike Air لتوفير أقصى درجات الراحة والثبات طوال اليوم.',
    680.00,
    799.00,
    v_cat_jordan,
    'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800',
    true,
    true
  ) returning id into v_p1;

  insert into public.product_variants (product_id, size, stock_quantity, is_available) values
    (v_p1, '40', 4, true),
    (v_p1, '41', 7, true),
    (v_p1, '42', 5, true),
    (v_p1, '43', 2, true),
    (v_p1, '44', 0, false);

  -- منتج 2: نايكي إير ماكس بلس أحمر
  insert into public.products (name, description, price, old_price, category_id, main_image_url, is_active, is_featured)
  values (
    'نايكي إير ماكس بلس أحمر ملفت',
    'تصميم جريء ومستقبلي يوفر ثباتاً ممتازاً وتبطين Air Max الأسطوري المزدوج. خفيف الوزن ومثالي للأنشطة الرياضية والخرجات اليومية.',
    490.00,
    550.00,
    v_cat_nike,
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
    true,
    true
  ) returning id into v_p2;

  insert into public.product_variants (product_id, size, stock_quantity, is_available) values
    (v_p2, '41', 12, true),
    (v_p2, '42', 8, true),
    (v_p2, '43', 4, true),
    (v_p2, '44', 1, true);

  -- منتج 3: أديداس ألترا بوست دي إن إيه
  insert into public.products (name, description, price, old_price, category_id, main_image_url, is_active, is_featured)
  values (
    'أديداس ألترا بوست دي إن إيه أسود',
    'حذاء الجري الثوري المزود بنعل Boost فائق الاستجابة وجزء علوي بتقنية Primeknit المرنة ليمنحك شعوراً بالراحة يشبه ارتداء الجورب.',
    540.00,
    null,
    v_cat_adidas,
    'https://images.unsplash.com/photo-1518002171953-a080ee817e1f?w=800',
    true,
    true
  ) returning id into v_p3;

  insert into public.product_variants (product_id, size, stock_quantity, is_available) values
    (v_p3, '40', 6, true),
    (v_p3, '41', 9, true),
    (v_p3, '42', 5, true),
    (v_p3, '43', 3, true);

  -- منتج 4: بوما آر إس-إكس3
  insert into public.products (name, description, price, old_price, category_id, main_image_url, is_active, is_featured)
  values (
    'بوما آر إس-إكس3 كلاسيك',
    'تصميم ضخم وعصري (Chunky Sneaker) مستوحى من أزياء الشارع في الثمانينات، مع خامات متعددة وطبقات ألوان متناسقة تناسب جميع الإطلالات.',
    390.00,
    440.00,
    v_cat_puma,
    'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800',
    true,
    false
  ) returning id into v_p4;

  insert into public.product_variants (product_id, size, stock_quantity, is_available) values
    (v_p4, '41', 4, true),
    (v_p4, '42', 6, true),
    (v_p4, '43', 0, false);

  -- منتج 5: ريبوك كلوب سي 85
  insert into public.products (name, description, price, old_price, category_id, main_image_url, is_active, is_featured)
  values (
    'ريبوك كلوب سي 85 فينتاج أبيض',
    'حذاء التنس التراثي النظيف، مصنوع من جلد ناعم ومريح مع نعل مطاطي متين يمنحك مظهراً كلاسيكياً أنيقاً لا تنتهي موضته.',
    350.00,
    null,
    v_cat_reebok,
    'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800',
    true,
    false
  ) returning id into v_p6;

  insert into public.product_variants (product_id, size, stock_quantity, is_available) values
    (v_p6, '40', 8, true),
    (v_p6, '41', 10, true),
    (v_p6, '42', 5, true),
    (v_p6, '43', 2, true);

end $$;

