-- ==============================================================================
-- المرحلة السابعة: الإشعارات وبوابة الدفع (Notifications & Payments)
-- ==============================================================================

-- 1. جدول الإشعارات (notifications)
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  message text not null,
  order_id uuid references public.orders(id) on delete set null,
  type text not null default 'order', -- 'order', 'promo', 'system'
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- فهارس تحسين الاستعلامات
create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_notifications_created_at on public.notifications(created_at desc);
create index if not exists idx_notifications_is_read on public.notifications(is_read);

-- تفعيل أمان الصفوف (RLS)
alter table public.notifications enable row level security;

-- كل مستخدم (عميلاً كان أو مالكاً) يرى فقط الإشعارات الموجهة إلى حسابه
drop policy if exists "Users can view own notifications" on public.notifications;
create policy "Users can view own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

drop policy if exists "Users can update own notifications" on public.notifications;
create policy "Users can update own notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

drop policy if exists "System can insert notifications" on public.notifications;
create policy "System can insert notifications"
  on public.notifications for insert
  with check (true);

-- 2. دالة ومشغل الإشعارات التلقائي للطلبات (Trigger for Orders)
create or replace function public.handle_order_notifications()
returns trigger
language plpgsql
security definer
as $$
declare
  owner_rec record;
  title_text text;
  msg_text text;
  v_is_customer boolean := true;
begin
  -- فحص ما إذا كان صاحب الطلب عميلاً أم مالكاً
  if exists (select 1 from public.profiles where id = new.user_id and role = 'owner') then
    v_is_customer := false;
  end if;

  -- عند إنشاء طلب جديد (INSERT)
  if tg_op = 'INSERT' then
    -- إشعار للعميل صاحب الطلب (فقط إذا كان عميلاً حقيقياً وليس حساب مالك يجرب)
    if v_is_customer then
      insert into public.notifications (user_id, title, message, order_id, type)
      values (
        new.user_id,
        'تم استلام طلبك بنجاح 🎉',
        'طلبك رقم #' || new.order_number || ' بقيمة ' || new.total || ' ر.س قيد المراجعة والتجهيز الآن.',
        new.id,
        'order'
      );
    end if;

    -- إشعار لجميع الملاك (Owners) بوجود طلب جديد في المتجر
    for owner_rec in select id from public.profiles where role = 'owner' loop
      insert into public.notifications (user_id, title, message, order_id, type)
      values (
        owner_rec.id,
        '📦 طلب جديد وارد!',
        'طلب جديد رقم #' || new.order_number || ' بقيمة ' || new.total || ' ر.س بانتظار المراجعة والتأكيد.',
        new.id,
        'order'
      );
    end loop;

  -- عند تعديل حالة الطلب (UPDATE)
  elsif tg_op = 'UPDATE' and old.order_status is distinct from new.order_status then
    -- 1. إذا ألغى العميل الطلب: نرسل تنبيهاً لجميع الملاك في المتجر
    if new.order_status = 'cancelled' then
      for owner_rec in select id from public.profiles where role = 'owner' loop
        insert into public.notifications (user_id, title, message, order_id, type)
        values (
          owner_rec.id,
          '⚠️ تنبيه: تم إلغاء طلب!',
          'تم إلغاء الطلب رقم #' || new.order_number || ' من قبل العميل، وتم إرجاع المنتجات للمخزون.',
          new.id,
          'order'
        );
      end loop;
    end if;

    -- 2. إرسال تحديثات حالة الشحن للعميل فقط (وليس للمالك)
    if v_is_customer then
      case new.order_status
        when 'confirmed' then
          title_text := 'تم تأكيد طلبك ✅';
          msg_text := 'تم تأكيد الطلب رقم #' || new.order_number || ' وسيتم البدء في تجهيزه قريباً.';
        when 'preparing' then
          title_text := 'طلبك قيد التجهيز 📦';
          msg_text := 'يقوم فريقنا الآن بتجهيز وتغليف طلبك رقم #' || new.order_number || '.';
        when 'shipped' then
          title_text := 'طلبك في الطريق إليك 🚚';
          msg_text := 'تم تسليم طلبك رقم #' || new.order_number || ' لشركة التوصيل للشحن إلى عنوانك.';
        when 'delivered' then
          title_text := 'تم تسليم طلبك بنجاح 🎁';
          msg_text := 'تم تسليم الطلب رقم #' || new.order_number || '، شكراً لتسوقك من سكارفس للأحذية!';
        when 'cancelled' then
          title_text := 'تم إلغاء الطلب ❌';
          msg_text := 'تم إلغاء الطلب رقم #' || new.order_number || ' بنجاح.';
        else
          title_text := 'تحديث حالة الطلب ℹ️';
          msg_text := 'حالة طلبك رقم #' || new.order_number || ' أصبحت الآن: ' || new.order_status;
      end case;

      insert into public.notifications (user_id, title, message, order_id, type)
      values (
        new.user_id,
        title_text,
        msg_text,
        new.id,
        'order'
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists on_order_notification_trigger on public.orders;
create trigger on_order_notification_trigger
  after insert or update of order_status on public.orders
  for each row execute function public.handle_order_notifications();

