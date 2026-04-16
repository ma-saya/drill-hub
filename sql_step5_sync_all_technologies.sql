-- =============================================
-- STEP 5: 追加技術とローカル問題を Supabase に同期する
-- このSQLは既存の Java 問題を残したまま、追加技術と追加問題を DB 化します。
-- 既存の study_records は削除しません。
-- =============================================
-- 追加対象の件数
--   合計: 526問
--   Java: 5問
--   Spring Boot: 72問
--   AWS: 46問
--   Flutter: 56問
--   PHP: 46問
--   HTML/CSS: 56問
--   Git/GitHub: 40問
--   SQL: 40問
--   Docker: 25問
--   JavaScript: 40問
--   TypeScript: 30問
--   React: 50問
--   Linux: 20問

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS technologies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE technologies ENABLE ROW LEVEL SECURITY;
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_records ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'technologies' AND policyname = 'Allow public read access on technologies'
  ) THEN
    CREATE POLICY "Allow public read access on technologies"
      ON technologies
      FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'themes' AND policyname = 'Allow public read access on themes'
  ) THEN
    CREATE POLICY "Allow public read access on themes"
      ON themes
      FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'problems' AND policyname = 'Allow public read access on problems'
  ) THEN
    CREATE POLICY "Allow public read access on problems"
      ON problems
      FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can create their own study records'
  ) THEN
    CREATE POLICY "Users can create their own study records"
      ON study_records
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can update their own study records'
  ) THEN
    CREATE POLICY "Users can update their own study records"
      ON study_records
      FOR UPDATE
      USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'study_records' AND policyname = 'Users can view their own study records'
  ) THEN
    CREATE POLICY "Users can view their own study records"
      ON study_records
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
END $$;

ALTER TABLE themes
  ADD COLUMN IF NOT EXISTS technology_id UUID;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'themes_technology_id_fkey'
  ) THEN
    ALTER TABLE themes
      ADD CONSTRAINT themes_technology_id_fkey
      FOREIGN KEY (technology_id) REFERENCES technologies(id) ON DELETE RESTRICT;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_themes_technology_id ON themes(technology_id);

DO $$
DECLARE
  current_definition TEXT;
BEGIN
  SELECT pg_get_constraintdef(oid) INTO current_definition FROM pg_constraint WHERE conname = 'problems_type_check' AND conrelid = 'problems'::regclass;

  IF current_definition IS NULL OR current_definition NOT LIKE '%code%' OR current_definition NOT LIKE '%procedure%' OR current_definition NOT LIKE '%concept%' THEN
    IF current_definition IS NOT NULL THEN
      ALTER TABLE problems DROP CONSTRAINT problems_type_check;
    END IF;

    ALTER TABLE problems
      ADD CONSTRAINT problems_type_check CHECK (type IN ('normal', 'fill_blank', 'code', 'procedure', 'concept'));
  END IF;
END $$;

INSERT INTO technologies (id, name, slug, description, display_order, is_active) VALUES
  ($pb$90000000-0000-0000-0000-000000000001$pb$, $pb$Java$pb$, $pb$java$pb$, $pb$Java の学習問題$pb$, 1, TRUE),
  ($pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot$pb$, $pb$spring-boot$pb$, $pb$Spring Boot の学習問題$pb$, 2, TRUE),
  ($pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS$pb$, $pb$aws$pb$, $pb$AWS の学習問題$pb$, 3, TRUE),
  ($pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter$pb$, $pb$flutter$pb$, $pb$Flutter の学習問題$pb$, 4, TRUE),
  ($pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP$pb$, $pb$php$pb$, $pb$PHP の学習問題$pb$, 5, TRUE),
  ($pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS$pb$, $pb$html-css$pb$, $pb$HTML/CSS の学習問題$pb$, 6, TRUE),
  ($pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub$pb$, $pb$git-github$pb$, $pb$Git/GitHub の学習問題$pb$, 7, TRUE),
  ($pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL$pb$, $pb$sql$pb$, $pb$SQL の学習問題$pb$, 8, TRUE),
  ($pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker$pb$, $pb$docker$pb$, $pb$Docker の学習問題$pb$, 9, TRUE),
  ($pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript$pb$, $pb$javascript$pb$, $pb$JavaScript の学習問題$pb$, 10, TRUE),
  ($pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript$pb$, $pb$typescript$pb$, $pb$TypeScript の学習問題$pb$, 11, TRUE),
  ($pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React$pb$, $pb$react$pb$, $pb$React の学習問題$pb$, 12, TRUE),
  ($pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux$pb$, $pb$linux$pb$, $pb$Linux の学習問題$pb$, 13, TRUE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;

UPDATE themes
SET technology_id = $pb$90000000-0000-0000-0000-000000000001$pb$
WHERE technology_id IS NULL;

INSERT INTO themes (id, technology_id, name, description, display_order) VALUES
  ($pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$90000000-0000-0000-0000-000000000001$pb$, $pb$Java: バグ修正$pb$, NULL, 6),
  ($pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Controller基礎$pb$, NULL, 7),
  ($pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Request / Response$pb$, NULL, 8),
  ($pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: DTO$pb$, NULL, 9),
  ($pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Service$pb$, NULL, 10),
  ($pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Repository$pb$, NULL, 11),
  ($pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Validation$pb$, NULL, 12),
  ($pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$90000000-0000-0000-0000-000000000002$pb$, $pb$Spring Boot: Exception Handling$pb$, NULL, 13),
  ($pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS: EC2$pb$, NULL, 14),
  ($pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS: S3$pb$, NULL, 15),
  ($pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS: RDS$pb$, NULL, 16),
  ($pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS: IAM$pb$, NULL, 17),
  ($pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$f1143de7-0c8b-467d-ac44-d1451752ae66$pb$, $pb$AWS: デプロイ構成$pb$, NULL, 18),
  ($pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter: Widget基礎$pb$, NULL, 19),
  ($pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter: レイアウト$pb$, NULL, 20),
  ($pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter: 状態管理$pb$, NULL, 21),
  ($pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter: 画面遷移$pb$, NULL, 22),
  ($pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$0bc92442-65f7-413f-a65b-cd90373b8059$pb$, $pb$Flutter: API連携$pb$, NULL, 23),
  ($pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: 基本文法$pb$, NULL, 24),
  ($pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: リクエスト処理$pb$, NULL, 25),
  ($pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: CRUD$pb$, NULL, 26),
  ($pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: DB連携$pb$, NULL, 27),
  ($pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: セキュリティ$pb$, NULL, 28),
  ($pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$f1c4d4ee-8803-4361-ad96-9c67dcc10dfd$pb$, $pb$PHP: Javaとの共通理解$pb$, NULL, 29),
  ($pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: HTML基礎$pb$, NULL, 30),
  ($pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: フォーム$pb$, NULL, 31),
  ($pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: CSS基礎$pb$, NULL, 32),
  ($pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: レイアウト$pb$, NULL, 33),
  ($pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: レスポンシブ$pb$, NULL, 34),
  ($pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$bbb31bc6-ff7e-47e4-ad08-efc743d126d7$pb$, $pb$HTML/CSS: セマンティック / アクセシビリティ$pb$, NULL, 35),
  ($pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: 基本操作$pb$, NULL, 36),
  ($pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: ブランチ$pb$, NULL, 37),
  ($pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: マージ / コンフリクト$pb$, NULL, 38),
  ($pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: GitHub基礎$pb$, NULL, 39),
  ($pb$822abdc8-0fab-4623-a2be-dbd93a7890c7$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: Pull Request$pb$, NULL, 40),
  ($pb$fb500652-7722-42b4-a84a-ceb7946a2d8d$pb$, $pb$c1cb1869-c9ef-4e46-a69f-b8914a191433$pb$, $pb$Git/GitHub: バグ修正$pb$, NULL, 41),
  ($pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: SELECT$pb$, NULL, 42),
  ($pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: WHERE / 条件$pb$, NULL, 43),
  ($pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: JOIN$pb$, NULL, 44),
  ($pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: GROUP BY$pb$, NULL, 45),
  ($pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: サブクエリ$pb$, NULL, 46),
  ($pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$d18206b5-063d-4ad0-a5be-b1c28e5f4cae$pb$, $pb$SQL: UPDATE / DELETE$pb$, NULL, 47),
  ($pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker: 基礎$pb$, NULL, 48),
  ($pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker: Dockerfile$pb$, NULL, 49),
  ($pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker: イメージ操作$pb$, NULL, 50),
  ($pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker: コンテナ操作$pb$, NULL, 51),
  ($pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$1b709473-c378-428b-a4d9-da5a39b7e85b$pb$, $pb$Docker: docker-compose$pb$, NULL, 52),
  ($pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: 基本文法$pb$, NULL, 53),
  ($pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: 配列 / オブジェクト$pb$, NULL, 54),
  ($pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: 関数 / スコープ$pb$, NULL, 55),
  ($pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: 非同期$pb$, NULL, 56),
  ($pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: DOM操作$pb$, NULL, 57),
  ($pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$f3961767-b128-444b-a91a-9f1fb0c651d0$pb$, $pb$JavaScript: API通信$pb$, NULL, 58),
  ($pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript: 型基礎$pb$, NULL, 59),
  ($pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript: 関数型$pb$, NULL, 60),
  ($pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript: オブジェクト型$pb$, NULL, 61),
  ($pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript: Generics$pb$, NULL, 62),
  ($pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$e5876637-e821-4c00-aba5-a4d953fe8c97$pb$, $pb$TypeScript: 実務型設計$pb$, NULL, 63),
  ($pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: 基礎（JSX / コンポーネント）$pb$, NULL, 64),
  ($pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: state$pb$, NULL, 65),
  ($pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: props$pb$, NULL, 66),
  ($pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: イベント処理$pb$, NULL, 67),
  ($pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: フォーム$pb$, NULL, 68),
  ($pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: API連携$pb$, NULL, 69),
  ($pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$4a060263-66c1-4ce0-a557-03caacc37749$pb$, $pb$React: コンポーネント分割$pb$, NULL, 70),
  ($pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux: 基本コマンド$pb$, NULL, 71),
  ($pb$5e1e247f-1560-464c-a100-e8f4155b49e7$pb$, $pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux: ファイル操作$pb$, NULL, 72),
  ($pb$e7fa0a39-0e71-4bcc-a197-db2f2f728553$pb$, $pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux: 権限$pb$, NULL, 73),
  ($pb$2f2fab65-ef16-434c-a12e-01c8896e167b$pb$, $pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux: プロセス / サーバ$pb$, NULL, 74),
  ($pb$328d8c07-3199-4179-a596-4c44073df86a$pb$, $pb$c5ed0562-addd-41db-ac5a-a2d7cc37ac36$pb$, $pb$Linux: ネットワーク / デプロイ補助$pb$, NULL, 75)
ON CONFLICT (id) DO UPDATE SET
  technology_id = EXCLUDED.technology_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order
;

INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$457bab4f-3e62-406d-a136-2f9565d79126$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$RESTコントローラーの基本アノテーション$pb$, 1, $pb$fill_blank$pb$, $pb$以下のクラスを REST API のコントローラーとして扱いたいです。
  空欄に入るアノテーションだけを答えてください。
  
  __________
  public class TaskController {
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$HTML画面ではなくJSONを返すコントローラーで使うアノテーションです。$pb$, $pb$@RestController$pb$, $pb$@RestController は @Controller と @ResponseBody の役割をまとめて持つため、REST API の入口でよく使います。$pb$, $pb$@Controller と書くと、戻り値をテンプレート名として扱う構成になりやすい点に注意です。$pb$, 601, TRUE),
  ($pb$f29b3f3c-be3a-4fb0-a42f-e9d2db3a63f5$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$GETエンドポイントのマッピング$pb$, 1, $pb$fill_blank$pb$, $pb$一覧取得用の GET エンドポイントを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @RestController
  @RequestMapping("/tasks")
  public class TaskController {
  
      __________
      public List<String> getTasks() {
          return List.of("A", "B");
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$GETメソッド用のマッピングです。$pb$, $pb$@GetMapping$pb$, $pb$@GetMapping を付けると、このメソッドが GET リクエストを受け取る入口になります。$pb$, $pb$@RequestMapping だけでも書けますが、初学者は GET / POST を明確に分ける書き方の方が理解しやすいです。$pb$, 602, TRUE),
  ($pb$b54491c9-b5a7-4b83-a9ac-23f225bf8654$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$PathVariableでIDを受け取る$pb$, 1, $pb$fill_blank$pb$, $pb$URL に含まれる id を受け取りたいです。
  空欄に入る引数だけを答えてください。
  
  @GetMapping("/{id}")
  public String getTask(__________) {
      return "task";
  }$pb$, $pb$空欄には引数1つ分だけを書いてください。$pb$, $pb$URLの {id} をメソッド引数へ結びつけるアノテーションです。$pb$, $pb$@PathVariable Long id$pb$, $pb$@PathVariable を付けると、URLパス中の値をそのまま引数で受け取れます。$pb$, $pb$RequestParam と混同しやすいですが、今回はクエリ文字列ではなくパスの一部です。$pb$, 603, TRUE),
  ($pb$e150acd1-661a-4172-af67-ba3eaa2581ab$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$RequestParamで検索条件を受け取る$pb$, 2, $pb$fill_blank$pb$, $pb$クエリパラメータの status を受け取りたいです。
  空欄に入る引数だけを答えてください。
  
  @GetMapping("/search")
  public String search(__________) {
      return status;
  }$pb$, $pb$空欄には引数1つ分だけを書いてください。$pb$, $pb$URLの ?status=done のような値を受け取るときに使います。$pb$, $pb$@RequestParam String status$pb$, $pb$@RequestParam はクエリパラメータを受け取るための基本アノテーションです。$pb$, $pb$@PathVariable と混同すると、URL設計と受け取り方がずれてしまいます。$pb$, 604, TRUE),
  ($pb$fa51ae7c-6966-4b21-a705-a126c3b7a2eb$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$POSTエンドポイントのマッピング$pb$, 1, $pb$fill_blank$pb$, $pb$新規作成用の POST エンドポイントを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @RestController
  @RequestMapping("/tasks")
  public class TaskController {
  
      __________
      public String create() {
          return "created";
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$POSTメソッド専用のマッピングです。$pb$, $pb$@PostMapping$pb$, $pb$@PostMapping は POST リクエストを受け取るときの基本アノテーションです。$pb$, $pb$@GetMapping のままにすると、作成系エンドポイントなのに GET 扱いになってしまいます。$pb$, 605, TRUE),
  ($pb$8dc32d76-db5c-489c-a6f9-25fd248d4f79$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$クラス単位の共通パス設定$pb$, 1, $pb$fill_blank$pb$, $pb$TaskController 配下のURLを /tasks にまとめたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @RestController
  __________
  public class TaskController {
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$メソッドごとではなく、クラス全体に共通パスを付けます。$pb$, $pb$@RequestMapping("/tasks")$pb$, $pb$@RequestMapping をクラスに付けると、そのクラス配下のエンドポイント全体に共通パスを付けられます。$pb$, $pb$各メソッドに毎回 "/tasks" を書いても動きますが、重複が増えて保守しづらくなります。$pb$, 606, TRUE),
  ($pb$ff0240b5-db78-4f81-adf8-f2ea7017666a$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$PUTエンドポイントのマッピング$pb$, 2, $pb$fill_blank$pb$, $pb$更新用の PUT エンドポイントを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @RestController
  @RequestMapping("/tasks")
  public class TaskController {
  
      __________
      public String update(@PathVariable Long id) {
          return "updated";
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$URLに id を含む更新系エンドポイントです。$pb$, $pb$@PutMapping("/{id}")$pb$, $pb$@PutMapping("/{id}") を付けると、特定IDの更新用エンドポイントを表現できます。$pb$, $pb$@PostMapping にすると新規作成と更新の意図が混ざりやすくなります。$pb$, 607, TRUE),
  ($pb$e5639eb0-97c7-4ebe-a267-ced6a149d5e2$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$DELETEエンドポイントのマッピング$pb$, 2, $pb$fill_blank$pb$, $pb$削除用の DELETE エンドポイントを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @RestController
  @RequestMapping("/tasks")
  public class TaskController {
  
      __________
      public void delete(@PathVariable Long id) {
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$HTTPメソッド名に対応する専用アノテーションがあります。$pb$, $pb$@DeleteMapping("/{id}")$pb$, $pb$@DeleteMapping を使うと、削除用エンドポイントであることがメソッド宣言だけで伝わります。$pb$, $pb$@GetMapping にしてしまうと、副作用のある処理を GET で呼ぶ不自然なAPIになります。$pb$, 608, TRUE),
  ($pb$e4bcbfc8-6a2f-47d6-ae08-dd50c1dad1f0$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$RequestBodyでJSONを受け取る$pb$, 2, $pb$fill_blank$pb$, $pb$POSTされた JSON を CreateTaskRequest に受け取りたいです。
  空欄に入る引数だけを答えてください。
  
  @PostMapping
  public String createTask(__________) {
      return request.getTitle();
  }$pb$, $pb$空欄には引数1つ分だけを書いてください。$pb$, $pb$JSONボディをJavaオブジェクトへ変換して受け取りたい場面です。$pb$, $pb$@RequestBody CreateTaskRequest request$pb$, $pb$@RequestBody を付けると、リクエストボディのJSONを指定したクラスへ変換して受け取れます。$pb$, $pb$RequestParam を使うと、JSONボディではなくクエリパラメータとして扱われます。$pb$, 701, TRUE),
  ($pb$986581f5-1aa1-44d2-aa64-04a60bc78553$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$201 Createdでレスポンスを返す$pb$, 3, $pb$fill_blank$pb$, $pb$作成成功時に 201 Created を返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  @PostMapping
  public ResponseEntity<TaskResponse> create(@RequestBody CreateTaskRequest request) {
      TaskResponse response = service.create(request);
      return __________;
  }$pb$, $pb$空欄には return の右辺だけを書いてください。$pb$, $pb$新規作成成功時は 200 OK ではなく 201 Created を返すことがあります。$pb$, $pb$ResponseEntity.status(HttpStatus.CREATED).body(response)$pb$, $pb$ResponseEntity を使うと、HTTPステータスとレスポンスボディをまとめて明示できます。$pb$, $pb$ResponseEntity.ok(response) でも動きますが、作成系APIでは CREATED を返す方が意図が伝わりやすいです。$pb$, 702, TRUE),
  ($pb$42cdb952-47b8-4b97-a109-54bb1b4af1d2$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$レスポンスDTOをrecordで定義する$pb$, 1, $pb$fill_blank$pb$, $pb$タスク一覧のレスポンス用 DTO を record で定義したいです。
  空欄に入る1行だけを答えてください。
  
  __________$pb$, $pb$id と title を持つ record を1行で定義してください。$pb$, $pb$Spring Boot 3系や最近のJavaでは、シンプルなレスポンスDTOに record がよく使われます。$pb$, $pb$public record TaskResponse(Long id, String title) {}$pb$, $pb$record は値を持つだけのシンプルなDTOを短く表現できる構文です。$pb$, $pb$class で書いても間違いではありませんが、この問題では record を使う前提です。$pb$, 703, TRUE),
  ($pb$c1fad2b5-b729-4df7-a8ea-db8d3d8a9f23$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$JSONレスポンスのreturn文$pb$, 2, $pb$fill_blank$pb$, $pb$TaskResponse を返すメソッドで、id=1, title="first task" のレスポンスを返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  @GetMapping("/sample")
  public TaskResponse sample() {
      return __________;
  }$pb$, $pb$空欄には return の右辺だけを書いてください。$pb$, $pb$戻り値の型が TaskResponse なので、その型のインスタンスを返します。$pb$, $pb$new TaskResponse(1L, "first task")$pb$, $pb$Spring Boot は戻り値のオブジェクトを自動で JSON に変換して返してくれます。$pb$, $pb$TaskEntity のような別の型を返すと、APIで見せたい項目と内部実装が混ざりやすくなります。$pb$, 704, TRUE),
  ($pb$4a19e49b-f71f-4aec-ae7f-d9da49893f00$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$リクエストDTOをrecordで定義する$pb$, 1, $pb$fill_blank$pb$, $pb$タスク作成用のリクエストDTOを record で定義したいです。
  空欄に入る1行だけを答えてください。
  
  __________$pb$, $pb$title と description を受け取る record を1行で定義してください。$pb$, $pb$シンプルな入力DTOは record で短く表現できます。$pb$, $pb$public record CreateTaskRequest(String title, String description) {}$pb$, $pb$record は入力値を受け取るだけのシンプルな DTO を短く定義するのに向いています。$pb$, $pb$record の最後の {} を忘れると定義として成立しません。$pb$, 705, TRUE),
  ($pb$50fcc866-e65f-4d04-a82d-1cc8b3e0c6db$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$一覧取得メソッドの戻り値型$pb$, 1, $pb$fill_blank$pb$, $pb$タスク一覧を JSON で返す Controller メソッドの戻り値型を決めたいです。
  空欄に入る型だけを答えてください。
  
  @GetMapping
  public __________ list() {
      return service.findAll();
  }$pb$, $pb$TaskResponse の一覧を返す型を書いてください。$pb$, $pb$DTOを複数返すので List を使います。$pb$, $pb$List<TaskResponse>$pb$, $pb$一覧APIでは、レスポンスDTOの List をそのまま返す形が基本です。$pb$, $pb$List<Task> にすると Entity を直接返す設計になり、DTOを使う意味が薄れます。$pb$, 706, TRUE),
  ($pb$5929cf81-144f-4a39-a83f-67c01f3b025a$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$204 No Content を返す$pb$, 2, $pb$fill_blank$pb$, $pb$削除成功時にレスポンス本文なしで 204 No Content を返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable Long id) {
      service.delete(id);
      return __________;
  }$pb$, $pb$空欄には return の右辺だけを書いてください。$pb$, $pb$本文なしで成功を返す専用メソッドがあります。$pb$, $pb$ResponseEntity.noContent().build()$pb$, $pb$noContent().build() を使うと、204 No Content を簡潔に返せます。$pb$, $pb$ok().build() にすると 200 OK になるため、削除成功時の意図が少し弱くなります。$pb$, 707, TRUE),
  ($pb$91bba7fd-0aac-4018-ab4e-d81f2536737d$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$ネストしたレスポンスDTOの定義$pb$, 2, $pb$fill_blank$pb$, $pb$担当者情報を含むタスク詳細レスポンスを record で定義したいです。
  空欄に入る1行だけを答えてください。
  
  __________$pb$, $pb$id, title, assignee の3項目を持つ TaskDetailResponse を1行で定義してください。$pb$, $pb$assignee には UserResponse 型を使います。$pb$, $pb$public record TaskDetailResponse(Long id, String title, UserResponse assignee) {}$pb$, $pb$レスポンスDTOの中に別DTOを入れると、ネストした JSON 構造を自然に表せます。$pb$, $pb$assignee を String にしてしまうと、利用者情報を1項目に押し込めてしまいます。$pb$, 708, TRUE),
  ($pb$25aaf3cb-3c23-45a4-a6cd-de178ef49360$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$EntityからDTOへ変換する$pb$, 1, $pb$fill_blank$pb$, $pb$Task エンティティを TaskResponse に変換したいです。
  空欄に入る return 文の右辺だけを答えてください。
  
  private TaskResponse toResponse(Task task) {
      return __________;
  }$pb$, $pb$id と title をそのまま DTO へ詰め替えてください。$pb$, $pb$getter で取り出した値を DTO のコンストラクタへ渡します。$pb$, $pb$new TaskResponse(task.getId(), task.getTitle())$pb$, $pb$Entity から DTO へ必要な項目だけを詰め替えるのは、Spring Boot でよく使う基本パターンです。$pb$, $pb$Entity 自体をそのまま返すと、不要な項目までAPIに出しやすくなります。$pb$, 751, TRUE),
  ($pb$7c43f51b-f5a9-4767-ae78-8921dde20b0a$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTOのstatic factoryメソッド名$pb$, 2, $pb$fill_blank$pb$, $pb$TaskResponse に、Task から生成する static factory を作りたいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public record TaskResponse(Long id, String title) {
      __________ {
          return new TaskResponse(task.getId(), task.getTitle());
      }
  }$pb$, $pb$Task を受け取って TaskResponse を返す static factory の宣言を書いてください。$pb$, $pb$static メソッドで DTO を作るときは from という名前がよく使われます。$pb$, $pb$public static TaskResponse from(Task task)$pb$, $pb$DTO生成ロジックを from メソッドに寄せると、呼び出し側を短く保ちやすくなります。$pb$, $pb$戻り値を Task にしてしまうと、DTOを作るメソッドとして意味がずれてしまいます。$pb$, 752, TRUE),
  ($pb$5f9e541d-4e87-43ac-aee0-4734f5cfd564$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTOリストへ変換するmap処理$pb$, 2, $pb$fill_blank$pb$, $pb$Entity の一覧を DTO の一覧に変換したいです。
  空欄に入る stream の1行だけを答えてください。
  
  return tasks.stream()
      __________
      .toList();$pb$, $pb$TaskResponse の static factory を使って変換してください。$pb$, $pb$各要素を別の型へ変換するときは map を使います。$pb$, $pb$.map(TaskResponse::from)$pb$, $pb$map は「要素ごとの変換」を行うときに使う Stream API の基本です。$pb$, $pb$filter は絞り込み用なので、型変換したいときには使いません。$pb$, 753, TRUE),
  ($pb$78caabf5-14ab-4b57-a095-4a4d8be12e9f$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTOをrecordで定義する$pb$, 1, $pb$fill_blank$pb$, $pb$タスク一覧表示用のDTOを定義したいです。
  空欄に入る1行だけを答えてください。
  
  __________$pb$, $pb$id と title を持つ TaskSummaryResponse を1行で定義してください。$pb$, $pb$DTO は短く record で表せます。$pb$, $pb$public record TaskSummaryResponse(Long id, String title) {}$pb$, $pb$シンプルなDTOは record にすると、getter やコンストラクタを自分で書かずに済みます。$pb$, $pb$record 名とファイル名の対応を無視すると、Javaのコンパイル時に混乱しやすいです。$pb$, 754, TRUE),
  ($pb$6af973c1-66e2-4e6a-abbf-84d995c1d5de$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTOのstatic factoryで返す式$pb$, 1, $pb$fill_blank$pb$, $pb$TaskSummaryResponse の from メソッド内で DTO を返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  public static TaskSummaryResponse from(Task task) {
      return __________;
  }$pb$, $pb$Task の id と title を使って DTO を作ってください。$pb$, $pb$DTOのコンストラクタへ必要な値を渡します。$pb$, $pb$new TaskSummaryResponse(task.getId(), task.getTitle())$pb$, $pb$static factory の中では、必要な項目だけを抜き出してDTOを生成します。$pb$, $pb$Entity をそのまま返すと、from メソッドが DTO 生成にならなくなります。$pb$, 755, TRUE),
  ($pb$c6bf6494-9ae9-4889-a102-e27e454c95a4$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTO生成メソッドの宣言$pb$, 2, $pb$fill_blank$pb$, $pb$TaskResponse に Task から生成する factory メソッドを追加したいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public record TaskResponse(Long id, String title) {
      __________ {
          return new TaskResponse(task.getId(), task.getTitle());
      }
  }$pb$, $pb$Task を引数に取り TaskResponse を返す static メソッドを書いてください。$pb$, $pb$static factory の名前は from がよく使われます。$pb$, $pb$public static TaskResponse from(Task task)$pb$, $pb$from のような static factory を置くと、DTO変換ロジックの置き場所がはっきりします。$pb$, $pb$public TaskResponse from(Task task) とすると、インスタンスメソッドになって意図が少しずれます。$pb$, 756, TRUE),
  ($pb$cd6c4252-617e-442a-a750-d07d00055077$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$DTOリストへ変換するstream処理$pb$, 2, $pb$fill_blank$pb$, $pb$Task の一覧を TaskResponse の一覧に変換したいです。
  空欄に入る1行だけを答えてください。
  
  return tasks.stream()
      __________
      .toList();$pb$, $pb$TaskResponse の static factory を使ってください。$pb$, $pb$各要素を別の型へ変えるときは map を使います。$pb$, $pb$.map(TaskResponse::from)$pb$, $pb$map(TaskResponse::from) と書くと、各 Task を TaskResponse に変換できます。$pb$, $pb$forEach は副作用用なので、別のリストへ変換して返したい場面には向きません。$pb$, 757, TRUE),
  ($pb$e9990cf6-12c7-4064-a965-d291eb309f30$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$null安全なDTO変換$pb$, 3, $pb$fill_blank$pb$, $pb$task が null なら null を返し、そうでなければ DTO に変換したいです。
  空欄に入る return の右辺だけを答えてください。
  
  private TaskResponse toResponse(Task task) {
      return __________;
  }$pb$, $pb$三項演算子を使って null 安全に書いてください。$pb$, $pb$null かどうかで分岐して、DTO生成か null を返します。$pb$, $pb$task == null ? null : TaskResponse.from(task)$pb$, $pb$変換前に null チェックを入れると、変換処理で NullPointerException を避けられます。$pb$, $pb$task.getId() を先に呼ぶと、null のときにその時点で落ちてしまいます。$pb$, 758, TRUE),
  ($pb$9108b55a-461e-4590-a2e9-7e0e3340f265$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$Serviceクラスの基本アノテーション$pb$, 1, $pb$fill_blank$pb$, $pb$ビジネスロジックを持つクラスとして Spring に管理させたいです。
  空欄に入るアノテーションだけを答えてください。
  
  __________
  public class TaskService {
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$Controller でも Repository でもない、中間の業務ロジック層です。$pb$, $pb$@Service$pb$, $pb$@Service はサービス層のクラスをSpring管理のBeanとして登録するときの代表的なアノテーションです。$pb$, $pb$@Component でも登録できますが、役割を明確にするために @Service を使う方が読みやすいです。$pb$, 801, TRUE),
  ($pb$8f66b7bf-8f86-4bae-a66e-3cb27b8de6f1$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$コンストラクタインジェクションの代入$pb$, 2, $pb$fill_blank$pb$, $pb$コンストラクタで受け取った repository をフィールドへ代入したいです。
  空欄に入る1行だけを答えてください。
  
  @Service
  public class TaskService {
      private final TaskRepository taskRepository;
  
      public TaskService(TaskRepository taskRepository) {
          __________
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$引数名とフィールド名が同じなので、this を使います。$pb$, $pb$this.taskRepository = taskRepository;$pb$, $pb$コンストラクタインジェクションでは、受け取った依存オブジェクトを final フィールドへ代入する形が基本です。$pb$, $pb$this を付け忘れると、引数同士の代入になってしまいフィールドが初期化されません。$pb$, 802, TRUE),
  ($pb$0e2a9299-ef20-49b2-a71c-ac00524fdec7$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$JPA Repositoryの継承$pb$, 2, $pb$fill_blank$pb$, $pb$タスクの永続化を担当する Repository インターフェースを作りたいです。
  空欄に入る継承先だけを答えてください。
  
  public interface TaskRepository extends __________ {
  }$pb$, $pb$空欄には型名だけを書いてください。$pb$, $pb$Spring Data JPA の基本形です。$pb$, $pb$JpaRepository<Task, Long>$pb$, $pb$JpaRepository<Entity, ID型> の形で継承すると、基本的なCRUDメソッドを自動で使えるようになります。$pb$, $pb$ID型を Integer にしてしまう、Entity型を DTO にしてしまう、の2つが初学者で起きやすいミスです。$pb$, 803, TRUE),
  ($pb$c8f11b3c-b96f-4cf9-a833-1448e4b0f352$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$Serviceメソッドにトランザクションを付ける$pb$, 2, $pb$fill_blank$pb$, $pb$作成処理を1つのトランザクションとして扱いたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @Service
  public class TaskService {
  
      __________
      public TaskResponse create(CreateTaskRequest request) {
          return null;
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$複数のDB操作をまとめて成功・失敗させたいときに使います。$pb$, $pb$@Transactional$pb$, $pb$@Transactional を付けると、そのメソッド内のDB処理を1つのトランザクションとして扱えます。$pb$, $pb$Controller に付けるより、業務処理をまとめる Service に付ける方が役割が分かりやすいです。$pb$, 804, TRUE),
  ($pb$8610df23-5bbc-45ed-a2a5-2b9926db9064$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$見つからないときに例外を投げる$pb$, 2, $pb$fill_blank$pb$, $pb$repository.findById(id) の結果が空なら TaskNotFoundException を投げたいです。
  空欄に入る Optional の右辺だけを答えてください。
  
  Task task = repository.findById(id)
      __________;$pb$, $pb$TaskNotFoundException(id) を投げる形にしてください。$pb$, $pb$Optional から値を取り出し、無ければ例外にしたいときの定番です。$pb$, $pb$.orElseThrow(() -> new TaskNotFoundException(id))$pb$, $pb$orElseThrow を使うと、「無いなら例外」という処理を短く明確に書けます。$pb$, $pb$null を返すだけにすると、呼び出し側で毎回nullチェックが必要になり、漏れやすくなります。$pb$, 805, TRUE),
  ($pb$327a2672-384d-4ddc-a33a-979b2fe84a37$pb$, $pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$セミコロン不足でコンパイルエラーになるコードを直す$pb$, 1, $pb$normal$pb$, $pb$次の Java コードはコンパイルエラーになります。原因を直したコードを書いてください。
  
  public class Main {
      public static void main(String[] args) {
          int count = 3
          System.out.println(count);
      }
  }$pb$, $pb$`int count = 3;` に直すこと
  それ以外は大きく変えなくてよいこと$pb$, $pb$Java は文の終わりに記号が必要です。$pb$, $pb$public class Main {
      public static void main(String[] args) {
          int count = 3;
          System.out.println(count);
      }
  }$pb$, $pb$Java のコンパイルエラーで最も基本的なのが、文末のセミコロン不足です。$pb$, $pb$変数型や `println` を変える必要はなく、今回の原因は文末記号だけです。$pb$, 806, TRUE),
  ($pb$68f0263b-f314-4905-a87c-ec0c6b350ad3$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$ServiceでRepositoryを受け取るフィールド宣言$pb$, 1, $pb$fill_blank$pb$, $pb$TaskService に TaskRepository を保持するフィールドを追加したいです。
  空欄に入る1行だけを答えてください。
  
  @Service
  public class TaskService {
      __________
  }$pb$, $pb$final フィールドで宣言してください。$pb$, $pb$コンストラクタインジェクション前提の書き方です。$pb$, $pb$private final TaskRepository taskRepository;$pb$, $pb$依存オブジェクトは final フィールドに持つと、初期化後に変わらないことが明確になります。$pb$, $pb$Repository 型ではなく Entity 型を書いてしまうと、依存対象がずれてしまいます。$pb$, 806, TRUE),
  ($pb$10423051-9bb1-479f-a607-dc7f6fda3a5d$pb$, $pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$文字列比較で==を使っているバグを直す$pb$, 2, $pb$normal$pb$, $pb$次のコードは、入力が `"admin"` でも期待どおりに判定されないことがあります。正しく判定できるように直してください。
  
  String role = "admin";
  if (role == "admin") {
      System.out.println("管理者です");
  }$pb$, $pb$`equals` を使うこと
  条件式だけでなく、コード全体を書いてよいこと$pb$, $pb$Java の文字列比較は、参照比較ではなく内容比較を使います。$pb$, $pb$String role = "admin";
  if ("admin".equals(role)) {
      System.out.println("管理者です");
  }$pb$, $pb$Java の `==` は参照比較なので、文字列の内容を比べたいときは `equals` を使います。$pb$, $pb$`role.equals("admin")` でも多くの場合動きますが、null 安全まで考えるなら定数側から呼ぶ形が安定です。$pb$, 807, TRUE),
  ($pb$91da4f93-7153-48c7-a545-68e9aa2d3654$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$保存後のEntityを受け取る$pb$, 2, $pb$fill_blank$pb$, $pb$作成した Task を保存し、その戻り値を saved に受け取りたいです。
  空欄に入る1行だけを答えてください。
  
  public TaskResponse create(Task task) {
      __________
      return TaskResponse.from(saved);
  }$pb$, $pb$repository の save メソッドを使ってください。$pb$, $pb$save の戻り値を変数で受け取る形です。$pb$, $pb$Task saved = taskRepository.save(task);$pb$, $pb$save の戻り値を受け取っておくと、保存後の状態を DTO へ変換しやすくなります。$pb$, $pb$save を呼ぶだけで変数に受けないと、続きの行で saved を使えません。$pb$, 807, TRUE),
  ($pb$7b025566-d053-4b55-a25c-04064853ac1b$pb$, $pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$配列ループの境界ミスを直す$pb$, 2, $pb$normal$pb$, $pb$次のコードは `ArrayIndexOutOfBoundsException` になる可能性があります。正しく最後まで表示できるように直してください。
  
  int[] scores = {70, 80, 90};
  for (int i = 0; i <= scores.length; i++) {
      System.out.println(scores[i]);
  }$pb$, $pb$for 文の条件を修正すること
  配列の中身はそのままでよいこと$pb$, $pb$配列の添字は 0 から始まり、最後は `length - 1` です。$pb$, $pb$int[] scores = {70, 80, 90};
  for (int i = 0; i < scores.length; i++) {
      System.out.println(scores[i]);
  }$pb$, $pb$配列ループでは `<=` を使うと最後に1つはみ出しやすく、研修でもよく出る定番ミスです。$pb$, $pb$`scores.length - 1` を条件式へ直接書く方法もありますが、`i < scores.length` の方が読みやすいです。$pb$, 808, TRUE),
  ($pb$2e7380bf-86f7-4219-acaa-3d13a4e6baf4$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$Serviceメソッドの戻り値をDTOにする$pb$, 2, $pb$fill_blank$pb$, $pb$作成処理の Service メソッドの宣言を書きたいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  @Service
  public class TaskService {
      __________ {
          return null;
      }
  }$pb$, $pb$CreateTaskRequest を受け取り、TaskResponse を返す create メソッドにしてください。$pb$, $pb$Controller から呼ばれて DTO を返す形です。$pb$, $pb$public TaskResponse create(CreateTaskRequest request)$pb$, $pb$Service が DTO を返す設計にすると、Controller 側が薄く保ちやすくなります。$pb$, $pb$戻り値を Task にすると、Controller 側でさらに DTO 変換が必要になります。$pb$, 808, TRUE),
  ($pb$435642fe-bf25-488d-a792-56332435dbf4$pb$, $pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$ScannerのnextInt後にnextLineが空になるバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のコードでは、年齢入力のあとに名前が正しく読めないことがあります。原因を直したコードを書いてください。
  
  Scanner scanner = new Scanner(System.in);
  System.out.print("年齢: ");
  int age = scanner.nextInt();
  System.out.print("名前: ");
  String name = scanner.nextLine();
  System.out.println(name + " さん");$pb$, $pb$`nextInt()` のあとに改行を読み飛ばす処理を入れること
  `name` は `nextLine()` で取得すること$pb$, $pb$`nextInt()` のあとには入力バッファに改行が残ることがあります。$pb$, $pb$Scanner scanner = new Scanner(System.in);
  System.out.print("年齢: ");
  int age = scanner.nextInt();
  scanner.nextLine();
  System.out.print("名前: ");
  String name = scanner.nextLine();
  System.out.println(name + " さん");$pb$, $pb$`nextInt()` のあとに残った改行を `nextLine()` が先に読んでしまうのは、Java 初学者の定番バグです。$pb$, $pb$`name = scanner.next()` に変えると空白を含む名前を扱いにくくなり、根本修正としては弱くなります。$pb$, 809, TRUE),
  ($pb$7f574fb9-d504-409d-ac22-af27cfd01fff$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$削除処理をRepositoryへ委譲する$pb$, 2, $pb$fill_blank$pb$, $pb$Service の delete メソッドで、実際の削除を Repository に委譲したいです。
  空欄に入る1行だけを答えてください。
  
  public void delete(Long id) {
      __________
  }$pb$, $pb$deleteById を使ってください。$pb$, $pb$Repository の基本CRUDメソッドを呼び出します。$pb$, $pb$taskRepository.deleteById(id);$pb$, $pb$Service は業務の流れをまとめ、実際の永続化処理は Repository に委譲するのが基本です。$pb$, $pb$Service の中で EntityManager を直接触り始めると、責務分割が崩れやすくなります。$pb$, 809, TRUE),
  ($pb$63c4c549-6949-4743-aefa-c0e688952628$pb$, $pb$d421c885-f76f-4286-a9f1-e92abc2fbc79$pb$, $pb$ArrayList未初期化によるNullPointerExceptionを直す$pb$, 3, $pb$normal$pb$, $pb$次のコードは実行時に `NullPointerException` になります。正しくタスク追加できるように直してください。
  
  import java.util.ArrayList;
  import java.util.List;
  
  public class Main {
      public static void main(String[] args) {
          List<String> tasks = null;
          tasks.add("買い物");
          System.out.println(tasks);
      }
  }$pb$, $pb$`tasks` を `new ArrayList<>()` で初期化すること
  追加処理はそのまま活かすこと$pb$, $pb$`null` のままメソッドを呼ぶと例外になります。$pb$, $pb$import java.util.ArrayList;
  import java.util.List;
  
  public class Main {
      public static void main(String[] args) {
          List<String> tasks = new ArrayList<>();
          tasks.add("買い物");
          System.out.println(tasks);
      }
  }$pb$, $pb$コレクションは宣言だけでは使えず、実体を生成してから使う必要があります。$pb$, $pb$`List<String> tasks;` とだけ書いても未初期化のままなので、修正としては不十分です。$pb$, 810, TRUE),
  ($pb$d903c0ad-a5ee-4223-acde-fc0130660cbe$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$findByIdの戻り値の型$pb$, 1, $pb$fill_blank$pb$, $pb$TaskRepository に ID検索メソッドを宣言したいです。
  空欄に入る戻り値の型だけを答えてください。
  
  public interface TaskRepository extends JpaRepository<Task, Long> {
      __________ findById(Long id);
  }$pb$, $pb$空欄には戻り値の型だけを書いてください。$pb$, $pb$見つからない可能性があるので、Spring Data JPA では Optional で扱うことが多いです。$pb$, $pb$Optional<Task>$pb$, $pb$findById は「あるかもしれないし、ないかもしれない」検索なので Optional<Task> が自然です。$pb$, $pb$Task をそのまま返す設計にすると、見つからないケースの扱いが曖昧になりやすいです。$pb$, 851, TRUE),
  ($pb$d4ba57f3-1a0b-43b9-a1d4-6004f433df37$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$状態で絞り込む派生クエリ$pb$, 2, $pb$fill_blank$pb$, $pb$status でタスク一覧を検索するメソッドを Repository に追加したいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public interface TaskRepository extends JpaRepository<Task, Long> {
      __________
  }$pb$, $pb$List と String status を使った派生クエリメソッドを書いてください。$pb$, $pb$Spring Data JPA では findByXxx の形でメソッド名からクエリを作れます。$pb$, $pb$List<Task> findByStatus(String status);$pb$, $pb$Spring Data JPA は findByStatus のような名前から、自動で検索クエリを組み立ててくれます。$pb$, $pb$メソッド名が searchStatus などになると、自動派生クエリとして認識されません。$pb$, 852, TRUE),
  ($pb$b30d7ad4-d0a1-4f10-a948-93ddf33b6744$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$saveメソッドの使い方$pb$, 1, $pb$fill_blank$pb$, $pb$新しい Task を保存したいです。
  空欄に入る1行だけを答えてください。
  
  public void create(Task task) {
      __________
  }$pb$, $pb$Repository の save メソッドを呼んでください。$pb$, $pb$JPA Repository の基本CRUDです。$pb$, $pb$taskRepository.save(task);$pb$, $pb$save は新規作成にも更新にも使える、Spring Data JPA の代表的なメソッドです。$pb$, $pb$add や insert のようなメソッド名は、JpaRepository には用意されていません。$pb$, 853, TRUE),
  ($pb$f9baeb62-4891-461a-abab-a58a5ff639cc$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$deleteByIdの呼び出し$pb$, 1, $pb$fill_blank$pb$, $pb$ID指定で削除したいです。
  空欄に入る1行だけを答えてください。
  
  public void delete(Long id) {
      __________
  }$pb$, $pb$deleteById を使ってください。$pb$, $pb$JpaRepository が標準で持っています。$pb$, $pb$taskRepository.deleteById(id);$pb$, $pb$IDで削除するだけなら、deleteById をそのまま呼ぶだけで十分です。$pb$, $pb$findById してから remove しようとすると、不要に手順が増えがちです。$pb$, 854, TRUE),
  ($pb$1604b62f-d913-47f0-ac1d-d8b09ba8e8ac$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$タイトル部分一致の派生クエリ$pb$, 2, $pb$fill_blank$pb$, $pb$タイトルに keyword を含むタスク一覧を検索したいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public interface TaskRepository extends JpaRepository<Task, Long> {
      __________
  }$pb$, $pb$keyword を引数に取り、部分一致検索を行うメソッドを書いてください。$pb$, $pb$Containing を使うと部分一致検索になります。$pb$, $pb$List<Task> findByTitleContaining(String keyword);$pb$, $pb$findByTitleContaining のような名前を書くと、Spring Data JPA が部分一致検索として解釈してくれます。$pb$, $pb$contains ではなく Containing という名前規則を使うのがポイントです。$pb$, 855, TRUE),
  ($pb$16d1a8df-f0a3-4b75-a2c5-0142f3703879$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$存在確認の派生クエリ$pb$, 2, $pb$fill_blank$pb$, $pb$同じタイトルのタスクが存在するか確認したいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public interface TaskRepository extends JpaRepository<Task, Long> {
      __________
  }$pb$, $pb$title を受け取って boolean を返す形にしてください。$pb$, $pb$existsBy... という命名があります。$pb$, $pb$boolean existsByTitle(String title);$pb$, $pb$existsByXxx は、存在確認専用の派生クエリとしてよく使われます。$pb$, $pb$戻り値を Task にすると、存在確認なのか検索なのかが曖昧になります。$pb$, 856, TRUE),
  ($pb$e1614ef1-80db-4478-a449-9c0acd537665$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$作成日時の降順取得$pb$, 3, $pb$fill_blank$pb$, $pb$新しい順にタスク一覧を取得したいです。
  空欄に入るメソッド宣言だけを答えてください。
  
  public interface TaskRepository extends JpaRepository<Task, Long> {
      __________
  }$pb$, $pb$createdAt の降順ソートを表すメソッド名にしてください。$pb$, $pb$OrderBy...Desc という書き方があります。$pb$, $pb$List<Task> findAllByOrderByCreatedAtDesc();$pb$, $pb$OrderByCreatedAtDesc を付けると、作成日時の降順で一覧を取得する派生クエリとして読めます。$pb$, $pb$findAllOrderByCreatedAtDesc は規則から外れていて、自動クエリとして解釈されません。$pb$, 857, TRUE),
  ($pb$daedaaa2-8b1a-46bb-a7bd-2f19ad9e50f6$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$必須入力のバリデーション$pb$, 2, $pb$fill_blank$pb$, $pb$タイトルを必須入力にしたいです。
  空欄に入るアノテーションだけを答えてください。
  
  public class CreateTaskRequest {
      __________
      private String title;
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$空文字や空白だけを弾きたいときに使います。$pb$, $pb$@NotBlank(message = "title is required")$pb$, $pb$@NotBlank は null だけでなく空文字や空白文字だけの入力も不正として扱えます。$pb$, $pb$@NotNull だと空文字を許してしまうため、文字列の必須チェックとしては弱いです。$pb$, 901, TRUE),
  ($pb$eda86057-4636-4949-adbe-b8138f0433b0$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$リクエストDTOに@Validを付ける$pb$, 2, $pb$fill_blank$pb$, $pb$CreateTaskRequest に書いたバリデーションを有効にしたいです。
  空欄に入る引数だけを答えてください。
  
  @PostMapping
  public ResponseEntity<Void> create(__________) {
      return ResponseEntity.ok().build();
  }$pb$, $pb$空欄には引数1つ分だけを書いてください。$pb$, $pb$バリデーション対象のDTOには @Valid を付けて受け取ります。$pb$, $pb$@Valid @RequestBody CreateTaskRequest request$pb$, $pb$@Valid を付けることで、DTOに書かれたアノテーションベースの入力チェックが実行されます。$pb$, $pb$@RequestBody だけだとDTOへの変換はされても、バリデーションは走りません。$pb$, 902, TRUE),
  ($pb$3900a3a3-2ce8-4df1-a647-a0a71f78d00e$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$例外ハンドラの対象指定$pb$, 3, $pb$fill_blank$pb$, $pb$TaskNotFoundException をまとめて処理したいです。
  空欄に入るアノテーションだけを答えてください。
  
  @ControllerAdvice
  public class GlobalExceptionHandler {
  
      __________
      public ResponseEntity<String> handleTaskNotFound(TaskNotFoundException e) {
          return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
      }
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$特定の例外クラスをハンドラメソッドに結びつけます。$pb$, $pb$@ExceptionHandler(TaskNotFoundException.class)$pb$, $pb$@ExceptionHandler を付けると、その例外が発生したときにこのメソッドでレスポンスを組み立てられます。$pb$, $pb$@ControllerAdvice を付けただけでは、どの例外をどのメソッドで処理するかまでは決まりません。$pb$, 903, TRUE),
  ($pb$ab7dcf72-f232-4729-a0d2-f970f12ccb72$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$最大文字数のバリデーション$pb$, 2, $pb$fill_blank$pb$, $pb$タイトルを50文字以内に制限したいです。
  空欄に入るアノテーションだけを答えてください。
  
  public class CreateTaskRequest {
      __________
      private String title;
  }$pb$, $pb$message 付きで最大50文字を表現してください。$pb$, $pb$文字列の長さ制限には Size を使います。$pb$, $pb$@Size(max = 50, message = "title must be at most 50 characters")$pb$, $pb$@Size は文字列の最小文字数・最大文字数を指定できる代表的なバリデーションです。$pb$, $pb$@NotBlank は必須チェックであって、文字数上限までは見てくれません。$pb$, 904, TRUE),
  ($pb$adabb9af-53d8-4eab-a1eb-1ca8ca00d41e$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$例外アドバイスの基本アノテーション$pb$, 1, $pb$fill_blank$pb$, $pb$例外処理を1か所にまとめるクラスを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  __________
  public class GlobalExceptionHandler {
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$複数のControllerで共通化したいときに使うアノテーションです。$pb$, $pb$@ControllerAdvice$pb$, $pb$@ControllerAdvice を付けると、複数のControllerに共通する例外処理を1か所へまとめられます。$pb$, $pb$@RestController を付けても例外処理の共通化クラスにはなりません。$pb$, 905, TRUE),
  ($pb$a6c1797f-bb32-4a36-abe6-0fcefd6b7969$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$404 Not Found を返すreturn文$pb$, 2, $pb$fill_blank$pb$, $pb$TaskNotFoundException を受けたときに 404 を返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  @ExceptionHandler(TaskNotFoundException.class)
  public ResponseEntity<String> handleTaskNotFound(TaskNotFoundException e) {
      return __________;
  }$pb$, $pb$HttpStatus.NOT_FOUND と e.getMessage() を使ってください。$pb$, $pb$ResponseEntity でステータスコードと本文を同時に返します。$pb$, $pb$ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage())$pb$, $pb$ResponseEntity.status(...).body(...) を使うと、エラー時のHTTPステータスと本文を明示できます。$pb$, $pb$ok() を使うと 200 OK になってしまい、エラーであることがクライアントに伝わりません。$pb$, 906, TRUE),
  ($pb$2854616f-28c7-4753-a446-f08f5e27edd7$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$nullを禁止するバリデーション$pb$, 1, $pb$fill_blank$pb$, $pb$id が null でないことだけを保証したいです。
  空欄に入るアノテーションだけを答えてください。
  
  public class UpdateTaskRequest {
      __________
      private Long id;
  }$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$空文字ではなく null そのものを禁止したい場面です。$pb$, $pb$@NotNull$pb$, $pb$@NotNull は null を禁止する最も基本的なバリデーションです。$pb$, $pb$@NotBlank は String 向けなので、Long に使うのは不自然です。$pb$, 907, TRUE),
  ($pb$71e4f8e3-5d3f-4344-a52d-22e182339703$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$最小文字数と最大文字数をまとめて指定する$pb$, 2, $pb$fill_blank$pb$, $pb$タイトルを1文字以上50文字以下に制限したいです。
  空欄に入るアノテーションだけを答えてください。
  
  public class CreateTaskRequest {
      __________
      private String title;
  }$pb$, $pb$message なしで構いません。$pb$, $pb$Size は min と max を同時に指定できます。$pb$, $pb$@Size(min = 1, max = 50)$pb$, $pb$@Size(min = 1, max = 50) と書くと、文字数の下限と上限を一度に指定できます。$pb$, $pb$@NotBlank だけでは最大文字数の制御まではできません。$pb$, 908, TRUE),
  ($pb$b14a1f1f-3639-4a1e-a606-d7ff26fef6b9$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$BindingResultを受け取る$pb$, 2, $pb$fill_blank$pb$, $pb$バリデーション結果をメソッド引数で受け取りたいです。
  空欄に入る引数だけを答えてください。
  
  @PostMapping
  public ResponseEntity<Void> create(@Valid @RequestBody CreateTaskRequest request, __________) {
      return ResponseEntity.ok().build();
  }$pb$, $pb$空欄には引数1つ分だけを書いてください。$pb$, $pb$バリデーションエラーを後続処理で確認するときに使います。$pb$, $pb$BindingResult bindingResult$pb$, $pb$BindingResult を使うと、バリデーションエラーの有無や内容をメソッド内で確認できます。$pb$, $pb$BindingResult は @Valid の直後に置くのが基本です。$pb$, 909, TRUE),
  ($pb$3c912eda-1fbd-4fe2-af98-5aa2203856d2$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$バリデーションエラーの有無を確認する$pb$, 2, $pb$fill_blank$pb$, $pb$BindingResult にエラーがあるか確認したいです。
  空欄に入る条件式だけを答えてください。
  
  if (__________) {
      return ResponseEntity.badRequest().build();
  }$pb$, $pb$bindingResult を使った条件式を書いてください。$pb$, $pb$エラーがあるかどうかをそのまま返すメソッドがあります。$pb$, $pb$bindingResult.hasErrors()$pb$, $pb$hasErrors() は、BindingResult に1件でもエラーがあるかを調べる基本メソッドです。$pb$, $pb$isEmpty() のようなメソッドは BindingResult にはありません。$pb$, 910, TRUE),
  ($pb$e14fefdf-827d-44e5-a53d-845851789b94$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$カスタムバリデーション用のアノテーションを付ける$pb$, 3, $pb$fill_blank$pb$, $pb$独自に作った TaskTitle アノテーションで title を検証したいです。
  空欄に入るアノテーションだけを答えてください。
  
  public class CreateTaskRequest {
      __________
      private String title;
  }$pb$, $pb$TaskTitle というカスタムアノテーションを付けてください。$pb$, $pb$独自に定義した制約アノテーションをそのままフィールドに付けます。$pb$, $pb$@TaskTitle$pb$, $pb$カスタムバリデーションは、作成済みの独自アノテーションをフィールドへ付けて使います。$pb$, $pb$@TaskTitleValidator のように、Validatorクラス名をそのまま付けるわけではありません。$pb$, 911, TRUE),
  ($pb$1125f20d-36d5-4d21-acd4-500846b9f8bb$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$カスタム例外クラスの継承元$pb$, 1, $pb$fill_blank$pb$, $pb$TaskNotFoundException を実行時例外として作りたいです。
  空欄に入る継承元だけを答えてください。
  
  public class TaskNotFoundException extends __________ {
  }$pb$, $pb$空欄には型名だけを書いてください。$pb$, $pb$チェック例外にしたくないので、実行時例外を使います。$pb$, $pb$RuntimeException$pb$, $pb$RuntimeException を継承すると、呼び出し側へ throws を強制しないカスタム例外になります。$pb$, $pb$Exception を継承すると、毎回 throws / try-catch を強制しやすくなります。$pb$, 951, TRUE),
  ($pb$b16d18ae-22ec-4903-a9f8-06e511952ef1$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$例外コンストラクタのsuper呼び出し$pb$, 1, $pb$fill_blank$pb$, $pb$TaskNotFoundException のコンストラクタでメッセージを親クラスへ渡したいです。
  空欄に入る1行だけを答えてください。
  
  public TaskNotFoundException(String message) {
      __________
  }$pb$, $pb$message を親クラスへ渡してください。$pb$, $pb$例外メッセージは親の RuntimeException に保持させます。$pb$, $pb$super(message);$pb$, $pb$super(message) と書くと、例外メッセージを RuntimeException 側へ渡せます。$pb$, $pb$this.message = message のように自前で保持すると、例外標準の仕組みを活かせません。$pb$, 952, TRUE),
  ($pb$ba1fca49-ad66-4d58-ae7b-d7a94711aafa$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$バリデーション例外を受けるアノテーション$pb$, 2, $pb$fill_blank$pb$, $pb$MethodArgumentNotValidException を処理するハンドラを作りたいです。
  空欄に入るアノテーションだけを答えてください。
  
  @ControllerAdvice
  public class GlobalExceptionHandler {
  
      __________
      public ResponseEntity<String> handleValidation(MethodArgumentNotValidException e) {
          return ResponseEntity.badRequest().body("validation error");
      }
  }$pb$, $pb$対象例外クラスを指定してください。$pb$, $pb$TaskNotFoundException のときと同じ書き方で、例外クラスだけ変わります。$pb$, $pb$@ExceptionHandler(MethodArgumentNotValidException.class)$pb$, $pb$@ExceptionHandler(例外クラス.class) で、どの例外をこのメソッドが受けるかを指定できます。$pb$, $pb$"@ExceptionHandler(MethodArgumentNotValidException)" のように .class を忘れると文法上成立しません。$pb$, 953, TRUE),
  ($pb$b2d3f592-7642-4c81-aac5-07ba747292fa$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$エラーレスポンスDTOの定義$pb$, 2, $pb$fill_blank$pb$, $pb$errorCode と message を持つエラーレスポンスDTOを record で定義したいです。
  空欄に入る1行だけを答えてください。
  
  __________$pb$, $pb$ErrorResponse という名前で1行定義してください。$pb$, $pb$通常のレスポンスDTOと同じく record が使えます。$pb$, $pb$public record ErrorResponse(String errorCode, String message) {}$pb$, $pb$エラー時専用の DTO を分けておくと、クライアント側が扱いやすいレスポンス構造になります。$pb$, $pb$Map をその場で返すより、型を作っておく方が後から見ても意味が分かりやすいです。$pb$, 954, TRUE),
  ($pb$9d20be6c-8374-4b5d-aeae-8b090d58ac2f$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$例外ハンドラでエラーレスポンスを返す$pb$, 3, $pb$fill_blank$pb$, $pb$TaskNotFoundException のハンドラで ErrorResponse を返したいです。
  空欄に入る return の右辺だけを答えてください。
  
  @ExceptionHandler(TaskNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleTaskNotFound(TaskNotFoundException e) {
      return __________;
  }$pb$, $pb$404 と ErrorResponse("TASK_NOT_FOUND", e.getMessage()) を使ってください。$pb$, $pb$ResponseEntity.status(...).body(...) の形です。$pb$, $pb$ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorResponse("TASK_NOT_FOUND", e.getMessage()))$pb$, $pb$例外ハンドラで専用DTOを返すと、エラー時のレスポンス形式を統一しやすくなります。$pb$, $pb$文字列だけ返すと、エラーコードのような機械判定向け情報を持たせにくくなります。$pb$, 955, TRUE),
  ($pb$e5badae9-edef-4661-a2b5-05f313b4f346$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$GET詳細取得エンドポイントを実装する$pb$, 2, $pb$normal$pb$, $pb$TaskController に、id を受け取って TaskResponse を返す GET エンドポイントを実装してください。$pb$, $pb$メソッド名は getTask とすること。
  @PathVariable Long id を受け取ること。
  service.getTask(id) の結果を返すこと。
  @GetMapping("/{id}") を付けること。$pb$, $pb$Controller は薄く保ち、実際の取得処理は service に委譲します。$pb$, $pb$@GetMapping("/{id}")
  public TaskResponse getTask(@PathVariable Long id) {
      return taskService.getTask(id);
  }$pb$, $pb$Spring Boot の Controller では、URLから受け取った値を引数で受け、サービス層へ処理を委譲する形が基本です。$pb$, $pb$Controller の中で直接 repository を呼び始めると、責務が混ざりやすくなります。$pb$, 956, TRUE),
  ($pb$b2599880-b237-4b2c-ada9-89762973110e$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$削除エンドポイントを実装する$pb$, 2, $pb$normal$pb$, $pb$TaskController に、id 指定でタスクを削除する DELETE エンドポイントを実装してください。$pb$, $pb$メソッド名は deleteTask とすること。
  @PathVariable Long id を受け取ること。
  service.delete(id) を呼ぶこと。
  戻り値は ResponseEntity<Void> とし、204 No Content を返すこと。$pb$, $pb$本文を返さない成功レスポンスには noContent().build() が使えます。$pb$, $pb$@DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
      taskService.delete(id);
      return ResponseEntity.noContent().build();
  }$pb$, $pb$削除成功時は本文なしの 204 No Content を返すと、APIの意図が分かりやすくなります。$pb$, $pb$200 OK を返しても動きますが、削除成功としては 204 の方が意味が伝わりやすいです。$pb$, 957, TRUE),
  ($pb$eb585cad-aa95-4224-aeb1-ee123ceaccb8$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$作成用リクエストDTOを定義する$pb$, 2, $pb$normal$pb$, $pb$タイトルと説明文を受け取る CreateTaskRequest を record で定義してください。$pb$, $pb$クラス名は CreateTaskRequest とすること。
  title と description を持つこと。
  record を使うこと。$pb$, $pb$Spring Boot のシンプルな入力DTOは record で十分なことが多いです。$pb$, $pb$public record CreateTaskRequest(String title, String description) {
  }$pb$, $pb$record を使うと、入力を受け取るだけの DTO を短く定義できます。$pb$, $pb$getter やコンストラクタを自分で長く書き始めると、シンプルなDTOの利点が減ってしまいます。$pb$, 958, TRUE),
  ($pb$3a589378-cbc9-4b3b-a688-f7df2805fc36$pb$, $pb$afb2ceda-9159-4b65-af2c-413d6f7e6c3e$pb$, $pb$EntityからDTOへ変換するfromメソッドを実装する$pb$, 2, $pb$normal$pb$, $pb$TaskResponse に、Task エンティティから DTO を作る from メソッドを実装してください。$pb$, $pb$public static TaskResponse from(Task task) とすること。
  Task の id と title を TaskResponse に詰め替えること。$pb$, $pb$static factory にしておくと、呼び出し側で map(TaskResponse::from) と書きやすくなります。$pb$, $pb$public static TaskResponse from(Task task) {
      return new TaskResponse(task.getId(), task.getTitle());
  }$pb$, $pb$Entity をそのまま返さず DTO へ変換することで、APIが外へ見せる項目をコントロールしやすくなります。$pb$, $pb$DTO 変換ロジックをあちこちに散らすと、項目変更時の修正漏れが起きやすくなります。$pb$, 959, TRUE),
  ($pb$5e5986a6-9d8a-4746-a528-5f37bf32810d$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$ID検索してDTOを返すServiceメソッドを実装する$pb$, 3, $pb$normal$pb$, $pb$TaskService に、id でタスクを取得して TaskResponse を返す getTask メソッドを実装してください。$pb$, $pb$引数は Long id とすること。
  repository.findById(id) を使うこと。
  見つからない場合は TaskNotFoundException(id) を投げること。
  見つかった Task は TaskResponse.from(task) で返すこと。$pb$, $pb$Optional から値を取り出すときは orElseThrow が便利です。$pb$, $pb$public TaskResponse getTask(Long id) {
      Task task = taskRepository.findById(id)
          .orElseThrow(() -> new TaskNotFoundException(id));
      return TaskResponse.from(task);
  }$pb$, $pb$Service 層では検索、例外化、DTO 変換の流れをまとめて扱うことが多いです。$pb$, $pb$null を返してしまうと、呼び出し側へ責務が漏れて Controller 側の分岐が増えやすくなります。$pb$, 960, TRUE),
  ($pb$3379f03b-5090-45fc-a66f-01316cbe8310$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$作成処理をServiceへ移す$pb$, 3, $pb$normal$pb$, $pb$CreateTaskRequest を受け取り、Task を保存して TaskResponse を返す create メソッドを TaskService に実装してください。$pb$, $pb$引数は CreateTaskRequest request とすること。
  new Task(request.title(), request.description()) で生成すること。
  repository.save(task) を使うこと。
  保存後は TaskResponse.from(saved) で返すこと。$pb$, $pb$Controller ではなく Service に作成処理を置くと責務が整理しやすくなります。$pb$, $pb$public TaskResponse create(CreateTaskRequest request) {
      Task task = new Task(request.title(), request.description());
      Task saved = taskRepository.save(task);
      return TaskResponse.from(saved);
  }$pb$, $pb$作成処理は Service に置き、Controller は入出力の受け渡しに寄せる方が保守しやすいです。$pb$, $pb$Controller の中で Entity を組み立て始めると、層の役割が曖昧になりやすくなります。$pb$, 961, TRUE),
  ($pb$ff6cf6b8-2a74-4ec0-a44b-432e65ebd7fa$pb$, $pb$f78192ff-12b1-41c8-a1b8-a07acfa030d5$pb$, $pb$Repositoryに派生クエリを定義する$pb$, 2, $pb$normal$pb$, $pb$TaskRepository に、status で絞り込んだ一覧取得メソッドと title の部分一致検索メソッドを定義してください。$pb$, $pb$TaskRepository は JpaRepository<Task, Long> を継承している前提。
  findByStatus(String status) を書くこと。
  findByTitleContaining(String keyword) を書くこと。$pb$, $pb$Spring Data JPA はメソッド名からクエリを自動生成できます。$pb$, $pb$public interface TaskRepository extends JpaRepository<Task, Long> {
      List<Task> findByStatus(String status);
      List<Task> findByTitleContaining(String keyword);
  }$pb$, $pb$findByXxx や Containing を使った派生クエリは、初学者が最初に覚えやすい Spring Data JPA の強みです。$pb$, $pb$searchByTitle のような自由な命名にすると、自動派生クエリとして認識されません。$pb$, 962, TRUE),
  ($pb$d73a3b4f-c6ef-4d64-a608-368b0c836b6f$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$リクエストDTOへ入力バリデーションを付ける$pb$, 2, $pb$normal$pb$, $pb$CreateTaskRequest の title に、必須かつ最大50文字のバリデーションを付けてください。$pb$, $pb$title フィールドに @NotBlank を付けること。
  さらに @Size(max = 50) を付けること。
  record ではなく class で書いてよい。$pb$, $pb$必須と文字数上限は別アノテーションで表現します。$pb$, $pb$public class CreateTaskRequest {
      @NotBlank
      @Size(max = 50)
      private String title;
  }$pb$, $pb$入力検証は「必須」と「長さ上限」のように、意味ごとにアノテーションを分けて付けるのが基本です。$pb$, $pb$@NotBlank だけでは最大文字数は制御できません。$pb$, 963, TRUE),
  ($pb$07631258-e58b-4282-a8d0-0c1c61099511$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$Controllerで@Validを付けて受け取る$pb$, 2, $pb$normal$pb$, $pb$TaskController の作成エンドポイントで、CreateTaskRequest のバリデーションを有効にした状態で受け取るメソッドを実装してください。$pb$, $pb$メソッド名は createTask とすること。
  @PostMapping を付けること。
  引数で @Valid @RequestBody CreateTaskRequest request を受け取ること。
  service.create(request) の結果を返すこと。$pb$, $pb$DTO側のバリデーションは、Controller側で @Valid を付けて初めて実行されます。$pb$, $pb$@PostMapping
  public TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {
      return taskService.create(request);
  }$pb$, $pb$DTO に制約を書くだけでは不十分で、受け取り側で @Valid を付ける必要があります。$pb$, $pb$@RequestBody だけだと JSON 変換はされても、バリデーションは走りません。$pb$, 964, TRUE),
  ($pb$adec8bdd-525f-42ed-aa37-0d37bb0bd954$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$TaskNotFoundExceptionを404へ変換する$pb$, 3, $pb$normal$pb$, $pb$GlobalExceptionHandler に、TaskNotFoundException を受けて 404 の ErrorResponse を返すハンドラメソッドを実装してください。$pb$, $pb$@ExceptionHandler(TaskNotFoundException.class) を付けること。
  戻り値は ResponseEntity<ErrorResponse> とすること。
  本文には new ErrorResponse("TASK_NOT_FOUND", e.getMessage()) を返すこと。
  HTTPステータスは NOT_FOUND とすること。$pb$, $pb$ResponseEntity.status(HttpStatus.NOT_FOUND).body(...) の形です。$pb$, $pb$@ExceptionHandler(TaskNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleTaskNotFound(TaskNotFoundException e) {
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(new ErrorResponse("TASK_NOT_FOUND", e.getMessage()));
  }$pb$, $pb$例外を API 向けの統一レスポンスへ変換すると、クライアント側で扱いやすい失敗レスポンスになります。$pb$, $pb$文字列だけ返すと、エラーコードのような機械判定用の情報を含めにくくなります。$pb$, 965, TRUE),
  ($pb$d41d1f58-b31b-4246-af94-0ce1b9f1f387$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$更新API用のServiceメソッドを書く$pb$, 3, $pb$normal$pb$, $pb$`TaskUpdateRequest request` を受け取り、既存タスクを更新して `TaskResponse` を返す `update` メソッドを `TaskService` に書いてください。$pb$, $pb$引数は `Long id, TaskUpdateRequest request` とすること
  `findById(id)` と `orElseThrow` を使うこと
  タイトルと説明文を更新すること
  `save` 後に `TaskResponse.from(saved)` を返すこと$pb$, $pb$更新系でも、新規作成と同じく Service に処理を寄せて Controller は薄く保つのが基本です。$pb$, $pb$public TaskResponse update(Long id, TaskUpdateRequest request) {
      Task task = taskRepository.findById(id)
          .orElseThrow(() -> new TaskNotFoundException(id));
      task.setTitle(request.title());
      task.setDescription(request.description());
      Task saved = taskRepository.save(task);
      return TaskResponse.from(saved);
  }$pb$, $pb$研修では「既存データを取得して更新し、保存して DTO へ変換する」一連の流れを自力で書けるかがよく問われます。$pb$, $pb$更新なのに毎回 `new Task(...)` を作ると、既存データの変更ではなく新規作成に寄ってしまいます。$pb$, 966, TRUE),
  ($pb$c527a3af-8619-4f69-a1a0-d5d3543cdddd$pb$, $pb$9e1f2897-9c55-4956-a2f4-c91a668b5408$pb$, $pb$作成APIで201 Createdを返すControllerを書く$pb$, 3, $pb$normal$pb$, $pb$`CreateTaskRequest` を受け取り、作成成功時に `201 Created` で `TaskResponse` を返す `POST /tasks` の Controller メソッドを書いてください。$pb$, $pb$`@PostMapping` を使うこと
  引数に `@Valid @RequestBody CreateTaskRequest request` を取ること
  戻り値は `ResponseEntity<TaskResponse>` にすること
  `HttpStatus.CREATED` を使うこと$pb$, $pb$単に DTO を返すだけでなく、作成系らしいステータスコードまで含めて書く問題です。$pb$, $pb$@PostMapping
  public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody CreateTaskRequest request) {
      TaskResponse response = taskService.create(request);
      return ResponseEntity.status(HttpStatus.CREATED).body(response);
  }$pb$, $pb$研修では REST API の作成系で `201 Created` を返せるかどうかも見られやすいポイントです。$pb$, $pb$作成成功でも常に `200 OK` だけ返すと、API の意図が伝わりにくくなります。$pb$, 967, TRUE),
  ($pb$ebcf7c0a-d7b5-4aa3-ad97-870ffc474032$pb$, $pb$67956584-edf1-4756-a97a-cd999f0b546e$pb$, $pb$GET詳細が404になるときの確認点を書く$pb$, 3, $pb$normal$pb$, $pb$`GET /tasks/1` へアクセスすると 404 が返ってきます。最初に確認したいポイントを2つ書いてください。$pb$, $pb$Controller の `@GetMapping` と `@PathVariable` の対応を書くこと
  DB に該当 id のデータが存在するか、または `findById` の結果確認を書くこと$pb$, $pb$最初から複雑に考えず、「ルーティングが合っているか」と「データがあるか」を分けて確認します。$pb$, $pb$1. Controller の `@GetMapping("/{id}")` と `@PathVariable Long id` の対応が正しいか確認する
  2. `findById(1)` で対象データが実際に存在するか確認する$pb$, $pb$研修の不具合対応では、まず入口のルーティングとデータ存在確認を分けて見る癖が大切です。$pb$, $pb$いきなり細かいフレームワーク設定を疑うより、最初は URL 対応とデータ有無を押さえる方が精度が高いです。$pb$, 968, TRUE),
  ($pb$feffde49-76bb-4016-a01c-e177565e2016$pb$, $pb$81bcb1ab-2a07-4509-a924-62d40fdc187c$pb$, $pb$@RequestBody がなくて JSON を受け取れないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次の Controller では `POST /tasks` に JSON を送っても `title` が入ってきません。原因を直したメソッドを書いてください。
  
  ```java
  @PostMapping("/tasks")
  public TaskResponse createTask(CreateTaskRequest request) {
      return taskService.create(request);
  }
  ```$pb$, $pb$`@RequestBody` を追加すること
  必要なら `@Valid` も付けること
  メソッド全体を正しい形で書くこと$pb$, $pb$Spring Boot で JSON のリクエストボディを DTO に変換するときに必要なアノテーションを思い出してください。$pb$, $pb$@PostMapping("/tasks")
  public TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {
      return taskService.create(request);
  }$pb$, $pb$JSON を DTO にマッピングするには `@RequestBody` が必要です。入力チェックも行うなら `@Valid` を一緒に付けるのが自然です。$pb$, $pb$`@RequestParam` に変えてしまうと JSON 本文の受け取りにはなりません。POST の本文を読むケースでは `@RequestBody` を使います。$pb$, 969, TRUE),
  ($pb$baf9627d-313b-4419-ad96-5e6d3485ab81$pb$, $pb$acc2d4bc-fbbc-430d-a358-98df7842b311$pb$, $pb$findById().get() で落ちる Service のバグを直す$pb$, 3, $pb$normal$pb$, $pb$次の Service は、存在しない ID を指定すると例外で落ちます。`TaskNotFoundException` を投げるように修正したコードを書いてください。
  
  ```java
  public TaskResponse getTask(Long id) {
      Task task = taskRepository.findById(id).get();
      return TaskResponse.from(task);
  }
  ```$pb$, $pb$`findById` の戻り値を安全に扱うこと
  見つからないときは `TaskNotFoundException` を投げること
  最後に `TaskResponse.from(task)` を返すこと$pb$, $pb$Repository から 1 件取得するときは `Optional` をそのまま `.get()` せず、見つからない場合を明示的に処理するのが基本です。$pb$, $pb$public TaskResponse getTask(Long id) {
      Task task = taskRepository.findById(id)
          .orElseThrow(() -> new TaskNotFoundException(id));
      return TaskResponse.from(task);
  }$pb$, $pb$`findById(...).get()` はデータがないと `NoSuchElementException` になります。業務では意味のある例外に置き換えておく方が API の挙動が分かりやすくなります。$pb$, $pb$`null` を返してしまうと Controller 側で別の `NullPointerException` を生みやすくなります。見つからないケースはその場で例外に寄せる方が安全です。$pb$, 970, TRUE),
  ($pb$704286a5-c2e1-45a3-a784-80b66d0226e0$pb$, $pb$6f1c3b31-001b-4b85-a5cb-cf03ae1a4e59$pb$, $pb$@Valid を付け忘れてバリデーションが効かないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次の Controller では `CreateTaskRequest` に `@NotBlank` が付いていても入力チェックが動きません。修正後のメソッドを書いてください。
  
  ```java
  @PostMapping("/tasks")
  public TaskResponse createTask(@RequestBody CreateTaskRequest request) {
      return taskService.create(request);
  }
  ```$pb$, $pb$引数のどこを直すか明確にすること
  `@RequestBody` は残すこと
  必要ならメソッド全体を書き直してよい$pb$, $pb$DTO に付けたバリデーションを Controller で有効にするためのアノテーションを確認してください。$pb$, $pb$@PostMapping("/tasks")
  public TaskResponse createTask(@Valid @RequestBody CreateTaskRequest request) {
      return taskService.create(request);
  }$pb$, $pb$DTO 側に制約アノテーションがあっても、Controller 引数に `@Valid` がないと検証は実行されません。$pb$, $pb$DTO クラス側だけ見直しても Controller の受け口がそのままだと直りません。バリデーション開始の起点は引数の `@Valid` です。$pb$, 971, TRUE),
  ($pb$db0243c9-d6f0-4192-a035-8d1436818077$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2の正式名称$pb$, 1, $pb$fill_blank$pb$, $pb$EC2 の正式名称を答えてください。
  空欄に入る英語だけを答えてください。
  
  Amazon __________$pb$, $pb$空欄には2単語を書いてください。$pb$, $pb$仮想サーバーを提供する代表的なAWSサービスです。$pb$, $pb$Elastic Compute$pb$, $pb$EC2 は Amazon Elastic Compute Cloud の略で、仮想サーバーを起動できるサービスです。$pb$, $pb$Cloud まで含めた正式名称は Elastic Compute Cloud ですが、空欄は EC2 の E と C に対応する部分だけです。$pb$, 1101, TRUE),
  ($pb$4781f2be-b31e-460f-a4d4-92cebb668943$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2インスタンスへ接続するプロトコル$pb$, 1, $pb$fill_blank$pb$, $pb$Linux の EC2 インスタンスへリモート接続するときによく使うプロトコルを答えてください。
  空欄に入る略称だけを答えてください。
  
  __________ 接続$pb$, $pb$空欄には大文字の略称を書いてください。$pb$, $pb$22番ポートを使うことが多い接続方式です。$pb$, $pb$SSH$pb$, $pb$EC2 へ安全にリモート接続するときは SSH を使うのが基本です。$pb$, $pb$HTTP や HTTPS はWebアクセス用であり、サーバーへログインするための接続方式ではありません。$pb$, 1102, TRUE),
  ($pb$9aff55fb-ad18-4a26-a692-371411b9b16e$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$Web公開で開ける代表ポート$pb$, 1, $pb$fill_blank$pb$, $pb$HTTP でWebアプリを公開するとき、セキュリティグループで許可する代表的なポート番号を答えてください。
  
  ポート __________$pb$, $pb$空欄には数字だけを書いてください。$pb$, $pb$ブラウザで http:// から始まる通信に使います。$pb$, $pb$80$pb$, $pb$HTTP の標準ポートは 80 です。WebアプリをHTTP公開するときはこのポートを開けます。$pb$, $pb$443 は HTTPS 用の標準ポートであり、HTTP とは別です。$pb$, 1103, TRUE),
  ($pb$ea970eae-3695-463f-ae15-a41e11938a53$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$JavaアプリをEC2で起動するコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$task-app.jar を EC2 上で起動したいです。
  空欄に入るコマンド全体を答えてください。
  
  __________$pb$, $pb$jar ファイルを起動する基本コマンドを書いてください。$pb$, $pb$Javaのjar実行コマンドです。$pb$, $pb$java -jar task-app.jar$pb$, $pb$Spring Boot の jar は java -jar で起動するのが基本です。$pb$, $pb$javac はコンパイル用なので、すでに出来上がった jar の起動には使いません。$pb$, 1104, TRUE),
  ($pb$b536fc22-7e42-4793-ae8b-65f3becec7da$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2の公開IPを確認する目的$pb$, 2, $pb$fill_blank$pb$, $pb$EC2 の公開IPアドレスをブラウザから使うときのURLの形を答えてください。
  空欄に入る形式だけを答えてください。
  
  http://__________$pb$, $pb$EC2 の公開IPをそのまま使う形で答えてください。$pb$, $pb$例として 1.2.3.4 のようなIPを入れる場所です。$pb$, $pb$<public-ip>$pb$, $pb$公開IP を使うと、DNS未設定でもブラウザからアプリの疎通確認ができます。$pb$, $pb$localhost は自分のPCを指すため、EC2確認用のURLにはなりません。$pb$, 1105, TRUE),
  ($pb$0c54f422-0c0a-4bc9-a198-6bc702f45e94$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2インスタンスの起動単位$pb$, 2, $pb$fill_blank$pb$, $pb$AWS で仮想サーバー1台分を表す単位名を答えてください。
  
  EC2 __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$EC2でサーバーを作るときによく使う呼び方です。$pb$, $pb$instance$pb$, $pb$EC2 では仮想サーバー1台を instance と呼びます。$pb$, $pb$container は ECS や Docker 周辺で使う言葉で、EC2 の基本単位とは別です。$pb$, 1106, TRUE),
  ($pb$f88a8441-a41c-46c9-ab25-a27b69335cdb$pb$, $pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$S3の保存単位$pb$, 1, $pb$fill_blank$pb$, $pb$S3 でファイルを保存する入れ物の単位名を答えてください。
  
  S3 __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$フォルダではなく、S3特有の呼び方があります。$pb$, $pb$bucket$pb$, $pb$S3 は bucket という単位の中にオブジェクトを保存します。$pb$, $pb$folder のように見えても、S3の基本単位は bucket と object です。$pb$, 1201, TRUE),
  ($pb$0eaa7d33-2c44-4dca-aa5c-e52fc27e3e2c$pb$, $pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$S3に保存されるファイルの呼び方$pb$, 1, $pb$fill_blank$pb$, $pb$S3 に保存されるファイル1件を AWS では何と呼ぶか答えてください。
  
  S3 __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$バケットの中に保存される単位です。$pb$, $pb$object$pb$, $pb$S3 では保存されるデータ1件を object と呼びます。$pb$, $pb$record や file でも意味は通じますが、AWSの正式な用語では object です。$pb$, 1202, TRUE),
  ($pb$bb562c82-0259-400b-a9a7-d7767b73ae6c$pb$, $pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$S3で静的サイトを公開する設定名$pb$, 2, $pb$fill_blank$pb$, $pb$S3 バケットで HTML を公開する機能名を答えてください。
  
  Static Website __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$S3でWebページをそのまま配信する機能です。$pb$, $pb$Hosting$pb$, $pb$S3 には Static Website Hosting という機能があり、静的サイト公開に使えます。$pb$, $pb$Streaming は動画配信周辺で使う言葉で、静的サイト公開の正式名ではありません。$pb$, 1203, TRUE),
  ($pb$bdcc6251-60b4-4d39-a155-5d11f1b84ace$pb$, $pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$S3のアクセス制御でよく使う設定$pb$, 2, $pb$fill_blank$pb$, $pb$S3 オブジェクトへ誰がアクセスできるかを定義する代表的な仕組みを答えてください。
  
  __________ policy$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$バケット単位で付けることが多いです。$pb$, $pb$Bucket$pb$, $pb$S3 では bucket policy を使ってアクセス許可をまとめて制御することがよくあります。$pb$, $pb$Security group は EC2 や RDS のネットワーク制御で、S3のアクセス制御とは別です。$pb$, 1204, TRUE),
  ($pb$53fcb5e4-f24d-45a7-adb0-be56340347a5$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDSの正式名称$pb$, 1, $pb$fill_blank$pb$, $pb$RDS の正式名称を答えてください。
  
  Amazon Relational Database __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$RDS の S に対応する単語です。$pb$, $pb$Service$pb$, $pb$RDS は Amazon Relational Database Service の略です。$pb$, $pb$System ではなく Service です。$pb$, 1301, TRUE),
  ($pb$6ef8a94e-3b3d-4ae7-ad05-6ee16eccc188$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$Spring BootのDB接続URL先$pb$, 2, $pb$fill_blank$pb$, $pb$Spring Boot から RDS に接続するとき、application.properties の接続先プロパティ名を答えてください。
  
  spring.datasource.__________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$JDBC接続文字列を入れる場所です。$pb$, $pb$url$pb$, $pb$spring.datasource.url に RDS への JDBC URL を設定するのが基本です。$pb$, $pb$host だけでは接続文字列として不十分で、Spring Boot の標準プロパティ名とも違います。$pb$, 1302, TRUE),
  ($pb$18d4b10d-b0f7-49ff-ac54-91eebf65ca6a$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDS接続で必要な認証情報$pb$, 2, $pb$fill_blank$pb$, $pb$Spring Boot の RDS 接続設定で、ユーザー名を入れるプロパティ名を答えてください。
  
  spring.datasource.__________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$password と対になる設定です。$pb$, $pb$username$pb$, $pb$spring.datasource.username に DB ユーザー名を設定します。$pb$, $pb$user ではなく username が Spring Boot の標準プロパティ名です。$pb$, 1303, TRUE),
  ($pb$d7e350ff-00be-4f9f-a08b-1889e9593155$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDSを公開しすぎないための制御$pb$, 2, $pb$fill_blank$pb$, $pb$EC2 から RDS への通信許可をネットワークレベルで制御するとき、よく使うAWS機能を答えてください。
  
  Security __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$EC2でもRDSでも使う通信ルールです。$pb$, $pb$Group$pb$, $pb$RDS への接続元やポートの制御には Security Group を使うのが基本です。$pb$, $pb$IAM は誰が使えるかの制御であり、ネットワーク通信の許可ではありません。$pb$, 1304, TRUE),
  ($pb$4f2f54a9-63f4-4c0a-ad6c-cd1aeb90657e$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$JavaからDBへつなぐ標準API$pb$, 1, $pb$fill_blank$pb$, $pb$Java アプリから RDS のようなDBへ接続するときに使う標準APIを答えてください。
  
  __________ 接続$pb$, $pb$空欄には大文字の略称を書いてください。$pb$, $pb$Spring Boot の裏側でも使われている基本技術です。$pb$, $pb$JDBC$pb$, $pb$JDBC は Java Database Connectivity の略で、Java からDBへ接続する基本APIです。$pb$, $pb$JPA は永続化の抽象化であり、DB接続APIそのものの略称ではありません。$pb$, 1305, TRUE),
  ($pb$933ab74b-dac0-4686-ad4c-8bdcbb64126e$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$IAMの正式名称の末尾$pb$, 1, $pb$fill_blank$pb$, $pb$IAM の正式名称 Identity and Access Management の最後の単語を答えてください。
  
  Identity and Access __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$M に対応する単語です。$pb$, $pb$Management$pb$, $pb$IAM は Identity and Access Management の略です。$pb$, $pb$Manager ではなく Management です。$pb$, 1401, TRUE),
  ($pb$c7aba4b3-8e0a-48c8-a8a0-cb960c3a1061$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$IAMで権限の集合を表す単位$pb$, 1, $pb$fill_blank$pb$, $pb$IAM で許可・拒否の内容をまとめた設定単位を答えてください。
  
  IAM __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$JSONで書かれることが多いです。$pb$, $pb$policy$pb$, $pb$IAM の権限は policy として定義され、ユーザーやロールに付与されます。$pb$, $pb$group はユーザーのまとめ方であり、権限ルールそのものの名称ではありません。$pb$, 1402, TRUE),
  ($pb$c7ffdcf3-966f-425b-a0cd-7963069e6d66$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$EC2に付けるIAMの単位$pb$, 2, $pb$fill_blank$pb$, $pb$EC2 インスタンスに S3 参照権限を持たせたいです。
  このとき EC2 に関連付ける IAM の単位を答えてください。
  
  IAM __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$ユーザーではなく、AWSサービスに権限を渡すときに使います。$pb$, $pb$role$pb$, $pb$EC2 などのAWSサービスに権限を渡すときは IAM role を使うのが基本です。$pb$, $pb$access key をサーバー内へ直接置くより、role を使う方が安全です。$pb$, 1403, TRUE),
  ($pb$f66e15ad-41aa-4e63-ae34-4a9c275d3f2c$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$ログイン主体の基本単位$pb$, 1, $pb$fill_blank$pb$, $pb$AWS マネジメントコンソールへ人がログインする主体としてよく作る IAM の基本単位を答えてください。
  
  IAM __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$人に対して発行する単位です。$pb$, $pb$user$pb$, $pb$人がログインして操作する前提なら IAM user を使うことがあります。$pb$, $pb$role はサービスや一時的な権限移譲向けで、恒久的な人のアカウントとは役割が違います。$pb$, 1404, TRUE),
  ($pb$5764a5f1-166d-4d8b-a684-b1ddcf42f494$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$アクセスキーの組み合わせ$pb$, 2, $pb$fill_blank$pb$, $pb$プログラムから IAM ユーザーとして認証するとき、アクセスキーIDとセットで使う値を答えてください。
  
  Secret Access __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$ID と対になる秘密情報です。$pb$, $pb$Key$pb$, $pb$アクセスキーIDとSecret Access Keyを組み合わせて認証します。$pb$, $pb$Password はコンソールログイン向けであり、APIアクセス用の組み合わせとは別です。$pb$, 1405, TRUE),
  ($pb$a675fdf5-be4d-4cf1-ae18-304d58554487$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$Spring BootをAWSへ出す代表構成$pb$, 1, $pb$fill_blank$pb$, $pb$Spring Boot アプリ本体を置く代表的な AWS サービスを答えてください。
  
  アプリ本体: __________$pb$, $pb$空欄にはサービス名を書いてください。$pb$, $pb$仮想サーバーに jar を置いて動かす構成です。$pb$, $pb$EC2$pb$, $pb$学習初期の構成では、Spring Boot の jar を EC2 上で動かす形が分かりやすいです。$pb$, $pb$RDS はデータベース用であり、アプリ本体を動かすサービスではありません。$pb$, 1501, TRUE),
  ($pb$35a9dff4-a721-41ea-a4e3-8ee635d2fea9$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$データベースを置く代表構成$pb$, 1, $pb$fill_blank$pb$, $pb$Spring Boot アプリのデータベースをマネージドで置く代表的な AWS サービスを答えてください。
  
  データベース: __________$pb$, $pb$空欄にはサービス名を書いてください。$pb$, $pb$MySQL や PostgreSQL をマネージドで使えるサービスです。$pb$, $pb$RDS$pb$, $pb$アプリは EC2、DB は RDS という構成は初学者にも理解しやすい代表例です。$pb$, $pb$S3 はファイル保存向けであり、リレーショナルDBの置き場所ではありません。$pb$, 1502, TRUE),
  ($pb$e2a47b1e-c441-4fd8-a9a6-140e656ccfda$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$設定値を外へ出す管理方法$pb$, 2, $pb$fill_blank$pb$, $pb$DB接続情報のような環境ごとに変わる値をコードへ直書きせず管理したいです。
  空欄に入る方法名を答えてください。
  
  __________ 変数$pb$, $pb$空欄には2文字の英字ではなく、日本語の一般名称を書いてください。$pb$, $pb$OSや実行環境ごとに持たせられる値です。$pb$, $pb$環境$pb$, $pb$DB接続情報などは環境変数で外出しするのが基本です。$pb$, $pb$application.properties に直接本番パスワードを書くと、漏えい時の影響が大きくなります。$pb$, 1503, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;
INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$20e56d12-0af0-43b1-a57f-e7c11ccdeeba$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$アプリ疎通確認で見る先$pb$, 1, $pb$fill_blank$pb$, $pb$EC2 にアプリを配置したあと、まずブラウザで確認しやすいアクセス先を答えてください。
  
  http://<EC2の__________>$pb$, $pb$空欄には日本語1語を書いてください。$pb$, $pb$DNS未設定でも試しやすい確認先です。$pb$, $pb$公開IP$pb$, $pb$デプロイ直後の疎通確認では、まず EC2 の公開IP へアクセスするのが分かりやすいです。$pb$, $pb$プライベートIP はVPC内向けなので、手元のブラウザからは直接届きません。$pb$, 1504, TRUE),
  ($pb$b6071949-6db2-4752-a668-c44821472121$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$アプリログを追うLinuxコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$app.log の末尾を追いかけながらログ確認したいです。
  空欄に入るコマンド全体を答えてください。
  
  __________$pb$, $pb$Linuxでログ末尾を追う基本コマンドを書いてください。$pb$, $pb$リアルタイム監視でよく使うコマンドです。$pb$, $pb$tail -f app.log$pb$, $pb$tail -f を使うと、ログの末尾を追いかけながらアプリの挙動を確認できます。$pb$, $pb$cat だと一度表示するだけで追従できません。$pb$, 1505, TRUE),
  ($pb$5b6c5716-b301-41f9-aa3a-6affb02290b4$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$HTTPS公開で代表的に使うポート$pb$, 1, $pb$fill_blank$pb$, $pb$HTTPS で外部公開するとき、セキュリティグループで許可する代表的なポート番号を答えてください。
  
  ポート __________$pb$, $pb$空欄には数字だけを書いてください。$pb$, $pb$http ではなく https の標準ポートです。$pb$, $pb$443$pb$, $pb$HTTPS の標準ポートは 443 です。$pb$, $pb$80 は HTTP 用なので、HTTPS と混同しないようにします。$pb$, 1506, TRUE),
  ($pb$15a6d272-9059-4aa4-ab52-5d293d55e156$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$障害切り分けでまず見るAWS設定$pb$, 2, $pb$fill_blank$pb$, $pb$ブラウザからEC2へアクセスできないとき、まず確認したいネットワーク設定を答えてください。
  
  Security __________$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$ポート開放の確認で最優先です。$pb$, $pb$Group$pb$, $pb$外からアクセスできないときは、まず Security Group の受信ルールを確認するのが基本です。$pb$, $pb$IAM 権限だけを見ても、ネットワーク疎通の問題は解決しません。$pb$, 1507, TRUE),
  ($pb$4146fcd6-e7b0-43bf-aadc-60e210c28707$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$JAR配置でよく使う転送手段$pb$, 2, $pb$fill_blank$pb$, $pb$ローカルの task-app.jar を EC2 にコピーするとき、SSH系でよく使う転送コマンドの略称を答えてください。
  
  __________ 転送$pb$, $pb$空欄には大文字の略称を書いてください。$pb$, $pb$SSH の仲間として使われます。$pb$, $pb$SCP$pb$, $pb$SCP を使うと、ローカルファイルを EC2 へ安全にコピーできます。$pb$, $pb$FTP はクラウド学習の最初のEC2転送手段としてはあまり代表的ではありません。$pb$, 1508, TRUE),
  ($pb$29ce09eb-002e-48da-a265-80eea2ad2e93$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$Spring Bootの実行ユーザーで避けたいこと$pb$, 3, $pb$fill_blank$pb$, $pb$本番構成では、権限を持ちすぎた root でアプリを常時動かすのは避けたいです。
  空欄に入るユーザー名を答えてください。
  
  避けたい実行ユーザー: __________$pb$, $pb$空欄には英字1語を書いてください。$pb$, $pb$Linuxで最上位権限を持つユーザーです。$pb$, $pb$root$pb$, $pb$本番では root 常用を避け、必要最小限の権限でアプリを動かす方が安全です。$pb$, $pb$すぐ動くからといって root で全部済ませると、事故時の影響が大きくなります。$pb$, 1509, TRUE),
  ($pb$5520183b-5fea-4c82-a84c-bc9dd9d3d32b$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$アーキテクチャ全体の基本形$pb$, 3, $pb$fill_blank$pb$, $pb$Spring Boot 学習用の代表的な AWS 構成を「アプリ本体 + DB」の形で答えてください。
  
  __________ + __________$pb$, $pb$左にアプリ本体、右にDBサービスを書いてください。$pb$, $pb$一番基本の2サービス構成です。$pb$, $pb$EC2 + RDS$pb$, $pb$EC2 + RDS は、Spring Boot の学習で全体像を理解しやすい基本構成です。$pb$, $pb$S3 は静的ファイル保存に向いていますが、この2層の基本構成のDB枠には入りません。$pb$, 1510, TRUE),
  ($pb$1eb4ceae-fd5a-418b-a530-e9d177c1f051$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2で8080番ポートを公開する設定を書く$pb$, 2, $pb$normal$pb$, $pb$Spring Boot アプリを EC2 上で 8080 番ポートで公開したいです。セキュリティグループで追加するインバウンドルールを1つ書いてください。$pb$, $pb$TCP を指定すること
  ポート番号 8080 を指定すること
  公開元は学習用なので 0.0.0.0/0 と書いてよいこと$pb$, $pb$HTTP の 80 番ではなく、Spring Boot をそのまま起動したときの典型ポートを開ける問題です。$pb$, $pb$Type: Custom TCP
  Port range: 8080
  Source: 0.0.0.0/0$pb$, $pb$EC2 に直接 Spring Boot を載せる構成では、まずアプリが待ち受けているポートをセキュリティグループで開ける必要があります。$pb$, $pb$22 を開けるのは SSH 用で、ブラウザからアプリへアクセスするための設定とは別です。$pb$, 1511, TRUE),
  ($pb$41a575a9-15db-4fcd-a81f-7fa3a9854509$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDS接続用のapplication.propertiesを書く$pb$, 3, $pb$normal$pb$, $pb$Spring Boot から RDS(MySQL) に接続するための `application.properties` を3行だけ書いてください。ホスト名は `sample-db.ap-northeast-1.rds.amazonaws.com`、DB名は `task_app`、ユーザー名は `appuser`、パスワードは `secret123` とします。$pb$, $pb$`spring.datasource.url` を書くこと
  `spring.datasource.username` を書くこと
  `spring.datasource.password` を書くこと$pb$, $pb$JDBC URL は `jdbc:mysql://ホスト名:3306/DB名` の形です。$pb$, $pb$spring.datasource.url=jdbc:mysql://sample-db.ap-northeast-1.rds.amazonaws.com:3306/task_app
  spring.datasource.username=appuser
  spring.datasource.password=secret123$pb$, $pb$RDS 接続では URL・ユーザー名・パスワードの3点が最低限必要です。初学者のうちはまずこの形を確実に書けるのが大事です。$pb$, $pb$URL に `http://` を書くと Web URL になってしまい、JDBC 接続文字列としては誤りです。$pb$, 1512, TRUE),
  ($pb$622f7cdb-efda-4b93-a7bc-494bfc78172d$pb$, $pb$042157ee-7483-4892-a7ef-133f159326e9$pb$, $pb$S3で静的サイトを公開する最小手順を書く$pb$, 2, $pb$normal$pb$, $pb$HTML ファイルを S3 で静的公開したいです。最小手順を3つ、短く書いてください。$pb$, $pb$バケット作成を書くこと
  Static Website Hosting を有効化すること
  `index.html` をアップロードすること$pb$, $pb$CloudFront や Route 53 はまだ不要です。S3 単体で公開する最初の形を答えます。$pb$, $pb$1. S3 バケットを作成する
  2. Static Website Hosting を有効にする
  3. index.html をアップロードする$pb$, $pb$S3 の静的公開は、まず単体で動く最小構成を理解するとあとで CloudFront へ広げやすくなります。$pb$, $pb$EC2 を立てる必要はありません。S3 単体で静的ファイルを公開できます。$pb$, 1513, TRUE),
  ($pb$44760fb8-aaf8-425f-ac9e-ec0a9fac5ebb$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$EC2にS3読み取り権限を持たせるIAM設定を書く$pb$, 3, $pb$normal$pb$, $pb$EC2 上のアプリから S3 のファイルを読み取りたいです。アクセスキーを直接アプリに埋め込まずに実現したいとき、IAM でどう設定するか短く書いてください。$pb$, $pb$IAM ロールを使うこと
  S3 読み取り権限の policy を付けること
  そのロールを EC2 に関連付けること$pb$, $pb$学習用でもアクセスキー直書きより、ロールを使う構成を覚えておく方が安全です。$pb$, $pb$1. S3 読み取り権限を持つ IAM ロールを作成する
  2. そのロールに policy を付与する
  3. 作成したロールを EC2 インスタンスに関連付ける$pb$, $pb$EC2 から AWS サービスへアクセスするときは、アクセスキーを置くより IAM ロールを関連付ける構成が基本です。$pb$, $pb$IAM user のアクセスキーを `application.properties` に書く運用は、初学者でも早めに避けた方がよいです。$pb$, 1514, TRUE),
  ($pb$c5a9033d-3c6c-4d9e-a1e3-84f48f0dfb9f$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$Spring BootをAWSへ配置する基本構成を説明する$pb$, 2, $pb$normal$pb$, $pb$Spring Boot アプリ、DB、画像ファイル保存先を AWS で分けて置きたいです。どのサービスに置くかを1行ずつ書いてください。$pb$, $pb$Spring Boot アプリの配置先を書くこと
  DB の配置先を書くこと
  画像ファイル保存先を書くこと$pb$, $pb$学習用の基本構成は、アプリ・DB・ファイル保存を役割ごとに分けます。$pb$, $pb$アプリ本体: EC2
  データベース: RDS
  画像ファイル保存: S3$pb$, $pb$役割ごとに AWS サービスを分けて考えると、構成の理解がかなり整理されます。$pb$, $pb$S3 はファイル保存向けで、リレーショナル DB の代わりにはなりません。$pb$, 1515, TRUE),
  ($pb$784de90b-e59b-4702-ae1b-30112cb268ce$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2でSpring Bootをバックグラウンド起動するコマンドを書く$pb$, 3, $pb$normal$pb$, $pb$`task-app.jar` を EC2 上で SSH 切断後も動き続けるように起動したいです。よく使う Linux コマンドを1行で書いてください。$pb$, $pb$`nohup` を使うこと
  `java -jar task-app.jar` を含めること
  ログ出力先を書くこと$pb$, $pb$`&` を付けてバックグラウンド起動にします。$pb$, $pb$nohup java -jar task-app.jar > app.log 2>&1 &$pb$, $pb$学習用の単純構成では `nohup` でバックグラウンド起動する形をまず覚えると運用確認がしやすくなります。$pb$, $pb$`java -jar task-app.jar` だけだと SSH セッション終了で停止しやすく、確認にも向きません。$pb$, 1516, TRUE),
  ($pb$f1d72008-7816-4dc3-aeac-502e5fd7f401$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$SSH接続がタイムアウトするときの確認点を書く$pb$, 2, $pb$normal$pb$, $pb$EC2 に SSH 接続しようとするとタイムアウトします。最初に確認したいポイントを2つ書いてください。$pb$, $pb$セキュリティグループで 22 番ポートが開いているかを書くこと
  正しいキーペアを使っているか、または接続先IPが合っているかのどちらかを書くこと$pb$, $pb$初学者が最初に詰まりやすいのは、ネットワーク設定と接続情報のミスです。$pb$, $pb$1. セキュリティグループで SSH 用の 22 番ポートが開いているか確認する
  2. 接続先の公開 IP と使用しているキーペアが正しいか確認する$pb$, $pb$SSH タイムアウトは、アプリの問題より先にネットワーク到達性や接続情報の確認が重要です。$pb$, $pb$IAM 権限だけを見ても SSH タイムアウトは解決しません。まずはネットワークです。$pb$, 1517, TRUE),
  ($pb$58ccb637-42f9-4be6-a0da-7d619a1669f3$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$EC2からRDSへつながらないときの確認点を書く$pb$, 3, $pb$normal$pb$, $pb$EC2 上の Spring Boot から RDS へ接続できません。最初に確認したいポイントを2つ書いてください。$pb$, $pb$RDS 側のセキュリティグループ設定を書くこと
  `spring.datasource.url` など接続情報の確認を書くこと$pb$, $pb$DB 接続エラーは、ネットワーク設定と接続文字列の両方を見るのが基本です。$pb$, $pb$1. RDS のセキュリティグループで EC2 からの接続が許可されているか確認する
  2. `spring.datasource.url`、ユーザー名、パスワードが正しいか確認する$pb$, $pb$RDS 接続トラブルは、設定ファイルだけ見ても不足で、セキュリティグループも必ず確認します。$pb$, $pb$IAM policy は RDS への JDBC 接続可否とは直接別物なので、最初の確認点としては優先度が下がります。$pb$, 1518, TRUE),
  ($pb$2fb5a1a1-0dca-4760-a0d1-1542985fbb9c$pb$, $pb$053d1e65-edca-4ae5-a2dd-df7e8e976930$pb$, $pb$S3読み取りだけを許可するpolicyの要点を書く$pb$, 3, $pb$normal$pb$, $pb$特定バケットのファイルを読むだけ許可したいです。IAM policy の要点を2つ短く書いてください。$pb$, $pb$Action に `s3:GetObject` を入れること
  Resource に対象バケット配下を指定すること$pb$, $pb$学習用なので JSON 全文ではなく、どこをどう書くかがわかれば大丈夫です。$pb$, $pb$Action: s3:GetObject
  Resource: arn:aws:s3:::sample-bucket/*$pb$, $pb$IAM policy は「何を(Action)」「どこへ(Resource)」の組み合わせで考えると整理しやすいです。$pb$, $pb$`s3:*` のように広く許可しすぎると、学習初期でも最小権限の考え方が身につきにくくなります。$pb$, 1519, TRUE),
  ($pb$f97a0b27-9904-4030-a8eb-cfc760c76c74$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$デプロイ直後に確認する項目を書く$pb$, 2, $pb$normal$pb$, $pb$Spring Boot アプリを EC2 へデプロイした直後に、最低限確認したい項目を3つ書いてください。$pb$, $pb$URL へアクセスして画面または API 応答を確認すること
  アプリログを確認すること
  DB 接続または主要機能を1つ動かして確認すること$pb$, $pb$「起動したはず」で終わらせず、見える確認を入れるのが大事です。$pb$, $pb$1. ブラウザや API クライアントで URL にアクセスして応答を確認する
  2. `tail -f app.log` などでアプリログを確認する
  3. DB を使う機能を1つ実行して接続できているか確認する$pb$, $pb$デプロイ確認は、起動確認だけでなく、通信・ログ・DB の3点を見ると不具合の見落としが減ります。$pb$, $pb$画面が開いたことだけで成功判定すると、DB エラーや一部機能の不具合を見逃しやすいです。$pb$, 1520, TRUE),
  ($pb$91a5b0a4-70a3-4c31-a817-f5f3f2a276fb$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$JAR配備から起動確認までの手順を書く$pb$, 3, $pb$normal$pb$, $pb$ローカルで作った `task-app.jar` を EC2 へ配置し、起動してログ確認するまでの流れを4手順で書いてください。$pb$, $pb$`scp` でファイル転送すること
  `ssh` で接続すること
  `nohup java -jar ...` で起動すること
  `tail -f app.log` でログ確認すること$pb$, $pb$研修では「画面を作る」だけでなく、サーバへ持っていって動かす流れもよく確認されます。$pb$, $pb$1. `scp task-app.jar ec2-user@<public-ip>:/home/ec2-user/` で JAR を転送する
  2. `ssh ec2-user@<public-ip>` で EC2 へ接続する
  3. `nohup java -jar task-app.jar > app.log 2>&1 &` で起動する
  4. `tail -f app.log` で起動ログを確認する$pb$, $pb$デプロイの最小手順を言語化できると、研修での手順抜けや詰まりをかなり減らせます。$pb$, $pb$JAR を転送しただけで完了と考えると、起動確認とログ確認が抜けやすくなります。$pb$, 1521, TRUE),
  ($pb$08626e9f-0f40-42a2-a029-83495b2bcd1b$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2上のアプリへブラウザ接続できないときの確認点を書く$pb$, 3, $pb$normal$pb$, $pb$Spring Boot を EC2 で起動したのに、ブラウザから `http://<public-ip>:8080` へアクセスできません。最初に確認したいポイントを3つ書いてください。$pb$, $pb$アプリが起動しているか、またはログ確認を書くこと
  8080 ポートのセキュリティグループ確認を書くこと
  公開 IP や URL が正しいか確認を書くこと$pb$, $pb$「アプリ」「ネットワーク」「アクセス先」の3つへ分けて見ると整理しやすいです。$pb$, $pb$1. `app.log` やプロセス確認で Spring Boot が実際に起動しているか確認する
  2. セキュリティグループで 8080 ポートが許可されているか確認する
  3. ブラウザでアクセスしている公開 IP とポート番号が正しいか確認する$pb$, $pb$AWS の接続不具合は、アプリ本体・ネットワーク・URL のどこで止まっているかを切り分けるのが基本です。$pb$, $pb$いきなり IAM 権限だけを見ると、本当に多い原因であるポート未開放や URL ミスを見逃しやすくなります。$pb$, 1522, TRUE),
  ($pb$60aaac84-96f1-4340-a1ae-e03a42925a59$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDS接続失敗の切り分け手順を書く$pb$, 3, $pb$normal$pb$, $pb$EC2 上の Spring Boot から RDS へ接続するとエラーになります。最初に確認したいポイントを3つ書いてください。$pb$, $pb$RDS 側のセキュリティグループ確認を書くこと
  `spring.datasource.url` など接続情報確認を書くこと
  RDS のエンドポイントや DB 状態確認を書くこと$pb$, $pb$DB 接続では「接続情報」「到達性」「DB 側の状態」の3つを見ると精度が上がります。$pb$, $pb$1. RDS のセキュリティグループで EC2 からの接続が許可されているか確認する
  2. `spring.datasource.url`、ユーザー名、パスワードが正しいか確認する
  3. RDS のエンドポイント名と DB インスタンスの状態が正しいか確認する$pb$, $pb$RDS 接続エラーは、設定ファイルだけではなくネットワーク許可と DB 自体の状態確認までセットで行うのが実践的です。$pb$, $pb$コードだけを見続けると、実際にはセキュリティグループや接続先ホスト名のミスだった、という定番パターンを逃しやすいです。$pb$, 1523, TRUE),
  ($pb$5a6aed20-75c3-4e8e-a36f-27fc9b90bb07$pb$, $pb$88324998-3702-4e01-a0c1-7acc45425485$pb$, $pb$EC2 上のアプリにブラウザ接続できないバグを切り分ける$pb$, 3, $pb$normal$pb$, $pb$Spring Boot アプリを EC2 に配置して起動できたつもりですが、`http://<public-ip>:8080` へアクセスしてもブラウザがタイムアウトします。まず確認するポイントを 3 つ書いてください。$pb$, $pb$アプリ自体の起動確認を 1 つ書くこと
  セキュリティグループを 1 つ書くこと
  URL や接続先の確認を 1 つ書くこと$pb$, $pb$「アプリが動いているか」「ポートが開いているか」「見に行く先が正しいか」の 3 つに分けると整理しやすいです。$pb$, $pb$1. `java -jar` のログや `app.log` を見て、Spring Boot が正常起動しているか確認する。
  2. EC2 のセキュリティグループで 8080 番ポートが許可されているか確認する。
  3. ブラウザでアクセスしている公開 IP とポート番号が正しいか確認する。$pb$, $pb$EC2 上の接続トラブルは、アプリ未起動・ポート未開放・接続先間違いの 3 パターンが特に多いです。$pb$, $pb$いきなり IAM 権限だけを疑うのは遠回りです。まずはブラウザ接続に直結するネットワークと起動状態から確認します。$pb$, 1524, TRUE),
  ($pb$00d20323-587e-4d50-a996-fa4e87e468d6$pb$, $pb$12e67569-e0a2-4eb4-af9b-f770cdc82f32$pb$, $pb$RDS に接続できないときの設定ミスを切り分ける$pb$, 3, $pb$normal$pb$, $pb$EC2 上の Spring Boot アプリから RDS に接続しようとするとエラーになります。設定ミスとして最初に確認したいポイントを 3 つ書いてください。$pb$, $pb$セキュリティグループの確認を含めること
  JDBC URL の確認を含めること
  ユーザー名・パスワードまたは DB 名の確認を含めること$pb$, $pb$DB 接続は「ネットワーク」「接続文字列」「認証情報」に分けて考えると原因を追いやすいです。$pb$, $pb$1. RDS 側のセキュリティグループで、EC2 からの接続が許可されているか確認する。
  2. `spring.datasource.url` のホスト名・ポート・DB 名が正しいか確認する。
  3. `spring.datasource.username` と `spring.datasource.password` が正しいか確認する。$pb$, $pb$RDS 接続失敗はコードそのものより、接続先の設定やネットワーク許可のずれで起きることが多いです。$pb$, $pb$JAR を再配置する前に、まず接続設定の基本 3 点を見た方が早いです。コードだけ見ていると原因を見落としやすくなります。$pb$, 1525, TRUE),
  ($pb$ebd6e787-a14b-47aa-aa47-077e6c9b9e46$pb$, $pb$2ede7b4a-06c2-48c5-a9d8-2fe45d29469d$pb$, $pb$古い JAR を起動していて修正が反映されないバグを見抜く$pb$, 3, $pb$normal$pb$, $pb$コードを直して JAR をアップロードしたつもりなのに、EC2 で動かすと古い挙動のままです。原因確認として行う操作を 3 つ書いてください。$pb$, $pb$新しい JAR が配置されたか確認すること
  起動中プロセスの確認を含めること
  再起動またはログ確認の観点を含めること$pb$, $pb$デプロイでは「ファイルが置き換わったか」「古いプロセスが残っていないか」「新しい起動が成功したか」を見ると整理できます。$pb$, $pb$1. EC2 上で JAR の配置先と更新日時を確認して、新しいファイルが置かれているか確かめる。
  2. `ps` などで古い Java プロセスが残っていないか確認する。
  3. 新しい JAR を起動し直し、ログを見て想定したバージョンのアプリが起動しているか確認する。$pb$, $pb$デプロイ後に修正が反映されないときは、コードよりも「古い成果物」「古いプロセス」「起動失敗」のどれかであることが多いです。$pb$, $pb$アップロードしたつもりでも別ディレクトリに置いていることがあります。まず配置先と実際に動いているプロセスを対応付けて確認します。$pb$, 1526, TRUE),
  ($pb$dde7bc04-8b28-4c5e-afcb-3aa187996484$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$画面を持たない基本Widget$pb$, 1, $pb$fill_blank$pb$, $pb$状態を持たない画面部品を作る基本クラス名を答えてください。
  
  __________$pb$, $pb$空欄にはクラス名だけを書いてください。$pb$, $pb$StatefulWidget と対になる基本Widgetです。$pb$, $pb$StatelessWidget$pb$, $pb$状態を持たないUI部品は StatelessWidget を継承して作るのが基本です。$pb$, $pb$StatefulWidget は状態を持つ前提のときに使うので、役割が違います。$pb$, 2101, TRUE),
  ($pb$6f5cb2bf-3015-449a-a710-2f669e28b4e5$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$状態を持つ基本Widget$pb$, 1, $pb$fill_blank$pb$, $pb$状態を持つ画面部品を作る基本クラス名を答えてください。
  
  __________$pb$, $pb$空欄にはクラス名だけを書いてください。$pb$, $pb$StatelessWidget と対になるもう一方です。$pb$, $pb$StatefulWidget$pb$, $pb$画面内で値が変わる場合は StatefulWidget を継承して作るのが基本です。$pb$, $pb$状態が変わるのに StatelessWidget を選ぶと、更新ロジックを自然に書きにくくなります。$pb$, 2102, TRUE),
  ($pb$e3974aed-62b9-47d9-add0-fa811c56cb3c$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$Widgetを返す基本メソッド$pb$, 1, $pb$fill_blank$pb$, $pb$Flutter でUIを組み立てる基本メソッド名を答えてください。
  
  __________ メソッド$pb$, $pb$空欄には1語だけを書いてください。$pb$, $pb$BuildContext を引数に受け取ることが多いです。$pb$, $pb$build$pb$, $pb$build メソッドの中でWidgetツリーを返して画面を構築します。$pb$, $pb$render のような名前ではなく、Flutter では build が基本です。$pb$, 2103, TRUE),
  ($pb$bc97d02b-74ae-4300-a20d-977c027a6c78$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$文字を表示するWidget$pb$, 1, $pb$fill_blank$pb$, $pb$「Hello」を画面に表示する基本Widget名を答えてください。
  
  __________("Hello")$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$最も基本的な表示用Widgetです。$pb$, $pb$Text$pb$, $pb$文字列を画面に表示するときは Text Widget を使います。$pb$, $pb$Label ではなく Text がFlutterの基本Widget名です。$pb$, 2104, TRUE),
  ($pb$f2a6272d-3541-4409-ae3e-4fc091a0be17$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$箱として使う基本Widget$pb$, 1, $pb$fill_blank$pb$, $pb$余白や背景色を付けた箱として使いやすい基本Widget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$大きさや色も設定しやすいWidgetです。$pb$, $pb$Container$pb$, $pb$Container は余白・色・サイズなどをまとめて扱いやすい基本Widgetです。$pb$, $pb$Box という名前の基本Widgetはありません。$pb$, 2105, TRUE),
  ($pb$daa5ba53-5ba5-4f78-a811-f0f58fb803fe$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$縦方向に並べるWidget$pb$, 1, $pb$fill_blank$pb$, $pb$子Widgetを縦方向に並べる基本Widget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$横並びの Row と対になるWidgetです。$pb$, $pb$Column$pb$, $pb$複数のWidgetを縦方向へ並べたいときは Column を使います。$pb$, $pb$縦並びなのに Row を使うと、レイアウト方向が逆になります。$pb$, 2106, TRUE),
  ($pb$79d1726b-adcf-4355-ac2d-6e2cb771736f$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$横方向に並べるWidget$pb$, 1, $pb$fill_blank$pb$, $pb$子Widgetを横方向に並べる基本Widget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$縦並びの Column と対になるWidgetです。$pb$, $pb$Row$pb$, $pb$複数のWidgetを横方向へ並べるときは Row を使います。$pb$, $pb$Column と混同しやすいですが、Row は横方向です。$pb$, 2107, TRUE),
  ($pb$5dd81ff3-87c9-4ddc-ab63-ed109762a7a4$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$基本画面の土台となるWidget$pb$, 1, $pb$fill_blank$pb$, $pb$AppBar や body をまとめて持てる基本画面Widget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$Material Design ベースの画面土台です。$pb$, $pb$Scaffold$pb$, $pb$Scaffold は AppBar や body など、基本画面の骨組みを提供します。$pb$, $pb$Screen ではなく Scaffold がFlutterの標準的な画面土台です。$pb$, 2108, TRUE),
  ($pb$0fde3688-6aee-443f-a657-06fcf553b69b$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$外側の余白を付けるWidget$pb$, 1, $pb$fill_blank$pb$, $pb$子Widgetの周りに余白を付ける基本Widget名を答えてください。
  
  __________(padding: EdgeInsets.all(16), child: Text("A"))$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$padding プロパティを持つ代表的Widgetです。$pb$, $pb$Padding$pb$, $pb$Padding を使うと、子Widgetの周りに余白を付けられます。$pb$, $pb$Margin というWidget名ではありません。$pb$, 2201, TRUE),
  ($pb$5d8a2627-3ad9-40ce-a268-575b6183b534$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$残り領域を広げて使うWidget$pb$, 1, $pb$fill_blank$pb$, $pb$Row や Column の中で、残り領域を広げて使う基本Widget名を答えてください。
  
  __________(child: Container())$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$flex を持たせると比率も調整できます。$pb$, $pb$Expanded$pb$, $pb$Expanded は残っているスペースを広げて使いたいときの基本Widgetです。$pb$, $pb$Center は中央寄せ用で、残り領域を分配する目的とは違います。$pb$, 2202, TRUE),
  ($pb$7264404c-ec2a-4ed4-abd5-fea8e7a75f72$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$柔軟に広がるWidget$pb$, 2, $pb$fill_blank$pb$, $pb$Expanded より柔らかくレイアウトさせたいときに使うWidget名を答えてください。
  
  __________(child: Text("A"))$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$Expanded と同じく Flex 系で使います。$pb$, $pb$Flexible$pb$, $pb$Flexible は、必要に応じて広がる柔軟なレイアウトを作るときに使います。$pb$, $pb$Expanded と役割が近いですが、挙動が少し違います。$pb$, 2203, TRUE),
  ($pb$be5c23a5-2aa5-4dd9-ad74-ac9a873ecb0a$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$縦スクロール一覧を作るWidget$pb$, 1, $pb$fill_blank$pb$, $pb$縦にスクロールするリスト表示を作る基本Widget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$builder コンストラクタもよく使います。$pb$, $pb$ListView$pb$, $pb$縦スクロールの一覧を作る基本は ListView です。$pb$, $pb$Column はスクロールしないので、要素数が増える一覧には向きません。$pb$, 2204, TRUE),
  ($pb$7d3ff5f4-f602-4c9b-a579-0905410679e6$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$格子状表示を作るWidget$pb$, 1, $pb$fill_blank$pb$, $pb$カードを格子状に並べるときによく使うWidget名を答えてください。
  
  __________$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$2列や3列で並べるUIに向いています。$pb$, $pb$GridView$pb$, $pb$GridView は格子状レイアウトに向いたスクロールWidgetです。$pb$, $pb$ListView は1方向のリスト表示なので、格子状には向きません。$pb$, 2205, TRUE),
  ($pb$ab617d10-2488-4c12-a140-21cf65cbac87$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$子Widgetを中央寄せするWidget$pb$, 1, $pb$fill_blank$pb$, $pb$子Widgetを中央に寄せる最も基本的なWidget名を答えてください。
  
  __________(child: Text("Hello"))$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$1つの子Widgetを真ん中へ置きたい場面です。$pb$, $pb$Center$pb$, $pb$Center は子Widgetを中央寄せするためのシンプルなWidgetです。$pb$, $pb$Align でも位置調整できますが、中央固定なら Center の方が素直です。$pb$, 2206, TRUE),
  ($pb$fcb49bc2-8125-4cff-aa26-21c07df76501$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$位置を細かく寄せるWidget$pb$, 2, $pb$fill_blank$pb$, $pb$子Widgetを左上や右下など、細かい位置へ寄せる基本Widget名を答えてください。
  
  __________(alignment: Alignment.topLeft, child: Text("A"))$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$alignment プロパティで位置指定します。$pb$, $pb$Align$pb$, $pb$Align は alignment を使って子Widgetの位置を細かく調整できます。$pb$, $pb$Center は中央寄せ専用で、左上や右下を直接指定できません。$pb$, 2207, TRUE),
  ($pb$51f8624e-df11-4fc4-aaec-c36f5452695c$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$スクロールさせる基本方向$pb$, 2, $pb$fill_blank$pb$, $pb$ListView の既定スクロール方向を答えてください。
  
  Axis.__________$pb$, $pb$空欄には列挙子名だけを書いてください。$pb$, $pb$普通の ListView は上下に動きます。$pb$, $pb$vertical$pb$, $pb$ListView の既定方向は Axis.vertical です。$pb$, $pb$横スクロールにしたい場合は horizontal を明示的に指定します。$pb$, 2208, TRUE),
  ($pb$a46555df-5c26-4129-a0a6-a9be0cdedc6b$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$StatefulWidgetで状態更新するメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$StatefulWidget で画面を再描画させる基本メソッド名を答えてください。
  
  __________(() {
    counter++;
  });$pb$, $pb$空欄にはメソッド名だけを書いてください。$pb$, $pb$状態更新と再描画をまとめて知らせます。$pb$, $pb$setState$pb$, $pb$setState を呼ぶと、状態変更後に build が再実行されます。$pb$, $pb$変数だけ変えても、setState を呼ばないと画面が更新されないことがあります。$pb$, 2301, TRUE),
  ($pb$7321c7e2-7f31-4439-adaf-6fc12d83cd4c$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$カウンターを1増やす式$pb$, 1, $pb$fill_blank$pb$, $pb$counter を 1 増やしたいです。
  空欄に入る1行だけを答えてください。
  
  setState(() {
    __________
  });$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$インクリメント演算子を使えます。$pb$, $pb$counter++;$pb$, $pb$setState の中で状態変数を更新すると、画面にも反映されます。$pb$, $pb$counter + 1; だけでは代入されないので値は変わりません。$pb$, 2302, TRUE),
  ($pb$e7b194bb-c44d-44fa-a034-94b54a08f542$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$TextFieldの入力値を受け取る引数名$pb$, 1, $pb$fill_blank$pb$, $pb$TextField で入力値の変化を受け取りたいです。
  空欄に入るプロパティ名を答えてください。
  
  TextField(
    __________: (value) {
      text = value;
    },
  )$pb$, $pb$空欄にはプロパティ名だけを書いてください。$pb$, $pb$入力中の値変化を受け取るコールバックです。$pb$, $pb$onChanged$pb$, $pb$onChanged を使うと、入力中の文字列変化をそのまま受け取れます。$pb$, $pb$onTap はタップ時イベントであり、入力値の変化通知ではありません。$pb$, 2303, TRUE),
  ($pb$f7940284-79d6-46c6-a90f-d3972e3fd7ad$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$入力値を保持するクラス$pb$, 2, $pb$fill_blank$pb$, $pb$TextField の値をコントローラで管理したいです。
  空欄に入るクラス名を答えてください。
  
  final controller = __________();$pb$, $pb$空欄にはクラス名だけを書いてください。$pb$, $pb$text プロパティを持つ入力制御クラスです。$pb$, $pb$TextEditingController$pb$, $pb$TextEditingController を使うと、TextField の現在値を取得・更新しやすくなります。$pb$, $pb$TextController という基本クラス名はありません。$pb$, 2304, TRUE),
  ($pb$946c601f-c0ff-4de2-a80f-6735aef44f80$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$初期値を0へ戻す式$pb$, 1, $pb$fill_blank$pb$, $pb$counter を 0 に戻したいです。
  空欄に入る1行だけを答えてください。
  
  setState(() {
    __________
  });$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$再代入すれば初期化できます。$pb$, $pb$counter = 0;$pb$, $pb$setState の中で 0 を代入すると、画面上の値もリセットされます。$pb$, $pb$counter == 0; は比較であり、代入ではありません。$pb$, 2305, TRUE),
  ($pb$08da4664-04de-4d9f-a99d-8c89aaa28ad8$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$bool状態を切り替える式$pb$, 2, $pb$fill_blank$pb$, $pb$isLoading の true / false を切り替えたいです。
  空欄に入る1行だけを答えてください。
  
  setState(() {
    __________
  });$pb$, $pb$空欄には1行だけを書いてください。$pb$, $pb$否定演算子を使います。$pb$, $pb$isLoading = !isLoading;$pb$, $pb$! を使うと bool 値を反転できます。$pb$, $pb$isLoading != isLoading; は代入ではないので状態更新になりません。$pb$, 2306, TRUE),
  ($pb$44c58a8b-81ed-46f2-a4ca-9d3b507bcab5$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$StatefulWidgetのState型宣言$pb$, 2, $pb$fill_blank$pb$, $pb$CounterPage の State クラス宣言を書きたいです。
  空欄に入る継承先だけを答えてください。
  
  class _CounterPageState extends __________ {
  }$pb$, $pb$空欄には型名だけを書いてください。$pb$, $pb$対応するWidgetクラスを型引数に取ります。$pb$, $pb$State<CounterPage>$pb$, $pb$State クラスは State<対応するWidget> を継承して作ります。$pb$, $pb$StatefulWidget を直接継承するのは State クラスの役割と違います。$pb$, 2307, TRUE),
  ($pb$c1995a53-84c3-46bd-aa8c-1aceeaf77a47$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$フォーム入力を取得する式$pb$, 2, $pb$fill_blank$pb$, $pb$controller から現在の入力文字列を取り出したいです。
  空欄に入る式だけを答えてください。
  
  final text = __________;$pb$, $pb$空欄には式だけを書いてください。$pb$, $pb$controller の text プロパティです。$pb$, $pb$controller.text$pb$, $pb$TextEditingController の text で現在値を取得できます。$pb$, $pb$controller.value だけでは文字列そのものではありません。$pb$, 2308, TRUE),
  ($pb$7be4c3ff-ee6e-4346-ab1e-39cffb25cea9$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$ロジックを分ける基本単位$pb$, 3, $pb$fill_blank$pb$, $pb$表示とは別の責務として、値計算や保存処理を分けるときの基本単位を答えてください。
  
  __________ 分離$pb$, $pb$空欄には日本語1語を書いてください。$pb$, $pb$UIと対になる役割を意識します。$pb$, $pb$ロジック$pb$, $pb$状態管理では、UI とロジックの責務を分ける発想が大切です。$pb$, $pb$全部を build メソッドに詰め込むと、後から読みにくくなります。$pb$, 2309, TRUE),
  ($pb$25c12927-2e35-42db-a9a7-b4c0a53455cc$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$状態を初期化するライフサイクル$pb$, 3, $pb$fill_blank$pb$, $pb$State クラスで初期化処理を書く代表的なメソッド名を答えてください。
  
  @override
  void __________() {
    super.initState();
  }$pb$, $pb$空欄にはメソッド名だけを書いてください。$pb$, $pb$build の前に1回呼ばれます。$pb$, $pb$initState$pb$, $pb$initState は State が最初に作られたタイミングで1回だけ呼ばれる初期化用メソッドです。$pb$, $pb$initialize という名前の標準メソッドはありません。$pb$, 2310, TRUE),
  ($pb$dd6af2cf-44f9-46c6-a44e-927b0c32743c$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$次の画面へ進むメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$新しい画面へ遷移するときによく使うメソッド名を答えてください。
  
  Navigator.__________(context, route)$pb$, $pb$空欄にはメソッド名だけを書いてください。$pb$, $pb$戻る操作の pop と対になるメソッドです。$pb$, $pb$push$pb$, $pb$新しい画面をスタックへ積んで遷移するときは Navigator.push を使います。$pb$, $pb$pop は戻る処理なので、進む操作とは逆です。$pb$, 2401, TRUE),
  ($pb$5f8517d7-c3c7-4bbf-aaec-78863fbd6e20$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$前の画面へ戻るメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$現在の画面を閉じて前の画面へ戻るメソッド名を答えてください。
  
  Navigator.__________(context);$pb$, $pb$空欄にはメソッド名だけを書いてください。$pb$, $pb$push の逆です。$pb$, $pb$pop$pb$, $pb$Navigator.pop を使うと、現在の画面を閉じて前の画面へ戻れます。$pb$, $pb$back という標準メソッド名ではありません。$pb$, 2402, TRUE),
  ($pb$8b3671d4-f468-492b-a6d1-c49fe05c5007$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$画面をMaterialPageRouteで包む$pb$, 1, $pb$fill_blank$pb$, $pb$NextPage へ遷移するための route を作りたいです。
  空欄に入る return の右辺だけを答えてください。
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return __________;
      },
    ),
  );$pb$, $pb$空欄には返すWidgetだけを書いてください。$pb$, $pb$遷移先の画面Widgetを生成します。$pb$, $pb$NextPage()$pb$, $pb$MaterialPageRoute の builder では、遷移先の画面Widgetを返します。$pb$, $pb$context を返すのではなく、画面Widgetそのものを返す必要があります。$pb$, 2403, TRUE),
  ($pb$972ef03d-b845-4b1c-a8e9-8489e348ed57$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$画面を名前付きで呼ぶメソッド$pb$, 2, $pb$fill_blank$pb$, $pb$名前付きルート "/detail" へ遷移したいです。
  空欄に入るメソッド名を答えてください。
  
  Navigator.__________(context, "/detail");$pb$, $pb$空欄にはメソッド名だけを書いてください。$pb$, $pb$push の名前付きルート版です。$pb$, $pb$pushNamed$pb$, $pb$名前付きルートへ遷移するときは Navigator.pushNamed を使います。$pb$, $pb$goNamed は標準の Navigator API ではありません。$pb$, 2404, TRUE),
  ($pb$31534a5b-1f71-4f39-a02d-2372c70a9a81$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$前画面へ値を返すpop$pb$, 2, $pb$fill_blank$pb$, $pb$選択した文字列 "done" を前の画面へ返しながら戻りたいです。
  空欄に入るコード全体を答えてください。
  
  __________$pb$, $pb$Navigator を使った1行で答えてください。$pb$, $pb$pop の第2引数に戻り値を渡せます。$pb$, $pb$Navigator.pop(context, "done");$pb$, $pb$Navigator.pop(context, 値) と書くと、戻ると同時に前画面へ値を返せます。$pb$, $pb$push に値を渡すのではなく、戻るときに pop で返すのがポイントです。$pb$, 2405, TRUE),
  ($pb$d2d43422-fcef-46c7-aeb0-5f5c2ffdcf37$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$push結果を待つ型$pb$, 3, $pb$fill_blank$pb$, $pb$画面遷移の戻り値を String 型で待ちたいです。
  空欄に入る await 式全体を答えてください。
  
  final result = __________;$pb$, $pb$Navigator.push と MaterialPageRoute を使ってください。$pb$, $pb$push は Future を返すので await できます。$pb$, $pb$await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => NextPage()))$pb$, $pb$Navigator.push<T> の T に戻り値型を書いておくと、受け取る側の型が明確になります。$pb$, $pb$await を付けないと、結果ではなく Future 自体を受け取ることになります。$pb$, 2406, TRUE),
  ($pb$7c787470-59dc-4498-a3bb-b145310bbdb9$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$HTTP GETでよく使うメソッド名$pb$, 1, $pb$fill_blank$pb$, $pb$APIから一覧取得するときによく使うHTTPメソッドを答えてください。
  
  HTTP __________$pb$, $pb$空欄には大文字のメソッド名を書いてください。$pb$, $pb$取得系APIの代表です。$pb$, $pb$GET$pb$, $pb$一覧取得や詳細取得など、読む系のAPIでは GET を使うことが多いです。$pb$, $pb$POST は作成系で使うことが多く、取得系とは役割が違います。$pb$, 2501, TRUE),
  ($pb$f512bf00-f090-45b5-a1f1-5902fd562faa$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$JSON文字列をMapへ変換する関数$pb$, 1, $pb$fill_blank$pb$, $pb$JSON文字列を Dart の Map へ変換したいです。
  空欄に入る関数名を答えてください。
  
  final data = __________(response.body);$pb$, $pb$空欄には関数名だけを書いてください。$pb$, $pb$dart:convert からよく使います。$pb$, $pb$jsonDecode$pb$, $pb$jsonDecode を使うと、JSON文字列を Dart のオブジェクトへ変換できます。$pb$, $pb$decodeJson という標準関数名ではありません。$pb$, 2502, TRUE),
  ($pb$f28eacb9-72c9-44b3-a373-7c783e1c5cd3$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$Futureを受け取って描画するWidget$pb$, 1, $pb$fill_blank$pb$, $pb$非同期取得したデータの状態に応じて画面を切り替えたいです。
  空欄に入るWidget名を答えてください。
  
  __________<Task>($pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$future と builder を取る代表Widgetです。$pb$, $pb$FutureBuilder$pb$, $pb$FutureBuilder を使うと、読み込み中・成功・失敗で表示を切り替えやすくなります。$pb$, $pb$StreamBuilder は継続的なデータ流れ向けで、1回取得のFutureとは少し用途が違います。$pb$, 2503, TRUE),
  ($pb$d16e74d6-b01b-444e-a227-25ae4f1794c9$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$読み込み中に表示する基本Widget$pb$, 1, $pb$fill_blank$pb$, $pb$通信中であることを示すクルクルした表示の基本Widget名を答えてください。
  
  __________()$pb$, $pb$空欄にはWidget名だけを書いてください。$pb$, $pb$ローディング表示の定番です。$pb$, $pb$CircularProgressIndicator$pb$, $pb$CircularProgressIndicator は読み込み中を示す代表的なWidgetです。$pb$, $pb$LoadingWidget という標準Widget名ではありません。$pb$, 2504, TRUE),
  ($pb$b59c07ab-3bcc-4c6d-a7df-605618258d94$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$HTTPレスポンスの本文プロパティ$pb$, 2, $pb$fill_blank$pb$, $pb$http パッケージの response から本文文字列を取り出したいです。
  空欄に入るプロパティ名を答えてください。
  
  response.__________$pb$, $pb$空欄にはプロパティ名だけを書いてください。$pb$, $pb$JSONを decode するときによく使います。$pb$, $pb$body$pb$, $pb$response.body にレスポンス本文の文字列が入っています。$pb$, $pb$data ではなく body が http パッケージの代表的プロパティです。$pb$, 2505, TRUE),
  ($pb$76a58691-2dcf-4d6d-a894-9f79eb931922$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$ステータスコード成功判定$pb$, 2, $pb$fill_blank$pb$, $pb$HTTP通信成功時だけ処理を進めたいです。
  空欄に入る条件式だけを答えてください。
  
  if (__________) {
    return response.body;
  }$pb$, $pb$200番の成功判定を書いてください。$pb$, $pb$代表的な成功コードです。$pb$, $pb$response.statusCode == 200$pb$, $pb$HTTP 200 は取得成功の代表的なステータスコードです。$pb$, $pb$response.code という標準プロパティ名ではありません。$pb$, 2506, TRUE),
  ($pb$8c03146a-a234-4b7d-a165-734df5ac6bb7$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$モデルへ変換するfactory宣言$pb$, 2, $pb$fill_blank$pb$, $pb$Map<String, dynamic> から Task モデルを作る factory を定義したいです。
  空欄に入る宣言だけを答えてください。
  
  class Task {
    final int id;
    final String title;
  
    __________ {
      return Task(id: json["id"], title: json["title"]);
    }
  }$pb$, $pb$factory コンストラクタの宣言を書いてください。$pb$, $pb$fromJson という名前がよく使われます。$pb$, $pb$factory Task.fromJson(Map<String, dynamic> json)$pb$, $pb$fromJson という factory を作ると、APIレスポンスからモデル生成しやすくなります。$pb$, $pb$戻り値型を別で書く通常メソッドではなく、factory 構文を使うのがポイントです。$pb$, 2507, TRUE),
  ($pb$0c0f7c90-c719-405c-a65c-96c31742acf3$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$通信失敗時に投げる基本例外$pb$, 3, $pb$fill_blank$pb$, $pb$ステータスコードが 200 以外なら例外を投げたいです。
  空欄に入るコード全体を答えてください。
  
  if (response.statusCode != 200) {
    __________
  }$pb$, $pb$簡単な文字列メッセージ付きで例外を投げてください。$pb$, $pb$throw と Exception を使います。$pb$, $pb$throw Exception("Failed to load data");$pb$, $pb$通信失敗時は throw Exception(...) のように例外化して、呼び出し側で扱えるようにします。$pb$, $pb$print だけでは失敗が上位へ伝わらず、UI側で適切にエラー表示しにくくなります。$pb$, 2508, TRUE),
  ($pb$9faae712-61ac-460e-a3c7-eb0150d2bc74$pb$, $pb$9b70220a-4ea8-4f07-adeb-71a6dcbe37fb$pb$, $pb$StatelessWidgetでHello画面を書く$pb$, 2, $pb$normal$pb$, $pb$`HelloPage` という `StatelessWidget` を作り、`Scaffold` の `body` に `Center(child: Text("Hello"))` を表示するコードを書いてください。$pb$, $pb$`StatelessWidget` を継承すること
  `build` メソッドを書くこと
  `Scaffold` と `Center` と `Text("Hello")` を使うこと$pb$, $pb$Flutter の最初の1画面を自分で書けるかを確かめる問題です。$pb$, $pb$class HelloPage extends StatelessWidget {
    const HelloPage({super.key});
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Center(
          child: Text("Hello"),
        ),
      );
    }
  }$pb$, $pb$Widget 基礎では、最小の画面を `StatelessWidget` で自力実装できることが大事です。$pb$, $pb$`return` せずに Widget を並べるだけだと `build` メソッドとして成立しません。$pb$, 2509, TRUE),
  ($pb$68689ee1-a28b-40c6-ad35-1771256a0dcc$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$カウンターを増やすStatefulWidgetを書く$pb$, 2, $pb$normal$pb$, $pb$ボタンを押すたびに `counter` が 1 増える簡単な `StatefulWidget` の `build` 部分を書いてください。$pb$, $pb$`Text("$counter")` を表示すること
  `ElevatedButton` を置くこと
  `onPressed` の中で `setState` を使って `counter++` すること$pb$, $pb$状態管理の最初の練習として、`setState` の位置を意識してください。$pb$, $pb$Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("$counter"),
      ElevatedButton(
        onPressed: () {
          setState(() {
            counter++;
          });
        },
        child: Text("増やす"),
      ),
    ],
  )$pb$, $pb$`setState` の中で状態を変えるのが Flutter 基礎の重要ポイントです。$pb$, $pb$`counter++` だけ書いて `setState` を呼ばないと画面が更新されません。$pb$, 2510, TRUE),
  ($pb$725167ed-ec62-4d11-a896-c3bf4d60d24e$pb$, $pb$fc1383d5-b29a-458f-a2c9-5130a97b9460$pb$, $pb$余白付きの縦並びレイアウトを書く$pb$, 2, $pb$normal$pb$, $pb$画面中央に `タイトル` と `説明` を縦並びで表示し、全体に 16 の余白を付けるコードを書いてください。$pb$, $pb$`Padding` を使うこと
  `Column` を使うこと
  `Text("タイトル")` と `Text("説明")` を含めること$pb$, $pb$1つの Widget に全部詰め込まず、外側から順に組み立てると書きやすいです。$pb$, $pb$Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("タイトル"),
        Text("説明"),
      ],
    ),
  )$pb$, $pb$Flutter のレイアウトは、`Padding` と `Column` の組み合わせをまず自然に書けるようになると強いです。$pb$, $pb$`Container` だけで何でも済ませようとすると、役割が曖昧になって読みづらくなります。$pb$, 2511, TRUE),
  ($pb$5208eeea-0880-4288-af1b-ffe5ba67f4ec$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$詳細画面へ遷移するコードを書く$pb$, 2, $pb$normal$pb$, $pb$ボタン押下で `DetailPage()` へ遷移する `onPressed` のコードを書いてください。$pb$, $pb$`Navigator.push` を使うこと
  `MaterialPageRoute` を使うこと
  `DetailPage()` を返すこと$pb$, $pb$Flutter の画面遷移は `context` と `route` をセットで考えると整理しやすいです。$pb$, $pb$onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(),
      ),
    );
  }$pb$, $pb$明示的な画面遷移は `Navigator.push` が基本です。$pb$, $pb$`Navigator.pop` は戻る処理なので、新しい画面へ進むときには使いません。$pb$, 2512, TRUE),
  ($pb$eb6d50a9-f696-4791-af5d-4d5f2d65a3ed$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$前の画面へ結果を返して戻るコードを書く$pb$, 3, $pb$normal$pb$, $pb$詳細画面から `"saved"` という文字列を前の画面へ返して閉じるコードを1行で書いてください。$pb$, $pb$`Navigator.pop` を使うこと
  `context` を渡すこと
  戻り値として `"saved"` を渡すこと$pb$, $pb$画面を閉じるだけでなく、戻り値を付けられる形です。$pb$, $pb$Navigator.pop(context, "saved");$pb$, $pb$Flutter では `pop` に値を渡すことで、前画面へ結果を返せます。$pb$, $pb$`Navigator.push` に値を渡しても戻り値にはなりません。$pb$, 2513, TRUE),
  ($pb$ba12d97f-b7c6-4511-afa0-e08f3b2c3899$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$TaskモデルのfromJsonを書く$pb$, 2, $pb$normal$pb$, $pb$`id` と `title` を持つ `Task` モデルに、`Map<String, dynamic>` から変換する `fromJson` を書いてください。$pb$, $pb$`factory Task.fromJson(...)` を書くこと
  `json["id"]` と `json["title"]` を使うこと
  `Task(...)` を返すこと$pb$, $pb$API 連携では、JSON をそのまま UI へ渡さずモデルへ変換する流れが重要です。$pb$, $pb$class Task {
    final int id;
    final String title;
  
    Task({required this.id, required this.title});
  
    factory Task.fromJson(Map<String, dynamic> json) {
      return Task(
        id: json["id"],
        title: json["title"],
      );
    }
  }$pb$, $pb$`fromJson` を自分で書けると、API レスポンスを扱う土台がかなり安定します。$pb$, $pb$`json.id` のようにドット記法で読むと `Map` のアクセスとしては誤りです。$pb$, 2514, TRUE),
  ($pb$ddca6f9b-86fe-4e2a-a2ee-90ca4e4b78b2$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$APIから一覧を取得する関数を書く$pb$, 3, $pb$normal$pb$, $pb$`https://example.com/tasks` からデータを取得し、成功時は `response.body` を返し、失敗時は例外を投げる `fetchTasks` 関数を書いてください。$pb$, $pb$`async` を使うこと
  `http.get(Uri.parse(...))` を使うこと
  `response.statusCode == 200` を判定すること$pb$, $pb$まずは返り値を JSON 変換する前の文字列でも大丈夫です。$pb$, $pb$Future<String> fetchTasks() async {
    final response = await http.get(Uri.parse("https://example.com/tasks"));
  
    if (response.statusCode == 200) {
      return response.body;
    }
  
    throw Exception("Failed to load tasks");
  }$pb$, $pb$API 連携の基本は、通信・成功判定・失敗時の例外処理を一連で書けることです。$pb$, $pb$`await` を付け忘れると `response` が `Future` のままになり、後続処理でつまずきます。$pb$, 2515, TRUE),
  ($pb$eacc1d03-0b91-476c-a8f1-52b40970fd41$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$FutureBuilderで読み込み中と成功時を描き分ける$pb$, 3, $pb$normal$pb$, $pb$`future: fetchTasks()` を使う `FutureBuilder<String>` の `builder` を書いてください。読み込み中は `CircularProgressIndicator`、成功時は `Text(snapshot.data!)` を表示してください。$pb$, $pb$`snapshot.connectionState == ConnectionState.waiting` を判定すること
  読み込み中表示を書くこと
  成功時の `Text(snapshot.data!)` を書くこと$pb$, $pb$最初はエラー分岐がなくても大丈夫ですが、待機中分岐は必須です。$pb$, $pb$FutureBuilder<String>(
    future: fetchTasks(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
  
      return Text(snapshot.data!);
    },
  )$pb$, $pb$`FutureBuilder` は非同期データを UI に反映する基本パターンです。$pb$, $pb$`snapshot.data` を待機中から直接使うと `null` で落ちやすくなります。$pb$, 2516, TRUE),
  ($pb$0e1b41db-5edf-4726-a53e-9516870acdea$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$TextFieldの入力値をボタン押下で使うコードを書く$pb$, 3, $pb$normal$pb$, $pb$`TextEditingController controller` を使って、ボタンを押したら `print(controller.text);` を実行するコードを書いてください。$pb$, $pb$`TextField(controller: controller)` を含めること
  `ElevatedButton` を使うこと
  `onPressed` の中で `print(controller.text);` を呼ぶこと$pb$, $pb$入力イベントで毎回保存する形ではなく、コントローラから読む形です。$pb$, $pb$Column(
    children: [
      TextField(controller: controller),
      ElevatedButton(
        onPressed: () {
          print(controller.text);
        },
        child: Text("送信"),
      ),
    ],
  )$pb$, $pb$フォーム入力では `TextEditingController` を通して値を読むパターンをよく使います。$pb$, $pb$`controller.value` だけを書くと、文字列そのものではなく別の情報を扱うことになりやすいです。$pb$, 2517, TRUE),
  ($pb$f053090c-d1c2-4cf2-aef0-b5c2ccdb5a1d$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$画面表示時にAPI取得を始めるinitStateを書く$pb$, 3, $pb$normal$pb$, $pb$`Future<String> taskFuture` を画面表示時に `fetchTasks()` で初期化したいです。`State` クラス内の `initState` を書いてください。$pb$, $pb$`@override` を書くこと
  `super.initState();` を呼ぶこと
  `taskFuture = fetchTasks();` を書くこと$pb$, $pb$最初の API 呼び出しは `build` の中より `initState` に置く方が安定します。$pb$, $pb$@override
  void initState() {
    super.initState();
    taskFuture = fetchTasks();
  }$pb$, $pb$`initState` は画面初期化時に一度だけ走らせたい処理を書く場所です。$pb$, $pb$`build` の中で毎回 `fetchTasks()` を呼ぶと、再描画のたびに通信が走りやすくなります。$pb$, 2518, TRUE),
  ($pb$65052e8e-b998-41a4-a41b-c842e6de55a2$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$一覧取得して表示するTaskList画面を書く$pb$, 3, $pb$normal$pb$, $pb$`fetchTasks()` が `Future<List<Task>>` を返す前提で、読み込み中はローディング、成功時は `ListView.builder` でタイトル一覧を表示する `FutureBuilder` を書いてください。$pb$, $pb$`FutureBuilder<List<Task>>` を使うこと
  待機中は `CircularProgressIndicator` を表示すること
  成功時は `ListView.builder` と `Text(tasks[index].title)` を使うこと$pb$, $pb$研修では API から一覧取得して画面に出す流れを 1 つ書けるとかなり強いです。$pb$, $pb$FutureBuilder<List<Task>>(
    future: fetchTasks(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
  
      final tasks = snapshot.data!;
  
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].title),
          );
        },
      );
    },
  )$pb$, $pb$非同期取得と一覧表示をまとめて書けるようになると、Flutter 研修の課題にかなり対応しやすくなります。$pb$, $pb$待機中分岐なしで `snapshot.data!` を使うと、読み込み前に null 参照しやすくなります。$pb$, 2519, TRUE),
  ($pb$b43949b3-69b7-4e3c-ac9c-e269b925d700$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$新規作成画面で入力して結果を返す処理を書く$pb$, 3, $pb$normal$pb$, $pb$`TextEditingController controller` を使ってタスク名を入力し、保存ボタンを押したら `Navigator.pop(context, controller.text)` で前画面へ返す `onPressed` のコードを書いてください。$pb$, $pb$`controller.text` を使うこと
  `Navigator.pop(context, ...)` を使うこと
  戻り値として入力文字列を返すこと$pb$, $pb$一覧画面から作成画面へ遷移して、戻ってきた値を受け取る流れの一部です。$pb$, $pb$onPressed: () {
    Navigator.pop(context, controller.text);
  }$pb$, $pb$研修では「別画面で入力して戻り値を返す」程度の画面連携がよく出ます。$pb$, $pb$`Navigator.push` を使うと画面が増えるだけで、前画面へ結果を返す処理にはなりません。$pb$, 2520, TRUE),
  ($pb$26fce2b0-8551-4ec5-aeb9-9fe7bbcdc0fc$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$buildのたびにAPIが再実行される原因と修正方針を書く$pb$, 3, $pb$normal$pb$, $pb$`build` メソッドの中で `fetchTasks()` を毎回呼んでいるため、画面更新のたびに API 通信が走っています。原因と修正方針を1つずつ書いてください。$pb$, $pb$原因として `build` が再実行されるたびに通信が走ることを書くこと
  修正方針として `initState` で `Future` を一度だけ作ることを書くこと$pb$, $pb$Flutter では「どこで非同期処理を開始するか」がかなり重要です。$pb$, $pb$原因: `build` は再描画のたびに呼ばれるので、その中で `fetchTasks()` を呼ぶと毎回通信が走る
  修正方針: `initState` で `taskFuture = fetchTasks();` を一度だけ実行し、その `Future` を `FutureBuilder` に渡す$pb$, $pb$実務や研修では、コードを書くだけでなく「なぜ重複通信が起きるのか」を説明できる力も大切です。$pb$, $pb$`setState` を減らすだけでは根本解決にならず、通信開始位置を直す必要があります。$pb$, 2521, TRUE),
  ($pb$f67b40de-59ae-4a50-a645-3e1b4cb01fbc$pb$, $pb$159dacd0-3a9b-41a6-af31-d25ce02beb5a$pb$, $pb$setState を呼ばずに画面が更新されないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のコードではボタンを押しても画面の数字が変わりません。正しく動くように修正した `onPressed` のコードを書いてください。
  
  ```dart
  int count = 0;
  
  onPressed: () {
    count++;
  }
  ```$pb$, $pb$`setState` を使うこと
  `count++` の更新を中に入れること$pb$, $pb$StatefulWidget で画面を再描画させたいときに必要な関数を思い出してください。$pb$, $pb$onPressed: () {
    setState(() {
      count++;
    });
  }$pb$, $pb$StatefulWidget では値を変えるだけでは再描画されません。`setState` の中で更新して初めて画面に反映されます。$pb$, $pb$`count++` だけ書くと内部の値は変わっても UI は更新されません。画面更新の通知までセットで必要です。$pb$, 2522, TRUE),
  ($pb$6d834451-4a03-482c-ab06-b7df8284445c$pb$, $pb$b7e6065b-d637-43d2-a751-bdcb9d89d26e$pb$, $pb$build のたびに API を呼ぶバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のコードは画面更新のたびに `fetchTasks()` が走ってしまいます。1回だけ取得する形に直す方針を、原因と修正コードつきで書いてください。
  
  ```dart
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchTasks(),
      builder: (context, snapshot) {
        return Container();
      },
    );
  }
  ```$pb$, $pb$原因を 1 つ書くこと
  `initState` で `Future` を保持する修正を書くこと
  `FutureBuilder` でその `Future` を使うこと$pb$, $pb$`build` は何度も呼ばれるので、重い処理や API 呼び出しを毎回その場で作らない構成にします。$pb$, $pb$原因: `build` が再実行されるたびに `fetchTasks()` を新しく呼んでいるため。
  
  late Future<List<Task>> taskFuture;
  
  @override
  void initState() {
    super.initState();
    taskFuture = fetchTasks();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskFuture,
      builder: (context, snapshot) {
        return Container();
      },
    );
  }$pb$, $pb$初回取得を `initState` に寄せて `Future` を保持しておくと、不要な再通信を防げます。$pb$, $pb$`setState` を足すだけでは原因は解消しません。問題は再描画時に API 呼び出し自体を作り直している点です。$pb$, 2523, TRUE),
  ($pb$bce2ef5f-0b75-473a-a952-434c53fbd885$pb$, $pb$39eccb20-d792-4c41-a4fe-2ac0f016ce16$pb$, $pb$戻るときに値を返せない Navigator のバグを直す$pb$, 3, $pb$normal$pb$, $pb$入力画面でタスク名を入力して前の画面へ返したいのに、次のコードだと値が返りません。正しい `onPressed` を書いてください。
  
  ```dart
  onPressed: () {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const TaskListPage()),
    );
  }
  ```$pb$, $pb$`Navigator.pop` を使うこと
  `controller.text` を返すこと$pb$, $pb$すでに開いている入力画面から前の画面へ戻すときは、さらに push せず、現在の画面を閉じます。$pb$, $pb$onPressed: () {
    Navigator.pop(context, controller.text);
  }$pb$, $pb$値を返しながら前画面へ戻るときは `Navigator.pop(context, value)` を使います。`push` では新しい画面を開くだけです。$pb$, $pb$一覧画面へもう一度 `push` すると画面が増えるだけで、戻り値は受け取れません。$pb$, 2524, TRUE),
  ($pb$36767a19-1920-43a5-ac46-b2e5a53c4f0d$pb$, $pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$PHPの変数で先頭に付ける記号$pb$, 1, $pb$fill_blank$pb$, $pb$PHP で変数を宣言するとき、変数名の先頭に付ける記号を書いてください。
  
  __________name = "Taro";$pb$, $pb$記号だけを書くこと$pb$, $pb$Java の変数宣言とは書き方が違います。$pb$, $pb$$$pb$, $pb$PHP の変数は `$name` のように、必ず `$` を付けて表現します。$pb$, $pb$`var` や `String` は型や宣言方法の話で、変数名の先頭に付ける記号ではありません。$pb$, 3101, TRUE),
  ($pb$ffbc2948-08cb-4be7-a6a2-88207ed15f42$pb$, $pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$文字を画面に出力する命令$pb$, 1, $pb$fill_blank$pb$, $pb$PHP で文字列を画面に表示するときによく使う命令を書いてください。
  
  <?php __________ "Hello"; ?>$pb$, $pb$命令名だけを書くこと$pb$, $pb$最初の PHP 学習でよく出てくる出力命令です。$pb$, $pb$echo$pb$, $pb$`echo` は PHP で文字列や値をそのまま出力するときの基本です。$pb$, $pb$`println` は Java で使う書き方で、PHP の基本出力ではありません。$pb$, 3102, TRUE),
  ($pb$64cf5671-370f-4312-a59a-714b6797a0de$pb$, $pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$文字列を結合する演算子$pb$, 1, $pb$fill_blank$pb$, $pb$PHP で `"Hello"` と `"World"` を結合するときに使う演算子を書いてください。
  
  "Hello" __________ "World"$pb$, $pb$演算子だけを書くこと$pb$, $pb$Java の `+` とは違います。$pb$, $pb$.$pb$, $pb$PHP の文字列結合はドット `.` を使います。$pb$, $pb$`+` は PHP では文字列結合の基本演算子ではありません。$pb$, 3103, TRUE),
  ($pb$30c63d48-cdaa-498c-aaa9-149f315063ab$pb$, $pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$関数を定義するときのキーワード$pb$, 1, $pb$fill_blank$pb$, $pb$PHP で関数を定義するときに使うキーワードを書いてください。
  
  __________ greet() {
    echo "Hi";
  }$pb$, $pb$キーワードだけを書くこと$pb$, $pb$Java のメソッド定義に似ていますが、書き出しは別です。$pb$, $pb$function$pb$, $pb$PHP で関数を作るときは `function` を使います。$pb$, $pb$`def` は Python の書き方で、PHP では使いません。$pb$, 3104, TRUE),
  ($pb$0f871a41-1995-472e-a72a-2b5b327826fc$pb$, $pb$7fa7de1c-548c-4a51-aa3b-fb81fc0f3dd9$pb$, $pb$配列の短縮構文$pb$, 1, $pb$fill_blank$pb$, $pb$PHP で配列を短く書くときに使う記号を書いてください。
  
  $items = __________;$pb$, $pb$記号だけを書くこと$pb$, $pb$空配列を作るときの書き方です。$pb$, $pb$[]$pb$, $pb$PHP では `[]` で空配列を作れます。$pb$, $pb$`{}` は配列ではなく、別の意味で使われることがあります。$pb$, 3105, TRUE),
  ($pb$b11b9356-c129-41b6-aab3-0d05af5869f8$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$GETパラメータを受け取る変数$pb$, 1, $pb$fill_blank$pb$, $pb$URL のクエリパラメータを PHP で受け取るスーパーグローバル変数を書いてください。
  
  __________["id"]$pb$, $pb$変数名だけを書くこと$pb$, $pb$`?id=1` のような値を受け取るときに使います。$pb$, $pb$$_GET$pb$, $pb$GET パラメータは `$_GET` から取得します。$pb$, $pb$`$_POST` はフォームの POST 送信時に使うもので、GET 専用ではありません。$pb$, 3201, TRUE),
  ($pb$59f19252-b463-4fce-aa35-9b8ab88abe66$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$POSTデータを受け取る変数$pb$, 1, $pb$fill_blank$pb$, $pb$フォームから POST 送信された値を PHP で受け取るスーパーグローバル変数を書いてください。
  
  __________["title"]$pb$, $pb$変数名だけを書くこと$pb$, $pb$登録フォームでよく使います。$pb$, $pb$$_POST$pb$, $pb$POST データは `$_POST` から取り出します。$pb$, $pb$`$_GET` を使うと送信方式が合わず、値が取れないことがあります。$pb$, 3202, TRUE),
  ($pb$7d8d2f49-57da-4995-abee-52d8eb51136c$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$フォームをPOST送信にする属性値$pb$, 1, $pb$fill_blank$pb$, $pb$HTML フォームを POST 送信にするとき、`method` 属性に入れる値を書いてください。
  
  <form method="__________">$pb$, $pb$値だけを書くこと$pb$, $pb$大文字小文字は一般的な小文字で答えてください。$pb$, $pb$post$pb$, $pb$`<form method="post">` と書くことで POST 送信になります。$pb$, $pb$`POST` でも意味は通じますが、HTML では通常小文字で統一されます。$pb$, 3203, TRUE),
  ($pb$a42cfc86-4131-4900-a8dd-b6404b3ef198$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$入力欄の値を送るための属性$pb$, 1, $pb$fill_blank$pb$, $pb$フォーム送信時に PHP 側で値を受け取れるように、`input` タグに必ず付けたい属性を書いてください。
  
  <input type="text" __________="title">$pb$, $pb$属性名だけを書くこと$pb$, $pb$`$_POST["title"]` の `"title"` に対応します。$pb$, $pb$name$pb$, $pb$`name` 属性がないと、フォーム送信しても PHP から値を取り出せません。$pb$, $pb$`id` は見た目や JavaScript 用で、送信名そのものではありません。$pb$, 3204, TRUE),
  ($pb$225b0ca5-55df-4a57-a7cf-d2f39ebd68ea$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$空入力を確認する関数$pb$, 1, $pb$fill_blank$pb$, $pb$入力値が空かどうかを確かめる PHP の基本関数を書いてください。
  
  if (__________($title)) {
    echo "必須です";
  }$pb$, $pb$関数名だけを書くこと$pb$, $pb$必須チェックでよく使います。$pb$, $pb$empty$pb$, $pb$`empty()` は値が空かどうかを簡単に判定できます。$pb$, $pb$`isEmpty` は Java 風の名前で、PHP の標準関数ではありません。$pb$, 3205, TRUE),
  ($pb$f43315d8-be1a-4d52-a483-f3d1be56575e$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$HTTPメソッドを確認する変数$pb$, 2, $pb$fill_blank$pb$, $pb$現在のリクエストが GET か POST かを確認するときによく使う変数名を書いてください。
  
  $_SERVER["__________"]$pb$, $pb$キー名だけを書くこと$pb$, $pb$`REQUEST_` から始まる名前です。$pb$, $pb$REQUEST_METHOD$pb$, $pb$`$_SERVER["REQUEST_METHOD"]` で GET / POST などを確認できます。$pb$, $pb$`METHOD` だけではキー名として足りません。$pb$, 3206, TRUE),
  ($pb$d22ca404-af25-4a7f-a1c0-e6f0c2b4a2c0$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$一覧表示で配列を回す構文$pb$, 1, $pb$fill_blank$pb$, $pb$タスク一覧配列 `$tasks` を1件ずつ取り出して表示するときに使う構文を書いてください。
  
  __________ ($tasks as $task) {
    echo $task["title"];
  }$pb$, $pb$構文キーワードだけを書くこと$pb$, $pb$配列の繰り返し処理です。$pb$, $pb$foreach$pb$, $pb$`foreach` は配列の各要素を順番に処理するときに使います。$pb$, $pb$`for` でも書けますが、この形の穴埋めでは `foreach` が正解です。$pb$, 3301, TRUE),
  ($pb$bf7fa720-d7e1-4f37-a409-bb43570e9568$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$連想配列からtitleを取り出す書き方$pb$, 1, $pb$fill_blank$pb$, $pb$連想配列 `$task` から title を取り出すコードを書いてください。
  
  $task[__________]$pb$, $pb$キーだけを書くこと$pb$, $pb$文字列キーです。$pb$, $pb$"title"$pb$, $pb$連想配列の値は `$task["title"]` のようにキーで取得します。$pb$, $pb$`title` だけだと文字列として扱われず、意図しない動きになります。$pb$, 3302, TRUE),
  ($pb$f7b4a4f7-01f6-46b5-a9df-dbfe4c70c5ce$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$配列の件数を数える関数$pb$, 1, $pb$fill_blank$pb$, $pb$配列 `$tasks` の件数を調べる PHP の関数を書いてください。
  
  __________($tasks)$pb$, $pb$関数名だけを書くこと$pb$, $pb$一覧件数表示などでよく使います。$pb$, $pb$count$pb$, $pb$`count()` で配列の要素数を取得できます。$pb$, $pb$`size` は Java のコレクションでよく出ますが、PHP の標準関数ではありません。$pb$, 3303, TRUE),
  ($pb$afb05203-93d9-49ad-adf0-4b17efcdfc0e$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$配列の末尾に要素を追加する関数$pb$, 2, $pb$fill_blank$pb$, $pb$配列 `$tasks` の末尾に新しいタスクを追加する関数を書いてください。
  
  __________($tasks, $newTask);$pb$, $pb$関数名だけを書くこと$pb$, $pb$新規追加処理で使えます。$pb$, $pb$array_push$pb$, $pb$`array_push()` で配列の末尾へ要素を追加できます。$pb$, $pb$`push` 単体は PHP の基本関数名ではありません。$pb$, 3304, TRUE),
  ($pb$9aa5be96-687d-4491-ab32-0b2cdbb2e97b$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$削除対象のidをGETで受け取る$pb$, 1, $pb$fill_blank$pb$, $pb$URL から削除対象の id を受け取るコードの空欄を埋めてください。
  
  $id = $_GET[__________];$pb$, $pb$キーだけを書くこと$pb$, $pb$`?id=3` のように受け取る想定です。$pb$, $pb$"id"$pb$, $pb$`$_GET["id"]` とすることで、クエリパラメータの id を取得できます。$pb$, $pb$`id` を引用符なしで書くと、意図した文字列キーになりません。$pb$, 3305, TRUE),
  ($pb$14ed0ed6-c927-4db1-a983-b79145886f88$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$更新対象のidをhiddenで送るinput type$pb$, 2, $pb$fill_blank$pb$, $pb$編集フォームで id を見えないまま送信したいです。`input` タグの `type` 属性に入れる値を書いてください。
  
  <input type="__________" name="id" value="1">$pb$, $pb$値だけを書くこと$pb$, $pb$ユーザーには見せない入力欄です。$pb$, $pb$hidden$pb$, $pb$`type="hidden"` で画面に表示せず値を送れます。$pb$, $pb$`text` にすると普通の入力欄として表示されてしまいます。$pb$, 3306, TRUE),
  ($pb$f981ae95-3126-4b3f-a54c-e12b27e29f81$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$リダイレクトに使う関数$pb$, 2, $pb$fill_blank$pb$, $pb$保存後に一覧画面へリダイレクトするときに使う PHP の関数を書いてください。
  
  __________("Location: list.php");$pb$, $pb$関数名だけを書くこと$pb$, $pb$HTTP ヘッダーを送る関数です。$pb$, $pb$header$pb$, $pb$`header("Location: ...")` でリダイレクトできます。$pb$, $pb$`redirect` という標準関数は PHP にはありません。$pb$, 3307, TRUE),
  ($pb$ddd53320-cf70-43a4-aaf9-3a4b169faf90$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$条件に合う要素を見つけたら抜ける命令$pb$, 2, $pb$fill_blank$pb$, $pb$ループ中に目的の id を見つけたら処理を抜けたいです。使う命令を書いてください。
  
  if ($task["id"] == $id) {
    __________;
  }$pb$, $pb$命令だけを書くこと$pb$, $pb$繰り返しを途中で止めます。$pb$, $pb$break$pb$, $pb$`break` を使うと、その場でループ処理を終了できます。$pb$, $pb$`return` でも抜けられますが、この問題はループ制御命令を問っています。$pb$, 3308, TRUE),
  ($pb$51574ac6-5bd1-4c09-a9e4-88bd70dc20ea$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$削除用リンクでidを付けるクエリ名$pb$, 1, $pb$fill_blank$pb$, $pb$削除リンク `delete.php?id=3` の `=` の左側にあるクエリ名を書いてください。
  
  delete.php?__________=3$pb$, $pb$クエリ名だけを書くこと$pb$, $pb$対象の識別子です。$pb$, $pb$id$pb$, $pb$`id` をクエリ名にしておくと、削除対象を取り出しやすくなります。$pb$, $pb$`title` だと一意に対象を識別しにくいことがあります。$pb$, 3309, TRUE),
  ($pb$36f46a2d-d9c6-4c0d-ae21-7feab80114ac$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$新規登録後によく使うHTTP処理$pb$, 2, $pb$fill_blank$pb$, $pb$フォーム再送信を避けるため、登録後は一覧へ移動させることが多いです。この流れを一言で表すと何ですか。
  
  登録後に __________ する$pb$, $pb$カタカナ1語で答えること$pb$, $pb$`header("Location: ...")` で行う処理です。$pb$, $pb$リダイレクト$pb$, $pb$登録後にリダイレクトすると、再読み込み時の二重送信を避けやすくなります。$pb$, $pb$`更新` だと画面側の動作を正確に表しきれません。$pb$, 3310, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;
INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$bb0dbee6-ffe3-45bb-a882-d41b49af25c2$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$配列に保存した全件を表示する繰り返し構文$pb$, 1, $pb$fill_blank$pb$, $pb$タスク配列 `$tasks` の全件を順番に表示したいです。使う繰り返し構文を書いてください。
  
  __________ ($tasks as $task)$pb$, $pb$構文キーワードだけを書くこと$pb$, $pb$PHP の配列表示で最もよく使います。$pb$, $pb$foreach$pb$, $pb$PHP の配列を全件処理するときは `foreach` が基本です。$pb$, $pb$`while` だと条件や添字管理が必要になり、この形とは合いません。$pb$, 3311, TRUE),
  ($pb$f4edf70c-a96e-4466-a047-77ad9f07aafb$pb$, $pb$f2ce7013-7a85-4239-ae34-48acfa3b7654$pb$, $pb$配列から1件を作る関数名$pb$, 1, $pb$fill_blank$pb$, $pb$連想配列を作るときによく使う PHP の関数名を書いてください。
  
  $task = __________("id" => 1, "title" => "買い物");$pb$, $pb$関数名だけを書くこと$pb$, $pb$配列作成の古い書き方です。$pb$, $pb$array$pb$, $pb$`array(...)` は PHP の配列作成で昔から使われる書き方です。$pb$, $pb$`list` は展開用の構文で、配列作成関数ではありません。$pb$, 3312, TRUE),
  ($pb$863bc60a-bb36-4993-ae7f-deba779b8db4$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$PHPでDB接続に使う基本クラス$pb$, 1, $pb$fill_blank$pb$, $pb$PHP でデータベース接続を行うときに学習でよく使うクラス名を書いてください。
  
  new __________($dsn, $user, $password)$pb$, $pb$クラス名だけを書くこと$pb$, $pb$MySQL や PostgreSQL 接続で広く使われます。$pb$, $pb$PDO$pb$, $pb$`PDO` は PHP の代表的な DB 接続手段です。$pb$, $pb$`JDBC` は Java の API 名なので、PHP では使いません。$pb$, 3401, TRUE),
  ($pb$42b47dee-5ab2-4ef8-a426-29d842d838c7$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$MySQL接続用DSNの先頭$pb$, 1, $pb$fill_blank$pb$, $pb$PDO で MySQL に接続するとき、DSN の先頭に付ける文字列を書いてください。
  
  __________:host=localhost;dbname=task_app;charset=utf8mb4$pb$, $pb$先頭部分だけを書くこと$pb$, $pb$接続先の種類を表します。$pb$, $pb$mysql$pb$, $pb$MySQL の PDO 接続では DSN を `mysql:...` から始めます。$pb$, $pb$`jdbc:mysql` は Java 側の書式で、PDO DSN とは異なります。$pb$, 3402, TRUE),
  ($pb$74553968-45e1-4baf-ac51-0fd33d1802e9$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$SQL文を安全に準備するメソッド$pb$, 2, $pb$fill_blank$pb$, $pb$PDO で SQL を実行する前に安全な形で準備するときのメソッド名を書いてください。
  
  $stmt = $pdo->__________("SELECT * FROM tasks WHERE id = ?");$pb$, $pb$メソッド名だけを書くこと$pb$, $pb$SQL インジェクション対策でも重要です。$pb$, $pb$prepare$pb$, $pb$`prepare()` で SQL を準備し、あとから値を渡す形にできます。$pb$, $pb$`query` は簡単に実行できますが、値埋め込みでは安全性が下がりやすいです。$pb$, 3403, TRUE),
  ($pb$5f7084ce-2d3c-47c3-a3ee-df8e1891b970$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$準備したSQLを実行するメソッド$pb$, 2, $pb$fill_blank$pb$, $pb$prepare した SQL を実際に動かすメソッド名を書いてください。
  
  $stmt->__________([$id]);$pb$, $pb$メソッド名だけを書くこと$pb$, $pb$prepare の次に使います。$pb$, $pb$execute$pb$, $pb$`execute()` で準備済み SQL を実行します。$pb$, $pb$`run` は PDOStatement の標準メソッドではありません。$pb$, 3404, TRUE),
  ($pb$21b145d7-1dc5-421e-a0ad-79e9a1bdc41a$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$検索結果を全件取得するメソッド$pb$, 2, $pb$fill_blank$pb$, $pb$SELECT の結果を全件まとめて取得するメソッド名を書いてください。
  
  $tasks = $stmt->__________();$pb$, $pb$メソッド名だけを書くこと$pb$, $pb$一覧表示でよく使います。$pb$, $pb$fetchAll$pb$, $pb$`fetchAll()` で結果セットをまとめて受け取れます。$pb$, $pb$`fetch` は1件ずつ取得する形で、全件まとめてではありません。$pb$, 3405, TRUE),
  ($pb$e8a4a7b2-b171-4ba2-a4ea-465ceba95dbc$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$名前付きプレースホルダへ値を入れるメソッド$pb$, 3, $pb$fill_blank$pb$, $pb$PDO の名前付きプレースホルダ `:title` に値をセットするメソッド名を書いてください。
  
  $stmt->__________(":title", $title);$pb$, $pb$メソッド名だけを書くこと$pb$, $pb$execute に直接配列を渡さない形です。$pb$, $pb$bindValue$pb$, $pb$`bindValue()` でプレースホルダへ値を関連付けられます。$pb$, $pb$`setValue` は PDOStatement の標準メソッドではありません。$pb$, 3406, TRUE),
  ($pb$02d15bdb-43b4-4ea1-a61e-30e791b6d8e3$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$XSS対策で出力前に使う関数$pb$, 1, $pb$fill_blank$pb$, $pb$ユーザー入力を画面へそのまま出さず、安全に表示するためによく使う関数を書いてください。
  
  echo __________($title, ENT_QUOTES, "UTF-8");$pb$, $pb$関数名だけを書くこと$pb$, $pb$`<script>` などをそのまま表示させないための対策です。$pb$, $pb$htmlspecialchars$pb$, $pb$`htmlspecialchars()` は XSS 対策の基本で、出力時に特殊文字をエスケープします。$pb$, $pb$`strip_tags` だけでは出力時エスケープの代わりになりません。$pb$, 3501, TRUE),
  ($pb$ee26698f-2233-4061-a531-6555be5e777b$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$SQLインジェクション対策の基本手法$pb$, 2, $pb$fill_blank$pb$, $pb$SQL インジェクション対策として、値を直接文字列連結せずに使う基本手法を書いてください。
  
  __________ statement$pb$, $pb$英単語2語で答えること$pb$, $pb$PDO の prepare と一緒に覚える重要語です。$pb$, $pb$prepared$pb$, $pb$prepared statement を使うと、値と SQL 構造を分けて扱えます。$pb$, $pb$`escape statement` という一般的な用語は使いません。$pb$, 3502, TRUE),
  ($pb$68a57bb8-13c6-4a06-a08d-801fb6b79fa3$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$CSRF対策でサーバ側に保存しやすい領域$pb$, 2, $pb$fill_blank$pb$, $pb$CSRF トークンをサーバ側に保存して比較するときに、PHP でよく使う仕組みを書いてください。
  
  __________$pb$, $pb$英単語で答えること$pb$, $pb$`$_SESSION` と関係があります。$pb$, $pb$session$pb$, $pb$CSRF トークンは session に保存してフォーム送信値と比較する構成が基本です。$pb$, $pb$`cookie` だけに置くと比較元として扱いにくく、基本形としては session が先です。$pb$, 3503, TRUE),
  ($pb$1de61bfe-fcee-419e-a038-5456b149f284$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$パスワードを安全にハッシュ化する関数$pb$, 2, $pb$fill_blank$pb$, $pb$パスワードを安全に保存するために、PHP でハッシュ化するときの基本関数を書いてください。
  
  $hash = __________($password, PASSWORD_DEFAULT);$pb$, $pb$関数名だけを書くこと$pb$, $pb$平文保存は避けます。$pb$, $pb$password_hash$pb$, $pb$`password_hash()` はパスワード保存時の基本関数です。$pb$, $pb$`md5` は学習初期でも推奨されない古い方法です。$pb$, 3504, TRUE),
  ($pb$08b04ce6-65bf-4097-a831-b6a4dabfef42$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$ログイン時にハッシュ照合する関数$pb$, 2, $pb$fill_blank$pb$, $pb$入力パスワードと保存済みハッシュを照合するときの関数名を書いてください。
  
  if (__________($password, $hash)) {
    echo "OK";
  }$pb$, $pb$関数名だけを書くこと$pb$, $pb$`password_hash` と対になる関数です。$pb$, $pb$password_verify$pb$, $pb$`password_verify()` で平文入力と保存済みハッシュを比較できます。$pb$, $pb$`password_check` は標準関数ではありません。$pb$, 3505, TRUE),
  ($pb$2f918472-b5b0-479f-aa7e-44c65708d3ca$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$CSRFトークンをフォームで送るinput type$pb$, 2, $pb$fill_blank$pb$, $pb$CSRF トークンをフォームに含めるとき、`input` タグの `type` 属性に入れる値を書いてください。
  
  <input type="__________" name="token" value="<?= $token ?>">$pb$, $pb$値だけを書くこと$pb$, $pb$画面には見せない値です。$pb$, $pb$hidden$pb$, $pb$CSRF トークンは hidden input で送るのが基本形です。$pb$, $pb$`text` にすると画面に出てしまい、フォームとして不自然です。$pb$, 3506, TRUE),
  ($pb$c559c037-a8d1-4ddc-a8c9-144d72c8b3ef$pb$, $pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$条件分岐の基本キーワード$pb$, 1, $pb$fill_blank$pb$, $pb$PHP でも Java でも条件分岐で使う基本キーワードを書いてください。
  
  __________ ($score >= 80) {
    echo "合格";
  }$pb$, $pb$キーワードだけを書くこと$pb$, $pb$両言語で共通です。$pb$, $pb$if$pb$, $pb$`if` は PHP と Java のどちらでも基本的な条件分岐で使います。$pb$, $pb$`when` はこの2言語の基本構文ではありません。$pb$, 3601, TRUE),
  ($pb$482f9d4d-4c36-4474-adc6-fe38b92e6a68$pb$, $pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$繰り返し処理の基本キーワード$pb$, 1, $pb$fill_blank$pb$, $pb$PHP と Java の両方で使う、基本的な繰り返し処理のキーワードを書いてください。
  
  __________ ($i = 0; $i < 3; $i++) {
    echo $i;
  }$pb$, $pb$キーワードだけを書くこと$pb$, $pb$添字つきの繰り返しです。$pb$, $pb$for$pb$, $pb$`for` は両言語で共通して使う繰り返し構文です。$pb$, $pb$`repeat` はどちらの基本構文でもありません。$pb$, 3602, TRUE),
  ($pb$60881dfa-eb2d-4524-aaa3-9020d133c017$pb$, $pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$値を返すキーワード$pb$, 1, $pb$fill_blank$pb$, $pb$関数やメソッドから値を返すときに使うキーワードを書いてください。
  
  __________ $result;$pb$, $pb$キーワードだけを書くこと$pb$, $pb$PHP でも Java でも共通です。$pb$, $pb$return$pb$, $pb$`return` は処理結果を呼び出し元へ返すときの基本キーワードです。$pb$, $pb$`yield` は別用途で、基本の返却とは違います。$pb$, 3603, TRUE),
  ($pb$19019cc5-f00a-417f-a6d8-1419a4c16ddb$pb$, $pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$クラス定義のキーワード$pb$, 1, $pb$fill_blank$pb$, $pb$PHP でも Java でもクラス定義で使うキーワードを書いてください。
  
  __________ Task {$pb$, $pb$キーワードだけを書くこと$pb$, $pb$オブジェクト指向の基本です。$pb$, $pb$class$pb$, $pb$`class` は両言語でクラスを定義するときの共通キーワードです。$pb$, $pb$`object` は型の概念としては近くても、定義キーワードではありません。$pb$, 3604, TRUE),
  ($pb$c06c8442-fa31-4b54-aeb1-d8ebe3f1cafd$pb$, $pb$ea2f3296-cd10-4951-a4c7-99addbd16fa7$pb$, $pb$公開メンバを表すアクセス修飾子$pb$, 1, $pb$fill_blank$pb$, $pb$PHP と Java のどちらでも、公開されたメソッドやプロパティによく使うアクセス修飾子を書いてください。
  
  __________ function save() {$pb$, $pb$修飾子だけを書くこと$pb$, $pb$`private` の反対側で考えると出やすいです。$pb$, $pb$public$pb$, $pb$`public` は外部からアクセス可能にするときの基本修飾子です。$pb$, $pb$`open` はこの2言語のアクセス修飾子ではありません。$pb$, 3605, TRUE),
  ($pb$f1fdfabe-c123-4ecf-ad27-77175f78bb59$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$POST受け取りと必須チェックを行う保存処理を書く$pb$, 3, $pb$normal$pb$, $pb$フォームから送られた `title` を `$_POST` で受け取り、空ならエラー表示、空でなければ `list.php` へリダイレクトする PHP コードを書いてください。$pb$, $pb$`$_POST["title"]` を使うこと
  `empty($title)` で必須チェックすること
  正常時は `header("Location: list.php");` を使うこと$pb$, $pb$研修では、フォーム受け取りから簡単な分岐までを 1 つの流れで書く問題がよく出ます。$pb$, $pb$$title = $_POST["title"];
  
  if (empty($title)) {
    echo "タイトルは必須です";
  } else {
    header("Location: list.php");
  }$pb$, $pb$PHP の基本力として、受け取り・バリデーション・分岐・リダイレクトを一連で書けることは重要です。$pb$, $pb$`name` 属性と `$_POST` のキー名がずれると、受け取り自体ができなくなります。$pb$, 3606, TRUE),
  ($pb$c27bdc1a-6da4-4771-ae14-74863b333f99$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$PDOで更新処理を書く$pb$, 3, $pb$normal$pb$, $pb$`id` と `title` を受け取り、`tasks` テーブルのタイトルを更新する PDO のコードを書いてください。$pb$, $pb$`prepare` を使うこと
  `UPDATE tasks SET title = ? WHERE id = ?` を書くこと
  `execute([$title, $id])` を使うこと$pb$, $pb$研修では SELECT だけでなく UPDATE を安全に書けるかもよく見られます。$pb$, $pb$$stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");
  $stmt->execute([$title, $id]);$pb$, $pb$更新処理でも prepared statement を使うことで、安全で読みやすいコードになります。$pb$, $pb$SQL を文字列連結で組み立てると、ミスや SQL インジェクションの温床になりやすいです。$pb$, 3607, TRUE),
  ($pb$a500796a-7c25-46c0-ab45-aa96db1fbf3c$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$一覧画面でXSS対策しながらタイトル表示を書く$pb$, 3, $pb$normal$pb$, $pb$`$tasks` の各要素にある `title` を一覧表示したいです。XSS 対策をしながら表示する `foreach` のコードを書いてください。$pb$, $pb$`foreach ($tasks as $task)` を使うこと
  `htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8")` を使うこと
  `echo` で出力すること$pb$, $pb$PHP では保存時よりも「出力時エスケープ」を確実にするのが基本です。$pb$, $pb$foreach ($tasks as $task) {
    echo htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8");
  }$pb$, $pb$一覧表示は単純に見えて、XSS 対策を含めて書けるかが実践力の差になりやすいです。$pb$, $pb$`echo $task["title"];` のままだと、悪意ある文字列をそのまま表示してしまう可能性があります。$pb$, 3608, TRUE),
  ($pb$c89b12bd-f572-45c0-acdc-2d7fd6e0f16b$pb$, $pb$b661ed46-4179-47bf-a9b7-c098d114a32f$pb$, $pb$フォームの name 不一致で値が取れないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のフォーム送信後、`$_POST["title"]` が取れません。原因を直した HTML を書いてください。
  
  ```php
  <form method="post" action="save.php">
    <input type="text" name="task_title">
    <button type="submit">保存</button>
  </form>
  ```
  
  ```php
  $title = $_POST["title"];
  ```$pb$, $pb$原因が `name` の不一致であることを反映すること
  修正後のフォーム HTML を書くこと$pb$, $pb$`$_POST["title"]` で受けるなら、フォーム側の `name` も同じキーで送る必要があります。$pb$, $pb$<form method="post" action="save.php">
    <input type="text" name="title">
    <button type="submit">保存</button>
  </form>$pb$, $pb$PHP は `name` 属性をキーとして送信値を受け取ります。キー名がずれると `$_POST["title"]` には入りません。$pb$, $pb$`id` を変えても `$_POST` のキーは直りません。送信値に影響するのは `name` 属性です。$pb$, 3609, TRUE),
  ($pb$01189ff0-01ab-4256-aefd-c1200910b883$pb$, $pb$94e9de1f-5272-48bf-a63c-23b96deef40b$pb$, $pb$XSS 対策なしで表示しているバグを直す$pb$, 3, $pb$normal$pb$, $pb$次の一覧表示は XSS の危険があります。安全に表示するコードへ修正してください。
  
  ```php
  foreach ($tasks as $task) {
    echo $task["title"];
  }
  ```$pb$, $pb$`htmlspecialchars` を使うこと
  `ENT_QUOTES` と `UTF-8` を指定すること$pb$, $pb$ユーザー入力をそのまま HTML に出すと危険です。表示前にエスケープします。$pb$, $pb$foreach ($tasks as $task) {
    echo htmlspecialchars($task["title"], ENT_QUOTES, "UTF-8");
  }$pb$, $pb$HTML に埋め込む前にエスケープすることで、悪意あるタグやスクリプトがそのまま実行されるのを防げます。$pb$, $pb$`strip_tags` だけでは不十分なケースがあります。表示時の基本は `htmlspecialchars` です。$pb$, 3610, TRUE),
  ($pb$1e3650ff-4e9a-4c25-a5ab-af79864998eb$pb$, $pb$4e9359ae-97ce-4a88-a039-3415aacc2ff2$pb$, $pb$PDO で execute し忘れて更新されないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のコードは SQL を準備していますが、実行されないためデータが更新されません。正しく動くコードを書いてください。
  
  ```php
  $stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");
  ```$pb$, $pb$`execute([$title, $id])` を使うこと
  2 つの値を正しい順で渡すこと$pb$, $pb$PDO は `prepare` だけでは実行されません。プレースホルダに値を渡して実行する処理が必要です。$pb$, $pb$$stmt = $pdo->prepare("UPDATE tasks SET title = ? WHERE id = ?");
  $stmt->execute([$title, $id]);$pb$, $pb$`prepare` は実行準備までです。実際に DB を更新するには `execute` が必要です。$pb$, $pb$`execute([$id, $title])` のように順番を逆にすると、意図しない値で更新されます。$pb$, 3611, TRUE),
  ($pb$52872652-3340-4b44-a1e8-2261ec291492$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$HTML文書の開始タグ$pb$, 1, $pb$fill_blank$pb$, $pb$HTML 文書の最上位で使う開始タグを書いてください。
  
  <__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$ページ全体を囲むタグです。$pb$, $pb$html$pb$, $pb$`<html>` は HTML 文書全体を表す基本タグです。$pb$, $pb$`body` は本文用で、文書全体を囲む最上位タグではありません。$pb$, 4101, TRUE),
  ($pb$15caf0fb-7042-46e8-a4ea-c3961da76e1e$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$ページタイトルを入れるタグ$pb$, 1, $pb$fill_blank$pb$, $pb$ブラウザのタブに表示されるタイトルを入れるタグを書いてください。
  
  <__________>My Page</__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$`head` の中に書くことが多いです。$pb$, $pb$title$pb$, $pb$`<title>` はブラウザタブや検索結果のタイトルとして使われます。$pb$, $pb$`h1` はページ本文の見出しで、タブタイトルではありません。$pb$, 4102, TRUE),
  ($pb$de0c5d48-366e-4657-af4b-d6ad05aca76d$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$本文を囲むタグ$pb$, 1, $pb$fill_blank$pb$, $pb$画面に表示される本文を囲むタグを書いてください。
  
  <__________>
    <h1>Hello</h1>
  </__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$見出しや文章などを入れる領域です。$pb$, $pb$body$pb$, $pb$`<body>` の中に、画面へ表示したい HTML を書きます。$pb$, $pb$`head` は設定やメタ情報用で、本文表示用ではありません。$pb$, 4103, TRUE),
  ($pb$7c6ff78d-0826-4e2f-a8bd-a86ad52a6dc0$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$最も大きい見出しタグ$pb$, 1, $pb$fill_blank$pb$, $pb$HTML で最も大きい見出しに使うタグを書いてください。
  
  <__________>見出し</__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$`h` から始まる見出しタグの最初です。$pb$, $pb$h1$pb$, $pb$`<h1>` はページ内で最上位の見出しとして使います。$pb$, $pb$`title` はブラウザタブ用で、本文の見出しではありません。$pb$, 4104, TRUE),
  ($pb$73ecd274-522e-4ba8-a897-c3860002e5e0$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$段落を表すタグ$pb$, 1, $pb$fill_blank$pb$, $pb$文章の段落を表すタグを書いてください。
  
  <__________>これは説明文です。</__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$`paragraph` の頭文字です。$pb$, $pb$p$pb$, $pb$`<p>` は文章の段落を表す基本タグです。$pb$, $pb$`span` はインライン要素で、段落全体の意味づけとは異なります。$pb$, 4105, TRUE),
  ($pb$f0e2d578-025a-45f3-a4f8-c39c95cf3fb1$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$画像を表示するタグ$pb$, 1, $pb$fill_blank$pb$, $pb$画像を表示するタグを書いてください。
  
  <__________ src="cat.png" alt="猫">$pb$, $pb$タグ名だけを書くこと$pb$, $pb$`image` ではなく短い形です。$pb$, $pb$img$pb$, $pb$`<img>` は画像を表示するためのタグです。$pb$, $pb$`image` は HTML の標準タグ名ではありません。$pb$, 4106, TRUE),
  ($pb$b77fcb17-7c8c-410e-a415-51a045d4713b$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$リンク先URLを入れる属性$pb$, 1, $pb$fill_blank$pb$, $pb$リンクタグで遷移先 URL を指定する属性を書いてください。
  
  <a __________="https://example.com">サイトへ</a>$pb$, $pb$属性名だけを書くこと$pb$, $pb$`https://...` を入れる場所です。$pb$, $pb$href$pb$, $pb$`href` はリンク先 URL を表す属性です。$pb$, $pb$`src` は画像やスクリプトでよく使いますが、リンク先指定ではありません。$pb$, 4107, TRUE),
  ($pb$9d210272-9a03-4bca-a7fc-362b0089484f$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$横並びで意味を持たない汎用タグ$pb$, 2, $pb$fill_blank$pb$, $pb$主にインライン要素として使う、意味を持たない汎用タグを書いてください。
  
  <__________ class="highlight">重要</__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$`div` のインライン版です。$pb$, $pb$span$pb$, $pb$`<span>` は文字の一部など、インライン範囲へスタイルを当てたいときに使います。$pb$, $pb$`div` はブロック要素なので、同じ役割ではありません。$pb$, 4108, TRUE),
  ($pb$006cec4a-098b-477b-ab31-5a91da2624aa$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$フォーム全体を囲むタグ$pb$, 1, $pb$fill_blank$pb$, $pb$入力欄や送信ボタンをまとめるタグを書いてください。
  
  <__________ action="save.php" method="post">$pb$, $pb$タグ名だけを書くこと$pb$, $pb$送信先や送信方式を指定します。$pb$, $pb$form$pb$, $pb$`<form>` で入力要素をまとめて送信できます。$pb$, $pb$`input` は入力欄1つを表すタグで、フォーム全体ではありません。$pb$, 4201, TRUE),
  ($pb$82ca186f-a6a7-42d7-a9a5-6b9e9c6d4c97$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$1行入力欄を作るタグ$pb$, 1, $pb$fill_blank$pb$, $pb$1 行のテキスト入力欄を作るタグを書いてください。
  
  <__________ type="text" name="title">$pb$, $pb$タグ名だけを書くこと$pb$, $pb$フォームで最もよく使う入力タグです。$pb$, $pb$input$pb$, $pb$`<input>` はテキストやチェックボックスなど多くの入力に使えます。$pb$, $pb$`textarea` は複数行入力用です。$pb$, 4202, TRUE),
  ($pb$b9b59fa8-bc0d-4eb6-aaae-e59deb112fab$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$複数行入力欄のタグ$pb$, 1, $pb$fill_blank$pb$, $pb$複数行の文章を入力できるタグを書いてください。
  
  <__________ name="message"></__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$問い合わせフォームの本文などで使います。$pb$, $pb$textarea$pb$, $pb$`<textarea>` は複数行テキスト入力用のタグです。$pb$, $pb$`input` は基本的に1行入力です。$pb$, 4203, TRUE),
  ($pb$de8b1b3e-0d53-4ae0-a90d-08484a8a55ba$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$ラベルと入力欄を関連付けるタグ$pb$, 1, $pb$fill_blank$pb$, $pb$入力欄の説明文として使い、クリックで入力欄にフォーカスしやすくなるタグを書いてください。
  
  <__________ for="email">メールアドレス</__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$アクセシビリティでも重要です。$pb$, $pb$label$pb$, $pb$`<label>` を使うと、入力欄の意味がわかりやすくなります。$pb$, $pb$`span` では説明文として見えても、関連付けの意味は持てません。$pb$, 4204, TRUE),
  ($pb$b7866694-7f97-4967-a198-339b8bb0387f$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$送信ボタンに使うtype属性$pb$, 1, $pb$fill_blank$pb$, $pb$フォーム送信ボタンにしたいとき、`button` タグの `type` に入れる値を書いてください。
  
  <button type="__________">送信</button>$pb$, $pb$値だけを書くこと$pb$, $pb$フォームを送信する役割です。$pb$, $pb$submit$pb$, $pb$`type="submit"` にするとフォーム送信ボタンになります。$pb$, $pb$`button` はタグ名で、type 属性の値ではありません。$pb$, 4205, TRUE),
  ($pb$00a30447-466e-479b-a767-a26ffbe04702$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$選択肢をプルダウン表示するタグ$pb$, 2, $pb$fill_blank$pb$, $pb$都道府県などをプルダウンで選ばせるときに使うタグを書いてください。
  
  <__________ name="prefecture">$pb$, $pb$タグ名だけを書くこと$pb$, $pb$中に `option` を入れます。$pb$, $pb$select$pb$, $pb$`<select>` は複数候補から1つ以上選ぶ UI に使います。$pb$, $pb$`option` は中の選択肢で、外側のタグではありません。$pb$, 4206, TRUE),
  ($pb$8b225afd-c11e-4f87-a115-b4dc037448d7$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$CSSで文字色を変えるプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$文字色を赤にしたいときに使う CSS プロパティを書いてください。
  
  __________: red;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$背景色ではありません。$pb$, $pb$color$pb$, $pb$`color` は文字の色を変える基本プロパティです。$pb$, $pb$`background-color` は背景色を変えるものです。$pb$, 4301, TRUE),
  ($pb$9c6342cc-9703-436a-ac75-dccbbcb211d1$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$背景色を変えるプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$要素の背景色を青にしたいときに使う CSS プロパティを書いてください。
  
  __________: blue;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$文字色ではなく背景です。$pb$, $pb$background-color$pb$, $pb$`background-color` で背景色を指定できます。$pb$, $pb$`color` は文字色なので用途が違います。$pb$, 4302, TRUE),
  ($pb$b81fd30c-83cf-4224-a2f6-c7f9e0435926$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$文字サイズを変えるプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$文字サイズを 24px にしたいときの CSS プロパティを書いてください。
  
  __________: 24px;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$`font` から始まる基本プロパティです。$pb$, $pb$font-size$pb$, $pb$`font-size` で文字の大きさを調整できます。$pb$, $pb$`text-size` は CSS の基本プロパティではありません。$pb$, 4303, TRUE),
  ($pb$12758e94-7ae1-4deb-a44e-8c898bdcf08c$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$外側の余白を表すプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$要素の外側に余白を付ける CSS プロパティを書いてください。
  
  __________: 16px;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$内側の余白ではありません。$pb$, $pb$margin$pb$, $pb$`margin` は要素の外側の余白です。$pb$, $pb$`padding` は内側の余白です。$pb$, 4304, TRUE),
  ($pb$5ef10e3f-34f1-4613-ae31-501fd263ff35$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$内側の余白を表すプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$要素の内側に余白を付ける CSS プロパティを書いてください。
  
  __________: 12px;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$border の内側の余白です。$pb$, $pb$padding$pb$, $pb$`padding` は要素の内側の余白です。$pb$, $pb$`margin` は外側の余白なので意味が違います。$pb$, 4305, TRUE),
  ($pb$4e2cdd0f-6d2e-4d96-a65d-5a8295cd0afd$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$枠線を付けるプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$要素に `1px solid #ccc` の枠線を付ける CSS プロパティを書いてください。
  
  __________: 1px solid #ccc;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$ボックスの縁を表します。$pb$, $pb$border$pb$, $pb$`border` で太さ・線種・色をまとめて指定できます。$pb$, $pb$`outline` とは別の基本プロパティです。$pb$, 4306, TRUE),
  ($pb$447474e4-a600-4759-a7e9-c6984f199161$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$classセレクタの記号$pb$, 1, $pb$fill_blank$pb$, $pb$CSS で class セレクタを書くとき、クラス名の前に付ける記号を書いてください。
  
  __________card {$pb$, $pb$記号だけを書くこと$pb$, $pb$id セレクタとは違う記号です。$pb$, $pb$.$pb$, $pb$class セレクタは `.card` のようにドットで書きます。$pb$, $pb$`#` は id セレクタで使う記号です。$pb$, 4307, TRUE),
  ($pb$a762256c-ecea-4a62-ae02-323b9b1b1631$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$idセレクタの記号$pb$, 1, $pb$fill_blank$pb$, $pb$CSS で id セレクタを書くとき、id 名の前に付ける記号を書いてください。
  
  __________header {$pb$, $pb$記号だけを書くこと$pb$, $pb$class セレクタの `.` とは別です。$pb$, $pb$#$pb$, $pb$id セレクタは `#header` のようにシャープで書きます。$pb$, $pb$`.` は class セレクタなので用途が異なります。$pb$, 4308, TRUE),
  ($pb$76eca1df-94b0-464b-ada5-06272850998c$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$Flexboxを有効にするdisplayの値$pb$, 2, $pb$fill_blank$pb$, $pb$親要素で Flexbox を使いたいとき、`display` に入れる値を書いてください。
  
  display: __________;$pb$, $pb$値だけを書くこと$pb$, $pb$横並びレイアウトでよく使います。$pb$, $pb$flex$pb$, $pb$`display: flex;` で Flexbox レイアウトが有効になります。$pb$, $pb$`block` では Flexbox は有効になりません。$pb$, 4401, TRUE),
  ($pb$2a420f68-1505-49d7-a996-97f95f317710$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$Flexboxで横方向に中央揃えするプロパティ$pb$, 2, $pb$fill_blank$pb$, $pb$Flexbox で主軸方向に中央揃えしたいです。使う CSS プロパティを書いてください。
  
  __________: center;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$横並びなら左右中央揃えに関係します。$pb$, $pb$justify-content$pb$, $pb$`justify-content` は主軸方向の並び方を制御します。$pb$, $pb$`align-items` は交差軸方向なので、意味が違います。$pb$, 4402, TRUE),
  ($pb$2b421592-8fa5-479f-a2b5-a32fbce0f608$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$Flexboxで縦方向に中央揃えするプロパティ$pb$, 2, $pb$fill_blank$pb$, $pb$Flexbox で交差軸方向に中央揃えしたいです。使う CSS プロパティを書いてください。
  
  __________: center;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$横並びなら上下中央揃えに関係します。$pb$, $pb$align-items$pb$, $pb$`align-items` は交差軸方向の配置を制御します。$pb$, $pb$`justify-content` は主軸方向です。$pb$, 4403, TRUE),
  ($pb$19452e7b-ae86-4e1f-a97e-9322f91d6615$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$要素を縦並びにするflex-directionの値$pb$, 2, $pb$fill_blank$pb$, $pb$Flexbox で要素を縦並びにしたいです。`flex-direction` に入れる値を書いてください。
  
  flex-direction: __________;$pb$, $pb$値だけを書くこと$pb$, $pb$列方向を表します。$pb$, $pb$column$pb$, $pb$`flex-direction: column;` で要素を縦方向へ並べられます。$pb$, $pb$`row` は横並びです。$pb$, 4404, TRUE),
  ($pb$3a44e8be-2127-424c-a4f3-ff7d38ce5792$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$中央寄せレイアウトで横幅指定によく使う単位$pb$, 2, $pb$fill_blank$pb$, $pb$コンテンツ幅を `960` の画面幅基準で指定したいとき、`width: 960__________;` に入れる単位を書いてください。$pb$, $pb$単位だけを書くこと$pb$, $pb$固定幅の基本単位です。$pb$, $pb$px$pb$, $pb$`px` は固定サイズ指定で最も基本的な単位です。$pb$, $pb$`%` は親要素基準なので、固定幅指定とは意味が異なります。$pb$, 4405, TRUE),
  ($pb$5abe3906-9280-45df-ace9-e5beb3c03f75$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$要素を非表示にするdisplayの値$pb$, 1, $pb$fill_blank$pb$, $pb$要素を表示しないようにしたいとき、`display` に入れる値を書いてください。
  
  display: __________;$pb$, $pb$値だけを書くこと$pb$, $pb$完全に表示されなくなります。$pb$, $pb$none$pb$, $pb$`display: none;` で要素を画面上から非表示にできます。$pb$, $pb$`hidden` は `visibility` の値として使うことがありますが、ここでは `display` の値を問っています。$pb$, 4406, TRUE),
  ($pb$7921ab4a-d171-457e-af88-ec2b7443ffef$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$角を丸くするプロパティ$pb$, 1, $pb$fill_blank$pb$, $pb$ボタンの角を丸くするときに使う CSS プロパティを書いてください。
  
  __________: 8px;$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$border と一緒によく使います。$pb$, $pb$border-radius$pb$, $pb$`border-radius` で角丸を指定できます。$pb$, $pb$`radius` だけでは CSS の基本プロパティとして成立しません。$pb$, 4407, TRUE),
  ($pb$743e7f9b-fd2b-4258-ad63-89011719afb6$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$影を付けるプロパティ$pb$, 2, $pb$fill_blank$pb$, $pb$カードに影を付けるときによく使う CSS プロパティを書いてください。
  
  __________: 0 4px 12px rgba(0, 0, 0, 0.1);$pb$, $pb$プロパティ名だけを書くこと$pb$, $pb$ボックス全体の影です。$pb$, $pb$box-shadow$pb$, $pb$`box-shadow` で要素に影を付けられます。$pb$, $pb$`text-shadow` は文字の影なので用途が違います。$pb$, 4408, TRUE),
  ($pb$ad9676aa-5f67-4639-a467-061bb3232ca8$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$メディアクエリの開始キーワード$pb$, 2, $pb$fill_blank$pb$, $pb$レスポンシブ対応で画面幅ごとに CSS を切り替えるとき、書き始めに使うキーワードを書いてください。
  
  __________ (max-width: 768px) {$pb$, $pb$キーワードだけを書くこと$pb$, $pb$`@` から始まります。$pb$, $pb$@media$pb$, $pb$`@media` を使うと、条件付きで CSS を適用できます。$pb$, $pb$`media` だけでは CSS の構文として不完全です。$pb$, 4501, TRUE),
  ($pb$2fc377ac-0c01-4762-a276-949a04182096$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$スマホ幅以下を表す比較条件$pb$, 2, $pb$fill_blank$pb$, $pb$画面幅が 768px 以下のときにスタイルを切り替えたいです。メディアクエリで使う条件名を書いてください。
  
  @media (__________: 768px) {$pb$, $pb$条件名だけを書くこと$pb$, $pb$`min-width` の反対側です。$pb$, $pb$max-width$pb$, $pb$`max-width` を使うと、指定値以下の画面幅にスタイルを適用できます。$pb$, $pb$`min-width` だと指定値以上に適用されてしまいます。$pb$, 4502, TRUE),
  ($pb$d6d02781-1add-4cde-a45e-f8bfb98e46f0$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$画像を親幅に合わせる幅指定$pb$, 2, $pb$fill_blank$pb$, $pb$画像が親要素からはみ出ないように、幅を親に合わせて縮めたいです。`width` に入れる値を書いてください。
  
  img {
    width: __________;
  }$pb$, $pb$値だけを書くこと$pb$, $pb$親の幅いっぱいを表します。$pb$, $pb$100%$pb$, $pb$`width: 100%;` で親要素の幅に合わせやすくなります。$pb$, $pb$`100px` だと固定サイズになり、レスポンシブではありません。$pb$, 4503, TRUE),
  ($pb$6cb4efe1-4df3-4ece-a5de-d0786a8d0f4e$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$ビューポート設定で使うmetaタグ名$pb$, 2, $pb$fill_blank$pb$, $pb$スマホで適切に表示するために使う meta タグの `name` 属性値を書いてください。
  
  <meta name="__________" content="width=device-width, initial-scale=1.0">$pb$, $pb$属性値だけを書くこと$pb$, $pb$画面幅に関係する英単語です。$pb$, $pb$viewport$pb$, $pb$`viewport` 設定はスマホ表示の基本です。$pb$, $pb$`screen` はこの meta 設定の名前ではありません。$pb$, 4504, TRUE),
  ($pb$bd96a26e-0a1d-4b70-aed9-9c75fbcd0921$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$横並びを折り返すflex-wrapの値$pb$, 3, $pb$fill_blank$pb$, $pb$カードが画面幅に応じて次の行へ折り返すようにしたいです。`flex-wrap` に入れる値を書いてください。
  
  flex-wrap: __________;$pb$, $pb$値だけを書くこと$pb$, $pb$`nowrap` の反対です。$pb$, $pb$wrap$pb$, $pb$`flex-wrap: wrap;` で要素を折り返せます。$pb$, $pb$`break` は CSS の値ではありません。$pb$, 4505, TRUE),
  ($pb$d4c2bba5-38f7-4af4-ab5c-291d238b007f$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$ページ上部の意味を持つタグ$pb$, 2, $pb$fill_blank$pb$, $pb$ページ上部やサイトのヘッダー領域に使うセマンティックタグを書いてください。
  
  <__________>
    <h1>Site</h1>
  </__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$HTML5 でよく使う意味付きタグです。$pb$, $pb$header$pb$, $pb$`<header>` はページやセクションの先頭部分を表す意味付きタグです。$pb$, $pb$`div` でも見た目は作れますが、意味づけとしては弱くなります。$pb$, 4601, TRUE),
  ($pb$8813af32-b0c5-480e-ae12-3ffd4624808a$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$主要なナビゲーションを表すタグ$pb$, 2, $pb$fill_blank$pb$, $pb$サイト内の主要リンク群を表すセマンティックタグを書いてください。
  
  <__________>
    <a href="/">Home</a>
  </__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$メニューやグローバルナビで使います。$pb$, $pb$nav$pb$, $pb$`<nav>` は主要なナビゲーション領域を表します。$pb$, $pb$`menu` は一般的な主要ナビの基本タグとしてはまず `nav` を覚える方が自然です。$pb$, 4602, TRUE),
  ($pb$d02cda80-c30d-4a81-aa34-d7f209910356$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$ページの主要コンテンツを表すタグ$pb$, 2, $pb$fill_blank$pb$, $pb$そのページの中心となる主要コンテンツを表すタグを書いてください。
  
  <__________>
    <article>...</article>
  </__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$ページの主役となる内容です。$pb$, $pb$main$pb$, $pb$`<main>` はページの主要内容を表す意味付きタグです。$pb$, $pb$`body` はページ全体で、主要部分だけを表すタグではありません。$pb$, 4603, TRUE),
  ($pb$97f21482-7cae-4858-aa5f-eb44113dfe19$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$画像の代替説明に使う属性$pb$, 1, $pb$fill_blank$pb$, $pb$画像が読めないときの代替説明や読み上げのために使う属性を書いてください。
  
  <img src="logo.png" __________="会社ロゴ">$pb$, $pb$属性名だけを書くこと$pb$, $pb$アクセシビリティでも重要です。$pb$, $pb$alt$pb$, $pb$`alt` 属性は画像の意味を文字で伝えるために重要です。$pb$, $pb$`title` は補足表示であり、代替テキストの基本ではありません。$pb$, 4604, TRUE),
  ($pb$d2b366cf-5184-45f1-aadb-fe3a849ac0ab$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$ページ下部を表すセマンティックタグ$pb$, 2, $pb$fill_blank$pb$, $pb$著作権表示や補助リンクなど、ページ下部の領域を表すタグを書いてください。
  
  <__________>
    <small>Copyright</small>
  </__________>$pb$, $pb$タグ名だけを書くこと$pb$, $pb$header の反対側で覚えると出やすいです。$pb$, $pb$footer$pb$, $pb$`<footer>` はページやセクションの末尾情報を表します。$pb$, $pb$`bottom` は HTML の標準タグではありません。$pb$, 4605, TRUE),
  ($pb$8922781a-6b83-4f7b-a201-0bfd047da2d2$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$見出しと説明文の基本HTMLを書く$pb$, 2, $pb$normal$pb$, $pb$ページの先頭に「学習ダッシュボード」という見出しと、「今日の進捗を確認します。」という説明文を表示する HTML を書いてください。$pb$, $pb$`h1` を使うこと
  説明文は `p` タグで書くこと
  2行の HTML にすること$pb$, $pb$最初の画面でよくある、見出し + 説明文の基本形です。$pb$, $pb$<h1>学習ダッシュボード</h1>
  <p>今日の進捗を確認します。</p>$pb$, $pb$HTML の基本は、見出しと文章を適切な意味のタグで分けて書くことです。$pb$, $pb$`div` だけで全部書くと見た目は作れても、意味づけの練習として弱くなります。$pb$, 4606, TRUE),
  ($pb$3535a4ab-522a-44ef-a13f-56d7ce4e0007$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$画像付きリンクのHTMLを書く$pb$, 2, $pb$normal$pb$, $pb$`logo.png` を表示し、その画像をクリックすると `/` へ移動する HTML を書いてください。代替テキストは「トップへ戻る」です。$pb$, $pb$`a` タグを使うこと
  `img` タグを使うこと
  `href` と `alt` を正しく書くこと$pb$, $pb$画像をリンクで包む形です。$pb$, $pb$<a href="/">
    <img src="logo.png" alt="トップへ戻る">
  </a>$pb$, $pb$リンクと画像を組み合わせるときも、`href` と `alt` を忘れないのが基本です。$pb$, $pb$`img` に `href` を直接書いてもリンクにはなりません。$pb$, 4607, TRUE),
  ($pb$d1c61808-a075-414a-aaa3-7853cfcf1749$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$お問い合わせフォームの最小HTMLを書く$pb$, 2, $pb$normal$pb$, $pb$POST で送信するお問い合わせフォームを書いてください。項目は「名前」の1つだけで、送信ボタンの文字は「送信」です。$pb$, $pb$`form` タグに `method="post"` を書くこと
  `input` に `name="name"` を書くこと
  送信ボタンを付けること$pb$, $pb$最小構成なので、入力欄は1つで大丈夫です。$pb$, $pb$<form method="post">
    <input type="text" name="name">
    <button type="submit">送信</button>
  </form>$pb$, $pb$フォームの基本は、送信方式・入力欄の name・送信ボタンの3点です。$pb$, $pb$`name` 属性がないと、サーバ側で値を受け取りにくくなります。$pb$, 4608, TRUE),
  ($pb$7da2a8d7-2478-4cd3-a7b2-334f8c8b245a$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$ラベル付きメール入力欄のHTMLを書く$pb$, 2, $pb$normal$pb$, $pb$「メールアドレス」というラベルと、`email` 型の入力欄を関連付けた HTML を書いてください。id と name はどちらも `email` にします。$pb$, $pb$`label` の `for` を使うこと
  `input type="email"` を使うこと
  `id="email"` と `name="email"` を書くこと$pb$, $pb$ラベルと入力欄が対応する形にします。$pb$, $pb$<label for="email">メールアドレス</label>
  <input type="email" id="email" name="email">$pb$, $pb$ラベルと入力欄を関連付けると、使いやすさとアクセシビリティが上がります。$pb$, $pb$`label` の `for` と `input` の `id` が一致しないと関連付けできません。$pb$, 4609, TRUE),
  ($pb$be5581c0-db27-436d-adbe-b38d1fe4d70b$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$見出しの色と大きさを変えるCSSを書く$pb$, 2, $pb$normal$pb$, $pb$`h1` の文字色を `#2563eb`、文字サイズを `32px` にする CSS を書いてください。$pb$, $pb$`h1` セレクタを書くこと
  `color` を使うこと
  `font-size` を使うこと$pb$, $pb$プロパティは2つだけです。$pb$, $pb$h1 {
    color: #2563eb;
    font-size: 32px;
  }$pb$, $pb$CSS の基本は、セレクタを決めて必要なプロパティを素直に書くことです。$pb$, $pb$`text-color` のような名前は CSS の基本プロパティではありません。$pb$, 4610, TRUE),
  ($pb$5af5d798-fa7b-48d5-a9c4-da3123d313ae$pb$, $pb$ac85ae8a-0c1b-4372-a882-56c466251c58$pb$, $pb$カードに余白と枠線を付けるCSSを書く$pb$, 2, $pb$normal$pb$, $pb$`.card` クラスに、内側の余白 `16px`、外側の余白 `24px`、薄いグレーの枠線 `1px solid #ddd` を付ける CSS を書いてください。$pb$, $pb$`.card` セレクタを書くこと
  `padding` と `margin` を使うこと
  `border` を書くこと$pb$, $pb$内側と外側の余白を混同しないのがポイントです。$pb$, $pb$.card {
    padding: 16px;
    margin: 24px;
    border: 1px solid #ddd;
  }$pb$, $pb$カード UI の基本は、padding・margin・border の役割を分けて書けることです。$pb$, $pb$`padding` と `margin` を逆にすると、見た目の意図がずれやすくなります。$pb$, 4611, TRUE),
  ($pb$7b648b45-7968-46f6-ad57-6c4889cb4393$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$Flexboxで横並び中央寄せのCSSを書く$pb$, 3, $pb$normal$pb$, $pb$`.menu` の子要素を横並びにし、左右中央寄せにする CSS を書いてください。$pb$, $pb$`display: flex` を使うこと
  `justify-content: center` を書くこと$pb$, $pb$主軸方向の中央寄せです。$pb$, $pb$.menu {
    display: flex;
    justify-content: center;
  }$pb$, $pb$Flexbox では、横並びの開始と主軸方向の配置をまずセットで覚えると使いやすいです。$pb$, $pb$`align-items: center` だけでは左右中央寄せにはなりません。$pb$, 4612, TRUE),
  ($pb$66b6db88-6181-4fae-a022-170e0cecebee$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$縦並びレイアウトのCSSを書く$pb$, 3, $pb$normal$pb$, $pb$`.sidebar` の中身を縦方向に並べる Flexbox の CSS を書いてください。$pb$, $pb$`display: flex` を使うこと
  `flex-direction: column` を書くこと$pb$, $pb$横並びから縦並びへ切り替える問題です。$pb$, $pb$.sidebar {
    display: flex;
    flex-direction: column;
  }$pb$, $pb$`flex-direction: column` を書けると、UI の組み立ての幅がかなり広がります。$pb$, $pb$`column` だけ単独で書いても CSS として成立しません。$pb$, 4613, TRUE),
  ($pb$55c57608-4e85-4938-a063-93f87a12e5ec$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$スマホ幅で縦並びに切り替えるmedia queryを書く$pb$, 3, $pb$normal$pb$, $pb$通常は横並びの `.cards` を、画面幅 `768px` 以下では縦並びに切り替える CSS を書いてください。$pb$, $pb$`@media (max-width: 768px)` を使うこと
  `.cards` に `flex-direction: column` を書くこと$pb$, $pb$親要素がすでに Flexbox になっている前提です。$pb$, $pb$@media (max-width: 768px) {
    .cards {
      flex-direction: column;
    }
  }$pb$, $pb$レスポンシブ対応では、どの幅で何を変えるかをはっきり書けることが大切です。$pb$, $pb$`min-width` を使うと、適用される画面幅の条件が逆になります。$pb$, 4614, TRUE),
  ($pb$818621c3-485f-4dbd-a34c-54e53ff8cfd4$pb$, $pb$ff5efa16-9f0b-4d9b-a5d2-19b72b2210ee$pb$, $pb$意味付きレイアウトのHTMLを書く$pb$, 3, $pb$normal$pb$, $pb$ページ上部にサイト名、中央に主要コンテンツ、下部に著作権表示を持つ HTML を、意味付きタグで3行で書いてください。$pb$, $pb$`header` を使うこと
  `main` を使うこと
  `footer` を使うこと$pb$, $pb$`div` ではなく、意味のあるタグを使う問題です。$pb$, $pb$<header>My Site</header>
  <main>主要コンテンツ</main>
  <footer>Copyright</footer>$pb$, $pb$セマンティックタグを使うと、構造が読みやすくなり、意図も伝わりやすくなります。$pb$, $pb$`div` だけで構造を作ると、見た目は作れても意味の練習として弱くなります。$pb$, 4615, TRUE),
  ($pb$6eb3020b-e969-476d-a237-e94c82e33279$pb$, $pb$0540cf1a-45cd-4512-a8c3-35723aa3466f$pb$, $pb$学習アプリの基本レイアウトHTMLを書く$pb$, 3, $pb$normal$pb$, $pb$ページ上部にタイトル、中央に学習カード一覧、下部にフッターを持つ HTML を、意味付きタグで書いてください。$pb$, $pb$`header` を使うこと
  中央は `main` を使うこと
  カード一覧は `section` を使ってよい
  下部は `footer` を使うこと$pb$, $pb$研修では見た目だけでなく、HTML 構造の意味づけも見られやすいです。$pb$, $pb$<header><h1>学習アプリ</h1></header>
  <main><section>カード一覧</section></main>
  <footer>Copyright</footer>$pb$, $pb$意味付きタグを使ったレイアウトを書けると、構造理解と保守性の両方が上がります。$pb$, $pb$`div` だけで全部作ると見た目は成立しても、意味を持った構造の練習として弱くなります。$pb$, 4616, TRUE),
  ($pb$dbfc4f1e-b82f-42ca-a1bf-7ea9bede1055$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$カード一覧を2列で並べるCSSを書く$pb$, 3, $pb$normal$pb$, $pb$`.cards` の中にあるカードを横並びで折り返し可能にし、カード同士の間隔を `16px` にする CSS を書いてください。$pb$, $pb$`display: flex` を使うこと
  `flex-wrap: wrap` を使うこと
  `gap: 16px` を使うこと$pb$, $pb$今どきのカード一覧でよくある最小構成です。$pb$, $pb$.cards {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
  }$pb$, $pb$カード一覧では、Flexbox の開始・折り返し・間隔をセットで書けるとかなり実践的です。$pb$, $pb$`margin` だけで間隔を調整しようとすると、親子関係によってズレやすくなります。$pb$, 4617, TRUE),
  ($pb$9ef980cc-2fa7-4c64-a4ca-b766bc2df180$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$スマホ幅でカード一覧を1列にするCSSを書く$pb$, 3, $pb$normal$pb$, $pb$通常は複数列の `.cards` を、画面幅 `768px` 以下では 1 列表示にしたいです。メディアクエリ込みで CSS を書いてください。$pb$, $pb$`@media (max-width: 768px)` を使うこと
  `.cards` に `flex-direction: column` を書くこと$pb$, $pb$既に `.cards` が Flexbox になっている前提で考えて大丈夫です。$pb$, $pb$@media (max-width: 768px) {
    .cards {
      flex-direction: column;
    }
  }$pb$, $pb$研修では、レイアウトを作るだけでなく、スマホ幅で崩れないように切り替える力もよく見られます。$pb$, $pb$`min-width` を使うと PC 側へ適用されやすくなり、意図と逆になることがあります。$pb$, 4618, TRUE),
  ($pb$7980af42-7119-4020-a46f-c871ea7eb256$pb$, $pb$7fef2ac8-77f6-4908-a2d3-5b34f186279b$pb$, $pb$HTML と CSS の class 名不一致バグを直す$pb$, 3, $pb$normal$pb$, $pb$次の HTML と CSS ではスタイルが当たりません。原因を直した HTML を書いてください。
  
  ```html
  <div class="card-list">
    <div class="card">Task</div>
  </div>
  ```
  
  ```css
  .cards {
    display: flex;
    gap: 16px;
  }
  ```$pb$, $pb$原因が class 名の不一致であることを反映すること
  修正後の HTML を書くこと$pb$, $pb$CSS セレクタ `.cards` と HTML 側の class 値が一致しているか見比べてください。$pb$, $pb$<div class="cards">
    <div class="card">Task</div>
  </div>$pb$, $pb$CSS は一致した class 名にしか適用されません。名前が少しでも違うと見た目は変わりません。$pb$, $pb$`.card` を変えてしまうと子要素側の意味までずれてしまいます。今回直すべきは親要素の class 名です。$pb$, 4619, TRUE),
  ($pb$87b9af84-9b60-4211-ae4b-1808cf71841e$pb$, $pb$2617845d-8575-44a7-abf6-3806eb47d1a0$pb$, $pb$label と input が結び付かないバグを直す$pb$, 3, $pb$normal$pb$, $pb$次のフォームではラベルをクリックしても入力欄にフォーカスしません。正しく動く HTML を書いてください。
  
  ```html
  <label for="email">メールアドレス</label>
  <input id="mail" type="email">
  ```$pb$, $pb$`for` と `id` を一致させること
  フォーム全体ではなく必要部分だけを書けばよい$pb$, $pb$ラベルと入力欄を結び付けるには、`label` の `for` と `input` の `id` を同じ値にします。$pb$, $pb$<label for="email">メールアドレス</label>
  <input id="email" type="email">$pb$, $pb$`for` と `id` が一致していると、ラベル操作が入力欄に関連付き、使いやすさとアクセシビリティが上がります。$pb$, $pb$`name` をそろえてもラベルとの関連付けにはなりません。必要なのは `for` と `id` の一致です。$pb$, 4620, TRUE),
  ($pb$d831196f-ad35-404c-af5f-82fd0b63c01c$pb$, $pb$da37f8f0-0cc6-4bcb-a8b9-25c8c2c2e743$pb$, $pb$メディアクエリ条件を逆にしているバグを直す$pb$, 3, $pb$normal$pb$, $pb$スマホ幅で縦並びにしたいのに、次の CSS だと PC 幅のときに縦並びになります。修正後の CSS を書いてください。
  
  ```css
  @media (min-width: 768px) {
    .cards {
      flex-direction: column;
    }
  }
  ```$pb$, $pb$`max-width: 768px` に修正すること
  `.cards` の指定は活かすこと$pb$, $pb$今回は「768px 以下」で切り替えたいので、幅条件の向きを見直します。$pb$, $pb$@media (max-width: 768px) {
    .cards {
      flex-direction: column;
    }
  }$pb$, $pb$`min-width` は指定幅以上で効く条件です。スマホ向けにしたいなら `max-width` を使って上限条件にします。$pb$, $pb$メディアクエリだけ直しても、元の `.cards` が Flexbox になっていないと縦並びは効きません。前提のレイアウト指定も合わせて確認します。$pb$, 4621, TRUE),
  ($pb$3ee74758-fb77-40fe-ab82-dad9e4847cb7$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$変更状況を確認するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$今どのファイルが変更されたか、追加されたかを確認したいです。Git で状態確認をするときのコマンドを書いてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$作業前後に一番よく見る基本コマンドです。$pb$, $pb$status$pb$, $pb$`git status` は、変更済みファイル、ステージ済みファイル、未追跡ファイルを確認するための基本コマンドです。$pb$, $pb$`log` は履歴確認、`diff` は差分確認です。現在の状態一覧を見るときは `status` を使います。$pb$, 5101, TRUE),
  ($pb$cfa89b60-a03d-42a9-afe7-d20f6676a83e$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$特定ファイルをステージに追加するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`app.js` だけをコミット対象にしたいです。ステージへ追加するコマンドを書いてください。
  
  git __________ app.js$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$コミット前に変更を登録する操作です。$pb$, $pb$add$pb$, $pb$`git add app.js` で、そのファイルの変更を次のコミット候補としてステージできます。$pb$, $pb$`commit` は記録、`push` は送信です。コミット対象に載せる段階では `add` を使います。$pb$, 5102, TRUE),
  ($pb$023a8c53-dff2-4b70-a70c-a2124c5b3c5e$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$メッセージ付きでコミットするコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$ステージ済みの変更を、`"fix login"` というメッセージでコミットしたいです。空欄を埋めてください。
  
  git commit __________ "fix login"$pb$, $pb$オプションだけを書くこと$pb$, $pb$コミットメッセージを後ろに続けるときの短いオプションです。$pb$, $pb$-m$pb$, $pb$`git commit -m "..."` で、コミットメッセージをその場で指定して保存できます。$pb$, $pb$`-a` は別の意味です。メッセージ指定では `-m` を使います。$pb$, 5103, TRUE),
  ($pb$951bf33e-2b8d-4e19-a872-a7dcfeb9301a$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$main ブランチをリモートへ送るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$ローカルの `main` ブランチを `origin` に送信したいです。空欄を埋めてください。
  
  git __________ origin main$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$ローカルから GitHub 側へ反映するときのコマンドです。$pb$, $pb$push$pb$, $pb$`git push origin main` で、ローカルの `main` ブランチの内容をリモートへ送れます。$pb$, $pb$`pull` は取り込む側です。送るときは `push` です。$pb$, 5104, TRUE),
  ($pb$3bce779a-aaf6-4ef4-af0b-39d2efa4a41a$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$リモートの変更を取り込むコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`origin` の `main` ブランチにある最新変更をローカルへ取り込みたいです。空欄を埋めてください。
  
  git __________ origin main$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$GitHub 側の更新を自分の PC へ反映するときの基本コマンドです。$pb$, $pb$pull$pb$, $pb$`git pull origin main` で、リモートの `main` の変更を取得して現在のブランチへ取り込めます。$pb$, $pb$`fetch` は取得だけでマージしません。まとめて取り込むなら `pull` です。$pb$, 5105, TRUE),
  ($pb$b7e228d4-3e6d-460b-ae08-e11d9cb7ded4$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$リポジトリをコピーしてくるコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$GitHub のリポジトリ URL を使って、自分の PC にプロジェクト一式をコピーしたいです。空欄を埋めてください。
  
  git __________ <URL>$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$新しくプロジェクトを手元へ持ってくるときに使います。$pb$, $pb$clone$pb$, $pb$`git clone <URL>` で、リモートリポジトリをローカルに複製できます。$pb$, $pb$`init` は新規作成、`pull` は既存リポジトリの更新です。最初にコピーするときは `clone` です。$pb$, 5106, TRUE),
  ($pb$37975e96-c375-4e82-a935-803d756139bd$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$新しい Git 管理を始めるコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$まだ Git 管理されていないフォルダで Git を使い始めたいです。空欄を埋めてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$新規プロジェクトで最初に 1 回だけ行うことが多いです。$pb$, $pb$init$pb$, $pb$`git init` で、そのフォルダを Git リポジトリとして初期化できます。$pb$, $pb$`clone` は既存リポジトリ取得用です。今あるフォルダを Git 管理にするなら `init` です。$pb$, 5107, TRUE),
  ($pb$49fb2fe3-48a5-47c0-a7ff-62ac1f62a18b$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$コミット履歴を見るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$これまでのコミット履歴を一覧で確認したいです。空欄を埋めてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$誰がいつ何を記録したか追うときに見ます。$pb$, $pb$log$pb$, $pb$`git log` で、過去のコミット履歴を新しい順に確認できます。$pb$, $pb$`status` は現在の状態、`diff` は差分です。履歴一覧は `log` です。$pb$, 5108, TRUE),
  ($pb$bd71384d-915d-4cbb-ada4-97d1dfdbb1c2$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$すべての変更をまとめてステージするコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$変更したファイルをまとめてステージしたいです。空欄を埋めてください。
  
  git add __________$pb$, $pb$記号も含めてそのまま書くこと$pb$, $pb$現在のフォルダ配下の変更をまとめて追加するときによく使います。$pb$, $pb$.$pb$, $pb$`git add .` で、現在のディレクトリ配下の変更をまとめてステージできます。$pb$, $pb$`*` を書くとシェル展開の影響を受けることがあります。基本練習では `.` を覚えるのが安全です。$pb$, 5109, TRUE),
  ($pb$377bac5b-dd88-4bb7-a91f-4d42b6756717$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$追跡したくないファイルを書く設定ファイル名$pb$, 1, $pb$fill_blank$pb$, $pb$`node_modules` や `.env` など、Git で管理したくないファイルを指定するときのファイル名を書いてください。
  
  __________$pb$, $pb$ファイル名をそのまま書くこと$pb$, $pb$先頭にドットが付くファイルです。$pb$, $pb$.gitignore$pb$, $pb$`.gitignore` に書いたパターンは、Git の追跡対象から外しやすくなります。$pb$, $pb$`README.md` は説明用です。無視設定には `.gitignore` を使います。$pb$, 5110, TRUE),
  ($pb$1b9fc330-4a25-4760-a94d-83b1420d87e1$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$新しいブランチを作るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`feature/login` という新しいブランチを作りたいです。空欄を埋めてください。
  
  git __________ feature/login$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$ブランチを作るだけの基本コマンドです。$pb$, $pb$branch$pb$, $pb$`git branch feature/login` で、新しいブランチを作成できます。$pb$, $pb$`switch` は移動、`merge` は統合です。作成だけなら `branch` です。$pb$, 5111, TRUE),
  ($pb$dfc7b33d-fdc7-4f60-a642-220ecc62c994$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$既存ブランチへ移動するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$すでに存在する `feature/login` ブランチへ移動したいです。空欄を埋めてください。
  
  git __________ feature/login$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$最近の Git で、ブランチ移動によく使うコマンドです。$pb$, $pb$switch$pb$, $pb$`git switch feature/login` で、そのブランチへ移動できます。$pb$, $pb$`branch` は作成や一覧です。移動したいときは `switch` を使います。$pb$, 5112, TRUE),
  ($pb$add1d35d-c85b-423d-ac22-8a978489ae16$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$ブランチ作成と移動を同時に行うオプション$pb$, 2, $pb$fill_blank$pb$, $pb$`feature/api` ブランチを作り、そのまま移動したいです。空欄を埋めてください。
  
  git switch __________ feature/api$pb$, $pb$オプションをそのまま書くこと$pb$, $pb$`switch` で新規ブランチを作るときの短いオプションです。$pb$, $pb$-c$pb$, $pb$`git switch -c feature/api` で、ブランチ作成と移動を一度に行えます。$pb$, $pb$`-d` は削除です。新規作成では `-c` を使います。$pb$, 5113, TRUE),
  ($pb$2b0dc31d-34c3-4cf4-a0a2-4709d8a81b7e$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$ブランチ一覧を見るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$今どんなブランチがあるか一覧を見たいです。空欄を埋めてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$新しいブランチを作るコマンドと同じ単語です。$pb$, $pb$branch$pb$, $pb$`git branch` だけを実行すると、ローカルブランチ一覧を確認できます。$pb$, $pb$`status` では現在ブランチ名は見えても一覧にはなりません。一覧は `branch` です。$pb$, 5114, TRUE),
  ($pb$0b60fe02-dfa6-40a1-a8db-d96c0de1ebe7$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$feature ブランチを main に取り込むコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$`main` ブランチにいる状態で、`feature/login` の変更を取り込みたいです。空欄を埋めてください。
  
  git __________ feature/login$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$ブランチ同士を統合するときのコマンドです。$pb$, $pb$merge$pb$, $pb$`git merge feature/login` で、そのブランチの変更を現在のブランチへ取り込めます。$pb$, $pb$`pull` はリモート取り込みです。ローカルブランチ同士の統合は `merge` です。$pb$, 5115, TRUE),
  ($pb$6d2a9096-c350-46e1-a384-ecade8e249c0$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$使い終わったブランチを削除するコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$マージが終わった `feature/login` ブランチを削除したいです。空欄を埋めてください。
  
  git branch __________ feature/login$pb$, $pb$オプションだけを書くこと$pb$, $pb$小文字 1 文字のオプションです。$pb$, $pb$-d$pb$, $pb$`git branch -d feature/login` で、使い終わったローカルブランチを削除できます。$pb$, $pb$`-c` は作成です。削除では `-d` を使います。$pb$, 5116, TRUE),
  ($pb$66f01f45-7450-4a48-ae1c-560c83c1bf86$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$main ブランチへ戻るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$feature ブランチでの作業を終えて、`main` に戻りたいです。空欄を埋めてください。
  
  git switch __________$pb$, $pb$ブランチ名だけを書くこと$pb$, $pb$多くのプロジェクトで基準になるデフォルトブランチ名です。$pb$, $pb$main$pb$, $pb$`git switch main` で `main` ブランチへ戻れます。$pb$, $pb$`master` を使うプロジェクトもありますが、この問題では `main` を前提にしています。$pb$, 5117, TRUE),
  ($pb$a4b64873-a3e9-4d0e-aeb4-4966c3c7041e$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$作業を分けるための仕組み名$pb$, 1, $pb$fill_blank$pb$, $pb$`main` に直接作業せず、機能ごとに作業を分けるときに使う Git の仕組み名を書いてください。
  
  __________$pb$, $pb$英単語 1 つで答えること$pb$, $pb$`feature/login` のような名前を付けて使います。$pb$, $pb$branch$pb$, $pb$Git ではブランチを使うことで、機能追加や修正作業を本流から分けて進められます。$pb$, $pb$`repository` は保管場所全体です。作業の分岐単位は `branch` です。$pb$, 5118, TRUE),
  ($pb$756f3ac9-84b3-4407-a1bb-c608692def25$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$コンフリクト先頭マーカー$pb$, 2, $pb$fill_blank$pb$, $pb$マージコンフリクトが起きたファイルの先頭側には、どの記号が表示されますか。空欄を埋めてください。
  
  __________ HEAD$pb$, $pb$記号をそのまま書くこと$pb$, $pb$小なり記号が連続するマーカーです。$pb$, $pb$<<<<<<<$pb$, $pb$コンフリクト箇所の自分側の変更は `<<<<<<< HEAD` から始まります。$pb$, $pb$`>>>>>>>` は相手側の終端です。先頭マーカーではありません。$pb$, 5119, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;
INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$3b273267-aad1-4544-a39a-d985fa0b8ad9$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$コンフリクト中央マーカー$pb$, 2, $pb$fill_blank$pb$, $pb$マージコンフリクトで、自分側と相手側の境目に表示される記号を書いてください。
  
  __________$pb$, $pb$記号をそのまま書くこと$pb$, $pb$イコール記号が連続します。$pb$, $pb$=======$pb$, $pb$`=======` は、コンフリクト中の 2 つの変更を区切る境目として表示されます。$pb$, $pb$`<<<<<<<` と `>>>>>>>` は開始と終了です。中央の区切りは `=======` です。$pb$, 5120, TRUE),
  ($pb$0ae8420d-d894-44cc-a590-be9665b3f113$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$コンフリクト終端マーカー$pb$, 2, $pb$fill_blank$pb$, $pb$マージコンフリクトで相手側変更の終わりに表示される記号を書いてください。
  
  __________ feature/login$pb$, $pb$記号をそのまま書くこと$pb$, $pb$大なり記号が連続するマーカーです。$pb$, $pb$>>>>>>>$pb$, $pb$`>>>>>>> branch-name` は、相手側の変更ブロックの終端として表示されます。$pb$, $pb$`<<<<<<<` は開始側です。終端は `>>>>>>>` です。$pb$, 5121, TRUE),
  ($pb$a0a717b0-7433-442d-ad5c-67ad5620d693$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$一時退避するコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$まだコミットしたくない変更を一時的に避けたいです。空欄を埋めてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$作業内容を一時的に棚へ置くイメージの機能です。$pb$, $pb$stash$pb$, $pb$`git stash` で、現在の変更を一時退避して作業ツリーをきれいな状態にできます。$pb$, $pb$`reset` や `restore` は取り消し寄りです。退避なら `stash` を使います。$pb$, 5122, TRUE),
  ($pb$79d4ed4a-8627-4a35-a1b0-7ed44833ff53$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$退避した変更を戻すコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$`git stash` した変更を取り出して戻したいです。空欄を埋めてください。
  
  git stash __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$退避したものを適用して、通常は一覧からも外れるコマンドです。$pb$, $pb$pop$pb$, $pb$`git stash pop` で、退避した変更を作業ツリーへ戻せます。$pb$, $pb$`push` は stash へ積む側です。戻すときは `pop` です。$pb$, 5123, TRUE),
  ($pb$1735e2b1-96a3-4f9f-a032-3de859093c54$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$差分を確認するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$コミット前に、どこが変更されたか行単位で確認したいです。空欄を埋めてください。
  
  git __________$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$追加行と削除行を見比べるときに使います。$pb$, $pb$diff$pb$, $pb$`git diff` で、作業ツリーとステージ、またはコミット間の差分を確認できます。$pb$, $pb$`status` は一覧だけで、具体的な差分内容までは出ません。$pb$, 5124, TRUE),
  ($pb$dde2c6b5-33f2-4f29-a124-472ef013c11e$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$課題管理や相談を残す GitHub 機能名$pb$, 1, $pb$fill_blank$pb$, $pb$不具合報告やタスク整理を GitHub 上で残すときに使う機能名を書いてください。
  
  GitHub __________$pb$, $pb$単語 1 つで答えること$pb$, $pb$バグ報告や作業メモを積む場所です。$pb$, $pb$Issues$pb$, $pb$GitHub Issues は、バグ報告、改善案、タスク管理などに使われます。$pb$, $pb$`Pull Requests` はコード変更の提案です。課題管理の場では `Issues` を使います。$pb$, 5125, TRUE),
  ($pb$9e8c90ee-dc25-4687-a396-6d38f6770727$pb$, $pb$822abdc8-0fab-4623-a2be-dbd93a7890c7$pb$, $pb$変更を取り込んでもらうための GitHub 機能名$pb$, 1, $pb$fill_blank$pb$, $pb$自分の変更をレビューしてもらい、取り込んでもらうために GitHub で作成するものを書いてください。
  
  Pull __________$pb$, $pb$単語 1 つで答えること$pb$, $pb$略して PR と呼ばれます。$pb$, $pb$Request$pb$, $pb$Pull Request は、変更のレビュー依頼とマージ提案を兼ねた GitHub の基本機能です。$pb$, $pb$`Issue` は相談や課題管理です。変更提案は Pull Request です。$pb$, 5126, TRUE),
  ($pb$8da89411-aee8-44dd-a783-682592942559$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$他人のリポジトリを自分の GitHub へ複製する機能名$pb$, 2, $pb$fill_blank$pb$, $pb$他人の GitHub リポジトリを、自分のアカウント側へコピーして作業を始める機能名を書いてください。
  
  __________$pb$, $pb$英単語 1 つで答えること$pb$, $pb$OSS 参加でよく使う機能です。$pb$, $pb$Fork$pb$, $pb$Fork は、他人のリポジトリを自分の GitHub アカウント配下へ複製して作業する仕組みです。$pb$, $pb$`clone` はローカル PC への複製です。GitHub 上の自分の領域へコピーするのは `Fork` です。$pb$, 5127, TRUE),
  ($pb$37aca7e7-a5df-4bb4-a222-8e3b36fc7784$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$リポジトリ説明を置く代表的なファイル名$pb$, 1, $pb$fill_blank$pb$, $pb$プロジェクト概要や起動方法を GitHub で最初に見せたいとき、よく使う代表的なファイル名を書いてください。
  
  __________$pb$, $pb$拡張子も含めて書くこと$pb$, $pb$GitHub のトップで自動表示されやすいファイルです。$pb$, $pb$README.md$pb$, $pb$`README.md` は、プロジェクト概要やセットアップ手順を書くための定番ファイルです。$pb$, $pb$`.gitignore` は無視設定用です。説明ファイルには `README.md` を使います。$pb$, 5128, TRUE),
  ($pb$f1da2c23-5619-4dc8-ad15-129a98dcc5e1$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$リモートリポジトリのデフォルト名$pb$, 1, $pb$fill_blank$pb$, $pb$GitHub から `clone` したとき、元リポジトリに付いていることが多いデフォルトのリモート名を書いてください。
  
  __________$pb$, $pb$単語 1 つで答えること$pb$, $pb$`git push origin main` の中にも出てくる名前です。$pb$, $pb$origin$pb$, $pb$`origin` は、clone 元のリモートリポジトリに対して自動で付くことが多い標準名です。$pb$, $pb$`main` はブランチ名です。リモート名ではありません。$pb$, 5129, TRUE),
  ($pb$38cfd75b-e9da-4bd2-adb4-43fede7fd464$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$リモート一覧を確認するコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$今どのリモート先が登録されているか確認したいです。空欄を埋めてください。
  
  git remote __________$pb$, $pb$オプションをそのまま書くこと$pb$, $pb$URL つきで確認したいときによく使います。$pb$, $pb$-v$pb$, $pb$`git remote -v` で、登録済みリモート名と URL を確認できます。$pb$, $pb$`-d` は削除です。表示では `-v` を使います。$pb$, 5130, TRUE),
  ($pb$ed94308b-b41d-43c1-a437-e1223826cd2a$pb$, $pb$822abdc8-0fab-4623-a2be-dbd93a7890c7$pb$, $pb$PR を出す前の基本手順を書く$pb$, 3, $pb$normal$pb$, $pb$GitHub で Pull Request を出す前に、自分の PC で行う基本手順を 3 ステップで書いてください。$pb$, $pb$変更をコミットする流れを含めること
  リモートへ push することを書くこと
  最後に GitHub で PR を作る流れにつながるように書くこと$pb$, $pb$作業ブランチで「add → commit → push」の流れを意識すると整理しやすいです。$pb$, $pb$1. 作業ブランチで変更を `git add` し、`git commit -m "..."` でコミットする。
  2. `git push origin ブランチ名` で GitHub へ送る。
  3. GitHub 上でそのブランチから Pull Request を作成する。$pb$, $pb$PR は GitHub 上で作りますが、その前にローカル変更をコミットし、リモートへ送っておく必要があります。$pb$, $pb$ローカルでコミットしただけでは GitHub に変更は出ません。PR 前に `push` が必要です。$pb$, 5131, TRUE),
  ($pb$dcc30a9d-ddf7-4996-a445-e8c9a0561d76$pb$, $pb$7c8d1d58-103a-470f-aa88-22807376f53f$pb$, $pb$feature ブランチで作業して main に取り込む流れを書く$pb$, 3, $pb$normal$pb$, $pb$`main` に直接作業せず、`feature/login` のようなブランチで開発するときの基本的な流れを 4 ステップで書いてください。$pb$, $pb$ブランチ作成または移動を含めること
  コミットを含めること
  最後に main へ取り込む流れを書くこと$pb$, $pb$作業前にブランチを切って、終わったら統合する流れです。$pb$, $pb$1. `main` から `git switch -c feature/login` で作業ブランチを作る。
  2. ファイルを編集して `git add` と `git commit` を行う。
  3. 必要なら `git push origin feature/login` で GitHub へ送る。
  4. 最後に `main` へマージするか Pull Request を作って取り込む。$pb$, $pb$機能ごとにブランチを分けると、main を安定させたまま安全に作業できます。$pb$, $pb$最初から `main` で作業すると、未完成の変更が本流に混ざりやすくなります。$pb$, 5132, TRUE),
  ($pb$b38dd834-b130-414b-a85e-1387d8f55d9b$pb$, $pb$822abdc8-0fab-4623-a2be-dbd93a7890c7$pb$, $pb$Pull Request の役割を書く$pb$, 3, $pb$normal$pb$, $pb$Pull Request は何のために使うのかを、初学者向けに 2 点で説明してください。$pb$, $pb$レビュー依頼であることを書くこと
  変更を取り込む相談の場であることを書くこと$pb$, $pb$単なる送信ボタンではなく、確認と相談の場でもあります。$pb$, $pb$1. Pull Request は、自分の変更を他の人にレビューしてもらうために使います。
  2. その変更を main などへ取り込んでよいか確認しながら進めるための場でもあります。$pb$, $pb$PR はコードを見てもらい、問題がないか確認した上で安全にマージするための重要な仕組みです。$pb$, $pb$PR を出しただけでは自動で本流へ入るわけではありません。レビューや確認を経てマージされます。$pb$, 5133, TRUE),
  ($pb$5cbc0978-c439-48d3-a26f-975d04c555cb$pb$, $pb$bb40d827-5ba9-4b55-abdb-561b93f39398$pb$, $pb$コンフリクトが起きたときの基本手順を書く$pb$, 3, $pb$normal$pb$, $pb$マージや pull の途中でコンフリクトが起きたときの基本対応を 3 ステップで書いてください。$pb$, $pb$ファイルを手で直すことを書くこと
  コンフリクト記号を消すことに触れること
  最後に add と commit まで書くこと$pb$, $pb$そのままでは終わらないので、内容確認と再登録が必要です。$pb$, $pb$1. コンフリクトしたファイルを開いて、残したい内容に手で修正し、`<<<<<<<` などの記号も消す。
  2. 修正後のファイルを `git add` する。
  3. 必要なコミットを行ってマージ作業を完了する。$pb$, $pb$コンフリクトは Git が自動判断できなかった状態なので、最終内容を人が決めて再登録する必要があります。$pb$, $pb$コンフリクト記号を残したまま add すると、そのまま壊れたコードが保存されることがあります。$pb$, 5134, TRUE),
  ($pb$896556cf-2cb9-493d-ad63-e3cf1ea58d66$pb$, $pb$fb500652-7722-42b4-a84a-ceb7946a2d8d$pb$, $pb$新規ファイルがコミットに入らないバグを直す$pb$, 2, $pb$normal$pb$, $pb$`login.js` を新しく作ったのに、コミット後も GitHub に反映されません。原因として考えやすいことと、直し方を 2 ステップで書いてください。$pb$, $pb$未ステージの可能性に触れること
  `git add` を使うことを書くこと$pb$, $pb$新規ファイルは編集しただけではコミット対象に入らないことがあります。$pb$, $pb$1. `login.js` を `git add login.js` していない可能性がある。
  2. `git add login.js` を行ってから、もう一度コミットして push する。$pb$, $pb$Git は、新規ファイルを自動でコミット対象にしません。まずステージへ追加する必要があります。$pb$, $pb$ファイルを保存しただけでコミットに含まれると思い込むと、このミスが起きやすいです。$pb$, 5135, TRUE),
  ($pb$3de2412f-85ee-49f9-a63e-0855fa7673a0$pb$, $pb$fb500652-7722-42b4-a84a-ceb7946a2d8d$pb$, $pb$push が rejected されたときの対処を書く$pb$, 3, $pb$normal$pb$, $pb$`git push origin main` をしたら rejected されました。リモート側に自分の持っていない更新があるときの基本対処を 3 ステップで書いてください。$pb$, $pb$まず pull することに触れること
  競合があれば解消することを書くこと
  最後に再度 push することを書くこと$pb$, $pb$自分の変更を送る前に、先に相手側の更新を取り込んでそろえる必要があります。$pb$, $pb$1. まず `git pull origin main` でリモートの変更を取り込む。
  2. もしコンフリクトが起きたら内容を直して add / commit で解消する。
  3. その後でもう一度 `git push origin main` を行う。$pb$, $pb$rejected は、リモート履歴の方が先に進んでいるときによく起きます。まず同期してから再送します。$pb$, $pb$理由を理解しないまま繰り返し `push` しても解決しません。先に差分を取り込みます。$pb$, 5136, TRUE),
  ($pb$894d9b49-f6e4-410a-a84a-6594149fd313$pb$, $pb$fb500652-7722-42b4-a84a-ceb7946a2d8d$pb$, $pb$コンフリクト記号を残したままにしないための修正手順$pb$, 3, $pb$normal$pb$, $pb$マージ後のファイルに `<<<<<<< HEAD` などの記号が残ってしまいました。どう直して作業を完了するかを 3 ステップで書いてください。$pb$, $pb$不要な記号を消すことを書くこと
  残したいコードを決めることを書くこと
  最後に add と commit を行うことを書くこと$pb$, $pb$Git の記号は最終コードではなく、判断待ちの印です。$pb$, $pb$1. ファイルを開いて、残すコードを決めながら `<<<<<<<` などの記号をすべて消す。
  2. 修正後のファイルを `git add` する。
  3. 必要なコミットをしてマージを完了する。$pb$, $pb$コンフリクト記号は、Git が解決できなかった範囲を示すだけなので、そのまま残してはいけません。$pb$, $pb$記号だけ消して中身の整合を確認しないと、動かないコードになることがあります。$pb$, 5137, TRUE),
  ($pb$41547484-704c-4983-a767-3bc118df0737$pb$, $pb$7795464c-5376-4bd4-a75f-bbe26b103ea4$pb$, $pb$GitHub Actions の役割$pb$, 2, $pb$fill_blank$pb$, $pb$push や Pull Request をきっかけに、自動でテストやチェックを動かす GitHub の機能名を書いてください。
  
  GitHub __________$pb$, $pb$単語をそのまま書くこと$pb$, $pb$CI/CD の入口としてよく使われる機能です。$pb$, $pb$Actions$pb$, $pb$GitHub Actions は、テスト、lint、デプロイなどを自動実行できる仕組みです。$pb$, $pb$`Issues` や `Projects` では自動実行はできません。自動化は Actions の役割です。$pb$, 5138, TRUE),
  ($pb$d6fb4c43-f300-4633-abc1-de453d4c4f7c$pb$, $pb$315e2565-7199-40bb-a63f-e3919a4b7795$pb$, $pb$fetch だけでリモート情報を取るコマンド$pb$, 2, $pb$fill_blank$pb$, $pb$マージはせず、まず `origin` の最新情報だけを取得したいです。空欄を埋めてください。
  
  git __________ origin$pb$, $pb$コマンド名だけを書くこと$pb$, $pb$`pull` よりも 1 段階手前の操作です。$pb$, $pb$fetch$pb$, $pb$`git fetch origin` は、リモートの更新情報を取得するだけで、自分のブランチへはまだ取り込みません。$pb$, $pb$`pull` は取得と統合をまとめて行います。取得だけなら `fetch` です。$pb$, 5139, TRUE),
  ($pb$7154a836-6f7b-4328-a39e-15d12fed1dc0$pb$, $pb$822abdc8-0fab-4623-a2be-dbd93a7890c7$pb$, $pb$レビューコメントを受けた後の基本対応を書く$pb$, 3, $pb$normal$pb$, $pb$Pull Request にレビューコメントが付き、修正を求められました。基本対応を 3 ステップで書いてください。$pb$, $pb$ローカルで修正することを書くこと
  修正後に commit / push することを書くこと
  PR 上で再確認してもらう流れにつなげること$pb$, $pb$PR は作り直しではなく、同じブランチへ追加 push する流れが多いです。$pb$, $pb$1. 指摘内容をローカルの作業ブランチで修正する。
  2. 修正を `git add` と `git commit` で記録し、同じブランチへ `git push` する。
  3. 既存の Pull Request に修正内容が反映されるので、再確認してもらう。$pb$, $pb$PR は 1 回出して終わりではなく、レビューを受けながら修正を積み増して完成度を上げていく場でもあります。$pb$, $pb$毎回 PR を作り直す必要はありません。同じブランチへ push すれば既存 PR に反映されることが多いです。$pb$, 5140, TRUE),
  ($pb$98152ce5-a75b-44bc-a4fe-085b8506a0db$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$社員名だけを取得する SELECT 文を書く$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから社員名だけを id 順に取得してください。
  期待する結果: Aoki, Sato, Suzuki, Tanaka, Ito, Kato の順に name 列が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$必要な列は name だけです。$pb$, $pb$SELECT name FROM employees ORDER BY id;$pb$, $pb$取得したい列だけを SELECT に書くのが基本です。$pb$, $pb$SELECT * にすると不要な列まで返ります。$pb$, 6101, TRUE),
  ($pb$df9f954c-0d30-4ec0-ae60-a4545805a73a$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$部署名を取得する SELECT 文を書く$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments テーブルから部署名だけを id 順に取得してください。
  期待する結果: Sales, Engineering, HR の順に name 列が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$departments テーブルの name 列を使います。$pb$, $pb$SELECT name FROM departments ORDER BY id;$pb$, $pb$単一テーブルから 1 列を取得する基本問題です。$pb$, $pb$テーブル名を employees にすると別データを見に行ってしまいます。$pb$, 6102, TRUE),
  ($pb$8c77f492-f4f6-476e-a29c-1a0c5ceeec8c$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$社員名と給与を同時に取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから name と salary を id 順に取得してください。
  期待する結果: 各社員の name と salary の 2 列が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$2 列ほしいので SELECT の後に列をカンマ区切りで並べます。$pb$, $pb$SELECT name, salary FROM employees ORDER BY id;$pb$, $pb$複数列を返したいときは SELECT に列を並べます。$pb$, $pb$salary だけ、または name だけにすると要件を満たしません。$pb$, 6103, TRUE),
  ($pb$2c10ee11-dfc3-445c-a350-ef112d6663cf$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$注文番号と金額を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから id と total を id 順に取得してください。
  期待する結果: 各注文の id と total の 2 列が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$orders テーブルから必要な 2 列だけを選びます。$pb$, $pb$SELECT id, total FROM orders ORDER BY id;$pb$, $pb$注文番号と金額だけを取りたいときの基本 SELECT です。$pb$, $pb$customer_id を取ると金額が分からず要件不足です。$pb$, 6104, TRUE),
  ($pb$4c909c34-eea7-49b4-a443-b68314079ff5$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$顧客名と地域を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: customers テーブルから name と region を id 順に取得してください。
  期待する結果: 各顧客の name と region が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$customers テーブルの 2 列です。$pb$, $pb$SELECT name, region FROM customers ORDER BY id;$pb$, $pb$顧客一覧の基本取得です。$pb$, $pb$orders テーブルには region がないので顧客テーブルを見る必要があります。$pb$, 6105, TRUE),
  ($pb$486fdb46-3067-4b71-a8ae-e6e2522b5f06$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$社員名と在籍状態を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから name と status を id 順に取得してください。
  期待する結果: 各社員の name と status が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status 列は employees テーブルにあります。$pb$, $pb$SELECT name, status FROM employees ORDER BY id;$pb$, $pb$一覧用に複数列を選ぶ基本パターンです。$pb$, $pb$department_id を取っても在籍状態にはなりません。$pb$, 6106, TRUE),
  ($pb$b3aecf71-22ad-4113-a477-78e366a4239f$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$部署テーブルの全列を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments テーブルの全列を id 順に取得してください。
  期待する結果: id と name の両方が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$今回は全列取得なのでワイルドカードを使えます。$pb$, $pb$SELECT * FROM departments ORDER BY id;$pb$, $pb$全列取得が許される問題では SELECT * も選択肢になります。$pb$, $pb$employees を見ると別テーブルになるので条件違いです。$pb$, 6107, TRUE),
  ($pb$3fb84001-fdb8-404a-a456-90235b64de56$pb$, $pb$c511ec40-1780-4628-a10b-d0e3eabeb2f5$pb$, $pb$注文の顧客IDと注文日を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから customer_id と ordered_at を id 順に取得してください。
  期待する結果: 各注文の customer_id と ordered_at が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$orders テーブルの 2 列です。$pb$, $pb$SELECT customer_id, ordered_at FROM orders ORDER BY id;$pb$, $pb$必要な列だけを取り出す基本 SELECT です。$pb$, $pb$id を返すだけでは注文日が分かりません。$pb$, 6108, TRUE),
  ($pb$6a60e2db-b604-439e-a4c3-99095f7d11b3$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$active の社員だけを取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから status が active の社員名を id 順に取得してください。
  期待する結果: Aoki, Sato, Tanaka, Ito, Kato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status 列で絞り込みます。$pb$, $pb$SELECT name FROM employees WHERE status = 'active' ORDER BY id;$pb$, $pb$単一条件の絞り込みです。$pb$, $pb$active をクォートなしで書くと文字列比較になりません。$pb$, 6109, TRUE),
  ($pb$75331150-c75a-461a-af4d-a6ba08e9a453$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$給与50万円以上の社員を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから salary が 500000 以上の社員名を salary の高い順で取得してください。
  期待する結果: Kato, Suzuki, Sato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$数値比較なので >= が使えます。$pb$, $pb$SELECT name FROM employees WHERE salary >= 500000 ORDER BY salary DESC;$pb$, $pb$数値条件と並び替えを組み合わせる基本形です。$pb$, $pb$500000 を文字列として比較しないように注意します。$pb$, 6110, TRUE),
  ($pb$d92f5ef7-58d6-42d0-ab13-e5b4fd3ecc20$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$Engineering かつ高給与の社員を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから department_id が 2 で、salary が 600000 より大きい社員名を salary の高い順で取得してください。
  期待する結果: Kato, Suzuki が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$部署条件と給与条件の 2 つがあります。$pb$, $pb$SELECT name FROM employees WHERE department_id = 2 AND salary > 600000 ORDER BY salary DESC;$pb$, $pb$複数条件は AND でつなぎます。$pb$, $pb$OR にすると条件が緩くなって別の社員まで入ります。$pb$, 6111, TRUE),
  ($pb$9a334fe5-ef94-4071-af47-c525761d062e$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$2月以降の paid 注文を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから status が paid で、ordered_at が 2024-02-01 以降の注文 id を id 順に取得してください。
  期待する結果: 5, 6 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status と ordered_at の両方で絞ります。$pb$, $pb$SELECT id FROM orders WHERE status = 'paid' AND ordered_at >= '2024-02-01' ORDER BY id;$pb$, $pb$文字列条件と日付条件の組み合わせです。$pb$, $pb$pending の注文 2 は paid ではないので入りません。$pb$, 6112, TRUE),
  ($pb$ef6378f7-6011-492f-aa46-120908d01153$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$East 以外の顧客を取得する$pb$, 1, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: customers テーブルから region が East ではない顧客名を id 順に取得してください。
  期待する結果: Bright, Delta が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$否定条件なので <> を使えます。$pb$, $pb$SELECT name FROM customers WHERE region <> 'East' ORDER BY id;$pb$, $pb$特定値以外を取る基本パターンです。$pb$, $pb$East の顧客まで入れないように条件を反対にしないことが大事です。$pb$, 6113, TRUE),
  ($pb$4c868d04-6314-4b7d-adfa-3845beb2928a$pb$, $pb$3da7c056-f4c8-40f4-af8a-525f40485b8d$pb$, $pb$leave 中または給与40万円未満の社員を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから status が leave、または salary が 400000 未満の社員名を id 順に取得してください。
  期待する結果: Suzuki, Ito が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$どちらかを満たせばよい条件です。$pb$, $pb$SELECT name FROM employees WHERE status = 'leave' OR salary < 400000 ORDER BY id;$pb$, $pb$どちらかの条件を満たすケースでは OR を使います。$pb$, $pb$AND にすると該当件数が減り、Ito が入らなくなります。$pb$, 6114, TRUE),
  ($pb$2efe0586-876a-43ac-a35a-1f15c676001b$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$社員名と部署名を結合して取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees と departments を結合して、社員名と部署名を employee の id 順に取得してください。
  期待する結果: Aoki-Sales, Sato-Engineering などのように name と department name が対応して返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$employees.department_id と departments.id を結びます。$pb$, $pb$SELECT e.name, d.name FROM employees e INNER JOIN departments d ON e.department_id = d.id ORDER BY e.id;$pb$, $pb$外部キーで別テーブルの名前を引く基本 JOIN です。$pb$, $pb$ON 句を忘れると正しく結合できません。$pb$, 6115, TRUE),
  ($pb$ed5bb920-8714-4243-a61f-ec10993c0c8c$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$顧客名と注文金額を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: customers と orders を結合して、顧客名と注文 total を orders.id 順に取得してください。
  期待する結果: ACME-120000, ACME-80000, Bright-150000 などのように返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$orders.customer_id と customers.id を結びます。$pb$, $pb$SELECT c.name, o.total FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;$pb$, $pb$注文だけでは顧客名が分からないので JOIN が必要です。$pb$, $pb$customers.name を取得しないと顧客情報が見えません。$pb$, 6116, TRUE),
  ($pb$d451c689-f7a7-4199-a7b6-600c29e7387b$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$paid 注文の顧客名と金額を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: paid の注文だけについて、顧客名と total を orders.id 順に取得してください。
  期待する結果: ACME-120000, Bright-150000, Delta-200000, Bright-90000 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$JOIN した後に status を絞ります。$pb$, $pb$SELECT c.name, o.total FROM orders o INNER JOIN customers c ON o.customer_id = c.id WHERE o.status = 'paid' ORDER BY o.id;$pb$, $pb$JOIN と絞り込みはよく一緒に使います。$pb$, $pb$orders.status の条件を付け忘れると pending や canceled も入ります。$pb$, 6117, TRUE),
  ($pb$bb5eec3d-67c1-4133-a021-ccc1f2c4bfdd$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$Engineering の社員名を部署名条件で取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments.name が Engineering の社員名を employees.id 順に取得してください。
  期待する結果: Sato, Suzuki, Kato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$部署名条件は departments テーブルにあります。$pb$, $pb$SELECT e.name FROM employees e INNER JOIN departments d ON e.department_id = d.id WHERE d.name = 'Engineering' ORDER BY e.id;$pb$, $pb$部署名で絞りたいときは部署テーブルまで JOIN します。$pb$, $pb$department_id = Engineering のような比較は型が合いません。$pb$, 6118, TRUE),
  ($pb$3ff9bafe-2e7e-4f38-ab10-dc3cefa17bd8$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$注文金額と顧客地域を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders と customers を結合して、orders.id 順に total と region を取得してください。
  期待する結果: 各注文ごとに total と region が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$地域は customers テーブルにあります。$pb$, $pb$SELECT o.total, c.region FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;$pb$, $pb$注文テーブルだけでは地域が分からないため JOIN が必要です。$pb$, $pb$orders に region 列はありません。$pb$, 6119, TRUE),
  ($pb$03fc003c-d9cf-47fb-a263-13a5d3936aff$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$Sales 所属の社員名と給与を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments.name が Sales の社員について、社員名と給与を employees.id 順に取得してください。
  期待する結果: Aoki-400000, Tanaka-450000 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$部署名で絞ってから name と salary を出します。$pb$, $pb$SELECT e.name, e.salary FROM employees e INNER JOIN departments d ON e.department_id = d.id WHERE d.name = 'Sales' ORDER BY e.id;$pb$, $pb$部署条件と社員列取得を同時に扱う基本 JOIN です。$pb$, $pb$department_id = 1 と書いてもよいですが、今回は部署名条件を使う意図です。$pb$, 6120, TRUE),
  ($pb$aaa4b737-b500-4ca3-a232-bed1bfb51cd8$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$部署名と社員名を部署ID順に取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments と employees を結合して、部署名と社員名を departments.id, employees.id の順で並べて取得してください。
  期待する結果: Sales-Aoki, Sales-Tanaka, Engineering-Sato などのように返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$並び順を 2 段階で指定します。$pb$, $pb$SELECT d.name, e.name FROM departments d INNER JOIN employees e ON d.id = e.department_id ORDER BY d.id, e.id;$pb$, $pb$並び順を複数指定すると見やすい一覧にできます。$pb$, $pb$ORDER BY を 1 列だけにすると期待順にならないことがあります。$pb$, 6121, TRUE),
  ($pb$61e847cd-4af8-486e-ad64-77a96e6dc5ef$pb$, $pb$b43d16f3-9a4a-44d9-a6b8-733746884c31$pb$, $pb$顧客名と注文状態を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders と customers を結合して、顧客名と注文 status を orders.id 順に取得してください。
  期待する結果: ACME-paid, ACME-pending, Bright-paid などのように返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status は orders テーブルにあります。$pb$, $pb$SELECT c.name, o.status FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;$pb$, $pb$別テーブルの名称と状態をまとめて見る典型例です。$pb$, $pb$customer_id の数字だけでは顧客名になりません。$pb$, 6122, TRUE),
  ($pb$2cff190d-99d9-42e3-a776-0c53f786ce42$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$部署ごとの社員数を集計する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments と employees を使って、部署ごとの社員数を部署名つきで取得してください。
  期待する結果: Sales-2, Engineering-3, HR-1 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$部署名ごとに COUNT(*) します。$pb$, $pb$SELECT d.name, COUNT(*) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;$pb$, $pb$集計ではグループ化した単位ごとに件数を数えます。$pb$, $pb$GROUP BY なしで COUNT(*) を使うと全体件数しか出ません。$pb$, 6123, TRUE),
  ($pb$b61753df-38eb-4f7b-a31c-7bba7851b252$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$部署ごとの平均給与を集計する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments と employees を使って、部署ごとの平均給与を部署名つきで取得してください。
  期待する結果: Sales-425000, Engineering-623333..., HR-380000 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$平均を取りたいので AVG(salary) を使います。$pb$, $pb$SELECT d.name, AVG(e.salary) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;$pb$, $pb$平均給与のような集計でも GROUP BY が基本です。$pb$, $pb$salary をそのまま SELECT すると集計になりません。$pb$, 6124, TRUE),
  ($pb$80a921ce-a64c-4943-a327-222efa2cdd91$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$顧客ごとの paid 合計金額を集計する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: paid の注文だけを対象に、顧客ごとの total 合計を顧客名つきで取得してください。
  期待する結果: ACME-120000, Bright-240000, Delta-200000 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$paid のみを絞ってから SUM します。$pb$, $pb$SELECT c.name, SUM(o.total) FROM orders o INNER JOIN customers c ON o.customer_id = c.id WHERE o.status = 'paid' GROUP BY c.name ORDER BY c.id;$pb$, $pb$集計前に絞ると、必要なデータだけで合計できます。$pb$, $pb$pending を除外しないと ACME の合計がずれます。$pb$, 6125, TRUE),
  ($pb$26b4bfb5-50a9-477a-afc3-7766b99d784b$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$注文状態ごとの件数を集計する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルで status ごとの件数を取得してください。
  期待する結果: paid-4, pending-1, canceled-1 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status ごとに COUNT(*) します。$pb$, $pb$SELECT status, COUNT(*) FROM orders GROUP BY status ORDER BY status;$pb$, $pb$カテゴリごとの件数確認は GROUP BY の定番です。$pb$, $pb$ORDER BY を入れないと表示順が不安定になることがあります。$pb$, 6126, TRUE),
  ($pb$74ac0d7d-6035-4eef-aa1a-453278b8ef51$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$部署ごとの最高給与を取得する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments と employees を使って、部署ごとの最高給与を部署名つきで取得してください。
  期待する結果: Sales-450000, Engineering-700000, HR-380000 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$最大値を出すので MAX(salary) を使います。$pb$, $pb$SELECT d.name, MAX(e.salary) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;$pb$, $pb$部署ごとの上限値を見るときの基本パターンです。$pb$, $pb$AVG を使うと平均給与になってしまいます。$pb$, 6127, TRUE),
  ($pb$41e98854-8e7c-4020-a0af-cd37007b8cc5$pb$, $pb$b6a1e58d-1e9a-45a5-a733-dc08cee3931e$pb$, $pb$地域ごとの顧客数を集計する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: customers テーブルで region ごとの顧客数を取得してください。
  期待する結果: East-2, South-1, West-1 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$region 単位で COUNT(*) します。$pb$, $pb$SELECT region, COUNT(*) FROM customers GROUP BY region ORDER BY region;$pb$, $pb$単一テーブルでもカテゴリ集計に GROUP BY を使います。$pb$, $pb$name ごとに数えると 1 件ずつになってしまいます。$pb$, 6128, TRUE),
  ($pb$5cc71642-75b1-4769-a7cf-713e71a7a888$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$平均給与より高い社員を取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから、全社員の平均給与より高い社員名を salary の高い順に取得してください。
  期待する結果: Kato, Suzuki, Sato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$平均給与は SELECT AVG(salary) ... で別に求められます。$pb$, $pb$SELECT name FROM employees WHERE salary > (SELECT AVG(salary) FROM employees) ORDER BY salary DESC;$pb$, $pb$比較基準を別 SELECT で作るのがサブクエリの基本です。$pb$, $pb$平均値を手で固定値にするとデータ変更に弱くなります。$pb$, 6129, TRUE),
  ($pb$235215bb-4c49-408d-a6bf-9ebb7f7a8f5e$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$平均注文金額より高い注文を取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから、平均 total より高い注文 id を id 順に取得してください。
  期待する結果: 1, 3, 5 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$orders の平均 total を先に求めます。$pb$, $pb$SELECT id FROM orders WHERE total > (SELECT AVG(total) FROM orders) ORDER BY id;$pb$, $pb$平均値との比較でもサブクエリが便利です。$pb$, $pb$paid のみを対象にしてしまうと平均基準が変わります。$pb$, 6130, TRUE),
  ($pb$24baf08d-e7cb-4a58-a111-260e4be99e2c$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$Engineering 部署の社員をサブクエリで取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: departments テーブルをサブクエリで参照し、部署名が Engineering の社員名を id 順に取得してください。
  期待する結果: Sato, Suzuki, Kato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$department_id と departments.id をサブクエリでつなげます。$pb$, $pb$SELECT name FROM employees WHERE department_id = (SELECT id FROM departments WHERE name = 'Engineering') ORDER BY id;$pb$, $pb$他テーブルのキーを先に取り出して比較する形です。$pb$, $pb$部署名を employees に直接書く列はありません。$pb$, 6131, TRUE),
  ($pb$3724da01-4ed3-4b8a-a053-02288411eed6$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$paid 注文がある顧客を取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: paid の注文を 1 件以上持つ顧客名を id 順に取得してください。
  期待する結果: ACME, Bright, Delta が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$orders から paid の customer_id を取り出して customers に当てます。$pb$, $pb$SELECT name FROM customers WHERE id IN (SELECT customer_id FROM orders WHERE status = 'paid') ORDER BY id;$pb$, $pb$複数の ID 候補を使うときは IN とサブクエリの組み合わせが便利です。$pb$, $pb$Central は canceled 注文しかないので含まれません。$pb$, 6132, TRUE),
  ($pb$97468ff9-1dac-4ce7-a362-f47d6a99ff36$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$最大金額の注文を取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから total が最大の注文 id を取得してください。
  期待する結果: 5 が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$MAX(total) を別 SELECT で求められます。$pb$, $pb$SELECT id FROM orders WHERE total = (SELECT MAX(total) FROM orders);$pb$, $pb$最大値そのものではなく、その行を取りたいときの定番形です。$pb$, $pb$ORDER BY total DESC LIMIT 1 でも取れますが、この問題はサブクエリを使う意図です。$pb$, 6133, TRUE),
  ($pb$3b32f6b9-deb6-496d-a2fe-de62aee40527$pb$, $pb$a175890d-ef11-429d-a23a-12efb2908c89$pb$, $pb$最も高い給与の社員を取得する$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから salary が最大の社員名を取得してください。
  期待する結果: Kato が返ること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$MAX(salary) を使って基準値を作れます。$pb$, $pb$SELECT name FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);$pb$, $pb$最大給与の行を直接取りたいときに使う基本形です。$pb$, $pb$AVG や MIN を使うと別の社員が対象になります。$pb$, 6134, TRUE),
  ($pb$3ef806ea-563d-41ba-ab89-2f0fe6c1996e$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$pending の注文を paid に更新する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルで id = 2 の注文の status を paid に更新してください。
  期待する結果: id=2 の status が pending から paid に変わること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$更新対象は 1 件だけです。$pb$, $pb$UPDATE orders SET status = 'paid' WHERE id = 2;$pb$, $pb$UPDATE は SET と WHERE の組み合わせで書きます。$pb$, $pb$WHERE を忘れると全件更新になります。$pb$, 6135, TRUE),
  ($pb$9dec2dc6-cbdf-4579-ac39-7b4ae47d3e5c$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$Sales 部署の給与を5万円上げる$pb$, 3, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: Sales 部署の社員の salary を一律 50000 上げてください。
  期待する結果: Aoki は 450000、Tanaka は 500000 になること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$Sales の department_id は 1 です。$pb$, $pb$UPDATE employees SET salary = salary + 50000 WHERE department_id = 1;$pb$, $pb$既存値に加算して更新する実務でよくある形です。$pb$, $pb$salary = 50000 にすると一律 50000 円になってしまいます。$pb$, 6136, TRUE),
  ($pb$0f660265-e129-414f-abe6-292197c6086e$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$canceled の注文を削除する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: orders テーブルから status が canceled の注文を削除してください。
  期待する結果: id=4 の注文が削除されること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$削除条件は status です。$pb$, $pb$DELETE FROM orders WHERE status = 'canceled';$pb$, $pb$DELETE は削除対象を WHERE で絞るのが基本です。$pb$, $pb$WHERE なしの DELETE は全件削除になるので危険です。$pb$, 6137, TRUE),
  ($pb$6c92e8c0-10d5-40a1-aa22-489cd8df3b7e$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$HR 部署の社員を削除する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから department_id が 3 の社員を削除してください。
  期待する結果: Ito が削除されること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$HR の department_id は 3 です。$pb$, $pb$DELETE FROM employees WHERE department_id = 3;$pb$, $pb$条件に一致する行だけ削除する基本問題です。$pb$, $pb$department_id を 2 にすると Engineering の社員が消えてしまいます。$pb$, 6138, TRUE),
  ($pb$15b06980-1fac-42df-aae7-c7fc7fe7d802$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$Delta の地域を West に更新する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: customers テーブルで name が Delta の顧客の region を West に更新してください。
  期待する結果: Delta の region が South から West に変わること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$条件は顧客名です。$pb$, $pb$UPDATE customers SET region = 'West' WHERE name = 'Delta';$pb$, $pb$文字列条件で対象行を絞る更新です。$pb$, $pb$name 条件を書かないと全顧客の region が変わります。$pb$, 6139, TRUE),
  ($pb$65a89c50-0046-4e4d-a55f-463e6248022d$pb$, $pb$f93b0d26-9b9e-4881-a6a6-05481904f043$pb$, $pb$leave 状態の社員を削除する$pb$, 2, $pb$code$pb$, $pb$テーブル定義:
  departments(id INTEGER, name VARCHAR(50))
  employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
  customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
  orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)
  
  サンプルデータ:
  departments: (1, Sales), (2, Engineering), (3, HR)
  employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
  customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
  orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)
  
  課題: employees テーブルから status が leave の社員を削除してください。
  期待する結果: Suzuki が削除されること。$pb$, $pb$SQL を 1 文だけ書いてください。$pb$, $pb$status 列で絞ります。$pb$, $pb$DELETE FROM employees WHERE status = 'leave';$pb$, $pb$状態列を使った削除の基本形です。$pb$, $pb$active を消してしまうと業務データが大きく変わってしまいます。$pb$, 6140, TRUE),
  ($pb$1558d51f-14d2-4920-aa57-6cb579fbe380$pb$, $pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$Docker の役割を説明する$pb$, 1, $pb$concept$pb$, $pb$Docker は何のために使うのかを、初学者向けに 2 点で説明してください。$pb$, $pb$環境差分を減らすことと、アプリ実行単位をまとめることに触れてください。$pb$, $pb$「同じ環境で動かす」と「まとめて配る」の 2 観点で考えると整理しやすいです。$pb$, $pb$1. Docker はアプリを動かすのに必要な環境をまとめて扱えるので、開発者ごとの環境差分を減らせます。
  2. アプリと必要な設定をコンテナとしてまとめて実行・配布しやすくなります。$pb$, $pb$Docker の価値は、再現性の高い実行環境を作れる点にあります。$pb$, $pb$仮想マシンそのものと完全に同じと考えると役割を説明しにくくなります。$pb$, 7101, TRUE),
  ($pb$f67c5edf-c7c4-4721-a33d-5566bd45e04a$pb$, $pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$Docker が使えるか確認する手順を書く$pb$, 1, $pb$procedure$pb$, $pb$自分の PC で Docker が使えるか確認したいです。基本確認手順を 2 ステップで書いてください。$pb$, $pb$Docker Desktop などの起動確認と、コマンド確認に触れてください。$pb$, $pb$アプリ起動確認のあと、ターミナルでバージョン確認をする流れです。$pb$, $pb$1. Docker Desktop などの Docker 本体が起動しているか確認する。
  2. ターミナルで `docker --version` を実行してコマンドが使えるか確認する。$pb$, $pb$GUI 側が起動していてもコマンドが使えないことがあるため、両方確認すると安全です。$pb$, $pb$`docker compose` だけ試して本体起動確認を省くと、原因切り分けがしづらくなります。$pb$, 7102, TRUE),
  ($pb$bd80d3db-4a07-438b-a502-d2f5da731409$pb$, $pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$イメージとコンテナの違いを説明する$pb$, 1, $pb$concept$pb$, $pb$Docker イメージと Docker コンテナの違いを、それぞれ 1 文ずつで説明してください。$pb$, $pb$イメージは設計図、コンテナは実行中の実体という意味が伝わるように書いてください。$pb$, $pb$「元になるもの」と「実際に動くもの」を分けると整理しやすいです。$pb$, $pb$イメージはコンテナを作る元になる設計図です。
  コンテナはそのイメージから作られて実際に動いている実行単位です。$pb$, $pb$この違いを理解すると、build と run の役割も見えやすくなります。$pb$, $pb$両方を同じものとして説明すると、操作コマンドの意味が分かりにくくなります。$pb$, 7103, TRUE),
  ($pb$21154300-1048-4689-a03f-1c0ef4de4aaa$pb$, $pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$アプリを Docker で動かす基本流れを書く$pb$, 2, $pb$procedure$pb$, $pb$アプリを Docker で動かすときの基本流れを 3 ステップで書いてください。$pb$, $pb$Dockerfile、build、run の流れを含めてください。$pb$, $pb$設計図を書く → イメージを作る → コンテナを起動する、の順です。$pb$, $pb$1. まず Dockerfile を用意して、アプリの実行方法を定義する。
  2. `docker build` でイメージを作成する。
  3. `docker run` でコンテナを起動してアプリを動かす。$pb$, $pb$Docker 利用の最小単位は Dockerfile、build、run の 3 段階です。$pb$, $pb$Dockerfile を作らずにいきなり run しようとすると、独自アプリの実行条件が定まりません。$pb$, 7104, TRUE),
  ($pb$05b9f811-de51-4254-ac8f-c1462b3795f1$pb$, $pb$e6694138-2feb-4eeb-a158-cfd04d2f5266$pb$, $pb$Docker を使う利点を説明する$pb$, 1, $pb$concept$pb$, $pb$Docker を研修や実務で使う利点を 2 点書いてください。$pb$, $pb$開発環境の統一と配布・再現のしやすさに触れてください。$pb$, $pb$チーム開発で困ることを想像すると書きやすいです。$pb$, $pb$1. 開発者ごとの環境差分を減らして、同じ条件でアプリを動かしやすくなる。
  2. アプリの実行環境ごとまとめて再現・配布しやすくなる。$pb$, $pb$環境差分と再現性は Docker 導入理由として非常に多いです。$pb$, $pb$単に「便利」と書くだけでは、何が便利なのかが伝わりません。$pb$, 7105, TRUE),
  ($pb$5b53b9b7-a62e-4db6-a4cf-10c665a1e3e0$pb$, $pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$Node アプリの Dockerfile を書く$pb$, 2, $pb$procedure$pb$, $pb$Node.js アプリをコンテナで動かしたいです。ベースイメージに `node:20-alpine` を使い、作業ディレクトリを `/app` にし、`package.json` をコピーして `npm install` 後、全体をコピーして `npm start` で起動する Dockerfile を書いてください。$pb$, $pb$`FROM`, `WORKDIR`, `COPY`, `RUN`, `CMD` を含めてください。$pb$, $pb$依存関係インストール前に package.json をコピーします。$pb$, $pb$FROM node:20-alpine
  WORKDIR /app
  COPY package.json ./
  RUN npm install
  COPY . .
  CMD ["npm", "start"]$pb$, $pb$Node アプリの最小 Dockerfile としてよく使う構成です。$pb$, $pb$最初に全ファイルを COPY すると、依存関係キャッシュが効きにくくなります。$pb$, 7106, TRUE),
  ($pb$0609e729-81d9-473e-ad50-e4484b6ae4e4$pb$, $pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$FROM の役割を説明する$pb$, 1, $pb$concept$pb$, $pb$Dockerfile の `FROM` は何を指定するのかを 1 文で説明してください。$pb$, $pb$ベースイメージを選ぶことが伝わるように書いてください。$pb$, $pb$コンテナの土台になるものです。$pb$, $pb$`FROM` は、その Dockerfile がどのベースイメージを土台にして作られるかを指定します。$pb$, $pb$ベースイメージが変わると、使える OS やランタイムも変わります。$pb$, $pb$アプリ名を書く場所だと考えると Dockerfile の構成を誤解しやすくなります。$pb$, 7107, TRUE),
  ($pb$326a3650-2d7e-44ee-a1cf-550e8094d6e4$pb$, $pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$COPY の役割を説明する$pb$, 1, $pb$concept$pb$, $pb$Dockerfile の `COPY . .` は何をしているのかを 1 文で説明してください。$pb$, $pb$ローカルのファイルをイメージ内へコピーすることに触れてください。$pb$, $pb$手元のファイルをコンテナ側へ持っていく命令です。$pb$, $pb$`COPY . .` は、ビルド元ディレクトリのファイルをイメージ内の現在ディレクトリへコピーします。$pb$, $pb$アプリ本体のソースコードをイメージへ入れるためによく使います。$pb$, $pb$ホスト PC とコンテナが自動で同じファイルを共有するわけではありません。$pb$, 7108, TRUE),
  ($pb$ffb7b038-64a9-457b-a76a-c8f4f84166c7$pb$, $pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$3000 番ポートで起動する Dockerfile を書く$pb$, 2, $pb$procedure$pb$, $pb$Node.js アプリを 3000 番ポートで動かす Dockerfile の一部として、`EXPOSE` と `CMD` を含む最小コードを書いてください。起動コマンドは `npm start` です。$pb$, $pb$`EXPOSE 3000` と `CMD ["npm", "start"]` を含めてください。$pb$, $pb$ポート公開の宣言と起動コマンドが必要です。$pb$, $pb$EXPOSE 3000
  CMD ["npm", "start"]$pb$, $pb$`EXPOSE` は利用ポートの宣言、`CMD` は起動時の既定コマンドです。$pb$, $pb$`RUN npm start` にするとビルド時に実行されてしまいます。$pb$, 7109, TRUE),
  ($pb$5d657ba9-3741-4a85-a65f-90f490eaf162$pb$, $pb$1a1ab79d-631f-44a7-a052-ca61bd68d4e6$pb$, $pb$package.json を先にコピーする理由を説明する$pb$, 2, $pb$concept$pb$, $pb$Dockerfile で `package.json` だけ先に `COPY` してから `npm install` することが多い理由を 1 点説明してください。$pb$, $pb$ビルドキャッシュに触れてください。$pb$, $pb$依存関係に変化がないとき、毎回 install をやり直さなくて済みます。$pb$, $pb$依存関係ファイルが変わっていなければ `npm install` のレイヤーをキャッシュ再利用できるため、ビルドを速くしやすいからです。$pb$, $pb$Dockerfile の順番はビルド速度に影響します。$pb$, $pb$単に「決まりだから」と覚えると応用が利きにくくなります。$pb$, 7110, TRUE),
  ($pb$1f164b8d-3734-43e0-a996-fe9be8d1a9fd$pb$, $pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$イメージを build するコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$現在のフォルダにある Dockerfile から、`todo-app` という名前のイメージを作りたいです。コマンドを書いてください。$pb$, $pb$タグは latest のままで構いません。$pb$, $pb$`-t` で名前を付けます。$pb$, $pb$docker build -t todo-app .$pb$, $pb$`docker build -t イメージ名 .` が基本形です。$pb$, $pb$最後の `.` を忘れるとビルドコンテキストが指定されません。$pb$, 7111, TRUE),
  ($pb$3014f68d-bdfd-4c90-a114-9bbc003d6e1a$pb$, $pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$イメージ一覧を見るコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$ローカルにある Docker イメージ一覧を確認したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$images という単語を使います。$pb$, $pb$docker images$pb$, $pb$`docker images` でローカルのイメージ一覧を確認できます。$pb$, $pb$`docker ps` はコンテナ一覧です。$pb$, 7112, TRUE),
  ($pb$718151b0-dd0d-416c-a969-d34ae4bb371d$pb$, $pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$イメージを削除するコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`todo-app:latest` イメージを削除したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`remove image` の短いコマンドです。$pb$, $pb$docker rmi todo-app:latest$pb$, $pb$`docker rmi` は不要になったイメージ削除で使います。$pb$, $pb$`docker rm` はコンテナ削除用です。$pb$, 7113, TRUE),
  ($pb$c15d3a7c-003c-4a09-a328-71c2fbd15550$pb$, $pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$タグの役割を説明する$pb$, 1, $pb$concept$pb$, $pb$Docker イメージのタグは何のために使うのかを 1 文で説明してください。$pb$, $pb$バージョンや識別に使うことが伝わるように書いてください。$pb$, $pb$`latest` や `v1` のような付け分けを思い出してください。$pb$, $pb$タグは、同じイメージ名の中でバージョンや用途を区別して管理しやすくするために使います。$pb$, $pb$タグを分けると、どの版を使うかを明確にできます。$pb$, $pb$タグをファイル名のように考えると Docker の識別構造を誤解しやすくなります。$pb$, 7114, TRUE),
  ($pb$c19619d9-3e50-415a-af0d-1888c11b6019$pb$, $pb$5ad05d2b-4426-41ee-a023-92bff3c0c6da$pb$, $pb$イメージに別タグを付けるコマンドを書く$pb$, 2, $pb$procedure$pb$, $pb$`todo-app:latest` に対して `todo-app:v1` という別タグを付けたいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`docker tag 元 先` の順です。$pb$, $pb$docker tag todo-app:latest todo-app:v1$pb$, $pb$tag コマンドで既存イメージへ別名を付けられます。$pb$, $pb$build し直さなくてもタグ付けだけなら `docker tag` で十分です。$pb$, 7115, TRUE),
  ($pb$a9a00835-00b2-4362-a0d4-96c88bd9955a$pb$, $pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$バックグラウンドでコンテナ起動するコマンドを書く$pb$, 2, $pb$procedure$pb$, $pb$`todo-app` イメージから、名前を `todo-web`、ポートを `3000:3000` でバックグラウンド起動したいです。コマンドを書いてください。$pb$, $pb$`-d`, `--name`, `-p` を含めてください。$pb$, $pb$detach, name, port の 3 つが必要です。$pb$, $pb$docker run -d --name todo-web -p 3000:3000 todo-app$pb$, $pb$よく使う起動オプションをまとめた実践形です。$pb$, $pb$`-p` を忘れるとホスト側からアクセスできません。$pb$, 7116, TRUE),
  ($pb$2acdde5b-5c38-4b1c-a64c-77cfcec7a82e$pb$, $pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$動いているコンテナを止めるコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`todo-web` コンテナを停止したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$stop コマンドです。$pb$, $pb$docker stop todo-web$pb$, $pb$起動中コンテナの停止には `docker stop` を使います。$pb$, $pb$`docker rm` は停止前のコンテナには基本的に使いません。$pb$, 7117, TRUE),
  ($pb$bb523808-4729-45bd-a305-b32e4adb3a7d$pb$, $pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$コンテナログを見るコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`todo-web` コンテナのログを確認したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$logs コマンドを使います。$pb$, $pb$docker logs todo-web$pb$, $pb$起動失敗やエラー確認でまず見る基本コマンドです。$pb$, $pb$ログ確認前にコンテナを消すと原因追跡がしづらくなります。$pb$, 7118, TRUE),
  ($pb$6249ee2d-ce08-4709-a762-d358f02e4c29$pb$, $pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$docker exec の役割を説明する$pb$, 2, $pb$concept$pb$, $pb$`docker exec -it` は何のために使うのかを 1 文で説明してください。$pb$, $pb$実行中コンテナの中でコマンドを実行することに触れてください。$pb$, $pb$シェルに入る用途を思い出してください。$pb$, $pb$`docker exec -it` は、起動中のコンテナ内でシェルやコマンドを実行して中身を確認・操作するときに使います。$pb$, $pb$コンテナ内調査や一時確認でよく使います。$pb$, $pb$`docker run` と混同すると、新しいコンテナを増やしてしまいます。$pb$, 7119, TRUE),
  ($pb$0a8628bc-960e-4ca7-aa92-25d544b15df4$pb$, $pb$59643298-e808-4792-aea2-ed0c0884ca89$pb$, $pb$停止済みコンテナを削除するコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`todo-web` という停止済みコンテナを削除したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$container remove の短いコマンドです。$pb$, $pb$docker rm todo-web$pb$, $pb$`docker rm` は不要になった停止済みコンテナの削除に使います。$pb$, $pb$動作中なら先に stop が必要なことがあります。$pb$, 7120, TRUE),
  ($pb$b600e9de-425e-425b-a45d-e42256261a3d$pb$, $pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$web と db を持つ compose 設定を書く$pb$, 3, $pb$procedure$pb$, $pb$web サービスは `todo-app:latest` を使い `3000:3000` を公開、db サービスは `mysql:8.0` を使う最小の `docker-compose.yml` を書いてください。$pb$, $pb$`services`, `web`, `db`, `ports`, `image` を含めてください。$pb$, $pb$最小構成でよいので、image と ports を中心に書きます。$pb$, $pb$services:
    web:
      image: todo-app:latest
      ports:
        - "3000:3000"
    db:
      image: mysql:8.0$pb$, $pb$compose では複数サービスを 1 ファイルでまとめて管理できます。$pb$, $pb$services の下に web / db を入れ忘れると compose の形になりません。$pb$, 7121, TRUE),
  ($pb$58b8e36d-d0aa-4935-a496-4ed301adbee6$pb$, $pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$compose の service の役割を説明する$pb$, 2, $pb$concept$pb$, $pb$`docker-compose.yml` の `service` は何を表すのかを 1 文で説明してください。$pb$, $pb$アプリや DB など、1 つの実行単位を定義することが伝わるように書いてください。$pb$, $pb$web や db のような単位です。$pb$, $pb$service は、アプリやデータベースなど、compose で一緒に管理したいコンテナの実行単位を表します。$pb$, $pb$service 単位で image、ports、environment などを定義します。$pb$, $pb$service をコンテナ 1 個の実体そのものだけと考えると、設定単位としての意味を見失いやすくなります。$pb$, 7122, TRUE),
  ($pb$f0e0d9e4-75cd-4a32-aba3-c525938a7235$pb$, $pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$compose でバックグラウンド起動するコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`docker-compose.yml` に定義したサービス群をバックグラウンド起動したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$up と -d を使います。$pb$, $pb$docker compose up -d$pb$, $pb$compose v2 では `docker compose up -d` が基本形です。$pb$, $pb$`docker run` では複数サービスをまとめて起動できません。$pb$, 7123, TRUE),
  ($pb$9bb506ab-0b57-42f9-a224-29507e2ffe9a$pb$, $pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$compose でサービス群を停止・削除するコマンドを書く$pb$, 1, $pb$procedure$pb$, $pb$`docker-compose.yml` で起動したサービス群をまとめて停止・削除したいです。コマンドを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$down コマンドです。$pb$, $pb$docker compose down$pb$, $pb$`docker compose down` は compose で起動したサービス群をまとめて片付けるときに使います。$pb$, $pb$`docker stop` だけでは複数サービスをまとめて管理しづらいです。$pb$, 7124, TRUE),
  ($pb$7c9ba172-0535-40b1-a9d9-e4debaeb9740$pb$, $pb$f27360a4-a075-4f83-a0ab-b4837bd4feac$pb$, $pb$compose の ports の意味を説明する$pb$, 2, $pb$concept$pb$, $pb$`docker-compose.yml` の `ports: - "3000:3000"` は何を意味するのかを 1 文で説明してください。$pb$, $pb$ホスト側とコンテナ側のポート対応に触れてください。$pb$, $pb$左がホスト、右がコンテナです。$pb$, $pb$`ports: "3000:3000"` は、ホストの 3000 番ポートへのアクセスをコンテナの 3000 番ポートへつなぐ設定です。$pb$, $pb$ポート公開はブラウザや他サービスからアクセスするための基本設定です。$pb$, $pb$両方ともホスト側だと誤解すると、接続トラブルの原因になります。$pb$, 7125, TRUE),
  ($pb$b7c51eb6-ea4c-467b-adcb-ae437f139f96$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$再代入しない変数宣言$pb$, 1, $pb$fill_blank$pb$, $pb$再代入しない変数を宣言したいです。空欄を埋めてください。
  
  __________ userName = "Aoki";$pb$, $pb$空欄だけを書いてください。$pb$, $pb$ES6 以降でよく使う宣言です。$pb$, $pb$const$pb$, $pb$再代入しない値には `const` を使うのが基本です。$pb$, $pb$`let` でも動きますが、再代入しない意図は弱くなります。$pb$, 8101, TRUE),
  ($pb$1f0764d3-2c4d-40be-afc6-92fdc060abf6$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$テンプレートリテラルの埋め込み記法$pb$, 1, $pb$fill_blank$pb$, $pb$`const name = "Aoki";` があるとき、`Hello, Aoki` を作る空欄を埋めてください。
  
  `Hello, __________`$pb$, $pb$空欄だけを書いてください。$pb$, $pb$テンプレートリテラル内で使う `${...}` の形です。$pb$, $pb$${name}$pb$, $pb$テンプレートリテラルでは `${変数}` で値を埋め込めます。$pb$, $pb$`+ name` は別解ですが、この問題はテンプレートリテラル前提です。$pb$, 8102, TRUE),
  ($pb$5f43e6f3-5642-45ca-aabf-05b15b429d9e$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$厳密比較演算子$pb$, 1, $pb$fill_blank$pb$, $pb$値も型も比較したいです。空欄を埋めてください。
  
  if (count __________ 3) {$pb$, $pb$空欄だけを書いてください。$pb$, $pb$`==` より厳密な比較です。$pb$, $pb$===$pb$, $pb$JavaScript では通常 `===` を使うと意図しない型変換を避けやすくなります。$pb$, $pb$`==` は暗黙の型変換が入るため、研修では避けることが多いです。$pb$, 8103, TRUE),
  ($pb$c61d144d-1c78-4c80-ac58-4072b6ebf46c$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$1 から 3 を出力する for 文を書く$pb$, 1, $pb$code$pb$, $pb$1 から 3 までを `console.log` で順番に表示する `for` 文を書いてください。$pb$, $pb$`for` を使うこと
  1, 2, 3 の順で出すこと$pb$, $pb$初期値 1、3 以下の間だけ回します。$pb$, $pb$for (let i = 1; i <= 3; i++) {
    console.log(i);
  }$pb$, $pb$反復回数が決まっているときは `for` 文が基本です。$pb$, $pb$`i < 3` にすると 3 が出ません。$pb$, 8104, TRUE),
  ($pb$c81aff2a-83f5-4826-a2ef-c1e9bda194e4$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$20 歳以上なら adult と出す if 文を書く$pb$, 1, $pb$code$pb$, $pb$`age` 変数が 20 以上なら `adult` と表示する `if` 文を書いてください。$pb$, $pb$`console.log("adult")` を使うこと$pb$, $pb$比較には `>=` を使います。$pb$, $pb$if (age >= 20) {
    console.log("adult");
  }$pb$, $pb$条件分岐の最小形です。$pb$, $pb$`>` にすると 20 歳ちょうどが外れてしまいます。$pb$, 8105, TRUE),
  ($pb$78c8372f-5ff9-48c8-a1a6-2ae72d6fbc3a$pb$, $pb$6ec6fa35-0a14-4120-a5b1-2e946303f34e$pb$, $pb$name と age を持つオブジェクトを作る$pb$, 1, $pb$code$pb$, $pb$`name` が `Aoki`、`age` が `25` のオブジェクト `user` を作るコードを書いてください。$pb$, $pb$オブジェクトリテラルで書くこと$pb$, $pb$`{ key: value }` の形です。$pb$, $pb$const user = {
    name: "Aoki",
    age: 25,
  };$pb$, $pb$基本的なオブジェクト作成は研修でもよく使います。$pb$, $pb$`=` の右側を配列にしないように注意します。$pb$, 8106, TRUE),
  ($pb$fe784a8f-7dd2-4db9-a274-49686fdf43bb$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$配列の先頭要素を取る記法$pb$, 1, $pb$fill_blank$pb$, $pb$`const numbers = [10, 20, 30];` の先頭要素を取りたいです。空欄を埋めてください。
  
  numbers[__________]$pb$, $pb$空欄だけを書いてください。$pb$, $pb$JavaScript の配列は 0 から始まります。$pb$, $pb$0$pb$, $pb$配列の添字は 0 始まりです。$pb$, $pb$1 と書くと 20 を取ってしまいます。$pb$, 8107, TRUE),
  ($pb$9aa667c8-976c-4922-a450-6e72b12e004a$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$配列の末尾に追加するメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`items` 配列の末尾に `"apple"` を追加したいです。空欄を埋めてください。
  
  items.__________("apple");$pb$, $pb$空欄だけを書いてください。$pb$, $pb$よく使う追加メソッドです。$pb$, $pb$push$pb$, $pb$`push` は配列の末尾追加で使います。$pb$, $pb$`add` というメソッドは標準配列にはありません。$pb$, 8108, TRUE),
  ($pb$f8ba9fd9-6182-42f8-adcc-5f000ba72723$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$オブジェクトの name を読む記法$pb$, 1, $pb$fill_blank$pb$, $pb$`const user = { name: "Aoki" };` の name を読みたいです。空欄を埋めてください。
  
  user.__________$pb$, $pb$空欄だけを書いてください。$pb$, $pb$プロパティ名をそのまま書きます。$pb$, $pb$name$pb$, $pb$ドット記法でプロパティを読めます。$pb$, $pb$`user["user"]` のようにキー名をずらさないようにします。$pb$, 8109, TRUE),
  ($pb$46e92296-72b3-4524-ad71-7c51652c348a$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$map で要素を 2 倍にする戻り値$pb$, 2, $pb$fill_blank$pb$, $pb$`numbers.map((num) => __________)` の空欄を埋めて、各要素を 2 倍にしてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$引数 `num` を使います。$pb$, $pb$num * 2$pb$, $pb$`map` は各要素から新しい値を返して新配列を作ります。$pb$, $pb$`numbers * 2` のように配列全体を直接掛け算はできません。$pb$, 8110, TRUE),
  ($pb$4c737f21-bcda-422f-a9f3-71219d4b32e3$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$偶数だけに絞る filter を書く$pb$, 2, $pb$code$pb$, $pb$`const numbers = [1, 2, 3, 4];` から偶数だけを取り出して `evens` に入れるコードを書いてください。$pb$, $pb$`filter` を使うこと$pb$, $pb$`num % 2 === 0` が条件です。$pb$, $pb$const evens = numbers.filter((num) => num % 2 === 0);$pb$, $pb$`filter` は条件に合う要素だけを残すときに使います。$pb$, $pb$`map` を使うと絞り込みではなく変換になります。$pb$, 8111, TRUE),
  ($pb$361b1cc8-f0fd-4593-a3be-e02c753b6188$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$name だけの配列を作る map を書く$pb$, 2, $pb$code$pb$, $pb$`const users = [{ name: "Aoki" }, { name: "Sato" }];` から name だけの配列 `names` を作るコードを書いてください。$pb$, $pb$`map` を使うこと$pb$, $pb$`user.name` を返します。$pb$, $pb$const names = users.map((user) => user.name);$pb$, $pb$`map` はプロパティ抽出でもよく使います。$pb$, $pb$`filter` を使うと要素数は変わりません。$pb$, 8112, TRUE),
  ($pb$85305280-4ba9-45ac-abc1-95df8d08bc52$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$reduce で合計を求める$pb$, 2, $pb$code$pb$, $pb$`const prices = [100, 200, 300];` の合計を `total` に入れるコードを書いてください。$pb$, $pb$`reduce` を使うこと$pb$, $pb$初期値は 0 です。$pb$, $pb$const total = prices.reduce((sum, price) => sum + price, 0);$pb$, $pb$`reduce` は集約処理の基本です。$pb$, $pb$初期値を省くと意図しない動きになることがあります。$pb$, 8113, TRUE),
  ($pb$50976d69-f48b-4d86-ae2b-86e6d95797c5$pb$, $pb$9973eeaa-03d4-4620-ad15-7fd786e3f8d9$pb$, $pb$新しい key を追加したオブジェクトを作る$pb$, 2, $pb$code$pb$, $pb$`const user = { name: "Aoki" };` をもとに、`age: 25` を追加した新しいオブジェクト `updatedUser` を作るコードを書いてください。$pb$, $pb$スプレッド構文を使うこと$pb$, $pb$`...user` を使います。$pb$, $pb$const updatedUser = {
    ...user,
    age: 25,
  };$pb$, $pb$既存オブジェクトを壊さずに更新するときはスプレッド構文が便利です。$pb$, $pb$元の user を直接書き換えると副作用が増えやすくなります。$pb$, 8114, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;
INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$72b5f5b4-58a0-46ac-ae24-6deee7a192f2$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$アロー関数の矢印記法$pb$, 1, $pb$fill_blank$pb$, $pb$`const add = (a, b) __________ a + b;` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$アロー関数で使う記号です。$pb$, $pb$=>$pb$, $pb$アロー関数は `=>` で書きます。$pb$, $pb$`->` は JavaScript の記法ではありません。$pb$, 8115, TRUE),
  ($pb$02dae314-887f-4a9f-a94a-9b8c6e555f5f$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$関数内だけで使える変数宣言$pb$, 1, $pb$fill_blank$pb$, $pb$ブロック内だけで使う変数 `count` を宣言したいです。空欄を埋めてください。
  
  __________ count = 0;$pb$, $pb$空欄だけを書いてください。$pb$, $pb$`var` よりスコープが狭い宣言です。$pb$, $pb$let$pb$, $pb$`let` はブロックスコープを持つ変数宣言です。$pb$, $pb$`var` は関数スコープで、意図より広く見えてしまうことがあります。$pb$, 8116, TRUE),
  ($pb$1b8b0bb6-a7dc-49d8-aa74-c20d935940c3$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$値を返すキーワード$pb$, 1, $pb$fill_blank$pb$, $pb$関数から計算結果を返したいです。空欄を埋めてください。
  
  __________ total;$pb$, $pb$空欄だけを書いてください。$pb$, $pb$関数の結果を呼び出し元へ返すときに使います。$pb$, $pb$return$pb$, $pb$`return` で関数の戻り値を返します。$pb$, $pb$`console.log` は表示であって戻り値ではありません。$pb$, 8117, TRUE),
  ($pb$e90dbab7-1f4f-401a-ac24-53bb697a471c$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$2 つの数を足す関数を書く$pb$, 1, $pb$code$pb$, $pb$`a` と `b` を受け取り、足し算結果を返す `add` 関数を書いてください。$pb$, $pb$通常の function 構文で書くこと$pb$, $pb$`return a + b;` を返します。$pb$, $pb$function add(a, b) {
    return a + b;
  }$pb$, $pb$通常の関数定義の基本形です。$pb$, $pb$戻り値を書かないと計算結果を再利用できません。$pb$, 8118, TRUE),
  ($pb$481ca472-aafd-4d04-a33a-749429207246$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$関数式で greet を書く$pb$, 2, $pb$code$pb$, $pb$`name` を受け取り `Hello, ${name}` を返すアロー関数 `greet` を書いてください。$pb$, $pb$アロー関数で書くこと$pb$, $pb$テンプレートリテラルを使います。$pb$, $pb$const greet = (name) => `Hello, ${name}`;$pb$, $pb$短い関数はアロー関数で簡潔に書けます。$pb$, $pb$波かっこを付けたのに return を忘れると undefined になります。$pb$, 8119, TRUE),
  ($pb$4c9754d9-9a25-45af-ac13-06dd8bca99a8$pb$, $pb$25eb8e60-78ca-4f3a-a294-e9e652499bc9$pb$, $pb$ブロックスコープの違いを確認するコードを書く$pb$, 2, $pb$code$pb$, $pb$if ブロック内でだけ使う `message` を宣言し、その中で `console.log(message)` するコードを書いてください。宣言には `const` を使ってください。$pb$, $pb$if 文と const を使うこと$pb$, $pb$ブロック内で完結させます。$pb$, $pb$if (true) {
    const message = "ok";
    console.log(message);
  }$pb$, $pb$ブロック内だけで完結する値は狭いスコープで宣言する方が安全です。$pb$, $pb$外に置く必要のない変数まで外に出すと見通しが悪くなります。$pb$, 8120, TRUE),
  ($pb$af9795e7-e7d2-48b1-ac0a-5b7b11dc2d54$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$Promise 成功時に使うメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`fetchData().__________((data) => console.log(data));` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$成功時の処理をつなぐメソッドです。$pb$, $pb$then$pb$, $pb$`then` は Promise 成功時の値を受け取るときに使います。$pb$, $pb$`catch` はエラー時です。$pb$, 8121, TRUE),
  ($pb$ed64aed0-8887-461e-a77d-9f8cda47c2a2$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$await を使う関数宣言$pb$, 1, $pb$fill_blank$pb$, $pb$`await` を使える関数にしたいです。空欄を埋めてください。
  
  __________ function loadData() {$pb$, $pb$空欄だけを書いてください。$pb$, $pb$`await` の前提になる宣言です。$pb$, $pb$async$pb$, $pb$`await` は `async function` の中で使います。$pb$, $pb$`function` だけでは await は使えません。$pb$, 8122, TRUE),
  ($pb$0a68845e-f4de-4675-a60e-666308fc1e67$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$Promise の失敗時に使うメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`fetchData().then(...).__________((error) => console.error(error));` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$エラーハンドリング用です。$pb$, $pb$catch$pb$, $pb$`catch` は Promise の失敗時処理で使います。$pb$, $pb$`finally` は成功失敗どちらでも動きますが、エラー内容受け取りの主役ではありません。$pb$, 8123, TRUE),
  ($pb$04ce0ffd-94c0-4f64-a34d-56c8f930e6e8$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$JSON 変換で使うメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`const data = await response.__________();` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$fetch のレスポンスを JSON として読むメソッドです。$pb$, $pb$json$pb$, $pb$`response.json()` で JSON 本文を JavaScript の値に変換できます。$pb$, $pb$`body()` というメソッドは標準ではありません。$pb$, 8124, TRUE),
  ($pb$0715db43-d302-48d0-a5a3-59ef0dcf7cbe$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$async/await で fetch する関数を書く$pb$, 2, $pb$code$pb$, $pb$`/api/tasks` に `fetch` し、レスポンスを JSON で返す `loadTasks` 関数を書いてください。$pb$, $pb$`async`, `await`, `response.json()` を使うこと$pb$, $pb$fetch の結果を response に受けます。$pb$, $pb$async function loadTasks() {
    const response = await fetch("/api/tasks");
    return response.json();
  }$pb$, $pb$fetch と JSON 変換の基本形です。$pb$, $pb$`await` を付け忘れると Promise のままになります。$pb$, 8125, TRUE),
  ($pb$b9ec72bf-1f4c-4777-a8d3-93800328a55d$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$Promise の then で title を出力する$pb$, 2, $pb$code$pb$, $pb$`fetchTask()` が Promise で `{ title: "Learn JS" }` を返すとき、`then` を使って title を `console.log` するコードを書いてください。$pb$, $pb$`then` を使うこと$pb$, $pb$then の引数で task を受けます。$pb$, $pb$fetchTask().then((task) => {
    console.log(task.title);
  });$pb$, $pb$Promise の値を then で受け取る基本形です。$pb$, $pb$Promise 自体をそのまま console.log しても中身の title は出ません。$pb$, 8126, TRUE),
  ($pb$6f47ee16-6b99-4c02-a0d0-5621a0080d13$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$try/catch でエラーを拾う async 関数を書く$pb$, 2, $pb$code$pb$, $pb$`fetch("/api/tasks")` を await し、失敗したら `console.error(error)` する `loadTasks` 関数を書いてください。$pb$, $pb$async と try/catch を使うこと$pb$, $pb$try の中で await、catch で error を受けます。$pb$, $pb$async function loadTasks() {
    try {
      const response = await fetch("/api/tasks");
      return await response.json();
    } catch (error) {
      console.error(error);
    }
  }$pb$, $pb$非同期処理でも try/catch でエラーハンドリングできます。$pb$, $pb$catch を付けないと失敗時の扱いが曖昧になります。$pb$, 8127, TRUE),
  ($pb$0256a58e-5d30-475d-a23c-6b87f7227f37$pb$, $pb$1bdc3a27-c6e8-4af2-aa71-205b177eb158$pb$, $pb$Promise.all の用途を説明する$pb$, 2, $pb$code$pb$, $pb$`Promise.all([fetchA(), fetchB()])` が何をするコードなのかを 1 文で説明してください。$pb$, $pb$複数 Promise をまとめて待つことに触れてください。$pb$, $pb$A と B が終わるのを両方待ちます。$pb$, $pb$複数の Promise がすべて完了するのをまとめて待ち、その結果を一度に受け取るためのコードです。$pb$, $pb$並列で複数の非同期処理を扱う基本知識です。$pb$, $pb$1 つだけ完了した時点で終わるわけではありません。$pb$, 8128, TRUE),
  ($pb$41e6c004-f8a6-4574-af36-ace164eabd2e$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$ID で要素を取るメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`<div id="message"></div>` を取得したいです。空欄を埋めてください。
  
  document.__________("message")$pb$, $pb$空欄だけを書いてください。$pb$, $pb$id 指定で取るときの標準メソッドです。$pb$, $pb$getElementById$pb$, $pb$`getElementById` は id 指定で DOM 要素を取得します。$pb$, $pb$`querySelector` でも取れますが、この問題は専用メソッド前提です。$pb$, 8129, TRUE),
  ($pb$4bbb68c0-3864-461c-a958-7ea4b47c2842$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$クラスで 1 件取得するメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`.item` に一致する最初の要素を取得したいです。空欄を埋めてください。
  
  document.__________(".item")$pb$, $pb$空欄だけを書いてください。$pb$, $pb$CSS セレクタ形式で指定します。$pb$, $pb$querySelector$pb$, $pb$`querySelector` は CSS セレクタで最初の 1 件を取れます。$pb$, $pb$`getElementById` ではクラス指定をそのまま使えません。$pb$, 8130, TRUE),
  ($pb$acc6c6fa-3be8-4d3a-ab38-c9331c30c1ae$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$クリックイベント登録メソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`button` にクリックイベントを付けたいです。空欄を埋めてください。
  
  button.__________("click", handleClick)$pb$, $pb$空欄だけを書いてください。$pb$, $pb$イベント登録でよく使うメソッドです。$pb$, $pb$addEventListener$pb$, $pb$`addEventListener` で DOM イベントを登録できます。$pb$, $pb$`onClick` は JSX などでは見ることがありますが、生 DOM では別物です。$pb$, 8131, TRUE),
  ($pb$e3408c5b-f549-42c6-a87b-e130fb545af3$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$要素のテキストを書き換えるコードを書く$pb$, 2, $pb$code$pb$, $pb$`id="message"` の要素のテキストを `完了しました` に変えるコードを書いてください。$pb$, $pb$`getElementById` と `textContent` を使うこと$pb$, $pb$取得してから textContent に代入します。$pb$, $pb$const message = document.getElementById("message");
  message.textContent = "完了しました";$pb$, $pb$テキスト更新は DOM 操作の基本です。$pb$, $pb$`innerHTML` を乱用すると不要な HTML 解釈が入ることがあります。$pb$, 8132, TRUE),
  ($pb$d738461e-5b4b-4bd7-a3b4-c985b654ef7f$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$ボタンにクリック時ログを付ける$pb$, 2, $pb$code$pb$, $pb$`id="saveButton"` のボタンにクリック時 `saved` と出すイベントを付けるコードを書いてください。$pb$, $pb$`addEventListener` を使うこと$pb$, $pb$最初にボタン要素を取得します。$pb$, $pb$const saveButton = document.getElementById("saveButton");
  saveButton.addEventListener("click", () => {
    console.log("saved");
  });$pb$, $pb$イベント登録の基本形です。$pb$, $pb$取得前に addEventListener を呼ぶと要素がなくて失敗することがあります。$pb$, 8133, TRUE),
  ($pb$d3ef10a9-c0bd-4e5d-af01-53c45fb91638$pb$, $pb$35089a29-e480-468f-aa19-38542095c373$pb$, $pb$入力欄の value を読むコードを書く$pb$, 2, $pb$code$pb$, $pb$`id="taskInput"` の input 要素の値を `const title` に入れるコードを書いてください。$pb$, $pb$DOM 取得と `.value` を使うこと$pb$, $pb$input 要素を取ってから value を読みます。$pb$, $pb$const taskInput = document.getElementById("taskInput");
  const title = taskInput.value;$pb$, $pb$フォーム入力を扱うときの基本です。$pb$, $pb$`textContent` を使うと input の入力値は取れません。$pb$, 8134, TRUE),
  ($pb$9ddcfb08-eda6-47a3-a17c-e02eade41450$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$GET 通信で使う fetch$pb$, 1, $pb$fill_blank$pb$, $pb$JavaScript で `/api/tasks` に GET 通信したいです。空欄を埋めてください。
  
  __________("/api/tasks")$pb$, $pb$空欄だけを書いてください。$pb$, $pb$標準の HTTP 通信 API です。$pb$, $pb$fetch$pb$, $pb$ブラウザ標準の通信関数として `fetch` がよく使われます。$pb$, $pb$`axios` もありますが、標準 API ではありません。$pb$, 8135, TRUE),
  ($pb$e6cf0762-f775-492e-a0bb-c54ca308f5f5$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$POST の method 指定$pb$, 1, $pb$fill_blank$pb$, $pb$fetch のオプションで POST 通信にしたいです。空欄を埋めてください。
  
  { __________: "POST" }$pb$, $pb$空欄だけを書いてください。$pb$, $pb$HTTP メソッドを指定するキーです。$pb$, $pb$method$pb$, $pb$`method` キーで GET / POST などを指定します。$pb$, $pb$`type` では HTTP メソッド指定になりません。$pb$, 8136, TRUE),
  ($pb$fb1a4122-d28c-4006-af7d-1c0f7adcf41b$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$JSON 文字列化に使う関数$pb$, 1, $pb$fill_blank$pb$, $pb$送信するオブジェクトを JSON 文字列へ変換したいです。空欄を埋めてください。
  
  __________(data)$pb$, $pb$空欄だけを書いてください。$pb$, $pb$組み込みの JSON オブジェクトを使います。$pb$, $pb$JSON.stringify$pb$, $pb$`JSON.stringify` でオブジェクトを文字列へ変換できます。$pb$, $pb$`JSON.parse` は逆方向です。$pb$, 8137, TRUE),
  ($pb$15a44044-bf79-44f9-a49b-5d97aa61b810$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$POST でタイトルを送る fetch を書く$pb$, 2, $pb$code$pb$, $pb$`title` という値を `/api/tasks` へ POST 送信する `fetch` コードを書いてください。body は JSON、header には `Content-Type: application/json` を入れてください。$pb$, $pb$`method`, `headers`, `body` を含めること$pb$, $pb$body には `JSON.stringify({ title })` を使います。$pb$, $pb$fetch("/api/tasks", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ title }),
  });$pb$, $pb$JSON 送信の基本形です。$pb$, $pb$body にオブジェクトをそのまま入れると期待どおり送れません。$pb$, 8138, TRUE),
  ($pb$55d6533a-98b3-41d4-a81f-8c925a13c45c$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$fetch 後に JSON を読む async 関数を書く$pb$, 2, $pb$code$pb$, $pb$`/api/users` を fetch して JSON を返す `loadUsers` 関数を書いてください。$pb$, $pb$async / await を使うこと$pb$, $pb$response.json() を返します。$pb$, $pb$async function loadUsers() {
    const response = await fetch("/api/users");
    return response.json();
  }$pb$, $pb$API 通信の最小形としてよく出ます。$pb$, $pb$`await` を忘れると response が Promise ではなくならない点に注意します。$pb$, 8139, TRUE),
  ($pb$bbc5da4c-fe12-450b-a92a-266a6725372b$pb$, $pb$acf227d7-ad42-408d-a21f-c31fce88bf54$pb$, $pb$取得した tasks を console に出すコードを書く$pb$, 2, $pb$code$pb$, $pb$`loadTasks()` が tasks 配列を Promise で返すとき、async/await を使って tasks を `console.log` するコードを書いてください。$pb$, $pb$async 関数の中で await すること$pb$, $pb$先に結果を変数で受けると見やすいです。$pb$, $pb$async function showTasks() {
    const tasks = await loadTasks();
    console.log(tasks);
  }$pb$, $pb$非同期取得した値を使うには await で待つ必要があります。$pb$, $pb$Promise のまま console.log すると配列本体ではなく Promise が見えます。$pb$, 8140, TRUE),
  ($pb$a5c01f25-a27b-4cfb-a2ba-57d4f1bb3ae1$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$string 型の変数を宣言する$pb$, 1, $pb$code$pb$, $pb$`userName` という変数を `string` 型で宣言し、`"Aoki"` を代入するコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$変数名の後ろに型注釈を書きます。$pb$, $pb$const userName: string = "Aoki";$pb$, $pb$TypeScript では `変数名: 型` で型注釈を書けます。$pb$, $pb$型注釈を値の後ろに書くことはできません。$pb$, 9101, TRUE),
  ($pb$eaf7b692-7214-472b-ae45-0315a3457ab9$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$number 型の配列を宣言する$pb$, 1, $pb$code$pb$, $pb$`scores` を number 配列として `[10, 20, 30]` で宣言するコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`number[]` の形です。$pb$, $pb$const scores: number[] = [10, 20, 30];$pb$, $pb$配列は `型[]` で型注釈できます。$pb$, $pb$`Array<number>` も別解ですが、この問題は `number[]` で十分です。$pb$, 9102, TRUE),
  ($pb$76797752-2d54-4a85-a2f1-95dd0e230df8$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$boolean 型のフラグを宣言する$pb$, 1, $pb$code$pb$, $pb$`isAdmin` を `boolean` 型で `false` として宣言するコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$真偽値型です。$pb$, $pb$const isAdmin: boolean = false;$pb$, $pb$真偽値を表すときは `boolean` を使います。$pb$, $pb$`"false"` のような文字列にしないよう注意します。$pb$, 9103, TRUE),
  ($pb$c328e8cb-90a4-49f6-ad81-d728b4a7a702$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$string または null の型を宣言する$pb$, 2, $pb$code$pb$, $pb$`errorMessage` を `string` または `null` で持てるようにし、初期値を `null` にするコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$ユニオン型を使います。$pb$, $pb$let errorMessage: string | null = null;$pb$, $pb$複数の型を許すときはユニオン型を使います。$pb$, $pb$`string, null` のような書き方は TypeScript の型になりません。$pb$, 9104, TRUE),
  ($pb$a3e1cc78-18b5-44aa-a0c2-94e669127d29$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$リテラル型を使ったステータス変数$pb$, 2, $pb$code$pb$, $pb$`status` に `"idle"` または `"loading"` だけ入るようにして、初期値を `"idle"` にするコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$文字列リテラル型のユニオンです。$pb$, $pb$let status: "idle" | "loading" = "idle";$pb$, $pb$決まった文字列だけ許したいときはリテラル型が便利です。$pb$, $pb$`string` にすると制約が弱くなります。$pb$, 9105, TRUE),
  ($pb$505f9e67-c20a-4be7-ae44-dee849a2356a$pb$, $pb$32d460ad-b3e0-43c9-af64-8b37c1696521$pb$, $pb$タプル型を宣言する$pb$, 2, $pb$code$pb$, $pb$`point` を `[number, number]` のタプルとして `[10, 20]` で宣言するコードを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$配列と似ていますが、要素ごとの型と順番を固定できます。$pb$, $pb$const point: [number, number] = [10, 20];$pb$, $pb$タプルは要素数と順序を固定したいときに使います。$pb$, $pb$`number[]` だと長さや順序までは縛れません。$pb$, 9106, TRUE),
  ($pb$7423be9c-9a18-4a5d-ae1a-2641840c7cf8$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$引数と戻り値が number の関数を書く$pb$, 1, $pb$code$pb$, $pb$`a` と `b` を受け取り、足し算結果を返す関数 `add` を TypeScript で書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$引数と戻り値に number を付けます。$pb$, $pb$function add(a: number, b: number): number {
    return a + b;
  }$pb$, $pb$TypeScript では引数型と戻り値型を明示できます。$pb$, $pb$戻り値の `: number` を省くと推論はされますが、意図が見えにくくなります。$pb$, 9107, TRUE),
  ($pb$082d00e5-2ebc-49d5-a3c4-0dd48e1ce45d$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$string を返すアロー関数を書く$pb$, 1, $pb$code$pb$, $pb$`name` を受け取り `Hello, ${name}` を返すアロー関数 `greet` を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$引数の型は string、戻り値も string です。$pb$, $pb$const greet = (name: string): string => `Hello, ${name}`;$pb$, $pb$アロー関数でも引数型と戻り値型を書けます。$pb$, $pb$テンプレートリテラル内の変数展開を忘れないことが大事です。$pb$, 9108, TRUE),
  ($pb$8140c5be-95a1-4fb8-a39e-d1357885157f$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$オプショナル引数を持つ関数を書く$pb$, 2, $pb$code$pb$, $pb$`name` は必須、`title` は省略可能な `buildLabel` 関数を書いてください。title があれば `${title} ${name}`、なければ `name` を返します。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$省略可能引数は `?` を付けます。$pb$, $pb$function buildLabel(name: string, title?: string): string {
    return title ? `${title} ${name}` : name;
  }$pb$, $pb$省略可能引数は `?` で表現できます。$pb$, $pb$必須引数より前に省略可能引数を置くと分かりにくくなります。$pb$, 9109, TRUE),
  ($pb$a895c284-2972-4c84-aec1-cdf84b121b41$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$void 戻り値の関数を書く$pb$, 1, $pb$code$pb$, $pb$`message` を受け取り `console.log` する `logMessage` 関数を書いてください。戻り値はありません。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$戻り値型は void です。$pb$, $pb$function logMessage(message: string): void {
    console.log(message);
  }$pb$, $pb$返り値を使わない関数には `void` を付けます。$pb$, $pb$`return message;` を書くと意図とずれます。$pb$, 9110, TRUE),
  ($pb$d89c89c2-b55a-4bd2-adef-973a88a220cb$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$コールバック型を持つ関数を書く$pb$, 2, $pb$code$pb$, $pb$`value: number` と `callback` を受け取り、`callback(value)` を実行する `runCallback` 関数を書いてください。callback の型も明示してください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$関数型は `(value: number) => void` の形です。$pb$, $pb$function runCallback(value: number, callback: (value: number) => void): void {
    callback(value);
  }$pb$, $pb$関数を引数で受けるときも型を明示できます。$pb$, $pb$callback を `Function` だけで済ませると型安全性が落ちます。$pb$, 9111, TRUE),
  ($pb$9895c31d-89ad-4104-a4cc-f198c839c2d6$pb$, $pb$514646e9-7355-41ba-a8e9-f75d9b0559df$pb$, $pb$Promise を返す関数を書く$pb$, 2, $pb$code$pb$, $pb$文字列 `"ok"` を返す `async` 関数 `fetchStatus` を書いてください。戻り値型も明示してください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$async 関数の戻り値は Promise になります。$pb$, $pb$async function fetchStatus(): Promise<string> {
    return "ok";
  }$pb$, $pb$非同期関数では戻り値型を `Promise<型>` として書けます。$pb$, $pb$戻り値型を `string` にすると実際の async の挙動とずれます。$pb$, 9112, TRUE),
  ($pb$05624700-f98b-48c6-ab11-867a82bd6756$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$User 型のオブジェクトを書く$pb$, 1, $pb$code$pb$, $pb$`id: number`, `name: string` を持つ `user` オブジェクトを型注釈つきで書いてください。値は `1` と `"Aoki"` にしてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$インラインのオブジェクト型で書けます。$pb$, $pb$const user: { id: number; name: string } = {
    id: 1,
    name: "Aoki",
  };$pb$, $pb$オブジェクトにも型注釈を付けられます。$pb$, $pb$プロパティ名のスペルがずれると型チェック以前に値参照で困ります。$pb$, 9113, TRUE),
  ($pb$aad56a87-f361-4be6-aac2-03c2096e1109$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$interface で Task を定義する$pb$, 1, $pb$code$pb$, $pb$`id: number`, `title: string`, `done: boolean` を持つ `Task` interface を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$interface 名は Task です。$pb$, $pb$interface Task {
    id: number;
    title: string;
    done: boolean;
  }$pb$, $pb$再利用したいオブジェクト形は interface で切り出すと見通しが良くなります。$pb$, $pb$型名を小文字で始めると識別しづらくなります。$pb$, 9114, TRUE),
  ($pb$6a57daa0-59ec-449c-a18f-ac1e73a4123a$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$interface を使った Task オブジェクトを書く$pb$, 1, $pb$code$pb$, $pb$`Task` interface がある前提で、`id: 1`, `title: "Study"`, `done: false` の `task` を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$変数側に `: Task` を付けます。$pb$, $pb$const task: Task = {
    id: 1,
    title: "Study",
    done: false,
  };$pb$, $pb$定義済み interface を使うと型の再利用ができます。$pb$, $pb$done を文字列 `"false"` にすると型が合いません。$pb$, 9115, TRUE),
  ($pb$9aad4fb5-e72d-4117-afa1-9bd7440248cf$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$readonly プロパティを持つ interface を書く$pb$, 2, $pb$code$pb$, $pb$`id` は readonly、`title` は通常の string とする `TaskSummary` interface を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$変更禁止にしたいプロパティの前に readonly を付けます。$pb$, $pb$interface TaskSummary {
    readonly id: number;
    title: string;
  }$pb$, $pb$外から変えてほしくない識別子に readonly を付けるのは実務でも有効です。$pb$, $pb$変わる値まで readonly にすると更新設計が不自然になることがあります。$pb$, 9116, TRUE),
  ($pb$ae315ac6-70e9-4611-ac98-dee9ca9be436$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$ネストしたオブジェクト型を書く$pb$, 2, $pb$code$pb$, $pb$`user` が `name: string` と `profile: { city: string }` を持つ型注釈つきオブジェクトを書いてください。値は `Aoki` と `Tokyo` にしてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$ネスト先にも型を付けます。$pb$, $pb$const user: { name: string; profile: { city: string } } = {
    name: "Aoki",
    profile: {
      city: "Tokyo",
    },
  };$pb$, $pb$ネスト構造も型で明確にできます。$pb$, $pb$profile を文字列にすると構造が崩れます。$pb$, 9117, TRUE),
  ($pb$77754d29-cfb1-4470-a448-6baec017ec81$pb$, $pb$f5731299-3801-4de7-abf1-aab98cb81979$pb$, $pb$型エイリアスで API レスポンスを定義する$pb$, 2, $pb$code$pb$, $pb$`success: boolean`, `message: string` を持つ `ApiResponse` 型エイリアスを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`type` を使います。$pb$, $pb$type ApiResponse = {
    success: boolean;
    message: string;
  };$pb$, $pb$オブジェクト形は interface だけでなく type alias でも表現できます。$pb$, $pb$type 名は値ではなく型として使うことを意識します。$pb$, 9118, TRUE),
  ($pb$aa403c97-e42c-4e24-a5ed-852b3d1b2318$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$ジェネリック関数 identity を書く$pb$, 2, $pb$code$pb$, $pb$受け取った値をそのまま返すジェネリック関数 `identity` を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`<T>` を使います。$pb$, $pb$function identity<T>(value: T): T {
    return value;
  }$pb$, $pb$ジェネリクスを使うと入力型と出力型の対応を保てます。$pb$, $pb$`any` にすると型情報が失われます。$pb$, 9119, TRUE),
  ($pb$38220ac7-48e2-47d4-ac97-4d26e362f9c2$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$配列の先頭を返すジェネリック関数を書く$pb$, 2, $pb$code$pb$, $pb$`items` 配列を受け取り先頭要素を返すジェネリック関数 `firstItem` を書いてください。戻り値は `T | undefined` にしてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$空配列もあるので undefined を考えます。$pb$, $pb$function firstItem<T>(items: T[]): T | undefined {
    return items[0];
  }$pb$, $pb$配列要素型をジェネリクスで保つ基本問題です。$pb$, $pb$戻り値を常に T にすると空配列ケースを表せません。$pb$, 9120, TRUE),
  ($pb$80b6074e-318f-48f9-afaf-27d25be5a584$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$ジェネリック interface Box を書く$pb$, 2, $pb$code$pb$, $pb$`value` という 1 プロパティを持つジェネリック interface `Box<T>` を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$interface 名の後ろに `<T>` を付けます。$pb$, $pb$interface Box<T> {
    value: T;
  }$pb$, $pb$ジェネリック interface は再利用しやすい入れ物を作るのに便利です。$pb$, $pb$value の型を any にするとジェネリクスの意味が薄れます。$pb$, 9121, TRUE),
  ($pb$26b16117-2c53-44e8-a602-9addf31311f7$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$Promise の中身型を明示する$pb$, 2, $pb$code$pb$, $pb$ユーザー一覧を返す非同期関数の戻り値型として、`Task[]` を返す Promise 型を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$Promise の山かっこ内に配列型を入れます。$pb$, $pb$Promise<Task[]>$pb$, $pb$Promise の中身型まで明示すると利用側で扱いやすくなります。$pb$, $pb$`Task[]` だけだと非同期であることが表現されません。$pb$, 9122, TRUE),
  ($pb$bcc656e7-318c-45e0-aa16-e0402d838c08$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$keyof を使う関数シグネチャを書く$pb$, 3, $pb$code$pb$, $pb$`obj` と `key` を受け取り、`obj[key]` を返す `getValue` 関数シグネチャを書いてください。`key` は `obj` のキーに限定してください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`K extends keyof T` を使います。$pb$, $pb$function getValue<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
  }$pb$, $pb$keyof とジェネリクスを組み合わせると安全なキー参照ができます。$pb$, $pb$key を string にしてしまうと存在しないキーも通ってしまいます。$pb$, 9123, TRUE),
  ($pb$ac267ec4-43ad-42b5-a75b-a353b64c9736$pb$, $pb$82f9b0ea-7845-40a7-a7ef-f4fb12e165f6$pb$, $pb$ジェネリック型エイリアス ApiResult を書く$pb$, 3, $pb$code$pb$, $pb$`data: T` と `success: boolean` を持つジェネリック型エイリアス `ApiResult<T>` を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`type ApiResult<T> = { ... }` の形です。$pb$, $pb$type ApiResult<T> = {
    data: T;
    success: boolean;
  };$pb$, $pb$API レスポンスを汎用化すると複数画面で再利用しやすくなります。$pb$, $pb$data を any にすると型情報が抜けます。$pb$, 9124, TRUE),
  ($pb$a2f353ab-33ef-4956-a8c2-65b7fc40e5ed$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$CreateTaskRequest 型を書く$pb$, 3, $pb$code$pb$, $pb$`title: string` と `description: string` を持つ `CreateTaskRequest` 型エイリアスを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$API 送信 DTO を意識します。$pb$, $pb$type CreateTaskRequest = {
    title: string;
    description: string;
  };$pb$, $pb$リクエスト DTO を型で切ると API 呼び出し側の見通しが良くなります。$pb$, $pb$画面専用の状態まで混ぜると DTO の責務がぶれます。$pb$, 9125, TRUE),
  ($pb$36954a1d-caa3-419e-a8ed-4153d3d6c369$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$TaskStatus のリテラル型を書く$pb$, 3, $pb$code$pb$, $pb$タスク状態を `"todo" | "doing" | "done"` で表す `TaskStatus` 型を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$文字列リテラルのユニオンです。$pb$, $pb$type TaskStatus = "todo" | "doing" | "done";$pb$, $pb$決まった状態だけを許すと UI と API のずれを減らせます。$pb$, $pb$`string` にすると制約が弱くなります。$pb$, 9126, TRUE),
  ($pb$a983f988-7119-42fa-a50a-ce6dfe56e812$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$Task 型で status を TaskStatus にする$pb$, 3, $pb$code$pb$, $pb$`id: number`, `title: string`, `status: TaskStatus` を持つ `Task` interface を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$status に先ほどの型を再利用します。$pb$, $pb$interface Task {
    id: number;
    title: string;
    status: TaskStatus;
  }$pb$, $pb$状態型を切り出すと、他の DTO とも整合を取りやすくなります。$pb$, $pb$status を string に戻すと型設計の意味が薄れます。$pb$, 9127, TRUE),
  ($pb$d7fe97f0-69ea-4046-a89b-983b5018f920$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$Partial を使った更新型を書く$pb$, 3, $pb$code$pb$, $pb$`Task` の部分更新を表す `UpdateTaskPayload` 型エイリアスを書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$標準ユーティリティ型を使います。$pb$, $pb$type UpdateTaskPayload = Partial<Task>;$pb$, $pb$更新 API で一部項目だけ送りたいときに便利です。$pb$, $pb$毎回すべてのプロパティを必須にすると部分更新と相性が悪くなります。$pb$, 9128, TRUE),
  ($pb$6abc8d1f-8861-4bf0-a1a7-d429e3350524$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$Record を使ったエラーマップ型を書く$pb$, 3, $pb$code$pb$, $pb$フォームエラーを `項目名 -> エラーメッセージ` で持つ `FormErrors` 型を `Record` で書いてください。キーも値も string です。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`Record<string, string>` の形です。$pb$, $pb$type FormErrors = Record<string, string>;$pb$, $pb$キーと値のパターンが決まっている辞書構造は Record が便利です。$pb$, $pb$配列型にすると項目名で直接引けません。$pb$, 9129, TRUE),
  ($pb$b718f149-775f-44a3-afef-d23e075bb2a2$pb$, $pb$f6a3fb5f-110b-4a14-ac28-50602a44036f$pb$, $pb$unknown を絞り込んで string 判定するコードを書く$pb$, 3, $pb$code$pb$, $pb$`value: unknown` を受け取り、string のときだけ `value.toUpperCase()` を返し、それ以外は `null` を返す関数を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`typeof value === "string"` で絞り込みます。$pb$, $pb$function toUpperIfString(value: unknown): string | null {
    if (typeof value === "string") {
      return value.toUpperCase();
    }
    return null;
  }$pb$, $pb$unknown はそのまま使えないので、型の絞り込みが必要です。$pb$, $pb$any に逃げると型安全性がなくなります。$pb$, 9130, TRUE),
  ($pb$395c2597-bf18-4318-a3d4-1a8207fe0182$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$JSX を返すキーワード$pb$, 1, $pb$fill_blank$pb$, $pb$関数コンポーネントの中で JSX を返したいです。空欄を埋めてください。
  
  __________ <h1>Hello</h1>;$pb$, $pb$空欄だけを書いてください。$pb$, $pb$関数の戻り値です。$pb$, $pb$return$pb$, $pb$関数コンポーネントは JSX を return して描画します。$pb$, $pb$JSX を書いただけでは描画されません。$pb$, 10101, TRUE),
  ($pb$a0951b8b-f5ef-4060-a2d5-c2a1db1cefb1$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$JSX で class 属性に使う名前$pb$, 1, $pb$fill_blank$pb$, $pb$React の JSX で CSS クラスを付けたいです。空欄を埋めてください。
  
  <div __________="card">$pb$, $pb$空欄だけを書いてください。$pb$, $pb$HTML の class とは少し違う名前です。$pb$, $pb$className$pb$, $pb$JSX では `class` ではなく `className` を使います。$pb$, $pb$HTML の感覚で `class` と書くと警告や不具合の原因になります。$pb$, 10102, TRUE),
  ($pb$059b992b-67d2-410a-a752-64b6ffd59e18$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$JSX で JavaScript 値を埋め込む記号$pb$, 1, $pb$fill_blank$pb$, $pb$props.title を JSX に表示したいです。空欄を埋めてください。
  
  <h1>__________</h1>$pb$, $pb$空欄だけを書いてください。$pb$, $pb$波かっこを使います。$pb$, $pb${props.title}$pb$, $pb$JSX では波かっこ内に JavaScript 式を書けます。$pb$, $pb$`$` やテンプレートリテラルの形は JSX ではそのまま使いません。$pb$, 10103, TRUE),
  ($pb$e63e2974-4c3d-4d5d-a0ce-67e71acdad61$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$Hello を表示する関数コンポーネントを書く$pb$, 1, $pb$code$pb$, $pb$`HelloMessage` という名前の関数コンポーネントを書いてください。表示内容は `<p>Hello</p>` だけで構いません。$pb$, $pb$関数コンポーネントで書くこと$pb$, $pb$return で JSX を返します。$pb$, $pb$function HelloMessage() {
    return <p>Hello</p>;
  }$pb$, $pb$関数コンポーネントの最小形です。$pb$, $pb$関数名を小文字にするとコンポーネントとして扱われにくくなります。$pb$, 10104, TRUE),
  ($pb$c7976206-5bbb-4ff3-a987-96af9da728f5$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$title を表示する TaskCard コンポーネントを書く$pb$, 1, $pb$code$pb$, $pb$`title` を props で受け取り、`<div>{title}</div>` を返す `TaskCard` コンポーネントを書いてください。$pb$, $pb$props を受け取ること$pb$, $pb$引数に props を受けて `props.title` を使えます。$pb$, $pb$function TaskCard(props) {
    return <div>{props.title}</div>;
  }$pb$, $pb$props を受け取ることで外から値を渡せます。$pb$, $pb$コンポーネント内で title 変数が未定義のまま使われないようにします。$pb$, 10105, TRUE),
  ($pb$f115b2ee-b433-4690-abdc-83751cbb3974$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$配列を li で描画する JSX を書く$pb$, 2, $pb$code$pb$, $pb$`const tasks = ["A", "B"];` を使って、`ul` の中に `li` を 2 件並べる JSX を `map` で書いてください。$pb$, $pb$`map` と `key` を使うこと$pb$, $pb$`task` 自体を key にして構いません。$pb$, $pb$return (
    <ul>
      {tasks.map((task) => (
        <li key={task}>{task}</li>
      ))}
    </ul>
  );$pb$, $pb$一覧描画は React の基本パターンです。$pb$, $pb$key を付けないと一覧更新時の挙動が分かりづらくなります。$pb$, 10106, TRUE),
  ($pb$bdcc0ccf-d4cb-44ad-a4e7-cc80567b08bd$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$デフォルト export の書き方$pb$, 1, $pb$fill_blank$pb$, $pb$`App` コンポーネントをデフォルト export したいです。空欄を埋めてください。
  
  __________ App;$pb$, $pb$空欄だけを書いてください。$pb$, $pb$ファイルの代表として外へ出すキーワードです。$pb$, $pb$export default$pb$, $pb$`export default` でそのファイルの主要コンポーネントを外へ出せます。$pb$, $pb$`export` だけだと import 側の書き方が変わります。$pb$, 10107, TRUE),
  ($pb$9d63c819-cc1c-4a5d-a9c0-f0a2d0cd4c7c$pb$, $pb$a2df8247-fae7-49b2-a020-0fe7ffa481a0$pb$, $pb$loading が true のときだけ文言を返す$pb$, 2, $pb$code$pb$, $pb$`loading` が true のときだけ `<p>Loading...</p>` を返す `if` 文を書いてください。$pb$, $pb$return を含めること$pb$, $pb$ガード節の形です。$pb$, $pb$if (loading) {
    return <p>Loading...</p>;
  }$pb$, $pb$先に特別ケースを返すと見通しが良くなります。$pb$, $pb$JSX の外で文字列だけ返すと表示形式がずれることがあります。$pb$, 10108, TRUE),
  ($pb$35418448-252f-4de8-a836-4c9809567159$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$state 管理に使うフック名$pb$, 1, $pb$fill_blank$pb$, $pb$コンポーネントの状態を持ちたいです。空欄を埋めてください。
  
  const [count, setCount] = __________(0);$pb$, $pb$空欄だけを書いてください。$pb$, $pb$もっとも基本の状態フックです。$pb$, $pb$useState$pb$, $pb$`useState` は React の基本的な状態管理フックです。$pb$, $pb$`useEffect` は副作用用で、状態そのものを持つものではありません。$pb$, 10109, TRUE),
  ($pb$0e2c0dc4-8dd3-446a-a20b-11d15de94f5f$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$setCount の役割$pb$, 1, $pb$fill_blank$pb$, $pb$`const [count, __________] = useState(0);` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$count を更新する関数名です。$pb$, $pb$setCount$pb$, $pb$useState の 2 つ目は状態更新関数です。$pb$, $pb$count 自体に代入しても React の再描画にはつながりません。$pb$, 10110, TRUE),
  ($pb$ff696f27-456b-43fb-a6a3-f307db60a0b8$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$初期値 0 の state を作る$pb$, 1, $pb$fill_blank$pb$, $pb$`const [count, setCount] = useState(__________);` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$数値 0 です。$pb$, $pb$0$pb$, $pb$state は初期値から始まります。$pb$, $pb$`"0"` のような文字列にすると型や挙動がずれます。$pb$, 10111, TRUE),
  ($pb$5ce8c505-c591-460e-a723-04f0e01a6586$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$カウントを 1 増やすボタンを書く$pb$, 1, $pb$code$pb$, $pb$`count` と `setCount` がある前提で、クリック時に `count + 1` するボタン JSX を書いてください。$pb$, $pb$`onClick` を使うこと$pb$, $pb$`setCount(count + 1)` を呼びます。$pb$, $pb$<button onClick={() => setCount(count + 1)}>増やす</button>$pb$, $pb$state 更新は setter 関数で行います。$pb$, $pb$count++ のような直接変更は React の状態更新ではありません。$pb$, 10112, TRUE),
  ($pb$e1c65d5f-0a33-409a-a4a2-5e499c55cd60$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$true / false を切り替える state 更新を書く$pb$, 2, $pb$code$pb$, $pb$`isOpen` と `setIsOpen` がある前提で、現在値を反転させるコードを書いてください。$pb$, $pb$setIsOpen を使うこと$pb$, $pb$`!isOpen` を渡します。$pb$, $pb$setIsOpen(!isOpen);$pb$, $pb$真偽値の切り替えは反転で書けます。$pb$, $pb$`isOpen = !isOpen` は state 更新になりません。$pb$, 10113, TRUE),
  ($pb$1983443e-4c24-4ae3-a1b7-3316dfc9b729$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$入力値を state に入れる onChange を書く$pb$, 2, $pb$code$pb$, $pb$`setTitle` がある前提で、input の変更時に `e.target.value` を state へ入れる `onChange` を書いてください。$pb$, $pb$アロー関数で書くこと$pb$, $pb$引数 e を受けます。$pb$, $pb$onChange={(e) => setTitle(e.target.value)}$pb$, $pb$入力フォームの state 管理は controlled component の基本です。$pb$, $pb$e.value ではなく `e.target.value` を使います。$pb$, 10114, TRUE),
  ($pb$081ea2d0-eece-4200-a4b7-bc4b3ec3ca57$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$配列 state に新しい要素を追加する$pb$, 2, $pb$code$pb$, $pb$`tasks` と `setTasks` がある前提で、文字列 `"Study"` を末尾追加するコードを書いてください。$pb$, $pb$スプレッド構文を使うこと$pb$, $pb$`[...tasks, "Study"]` の形です。$pb$, $pb$setTasks([...tasks, "Study"]);$pb$, $pb$配列 state は新しい配列を作って更新します。$pb$, $pb$`tasks.push("Study")` は既存配列を直接変更してしまいます。$pb$, 10115, TRUE),
  ($pb$1f8851b6-1099-493d-abd1-ea7d4d39aac4$pb$, $pb$241ee4a8-760e-482f-a371-51eacff936f9$pb$, $pb$入力フォームを空文字で初期化する state を作る$pb$, 1, $pb$code$pb$, $pb$`title` と `setTitle` を持つ state を、初期値が空文字になるように書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$`useState("")` です。$pb$, $pb$const [title, setTitle] = useState("");$pb$, $pb$文字列入力用 state の典型的な初期値は空文字です。$pb$, $pb$`null` から始めると input の value と扱いがずれることがあります。$pb$, 10116, TRUE),
  ($pb$b7618e7f-78dd-442c-ab59-5bff9f2bb0b1$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$props を分割代入する記法$pb$, 1, $pb$fill_blank$pb$, $pb$`function TaskCard(__________) {` の空欄を埋めて、`title` を分割代入で受け取ってください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$波かっこで囲みます。$pb$, $pb${ title }$pb$, $pb$props は関数引数で分割代入できます。$pb$, $pb$`title` だけだとオブジェクト分解になりません。$pb$, 10117, TRUE),
  ($pb$21ea7af9-753c-4bde-ac85-8c18e2abcc72$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$props.title を表示する JSX$pb$, 1, $pb$fill_blank$pb$, $pb$`function TaskCard(props) { return <p>__________</p>; }` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$props オブジェクトから title を読みます。$pb$, $pb${props.title}$pb$, $pb$props 経由で親から渡された値を表示できます。$pb$, $pb$`{title}` と書くなら引数側で分割代入が必要です。$pb$, 10118, TRUE),
  ($pb$206cd51e-874e-4e77-a6dc-76056fb3bfee$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$title prop を表示する子コンポーネントを書く$pb$, 1, $pb$code$pb$, $pb$`title` を props で受け取り `<h2>{title}</h2>` を返す `TaskTitle` コンポーネントを書いてください。$pb$, $pb$分割代入で受け取ってください。$pb$, $pb$`function TaskTitle({ title })` の形です。$pb$, $pb$function TaskTitle({ title }) {
    return <h2>{title}</h2>;
  }$pb$, $pb$props を必要な分だけ受け取ると読みやすくなります。$pb$, $pb$props 全体を受けたのに title を直接参照すると未定義になります。$pb$, 10119, TRUE),
  ($pb$598fa5fb-a96a-44a9-ab0c-97d70df8c920$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$onDelete prop をボタンへつなぐ$pb$, 2, $pb$code$pb$, $pb$`onDelete` を props で受け取り、クリック時にそれを実行するボタン JSX を書いてください。$pb$, $pb$`onClick={onDelete}` の形で書くこと$pb$, $pb$今回は追加引数はありません。$pb$, $pb$<button onClick={onDelete}>削除</button>$pb$, $pb$親から受けた関数を子のイベントへそのまま渡すのはよくある形です。$pb$, $pb$`onClick={onDelete()}` とすると描画時に実行されます。$pb$, 10120, TRUE),
  ($pb$50f80d1c-e2ac-4093-a963-da02c09359fb$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$isDone に応じて文言を分ける JSX を書く$pb$, 2, $pb$code$pb$, $pb$`isDone` を props で受け取り、true なら `<span>完了</span>`、false なら `<span>未完了</span>` を返す JSX を書いてください。$pb$, $pb$三項演算子を使うこと$pb$, $pb$`isDone ? ... : ...` です。$pb$, $pb${isDone ? <span>完了</span> : <span>未完了</span>}$pb$, $pb$props に応じた表示分岐は React の基本です。$pb$, $pb$if 文を JSX の中へそのまま書くことはできません。$pb$, 10121, TRUE),
  ($pb$cc9ac345-c8fd-4aa9-ad05-51e91c2431eb$pb$, $pb$688509eb-04dd-4203-a866-e3de59220990$pb$, $pb$親から task を渡して子を呼ぶ JSX を書く$pb$, 2, $pb$code$pb$, $pb$`task` 変数がある前提で、`TaskItem` コンポーネントへ `task` prop を渡す JSX を書いてください。$pb$, $pb$prop 名は task にしてください。$pb$, $pb$JSX 属性で渡します。$pb$, $pb$<TaskItem task={task} />$pb$, $pb$オブジェクト props をそのまま渡すのもよく使います。$pb$, $pb$`task="task"` とすると文字列になってしまいます。$pb$, 10122, TRUE),
  ($pb$f584b056-aad9-4b0b-a90e-b81db0883970$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$クリックイベント属性名$pb$, 1, $pb$fill_blank$pb$, $pb$React のボタンでクリックイベントを付けたいです。空欄を埋めてください。
  
  <button __________={handleClick}>$pb$, $pb$空欄だけを書いてください。$pb$, $pb$camelCase です。$pb$, $pb$onClick$pb$, $pb$React のイベント属性は camelCase で書きます。$pb$, $pb$`onclick` は HTML 属性で、React では使いません。$pb$, 10123, TRUE),
  ($pb$80c1fb19-937f-4b2b-aa0e-86635cae9424$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$入力値を読む式$pb$, 1, $pb$fill_blank$pb$, $pb$onChange の引数 `event` から入力値を取りたいです。空欄を埋めてください。
  
  event.__________$pb$, $pb$空欄だけを書いてください。$pb$, $pb$target の value までたどります。$pb$, $pb$target.value$pb$, $pb$React の入力イベントでも `event.target.value` を使います。$pb$, $pb$`event.value` では値を直接取れません。$pb$, 10124, TRUE),
  ($pb$1c3d518e-06cf-4fcb-ae9b-256d9cfdad73$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$submit を止める handleSubmit を書く$pb$, 2, $pb$code$pb$, $pb$フォーム送信時の再読み込みを止める `handleSubmit` 関数を書いてください。$pb$, $pb$`event.preventDefault()` を使うこと$pb$, $pb$引数 event を受けます。$pb$, $pb$function handleSubmit(event) {
    event.preventDefault();
  }$pb$, $pb$フォーム送信の既定動作を止める基本コードです。$pb$, $pb$preventDefault を呼ばないと画面再読み込みが起きやすくなります。$pb$, 10125, TRUE),
  ($pb$77e3c72b-a674-4aa4-ada0-8047d6ef6348$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$保存ボタンに handleSave を付ける JSX$pb$, 1, $pb$code$pb$, $pb$`handleSave` をクリック時に呼ぶボタン JSX を書いてください。表示文言は `保存` にしてください。$pb$, $pb$`onClick={handleSave}` を使うこと$pb$, $pb$今回は追加引数は不要です。$pb$, $pb$<button onClick={handleSave}>保存</button>$pb$, $pb$イベントハンドラを props やローカル関数でつなぐ基本形です。$pb$, $pb$`handleSave()` と書くと即実行になります。$pb$, 10126, TRUE),
  ($pb$177022a5-82aa-4f49-a4ef-3f7a55b8bf3a$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$task.id を渡して削除する onClick を書く$pb$, 2, $pb$code$pb$, $pb$`handleDelete` と `task.id` がある前提で、クリック時に `handleDelete(task.id)` を呼ぶボタン JSX を書いてください。$pb$, $pb$アロー関数で包むこと$pb$, $pb$引数ありのときはその場で関数を作ります。$pb$, $pb$<button onClick={() => handleDelete(task.id)}>削除</button>$pb$, $pb$引数付きでイベントを渡すときの定番です。$pb$, $pb$`onClick={handleDelete(task.id)}` だと描画時に実行されます。$pb$, 10127, TRUE),
  ($pb$9f3c4283-5833-4c8a-a827-05d516008727$pb$, $pb$173e3702-a21d-4b76-a9d5-aa52389b6600$pb$, $pb$チェックボックスの checked を state へ入れる$pb$, 2, $pb$code$pb$, $pb$`setIsDone` がある前提で、checkbox の変更時に `event.target.checked` を state へ入れる `onChange` を書いてください。$pb$, $pb$checked を使うこと$pb$, $pb$checkbox は value ではなく checked を見ます。$pb$, $pb$onChange={(event) => setIsDone(event.target.checked)}$pb$, $pb$checkbox では checked を使うのが基本です。$pb$, $pb$value を見ると true/false ではなく文字列扱いになりやすいです。$pb$, 10128, TRUE),
  ($pb$31be38d5-4277-4e3c-a411-eaf7efd15a51$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$controlled input の値属性名$pb$, 1, $pb$fill_blank$pb$, $pb$input を controlled component にしたいです。state 変数 `title` をつなぐ空欄を埋めてください。
  
  <input __________={title} />$pb$, $pb$空欄だけを書いてください。$pb$, $pb$入力欄の現在値を表す属性です。$pb$, $pb$value$pb$, $pb$controlled input は state を value に結び付けます。$pb$, $pb$`defaultValue` は初期値だけで、その後の状態同期とは役割が違います。$pb$, 10129, TRUE),
  ($pb$76b5e303-68b4-4e5b-a4c6-ec3a4a0127df$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$textarea の変更イベント属性名$pb$, 1, $pb$fill_blank$pb$, $pb$textarea の内容変化を拾いたいです。空欄を埋めてください。
  
  <textarea __________={handleChange} />$pb$, $pb$空欄だけを書いてください。$pb$, $pb$input と同じイベント属性です。$pb$, $pb$onChange$pb$, $pb$textarea でも `onChange` を使います。$pb$, $pb$`onInput` よりも React では `onChange` が基本です。$pb$, 10130, TRUE),
  ($pb$aaf0792f-1045-4f12-acc2-75cf563b7602$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$title 入力欄の controlled input を書く$pb$, 2, $pb$code$pb$, $pb$`title` と `setTitle` がある前提で、value と onChange を持つ text input JSX を書いてください。$pb$, $pb$`event.target.value` を使うこと$pb$, $pb$input の value と setTitle を結びます。$pb$, $pb$<input value={title} onChange={(event) => setTitle(event.target.value)} />$pb$, $pb$value と onChange の 2 点セットが controlled input の基本です。$pb$, $pb$value だけ付けて onChange がないと入力できなくなります。$pb$, 10131, TRUE),
  ($pb$53da59e3-fca3-4d57-abe2-98008238a656$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$status を選ぶ select を書く$pb$, 2, $pb$code$pb$, $pb$`status` と `setStatus` がある前提で、`todo` と `done` を選べる select JSX を書いてください。$pb$, $pb$value と onChange を持つこと$pb$, $pb$option を 2 つ書きます。$pb$, $pb$<select value={status} onChange={(event) => setStatus(event.target.value)}>
    <option value="todo">todo</option>
    <option value="done">done</option>
  </select>$pb$, $pb$select も controlled component として扱えます。$pb$, $pb$selected 属性を個別 option に付けるより、React では select 全体の value を管理する方が自然です。$pb$, 10132, TRUE),
  ($pb$ed9b9c77-4d04-4dff-abbd-fe246727a3fe$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$title と description を送信するフォームを書く$pb$, 2, $pb$code$pb$, $pb$`title`, `setTitle`, `description`, `setDescription`, `handleSubmit` がある前提で、2 つの入力欄と送信ボタンを持つフォーム JSX を書いてください。$pb$, $pb$form の onSubmit を使うこと$pb$, $pb$input と textarea の組み合わせです。$pb$, $pb$<form onSubmit={handleSubmit}>
    <input value={title} onChange={(event) => setTitle(event.target.value)} />
    <textarea value={description} onChange={(event) => setDescription(event.target.value)} />
    <button type="submit">保存</button>
  </form>$pb$, $pb$複数入力をまとめて送るフォームの基本形です。$pb$, $pb$button の type を省くと意図が伝わりにくくなります。$pb$, 10133, TRUE),
  ($pb$b9184910-b13a-4a09-afcc-ebb183683f54$pb$, $pb$ced66884-d647-451d-a46f-264d4a28ef33$pb$, $pb$送信後にフォームを初期化するコードを書く$pb$, 2, $pb$code$pb$, $pb$送信成功後に `title` と `description` を空文字へ戻すコードを書いてください。$pb$, $pb$setTitle と setDescription を使うこと$pb$, $pb$両方とも空文字へ戻します。$pb$, $pb$setTitle("");
  setDescription("");$pb$, $pb$送信後にフォームをリセットするのは実務でもよくあります。$pb$, $pb$片方だけ戻すと UI 状態が中途半端になります。$pb$, 10134, TRUE),
  ($pb$2e9dbafa-8b20-40e5-af24-413bf370784e$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$副作用で使うフック名$pb$, 1, $pb$fill_blank$pb$, $pb$初回表示時に API を呼びたいです。空欄を埋めてください。
  
  __________(() => {$pb$, $pb$空欄だけを書いてください。$pb$, $pb$副作用処理の基本フックです。$pb$, $pb$useEffect$pb$, $pb$`useEffect` はデータ取得などの副作用で使います。$pb$, $pb$`useState` は状態保持用で、API 実行タイミングの管理役ではありません。$pb$, 10135, TRUE),
  ($pb$1fe60980-d9e6-47a7-a39d-7fb8c0b8d336$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$HTTP 通信に使う関数名$pb$, 1, $pb$fill_blank$pb$, $pb$ブラウザ標準で `/api/tasks` を取得したいです。空欄を埋めてください。
  
  __________("/api/tasks")$pb$, $pb$空欄だけを書いてください。$pb$, $pb$JavaScript 標準の通信 API です。$pb$, $pb$fetch$pb$, $pb$React でも標準通信は `fetch` をよく使います。$pb$, $pb$`axios` もありますが、この問題は標準 API 前提です。$pb$, 10136, TRUE),
  ($pb$5d6225f5-bbbe-4863-a081-ce73a3918e49$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$レスポンスを JSON にするメソッド$pb$, 1, $pb$fill_blank$pb$, $pb$`const data = await response.__________();` の空欄を埋めてください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$JSON へ変換するメソッドです。$pb$, $pb$json$pb$, $pb$`response.json()` でレスポンス本文をオブジェクトへ変換できます。$pb$, $pb$`parse()` ではありません。$pb$, 10137, TRUE),
  ($pb$29a87972-5784-4210-a547-a8f6e407f8c1$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$初回表示で tasks を取得する useEffect を書く$pb$, 2, $pb$code$pb$, $pb$`tasks` と `setTasks` がある前提で、`/api/tasks` を取得して JSON 結果を `setTasks` に入れる `useEffect` を書いてください。$pb$, $pb$依存配列は空配列にすること$pb$, $pb$useEffect の中で async 関数を定義して呼ぶ形でも構いません。$pb$, $pb$useEffect(() => {
    async function loadTasks() {
      const response = await fetch("/api/tasks");
      const data = await response.json();
      setTasks(data);
    }
  
    loadTasks();
  }, []);$pb$, $pb$初回取得の典型パターンです。$pb$, $pb$依存配列を省くと再描画のたびに取得が走りやすくなります。$pb$, 10138, TRUE),
  ($pb$2d88d5b0-92d6-4c80-a043-c0e95dfa83c9$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$loading を使う API 取得コードを書く$pb$, 2, $pb$code$pb$, $pb$`setLoading` と `setTasks` がある前提で、取得開始前に loading を true、取得後に false に戻す非同期処理を書いてください。$pb$, $pb$finally を使うこと$pb$, $pb$try/finally で後片付けします。$pb$, $pb$async function loadTasks() {
    setLoading(true);
    try {
      const response = await fetch("/api/tasks");
      const data = await response.json();
      setTasks(data);
    } finally {
      setLoading(false);
    }
  }$pb$, $pb$loading は成功失敗に関係なく戻す必要があるため finally が便利です。$pb$, $pb$成功時だけ false に戻すと、失敗時に loading が残り続けます。$pb$, 10139, TRUE),
  ($pb$a25b212c-3702-4429-a831-16281e2213c3$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$新しい task を POST 送信するコードを書く$pb$, 2, $pb$code$pb$, $pb$`title` を `/api/tasks` に POST 送信する fetch コードを書いてください。body は JSON にしてください。$pb$, $pb$`method`, `headers`, `body` を含めること$pb$, $pb$`Content-Type` は application/json です。$pb$, $pb$await fetch("/api/tasks", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ title }),
  });$pb$, $pb$React でも送信処理は JavaScript の fetch 基本形です。$pb$, $pb$body を JSON.stringify しないと正しい JSON になりません。$pb$, 10140, TRUE),
  ($pb$2b53a2a7-b08b-49db-a799-1ab67890d595$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$API エラーを state に入れるコードを書く$pb$, 3, $pb$code$pb$, $pb$`setErrorMessage` がある前提で、fetch 失敗時に `error.message` を state に入れる try/catch コードを書いてください。$pb$, $pb$catch で error を受けること$pb$, $pb$成功時処理は簡略化して構いません。$pb$, $pb$try {
    const response = await fetch("/api/tasks");
    await response.json();
  } catch (error) {
    setErrorMessage(error.message);
  }$pb$, $pb$失敗時の表示制御まで含めると実務に近づきます。$pb$, $pb$catch を書かないと失敗時の UI が分かりにくくなります。$pb$, 10141, TRUE),
  ($pb$f99623c6-477c-480f-acb3-43f8e73a763b$pb$, $pb$ae242d38-c6b3-4e33-ae25-36fde82d86de$pb$, $pb$初回だけ実行する依存配列$pb$, 1, $pb$fill_blank$pb$, $pb$`useEffect(() => { loadTasks(); }, __________);` の空欄を埋めて、初回だけ実行してください。$pb$, $pb$空欄だけを書いてください。$pb$, $pb$空の配列です。$pb$, $pb$[]$pb$, $pb$空配列を渡すと初回マウント時だけ実行されます。$pb$, $pb$配列を省くと再描画ごとに動く可能性があります。$pb$, 10142, TRUE),
  ($pb$c2cea966-3a4c-44c8-ab39-ce99dfb5624e$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$子コンポーネントへ値を渡す仕組み名$pb$, 1, $pb$fill_blank$pb$, $pb$親コンポーネントから子コンポーネントへ値を渡す仕組み名を書いてください。
  
  __________$pb$, $pb$空欄だけを書いてください。$pb$, $pb$React の基本用語です。$pb$, $pb$props$pb$, $pb$props は親から子へデータや関数を渡す仕組みです。$pb$, $pb$state は各コンポーネント内の状態で、役割が違います。$pb$, 10143, TRUE),
  ($pb$e33f6d1f-407a-40a0-aade-ba83d5b47ce6$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$子コンポーネントを import する記法$pb$, 1, $pb$fill_blank$pb$, $pb$`TaskList` コンポーネントを `./TaskList` から読み込みたいです。空欄を埋めてください。
  
  __________ TaskList from "./TaskList";$pb$, $pb$空欄だけを書いてください。$pb$, $pb$ES Modules の読み込みです。$pb$, $pb$import$pb$, $pb$コンポーネント分割後は import で取り込みます。$pb$, $pb$`require` を混ぜると書き方がぶれやすくなります。$pb$, 10144, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;
INSERT INTO problems (id, theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order, is_active) VALUES
  ($pb$f7738b40-adbf-49d9-a0e2-ae83740fb923$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$TaskList コンポーネントを書く$pb$, 2, $pb$code$pb$, $pb$`tasks` を props で受け取り、`TaskItem` を使って一覧表示する `TaskList` コンポーネントを書いてください。`key` は `task.id` を使ってください。$pb$, $pb$`map` と `TaskItem` を使うこと$pb$, $pb$親から受けた tasks をそのまま map します。$pb$, $pb$function TaskList({ tasks }) {
    return (
      <ul>
        {tasks.map((task) => (
          <TaskItem key={task.id} task={task} />
        ))}
      </ul>
    );
  }$pb$, $pb$一覧責務を切り出すと親コンポーネントが軽くなります。$pb$, $pb$li の中身を全部親に残したままだと分割の効果が薄れます。$pb$, 10145, TRUE),
  ($pb$b50f2d85-99ed-47d8-aeab-b2da1eb6f71e$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$task を表示する TaskItem を書く$pb$, 2, $pb$code$pb$, $pb$`task` を props で受け取り、`<li>{task.title}</li>` を返す `TaskItem` コンポーネントを書いてください。$pb$, $pb$props は分割代入せず task をそのまま受けても構いません。$pb$, $pb$表示責務だけに絞ります。$pb$, $pb$function TaskItem({ task }) {
    return <li>{task.title}</li>;
  }$pb$, $pb$1 件表示を分けると再利用しやすくなります。$pb$, $pb$task.title の代わりに title を直接使うなら引数側も合わせる必要があります。$pb$, 10146, TRUE),
  ($pb$42cc15cb-5544-41a3-a4f7-28696c50af8e$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$children を受け取る Layout を書く$pb$, 2, $pb$code$pb$, $pb$`children` を props で受け取り、`<main>{children}</main>` を返す `Layout` コンポーネントを書いてください。$pb$, $pb$`children` を表示すること$pb$, $pb$分割代入で children を受けると見やすいです。$pb$, $pb$function Layout({ children }) {
    return <main>{children}</main>;
  }$pb$, $pb$children を使うとレイアウト部品が作りやすくなります。$pb$, $pb$children を返さないと内側の要素が表示されません。$pb$, 10147, TRUE),
  ($pb$62d82614-2dd2-4582-ab85-f54a8f1c68ed$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$親から TaskList へ tasks を渡す JSX を書く$pb$, 1, $pb$code$pb$, $pb$`tasks` 変数がある前提で、`TaskList` コンポーネントへ tasks を渡す JSX を書いてください。$pb$, $pb$回答をそのまま書いてください。$pb$, $pb$prop 名も tasks にします。$pb$, $pb$<TaskList tasks={tasks} />$pb$, $pb$親から子へ一覧データを渡す基本形です。$pb$, $pb$`tasks="tasks"` にすると文字列が渡ります。$pb$, 10148, TRUE),
  ($pb$29906751-e4c0-443a-aeda-6b35866300af$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$isOpen が false なら何も出さない Modal を書く$pb$, 3, $pb$code$pb$, $pb$`isOpen` と `children` を props で受け取り、`isOpen` が false なら `null`、true なら `<div>{children}</div>` を返す `Modal` コンポーネントを書いてください。$pb$, $pb$早期 return を使って構いません。$pb$, $pb$閉じているときは null を返します。$pb$, $pb$function Modal({ isOpen, children }) {
    if (!isOpen) {
      return null;
    }
  
    return <div>{children}</div>;
  }$pb$, $pb$表示制御を部品側で持たせると親がすっきりします。$pb$, $pb$false のとき空文字を返すより null の方が React では意図が明確です。$pb$, 10149, TRUE),
  ($pb$ff3eb849-0fa8-4dfd-a786-c5a323744ce7$pb$, $pb$6a2b82c5-ce03-4cfe-a3d8-676b672917bc$pb$, $pb$TaskPage を小さい部品で組み立てる JSX を書く$pb$, 3, $pb$code$pb$, $pb$`Header`, `TaskForm`, `TaskList` の 3 コンポーネントがある前提で、上から順に並べて返す `TaskPage` コンポーネントを書いてください。`tasks` は `TaskList` へ渡してください。$pb$, $pb$`tasks` prop を使うこと$pb$, $pb$大きい画面を小さい部品へ分ける意識です。$pb$, $pb$function TaskPage({ tasks }) {
    return (
      <div>
        <Header />
        <TaskForm />
        <TaskList tasks={tasks} />
      </div>
    );
  }$pb$, $pb$画面を部品で組み立てる練習は研修でも重要です。$pb$, $pb$すべてを 1 コンポーネントに詰め込むと責務が重くなります。$pb$, 10150, TRUE),
  ($pb$44733f61-7ff4-40d8-a0b1-79954e7eaa36$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$現在のディレクトリ一覧を見るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$今いるディレクトリのファイルやフォルダ一覧を確認したいです。空欄を埋めてください。
  
  __________$pb$, $pb$コマンドだけを書いてください。$pb$, $pb$Linux 学習の最初に出てくる基本コマンドです。$pb$, $pb$ls$pb$, $pb$`ls` は現在のディレクトリ内にあるファイルやフォルダを一覧表示します。$pb$, $pb$`pwd` は場所確認で、一覧表示ではありません。$pb$, 11101, TRUE),
  ($pb$494ee7d2-9f44-451d-a078-790fd611e287$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$現在地を表示するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$自分が今どのディレクトリにいるか確認したいです。空欄を埋めてください。
  
  __________$pb$, $pb$コマンドだけを書いてください。$pb$, $pb$print working directory の略です。$pb$, $pb$pwd$pb$, $pb$`pwd` は現在の作業ディレクトリのパスを表示します。$pb$, $pb$`cd` は移動、`pwd` は現在地確認です。$pb$, 11102, TRUE),
  ($pb$c5049dd7-9eb2-4d2f-ab7a-8c1955e79f40$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$documents ディレクトリへ移動するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`documents` ディレクトリへ移動したいです。空欄を埋めてください。
  
  __________ documents$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$change directory の略です。$pb$, $pb$cd$pb$, $pb$`cd documents` で指定したディレクトリへ移動できます。$pb$, $pb$`ls documents` は中身を見るだけで移動はしません。$pb$, 11103, TRUE),
  ($pb$78b84a17-a22c-4dcc-ac97-0e9b330648e0$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$新しいフォルダを作るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`logs` という名前のディレクトリを作成したいです。空欄を埋めてください。
  
  __________ logs$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$make directory の略です。$pb$, $pb$mkdir$pb$, $pb$`mkdir logs` で新しいディレクトリを作成できます。$pb$, $pb$`touch` はファイル作成で、ディレクトリ作成ではありません。$pb$, 11104, TRUE),
  ($pb$999b3d94-875e-40f6-a30c-e973530128d4$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$file.txt を削除するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`file.txt` を削除したいです。空欄を埋めてください。
  
  __________ file.txt$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$remove の略です。$pb$, $pb$rm$pb$, $pb$`rm file.txt` でファイルを削除できます。$pb$, $pb$`rmdir` は空ディレクトリ向けで、通常のファイル削除とは用途が違います。$pb$, 11105, TRUE),
  ($pb$64c1bd0c-7fa1-41b6-a539-f71a1fe01ac0$pb$, $pb$50b0b645-60a9-4b90-ab04-72af767d0480$pb$, $pb$ファイルをコピーするコマンド名$pb$, 1, $pb$fill_blank$pb$, $pb$`report.txt` を `backup.txt` として複製したいです。空欄を埋めてください。
  
  __________ report.txt backup.txt$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$copy の略です。$pb$, $pb$cp$pb$, $pb$`cp 元 先` でファイルやディレクトリをコピーできます。$pb$, $pb$`mv` は移動や名前変更で、複製ではありません。$pb$, 11106, TRUE),
  ($pb$77cdd36d-fa38-48e7-a02e-9b94d8e9e290$pb$, $pb$5e1e247f-1560-464c-a100-e8f4155b49e7$pb$, $pb$ファイル内容をそのまま表示するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`config.txt` の中身をそのまま表示したいです。空欄を埋めてください。
  
  __________ config.txt$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$短いファイルの確認でよく使います。$pb$, $pb$cat$pb$, $pb$`cat` はファイル内容を標準出力へそのまま表示します。$pb$, $pb$`less` はページ送りしながら読むときに向いています。$pb$, 11107, TRUE),
  ($pb$0c3e39b8-799d-4b86-a684-cb6e35f0fabc$pb$, $pb$5e1e247f-1560-464c-a100-e8f4155b49e7$pb$, $pb$長いファイルをページ送りで確認するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`server.log` をページ送りしながら確認したいです。空欄を埋めてください。
  
  __________ server.log$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$長いログを読むときによく使います。$pb$, $pb$less$pb$, $pb$`less` は長いファイルをスクロールしながら確認できるコマンドです。$pb$, $pb$`cat` だと長い内容が一気に流れて読みづらくなります。$pb$, 11108, TRUE),
  ($pb$53f577c0-2853-48fc-a52a-6b9e1216b741$pb$, $pb$5e1e247f-1560-464c-a100-e8f4155b49e7$pb$, $pb$空のファイルを作るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`notes.txt` という空ファイルを新しく作りたいです。空欄を埋めてください。
  
  __________ notes.txt$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$存在しないファイルを作る基本コマンドです。$pb$, $pb$touch$pb$, $pb$`touch notes.txt` で空ファイル作成や更新日時変更ができます。$pb$, $pb$`mkdir` はフォルダ作成用です。$pb$, 11109, TRUE),
  ($pb$59ec0d8b-16dd-4298-a31a-8885885cb669$pb$, $pb$5e1e247f-1560-464c-a100-e8f4155b49e7$pb$, $pb$config.txt を開いて編集する手順を書く$pb$, 2, $pb$procedure$pb$, $pb$`config.txt` をターミナル上で開いて編集したいです。Linux 初学者向けの基本手順を 2 ステップで書いてください。$pb$, $pb$エディタでファイルを開くことを書くこと
  保存して終了することに触れること$pb$, $pb$まずは `nano` を例にすると説明しやすいです。$pb$, $pb$1. `nano config.txt` のようにエディタでファイルを開く。
  2. 内容を編集し、保存してエディタを終了する。$pb$, $pb$Linux ではコマンドラインエディタでそのままファイル編集する場面がよくあります。$pb$, $pb$`cat` では表示だけで編集できません。$pb$, 11110, TRUE),
  ($pb$742df4d2-53fa-4440-aec0-05110b8d9315$pb$, $pb$e7fa0a39-0e71-4bcc-a197-db2f2f728553$pb$, $pb$権限表示を確認するオプション$pb$, 1, $pb$fill_blank$pb$, $pb$ファイルの権限を `-rw-r--r--` のような形式で見たいです。空欄を埋めてください。
  
  ls __________$pb$, $pb$オプションだけを書いてください。$pb$, $pb$long format の略です。$pb$, $pb$-l$pb$, $pb$`ls -l` で権限、所有者、サイズなどを詳しく表示できます。$pb$, $pb$`-a` は隠しファイル表示で、権限表示の主目的ではありません。$pb$, 11111, TRUE),
  ($pb$2851ebc5-f7bc-47cf-acb1-05d5c6f216c7$pb$, $pb$e7fa0a39-0e71-4bcc-a197-db2f2f728553$pb$, $pb$実行権限を追加するコマンド名$pb$, 1, $pb$fill_blank$pb$, $pb$`script.sh` に実行権限を付けたいです。空欄を埋めてください。
  
  __________ +x script.sh$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$change mode の略です。$pb$, $pb$chmod$pb$, $pb$`chmod +x` で実行権限を追加できます。$pb$, $pb$`chown` は所有者変更で、権限ビット変更ではありません。$pb$, 11112, TRUE),
  ($pb$57cdf227-ac5c-47c1-a6ec-9f8a9ef0da24$pb$, $pb$e7fa0a39-0e71-4bcc-a197-db2f2f728553$pb$, $pb$所有者を変えるコマンド名$pb$, 2, $pb$fill_blank$pb$, $pb$`app.log` の所有者を `ubuntu` に変更したいです。空欄を埋めてください。
  
  __________ ubuntu app.log$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$change owner の略です。$pb$, $pb$chown$pb$, $pb$`chown` はファイルやディレクトリの所有者を変更するときに使います。$pb$, $pb$`chmod` は権限変更で、所有者変更には使えません。$pb$, 11113, TRUE),
  ($pb$26711c03-b19b-48be-a2a6-0fd25b2b9814$pb$, $pb$e7fa0a39-0e71-4bcc-a197-db2f2f728553$pb$, $pb$実行権限付きか確認する観点を書く$pb$, 2, $pb$procedure$pb$, $pb$`script.sh` が実行できないとき、権限観点でまず何を確認するかを 2 点書いてください。$pb$, $pb$`ls -l` で権限を確認することに触れること
  実行権限 `x` の有無に触れること$pb$, $pb$まず見方を確認してから、x が付いているかを見ます。$pb$, $pb$1. `ls -l script.sh` で権限表示を確認する。
  2. 所有者や実行対象に `x` が付いているかを確認する。$pb$, $pb$実行できない原因として、まず権限不足を疑うのが基本です。$pb$, $pb$内容だけ見直しても、実行権限がなければ起動できません。$pb$, 11114, TRUE),
  ($pb$b4baf614-9780-4859-a940-aeb1df88be20$pb$, $pb$2f2fab65-ef16-434c-a12e-01c8896e167b$pb$, $pb$実行中プロセスを見るコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$今動いているプロセスを確認したいです。空欄を埋めてください。
  
  __________$pb$, $pb$コマンドだけを書いてください。$pb$, $pb$process status の略です。$pb$, $pb$ps$pb$, $pb$`ps` は実行中プロセス確認の基本コマンドです。$pb$, $pb$`pwd` は現在地確認で、プロセス確認ではありません。$pb$, 11115, TRUE),
  ($pb$198c2237-40bb-4a6f-a79b-82c16183f4d7$pb$, $pb$2f2fab65-ef16-434c-a12e-01c8896e167b$pb$, $pb$PID 1234 を終了するコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$PID が 1234 のプロセスを終了したいです。空欄を埋めてください。
  
  __________ 1234$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$プロセス終了の基本コマンドです。$pb$, $pb$kill$pb$, $pb$`kill 1234` で指定した PID のプロセスへ終了シグナルを送れます。$pb$, $pb$`rm` はファイル削除で、プロセス終了には使いません。$pb$, 11116, TRUE),
  ($pb$a38e3424-9696-46d7-ada9-a382dcee2060$pb$, $pb$2f2fab65-ef16-434c-a12e-01c8896e167b$pb$, $pb$サーバが起動しているか確認する手順を書く$pb$, 2, $pb$procedure$pb$, $pb$Spring Boot サーバが Linux 上で起動しているか確認したいです。基本的な確認手順を 2 つ書いてください。$pb$, $pb$プロセス確認またはログ確認に触れること
  ポート確認または応答確認に触れること$pb$, $pb$「動いているか」と「外から応答するか」の 2 観点です。$pb$, $pb$1. `ps` やログ確認で、サーバプロセスが起動しているかを確認する。
  2. ポート確認や `curl` で、実際に応答できる状態かを確認する。$pb$, $pb$サーバ確認では、プロセスと通信の両方を見ると切り分けしやすくなります。$pb$, $pb$プロセスだけ見ても、ポート待受や応答異常を見落とすことがあります。$pb$, 11117, TRUE),
  ($pb$f40b7b78-8f7b-47e4-a0d3-3a9add8db2e5$pb$, $pb$328d8c07-3199-4179-a596-4c44073df86a$pb$, $pb$HTTP 応答確認に使うコマンド$pb$, 1, $pb$fill_blank$pb$, $pb$`http://localhost:8080` に応答があるか確認したいです。空欄を埋めてください。
  
  __________ http://localhost:8080$pb$, $pb$コマンド名だけを書いてください。$pb$, $pb$HTTP リクエスト送信の基本コマンドです。$pb$, $pb$curl$pb$, $pb$`curl` は URL へリクエストを送って応答確認するときに便利です。$pb$, $pb$`cd` や `cat` ではネットワーク確認はできません。$pb$, 11118, TRUE),
  ($pb$1c611fed-89df-41d2-aa10-c0755034de39$pb$, $pb$328d8c07-3199-4179-a596-4c44073df86a$pb$, $pb$8080 番ポート確認の手順を書く$pb$, 2, $pb$procedure$pb$, $pb$アプリが 8080 番で待ち受けしているか確認したいです。Linux 初学者向けに基本確認手順を 2 点書いてください。$pb$, $pb$ポート確認コマンドに触れること
  応答確認にも触れること$pb$, $pb$`ss` や `netstat` のようなポート確認と、`curl` のような応答確認を組み合わせると分かりやすいです。$pb$, $pb$1. `ss -lntp` などで 8080 番ポートを待ち受けしているプロセスがあるか確認する。
  2. `curl http://localhost:8080` で実際に応答が返るか確認する。$pb$, $pb$ポート待受と HTTP 応答の両方を見ると、起動確認の精度が上がります。$pb$, $pb$ポートだけ見て、実際の応答が失敗しているケースを見落としやすいです。$pb$, 11119, TRUE),
  ($pb$f3dc756d-d961-46e8-a8a3-19945d068016$pb$, $pb$328d8c07-3199-4179-a596-4c44073df86a$pb$, $pb$ログ確認の基本手順を書く$pb$, 2, $pb$procedure$pb$, $pb$サーバエラーの原因を追うために `app.log` を確認したいです。基本的な確認手順を 2 ステップで書いてください。$pb$, $pb$まず内容を見ることに触れること
  必要なら末尾や更新を見る観点に触れること$pb$, $pb$`less` や `tail` を使う流れをイメージすると書きやすいです。$pb$, $pb$1. `less app.log` などでログ内容を開いて確認する。
  2. 直近のエラーを追いたい場合は末尾を重点的に確認する。$pb$, $pb$ログ確認では全体を開く視点と、直近エラーへ寄る視点の両方が役立ちます。$pb$, $pb$ログを見ずに設定変更だけを繰り返すと、原因特定が遅くなりやすいです。$pb$, 11120, TRUE)
ON CONFLICT (id) DO UPDATE SET
  theme_id = EXCLUDED.theme_id,
  title = EXCLUDED.title,
  level = EXCLUDED.level,
  type = EXCLUDED.type,
  statement = EXCLUDED.statement,
  requirements = EXCLUDED.requirements,
  hint = EXCLUDED.hint,
  answer = EXCLUDED.answer,
  explanation = EXCLUDED.explanation,
  common_mistakes = EXCLUDED.common_mistakes,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now())
;

COMMIT;
