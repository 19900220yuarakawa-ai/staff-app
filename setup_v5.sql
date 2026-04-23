-- ============================================================
-- 社員評価アプリ 追加セットアップSQL (第5弾)
-- 資格マスター機能を追加
-- setup.sql〜setup_v4.sql 実行済みの前提
-- ============================================================

-- 1. 資格マスター
create table if not exists employee_qualifications (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order int default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- 2. スタッフと資格の紐付け(多対多)
create table if not exists employee_staff_qualifications (
  id uuid primary key default gen_random_uuid(),
  staff_id uuid not null references employee_eval_staff(id) on delete cascade,
  qualification_id uuid not null references employee_qualifications(id) on delete cascade,
  note text,          -- 取得日やメモ(任意)
  created_at timestamptz default now(),
  unique (staff_id, qualification_id)
);

-- 3. RLS
alter table employee_qualifications enable row level security;
alter table employee_staff_qualifications enable row level security;

drop policy if exists "anon all employee_qualifications" on employee_qualifications;
drop policy if exists "anon all employee_staff_qualifications" on employee_staff_qualifications;

create policy "anon all employee_qualifications" on employee_qualifications
  for all using (true) with check (true);
create policy "anon all employee_staff_qualifications" on employee_staff_qualifications
  for all using (true) with check (true);

-- 4. 初期データ(飲食店でありそうな資格)
insert into employee_qualifications (name, sort_order)
select * from (values
  ('調理師免許', 1),
  ('食品衛生責任者', 2),
  ('フグ処理師', 3),
  ('利き酒師', 4),
  ('ソムリエ', 5),
  ('防火管理者', 6)
) as v(name, sort_order)
where not exists (select 1 from employee_qualifications);
