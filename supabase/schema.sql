-- ==============================================================================
-- الخطة الكاملة لقاعدة بيانات المتجر (Supabase PostgreSQL)
-- المتجر: Scarvs (يدعم اللغة العربية، العملاء، والمالك)
-- ==============================================================================

-- 1. تفعيل الامتدادات المطلوبة
create extension if not exists "uuid-ossp";

-- ==============================================================================
-- 2. الجداول (Tables) - يتم إنشاؤها أولاً قبل الدوال والسياسات
-- ==============================================================================

-- 2.1 جدول الملفات الشخصية (profiles)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text,
  phone text default '',
  role text not null default 'customer' check (role in ('customer', 'owner')),
  address text default '',
  city text default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2.2 جدول التصنيفات (categories)
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- 2.3 جدول المنتجات (products)
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text default '',
  price numeric(10,2) not null check (price >= 0),
  old_price numeric(10,2) check (old_price is null or old_price >= 0),
  category_id uuid references public.categories(id) on delete set null,
  main_image_url text,
  is_active boolean not null default true,
  is_featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2.4 جدول صور المنتجات المتعددة (product_images)
create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- 2.5 جدول مقاسات ومخزون المنتجات (product_variants)
create table if not exists public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  size text not null,
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  is_available boolean not null default true,
  constraint unique_product_size unique (product_id, size)
);

-- 2.6 جدول السلة (cart_items)
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint unique_user_product_variant unique (user_id, product_id, variant_id)
);

-- 2.7 جدول الطلبات (orders)
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  subtotal numeric(10,2) not null check (subtotal >= 0),
  shipping_fee numeric(10,2) not null default 0 check (shipping_fee >= 0),
  discount numeric(10,2) not null default 0 check (discount >= 0),
  total numeric(10,2) not null check (total >= 0),
  payment_method text not null default 'cash_on_delivery',
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'failed', 'cash_on_delivery', 'refunded')),
  order_status text not null default 'pending' check (order_status in ('pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'cancelled')),
  shipping_address text not null,
  city text not null,
  phone text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2.8 جدول عناصر الطلب (order_items)
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  product_image text,
  size text,
  quantity integer not null check (quantity > 0),
  unit_price numeric(10,2) not null check (unit_price >= 0),
  total_price numeric(10,2) not null check (total_price >= 0)
);

-- 2.9 جدول المدفوعات (payments)
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider text not null,
  transaction_id text,
  amount numeric(10,2) not null,
  status text not null,
  response jsonb,
  created_at timestamptz not null default now()
);

-- 2.10 جدول إعدادات المتجر (store_settings)
create table if not exists public.store_settings (
  id uuid primary key default gen_random_uuid(),
  store_name text not null default 'Scarvs',
  logo_url text,
  phone text default '',
  whatsapp text default '',
  shipping_fee numeric(10,2) not null default 0 check (shipping_fee >= 0),
  free_shipping_limit numeric(10,2) not null default 0 check (free_shipping_limit >= 0),
  cash_on_delivery_enabled boolean not null default true,
  online_payment_enabled boolean not null default false,
  maintenance_mode boolean not null default false,
  updated_at timestamptz not null default now()
);

-- إدخال إعدادات المتجر الافتراضية
insert into public.store_settings (store_name, phone, shipping_fee, free_shipping_limit)
select 'Scarvs Store', '+966500000000', 25.00, 300.00
where not exists (select 1 from public.store_settings);

-- ==============================================================================
-- 3. الدوال والمشغلات التلقائية (Helper Functions & Triggers)
-- ==============================================================================

-- 3.1 تحديث حقل updated_at تلقائياً
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists update_profiles_updated_at on public.profiles;
create trigger update_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists update_products_updated_at on public.products;
create trigger update_products_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

drop trigger if exists update_cart_items_updated_at on public.cart_items;
create trigger update_cart_items_updated_at
  before update on public.cart_items
  for each row execute function public.set_updated_at();

drop trigger if exists update_orders_updated_at on public.orders;
create trigger update_orders_updated_at
  before update on public.orders
  for each row execute function public.set_updated_at();

drop trigger if exists update_store_settings_updated_at on public.store_settings;
create trigger update_store_settings_updated_at
  before update on public.store_settings
  for each row execute function public.set_updated_at();

-- 3.2 التحقق مما إذا كان المستخدم الحالي مالكاً للمتجر (Owner)
create or replace function public.is_owner()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(
    (select role = 'owner' and is_active = true from public.profiles where id = auth.uid()),
    false
  );
$$;

-- 3.3 إنشاء profile تلقائياً عند تسجيل المستخدم في auth.users
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
  v_phone text;
begin
  -- فحص البريد: إذا كان بريداً تلقائياً للهاتف نجعله null في الملف الشخصي
  v_email := new.raw_user_meta_data->>'email';
  if v_email is null or v_email = '' or v_email like '%@phone.scarvs.app' then
    if new.email is not null and new.email not like '%@phone.scarvs.app' then
      v_email := new.email;
    else
      v_email := null;
    end if;
  end if;

  v_phone := coalesce(new.raw_user_meta_data->>'phone', new.phone, '');

  insert into public.profiles (id, full_name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    v_email,
    v_phone,
    coalesce(new.raw_user_meta_data->>'role', 'customer')
  )
  on conflict (id) do update set
    email = case 
      when excluded.email is not null and excluded.email not like '%@phone.scarvs.app' then excluded.email 
      else profiles.email 
    end,
    full_name = case when excluded.full_name <> '' then excluded.full_name else profiles.full_name end,
    phone = case when excluded.phone <> '' then excluded.phone else profiles.phone end;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ==============================================================================
-- 4. الفهارس لتحسين الأداء (Indexes)
-- ==============================================================================
create index if not exists idx_profiles_role on public.profiles(role);
create unique index if not exists idx_profiles_phone_unique on public.profiles(phone) where phone is not null and phone <> '';
create index if not exists idx_categories_sort_order on public.categories(sort_order);
create index if not exists idx_products_category_id on public.products(category_id);
create index if not exists idx_products_is_active on public.products(is_active);
create index if not exists idx_products_is_featured on public.products(is_featured);
create index if not exists idx_product_images_product_id on public.product_images(product_id);
create index if not exists idx_product_variants_product_id on public.product_variants(product_id);
create index if not exists idx_cart_items_user_id on public.cart_items(user_id);
create index if not exists idx_orders_user_id on public.orders(user_id);
create index if not exists idx_orders_order_status on public.orders(order_status);
create index if not exists idx_orders_order_number on public.orders(order_number);
create index if not exists idx_order_items_order_id on public.order_items(order_id);
create index if not exists idx_payments_order_id on public.payments(order_id);

-- ==============================================================================
-- 5. تفعيل وسياسات أمان مستوى الصف (Row Level Security - RLS)
-- ==============================================================================

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_variants enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.store_settings enable row level security;

-- 5.1 سياسات profiles
drop policy if exists "Profiles are viewable by owner or self" on public.profiles;
create policy "Profiles are viewable by owner or self"
  on public.profiles for select
  using (auth.uid() = id or public.is_owner());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id or public.is_owner())
  with check (
    -- المستخدم العادي لا يستطيع ترقية نفسه إلى مالك
    (auth.uid() = id and role = (select role from public.profiles where id = auth.uid()))
    or public.is_owner()
  );

drop policy if exists "Insert profile on registration" on public.profiles;
create policy "Insert profile on registration"
  on public.profiles for insert
  with check (auth.uid() = id or public.is_owner());

-- 5.2 سياسات categories
drop policy if exists "Categories viewable by everyone" on public.categories;
create policy "Categories viewable by everyone"
  on public.categories for select
  using (is_active = true or public.is_owner());

drop policy if exists "Owner can manage categories" on public.categories;
create policy "Owner can manage categories"
  on public.categories for all
  using (public.is_owner())
  with check (public.is_owner());

-- 5.3 سياسات products
drop policy if exists "Active products are viewable by everyone" on public.products;
create policy "Active products are viewable by everyone"
  on public.products for select
  using (is_active = true or public.is_owner());

drop policy if exists "Owner can manage products" on public.products;
create policy "Owner can manage products"
  on public.products for all
  using (public.is_owner())
  with check (public.is_owner());

-- 5.4 سياسات product_images
drop policy if exists "Product images viewable by everyone" on public.product_images;
create policy "Product images viewable by everyone"
  on public.product_images for select
  using (true);

drop policy if exists "Owner can manage product images" on public.product_images;
create policy "Owner can manage product images"
  on public.product_images for all
  using (public.is_owner())
  with check (public.is_owner());

-- 5.5 سياسات product_variants
drop policy if exists "Product variants viewable by everyone" on public.product_variants;
create policy "Product variants viewable by everyone"
  on public.product_variants for select
  using (is_available = true or public.is_owner());

drop policy if exists "Owner can manage product variants" on public.product_variants;
create policy "Owner can manage product variants"
  on public.product_variants for all
  using (public.is_owner())
  with check (public.is_owner());

-- 5.6 سياسات cart_items
drop policy if exists "Users can manage their own cart" on public.cart_items;
create policy "Users can manage their own cart"
  on public.cart_items for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 5.7 سياسات orders
drop policy if exists "Users can view their own orders" on public.orders;
create policy "Users can view their own orders"
  on public.orders for select
  using (auth.uid() = user_id or public.is_owner());

drop policy if exists "Users can create their own orders" on public.orders;
create policy "Users can create their own orders"
  on public.orders for insert
  with check (auth.uid() = user_id);

drop policy if exists "Owner can update orders" on public.orders;
create policy "Owner can update orders"
  on public.orders for update
  using (public.is_owner())
  with check (public.is_owner());

-- 5.8 سياسات order_items
drop policy if exists "Users can view items in their orders" on public.order_items;
create policy "Users can view items in their orders"
  on public.order_items for select
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
        and (orders.user_id = auth.uid() or public.is_owner())
    )
  );

drop policy if exists "Insert order items" on public.order_items;
create policy "Insert order items"
  on public.order_items for insert
  with check (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
        and orders.user_id = auth.uid()
    )
    or public.is_owner()
  );

-- 5.9 سياسات payments
drop policy if exists "Users can view their own payments" on public.payments;
create policy "Users can view their own payments"
  on public.payments for select
  using (auth.uid() = user_id or public.is_owner());

drop policy if exists "Owner can manage payments" on public.payments;
create policy "Owner can manage payments"
  on public.payments for all
  using (public.is_owner())
  with check (public.is_owner());

-- 5.10 سياسات store_settings
drop policy if exists "Store settings viewable by everyone" on public.store_settings;
create policy "Store settings viewable by everyone"
  on public.store_settings for select
  using (true);

drop policy if exists "Owner can update store settings" on public.store_settings;
create policy "Owner can update store settings"
  on public.store_settings for all
  using (public.is_owner())
  with check (public.is_owner());

-- ==============================================================================
-- 6. إنشاء حاويات التخزين وسياسات Supabase Storage
-- ==============================================================================

-- إنشاء Buckets في storage.buckets
insert into storage.buckets (id, name, public)
values 
  ('product-images', 'product-images', true),
  ('category-images', 'category-images', true),
  ('store-assets', 'store-assets', true)
on conflict (id) do update set public = true;

-- سياسات قراءة الصور للجميع (Public Read)
drop policy if exists "Public Access for product images" on storage.objects;
create policy "Public Access for product images"
  on storage.objects for select
  using (bucket_id in ('product-images', 'category-images', 'store-assets'));

-- سياسات رفع وتعديل وحذف الصور للمالك فقط
drop policy if exists "Owner can upload storage objects" on storage.objects;
create policy "Owner can upload storage objects"
  on storage.objects for insert
  with check (
    bucket_id in ('product-images', 'category-images', 'store-assets')
    and public.is_owner()
  );

drop policy if exists "Owner can update storage objects" on storage.objects;
create policy "Owner can update storage objects"
  on storage.objects for update
  using (
    bucket_id in ('product-images', 'category-images', 'store-assets')
    and public.is_owner()
  );

drop policy if exists "Owner can delete storage objects" on storage.objects;
create policy "Owner can delete storage objects"
  on storage.objects for delete
  using (
    bucket_id in ('product-images', 'category-images', 'store-assets')
    and public.is_owner()
  );

-- ==============================================================================
-- 7. عملية إنشاء الطلب كمعاملة آمنة (Atomic Checkout Procedure)
-- ==============================================================================
create or replace function public.place_order_from_cart(
  p_shipping_address text,
  p_city text,
  p_phone text,
  p_notes text default null,
  p_payment_method text default 'cash_on_delivery'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_subtotal numeric(10,2) := 0;
  v_shipping_fee numeric(10,2) := 0;
  v_free_shipping_limit numeric(10,2) := 0;
  v_total numeric(10,2) := 0;
  v_item record;
  v_stock integer;
  v_count integer := 0;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    return jsonb_build_object('success', false, 'message', 'يجب تسجيل الدخول أولاً');
  end if;

  -- التحقق من وجود عناصر في السلة
  select count(*) into v_count from public.cart_items where user_id = v_user_id;
  if v_count = 0 then
    return jsonb_build_object('success', false, 'message', 'السلة فارغة');
  end if;

  -- قراءة إعدادات رسوم التوصيل
  select coalesce(shipping_fee, 0), coalesce(free_shipping_limit, 0)
  into v_shipping_fee, v_free_shipping_limit
  from public.store_settings
  limit 1;

  -- فحص المخزون والأسعار الحقيقية من قاعدة البيانات لكل عنصر وحساب المجموع
  for v_item in
    select 
      c.id as cart_item_id,
      c.product_id,
      c.variant_id,
      c.quantity,
      p.name as product_name,
      p.price as product_price,
      p.main_image_url as product_image,
      p.is_active as product_active,
      v.size as variant_size,
      v.stock_quantity as variant_stock,
      v.is_available as variant_available
    from public.cart_items c
    join public.products p on p.id = c.product_id
    left join public.product_variants v on v.id = c.variant_id
    where c.user_id = v_user_id
  loop
    -- التحقق من نشاط المنتج
    if not v_item.product_active then
      return jsonb_build_object('success', false, 'message', 'المنتج ' || v_item.product_name || ' غير متوفر حالياً');
    end if;

    -- التحقق من كفاية المخزون
    if v_item.variant_id is not null then
      if not v_item.variant_available or v_item.variant_stock < v_item.quantity then
        return jsonb_build_object(
          'success', false,
          'message', 'الكمية المطلوبة للمنتج ' || v_item.product_name || ' (مقاس: ' || coalesce(v_item.variant_size, '') || ') غير متوفرة في المخزون'
        );
      end if;
    end if;

    v_subtotal := v_subtotal + (v_item.product_price * v_item.quantity);
  end loop;

  -- تطبيق الشحن المجاني إن تحقق الحد الأدنى
  if v_free_shipping_limit > 0 and v_subtotal >= v_free_shipping_limit then
    v_shipping_fee := 0;
  end if;

  v_total := v_subtotal + v_shipping_fee;

  -- توليد رقم الطلب الفريد
  v_order_number := 'ORD-' || to_char(now(), 'YYYYMMDD') || '-' || upper(substring(gen_random_uuid()::text, 1, 6));

  -- إدخال الطلب الرئيسي
  insert into public.orders (
    order_number,
    user_id,
    subtotal,
    shipping_fee,
    discount,
    total,
    payment_method,
    payment_status,
    order_status,
    shipping_address,
    city,
    phone,
    notes
  ) values (
    v_order_number,
    v_user_id,
    v_subtotal,
    v_shipping_fee,
    0,
    v_total,
    p_payment_method,
    case when p_payment_method = 'cash_on_delivery' then 'cash_on_delivery' else 'pending' end,
    'pending',
    p_shipping_address,
    p_city,
    p_phone,
    p_notes
  ) returning id into v_order_id;

  -- نقل عناصر السلة إلى order_items وخصم المخزون
  for v_item in
    select 
      c.product_id,
      c.variant_id,
      c.quantity,
      p.name as product_name,
      p.price as product_price,
      p.main_image_url as product_image,
      v.size as variant_size
    from public.cart_items c
    join public.products p on p.id = c.product_id
    left join public.product_variants v on v.id = c.variant_id
    where c.user_id = v_user_id
  loop
    -- إضافة العنصر للطلب
    insert into public.order_items (
      order_id,
      product_id,
      product_name,
      product_image,
      size,
      quantity,
      unit_price,
      total_price
    ) values (
      v_order_id,
      v_item.product_id,
      v_item.product_name,
      v_item.product_image,
      v_item.variant_size,
      v_item.quantity,
      v_item.product_price,
      v_item.product_price * v_item.quantity
    );

    -- خصم المخزون
    if v_item.variant_id is not null then
      update public.product_variants
      set stock_quantity = stock_quantity - v_item.quantity
      where id = v_item.variant_id;
    end if;
  end loop;

  -- تفريغ سلة العميل
  delete from public.cart_items where user_id = v_user_id;

  return jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'total', v_total
  );
end;
$$;
