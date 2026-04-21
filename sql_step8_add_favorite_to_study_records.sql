-- =============================================
-- STEP 8: お気に入り状態を学習記録に追加する
-- - 既存データは削除しない
-- - study_records に is_favorite を増分追加する
-- - 既存の学習記録は false で初期化される
-- =============================================

ALTER TABLE IF EXISTS public.study_records
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN NOT NULL DEFAULT false;
