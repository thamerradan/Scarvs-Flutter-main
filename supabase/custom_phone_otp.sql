-- ============================================================
-- نظام التحقق المباشر برقم الهاتف عبر قاعدة البيانات (Custom In-Database OTP)
-- التحديث: منع تكرار أرقام الهواتف وجعل البريد الإلكتروني اختيارياً
-- ============================================================

-- 1. جدول رموز التحقق
create table if not exists public.phone_verifications (
  id uuid primary key default gen_random_uuid(),
  phone text not null,
  otp_code text not null,
  expires_at timestamptz not null default (now() + interval '5 minutes'),
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

-- فهرس لسرعة البحث برقم الهاتف
create index if not exists idx_phone_verifications_phone 
  on public.phone_verifications(phone, created_at desc);

-- تفعيل RLS
alter table public.phone_verifications enable row level security;

-- سياسة الأمان: السماح بالعمليات عبر دوال الـ RPC الآمنة
drop policy if exists "Allow access via functions" on public.phone_verifications;
create policy "Allow access via functions" 
  on public.phone_verifications
  for all using (true) with check (true);

-- 2. تنظيف تكرارات أرقام الهواتف القديمة في profiles وفرض قيد عدم التكرار (Unique)
delete from public.profiles a
using public.profiles b
where a.phone = b.phone
  and a.phone is not null
  and a.phone <> ''
  and a.created_at < b.created_at;

-- إضافة قيد عدم تكرار أرقام الهواتف: كل رقم هاتف حساب واحد فقط
create unique index if not exists idx_profiles_phone_unique 
  on public.profiles(phone) 
  where phone is not null and phone <> '';

-- تنظيف أي بريد إلكتروني وهمي تلقائي سابق في profiles
update public.profiles
set email = null
where email like '%@phone.scarvs.app';

-- 3. دالة توليد وحفظ رمز التحقق مع التحقق الصارم من عدم تكرار الرقم
create or replace function public.generate_phone_otp(
  p_phone text,
  p_is_signup boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_clean_phone text;
  v_digits text;
  v_exists boolean;
  v_otp text;
begin
  -- تنظيف رقم الهاتف وإزالة المسافات
  v_clean_phone := trim(regexp_replace(p_phone, '\s+', '', 'g'));
  
  if v_clean_phone is null or length(v_clean_phone) < 7 then
    return jsonb_build_object(
      'success', false,
      'message', 'رقم الهاتف غير صالح'
    );
  end if;

  v_digits := regexp_replace(v_clean_phone, '[^0-9]', '', 'g');

  -- فحص هل الرقم مسجل مسبقاً في جدول profiles (بالمقارنة الرقمية المباشرة)
  select exists (
    select 1 from public.profiles
    where phone = v_clean_phone
       or regexp_replace(phone, '[^0-9]', '', 'g') = v_digits
  ) into v_exists;

  -- إذا كانت العملية إنشاء حساب جديد والرقم مسجل مسبقاً نرفض العملية
  if p_is_signup and v_exists then
    return jsonb_build_object(
      'success', false,
      'message', 'رقم الهاتف هذا مسجل مسبقاً، يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد'
    );
  end if;

  -- إذا كانت العملية تسجيل دخول والرقم غير مسجل نطلب إنشاء حساب
  if (not p_is_signup) and (not v_exists) then
    return jsonb_build_object(
      'success', false,
      'message', 'رقم الهاتف هذا غير مسجل، يرجى إنشاء حساب جديد أولاً'
    );
  end if;

  -- توليد رمز عشوائي مكون من 6 أرقام
  v_otp := lpad(floor(random() * 1000000)::text, 6, '0');

  -- إبطال أي رموز غير مستخدمة سابقة لهذا الرقم
  delete from public.phone_verifications 
  where phone = v_clean_phone and is_verified = false;

  -- إدراج الرمز الجديد بصلاحية 5 دقائق
  insert into public.phone_verifications (phone, otp_code, expires_at)
  values (v_clean_phone, v_otp, now() + interval '5 minutes');

  return jsonb_build_object(
    'success', true,
    'message', 'تم إنشاء رمز التحقق بنجاح',
    'phone', v_clean_phone,
    'otp', v_otp
  );
end;
$$;

-- 4. دالة التحقق من رمز الـ OTP
create or replace function public.verify_phone_otp(p_phone text, p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_clean_phone text;
  v_clean_token text;
  v_record record;
begin
  v_clean_phone := trim(regexp_replace(p_phone, '\s+', '', 'g'));
  v_clean_token := trim(p_token);

  select * into v_record
  from public.phone_verifications
  where phone = v_clean_phone
    and otp_code = v_clean_token
    and is_verified = false
    and expires_at > now()
  order by created_at desc
  limit 1;

  if v_record.id is null then
    return jsonb_build_object(
      'success', false,
      'message', 'رمز التحقق غير صحيح أو انتهت صلاحيته'
    );
  end if;

  -- تحديث حالة الرمز إلى تم التحقق
  update public.phone_verifications
  set is_verified = true
  where id = v_record.id;

  return jsonb_build_object(
    'success', true,
    'message', 'تم التحقق من الرمز بنجاح'
  );
end;
$$;

-- 5. تحديث دالة handle_new_user لعدم حفظ أي بريد إلكتروني تلقائي وهمي
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
  -- فحص البريد: إذا كان بريداً تلقائياً للهاتف نجعله null تماماً في الملف الشخصي
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

-- 6. منح الصلاحيات لدوال الـ RPC
grant execute on function public.generate_phone_otp(text, boolean) to anon, authenticated;
grant execute on function public.verify_phone_otp(text, text) to anon, authenticated;
