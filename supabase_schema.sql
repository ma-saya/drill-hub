-- 1. 技術 (technologies) テーブル
CREATE TABLE technologies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. テーマ (themes) テーブル
CREATE TABLE themes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    technology_id UUID REFERENCES technologies(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. 問題 (problems) テーブル
CREATE TABLE problems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    theme_id UUID REFERENCES themes(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level IN (1, 2, 3)),
    type TEXT NOT NULL CHECK (type IN ('normal', 'fill_blank')),
    statement TEXT NOT NULL,
    requirements TEXT,
    hint TEXT,
    answer TEXT NOT NULL,
    explanation TEXT,
    common_mistakes TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. 学習記録 (study_records) テーブル
CREATE TABLE study_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    problem_id UUID REFERENCES problems(id) ON DELETE CASCADE,
    user_code TEXT,
    self_assessment TEXT CHECK (self_assessment IN ('success', 'close', 'fail')),
    is_strong BOOLEAN NOT NULL DEFAULT false,
    is_weak BOOLEAN NOT NULL DEFAULT false,
    last_studied_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, problem_id) -- 1ユーザーにつき1問題の記録を持つ
);

-- Row Level Security (RLS) の有効化とポリシー設定

-- 技術・テーマ・問題は全員(ゲスト含む)が読み取り可能
ALTER TABLE technologies ENABLE ROW LEVEL SECURITY;
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE problems ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on technologies" ON technologies FOR SELECT USING (true);
CREATE POLICY "Allow public read access on themes" ON themes FOR SELECT USING (true);
CREATE POLICY "Allow public read access on problems" ON problems FOR SELECT USING (true);

-- 学習記録は自分自身のデータのみ読み書き可能
ALTER TABLE study_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create their own study records" 
ON study_records FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study records" 
ON study_records FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own study records" 
ON study_records FOR SELECT 
USING (auth.uid() = user_id);

-- シードデータ（初期データ）の投入 --
-- 1. 技術の投入
INSERT INTO technologies (id, name, slug, description, display_order) VALUES
('90000000-0000-0000-0000-000000000001', 'Java', 'java', 'Java基礎の実装問題', 1),
('90000000-0000-0000-0000-000000000002', 'Spring Boot', 'spring-boot', 'Spring Boot入門の実装問題', 2);

-- 2. テーマの投入
INSERT INTO themes (id, technology_id, name, description, display_order) VALUES
('11111111-1111-1111-1111-111111111111', '90000000-0000-0000-0000-000000000001', 'テーマ1: TODOアプリ基礎', 'クラス、フィールド、コンストラクタ、CRUD処理', 1),
('22222222-2222-2222-2222-222222222222', '90000000-0000-0000-0000-000000000001', 'テーマ2: ユーザー管理', 'バリデーション、重複判定、条件分岐', 2),
('33333333-3333-3333-3333-333333333333', '90000000-0000-0000-0000-000000000001', 'テーマ3: コレクション / Stream', 'filter, map, sorted, 集計', 3),
('44444444-4444-4444-4444-444444444444', '90000000-0000-0000-0000-000000000001', 'テーマ4: ファイル / JSON', '文字列整形、入出力の概念', 4),
('55555555-5555-5555-5555-555555555555', '90000000-0000-0000-0000-000000000001', 'テーマ5: 疑似業務設計', 'DTO, Service, Repository, 責務分割', 5),
('66666666-6666-6666-6666-000000000001', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Controller基礎', 'Controllerとルーティングの基本', 6),
('66666666-6666-6666-6666-000000000002', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Request / Response', 'リクエスト受け取りとレスポンス返却の基本', 7),
('66666666-6666-6666-6666-000000000003', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Service / Repository', 'サービス層とデータアクセス層の基礎', 8),
('66666666-6666-6666-6666-000000000004', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Validation / Exception', '入力検証と例外ハンドリングの基礎', 9);

-- 2. 問題の投入 (サンプル各1問ずつ)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'Taskクラスの作成', 1, 'normal', 'TODOアプリで扱うTaskクラスを作成してください。', '- id (int), title (String), isCompleted (boolean) のフィールドを持つこと\n- 全フィールドを初期化するコンストラクタを持つこと', 'アクセス修飾子は private にし、getter/setterは省略してよいです。', 'public class Task {\n    private int id;\n    private String title;\n    private boolean isCompleted;\n\n    public Task(int id, String title, boolean isCompleted) {\n        this.id = id;\n        this.title = title;\n        this.isCompleted = isCompleted;\n    }\n}', 'クラスの基本的な構成を理解するための問題です。', 'thisをつけ忘れるミス', 1),
('33333333-3333-3333-3333-333333333333', '完了済みタスクの抽出', 1, 'fill_blank', 'List<Task> から、isCompleted が true のものだけを抽出するように空欄を埋めてください。', 'Stream APIを使用すること', 'filterを使います。', 'task.isCompleted()', 'filter内では関数型インターフェースに基づくラムダ式を使います。', 'task -> task.isCompleted == true のように冗長に書く', 1);
