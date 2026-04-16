-- =============================================
-- STEP 4: 既存Javaアプリに Spring Boot を安全に追加する
-- - technologies テーブル追加
-- - 既存テーマを Java にひも付け
-- - Spring Boot のテーマを追加
-- - 初学者向けに手動で厳選した Spring Boot 穴埋め問題を追加
-- =============================================

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

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'technologies'
          AND policyname = 'Allow public read access on technologies'
    ) THEN
        CREATE POLICY "Allow public read access on technologies"
        ON technologies
        FOR SELECT
        USING (true);
    END IF;
END $$;

ALTER TABLE themes
ADD COLUMN IF NOT EXISTS technology_id UUID;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'themes_technology_id_fkey'
    ) THEN
        ALTER TABLE themes
        ADD CONSTRAINT themes_technology_id_fkey
        FOREIGN KEY (technology_id) REFERENCES technologies(id) ON DELETE RESTRICT;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_themes_technology_id ON themes(technology_id);

INSERT INTO technologies (id, name, slug, description, display_order, is_active)
VALUES
('90000000-0000-0000-0000-000000000001', 'Java', 'java', 'Java基礎の実装問題', 1, true),
('90000000-0000-0000-0000-000000000002', 'Spring Boot', 'spring-boot', 'Spring Boot入門の実装問題', 2, true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    display_order = EXCLUDED.display_order,
    is_active = EXCLUDED.is_active,
    updated_at = timezone('utc'::text, now());

UPDATE themes
SET technology_id = '90000000-0000-0000-0000-000000000001'
WHERE technology_id IS NULL;

INSERT INTO themes (id, technology_id, name, description, display_order)
VALUES
('66666666-6666-6666-6666-000000000001', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Controller基礎', 'Controllerとルーティングの基本', 6),
('66666666-6666-6666-6666-000000000002', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Request / Response', 'リクエスト受け取りとレスポンス返却の基本', 7),
('66666666-6666-6666-6666-000000000003', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Service / Repository', 'サービス層とデータアクセス層の基礎', 8),
('66666666-6666-6666-6666-000000000004', '90000000-0000-0000-0000-000000000002', 'Spring Boot: Validation / Exception', '入力検証と例外ハンドリングの基礎', 9)
ON CONFLICT (id) DO UPDATE SET
    technology_id = EXCLUDED.technology_id,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    display_order = EXCLUDED.display_order;

INSERT INTO problems (
    id,
    theme_id,
    title,
    level,
    type,
    statement,
    requirements,
    hint,
    answer,
    explanation,
    common_mistakes,
    display_order
)
VALUES
(
    '77777777-7777-7777-7777-000000000001',
    '66666666-6666-6666-6666-000000000001',
    'RESTコントローラーの基本アノテーション',
    1,
    'fill_blank',
    E'以下のクラスを REST API のコントローラーとして扱いたいです。\n空欄に入るアノテーションだけを答えてください。\n\n__________\npublic class TaskController {\n}',
    E'空欄には1行だけを書いてください。',
    'HTML画面ではなくJSONを返すコントローラーで使うアノテーションです。',
    '@RestController',
    '@RestController は @Controller と @ResponseBody の役割をまとめて持つため、REST API の入口でよく使います。',
    '@Controller と書くと、戻り値をテンプレート名として扱う構成になりやすい点に注意です。',
    601
),
(
    '77777777-7777-7777-7777-000000000002',
    '66666666-6666-6666-6666-000000000001',
    'GETエンドポイントのマッピング',
    1,
    'fill_blank',
    E'一覧取得用の GET エンドポイントを作りたいです。\n空欄に入るアノテーションだけを答えてください。\n\n@RestController\n@RequestMapping("/tasks")\npublic class TaskController {\n\n    __________\n    public List<String> getTasks() {\n        return List.of("A", "B");\n    }\n}',
    E'空欄には1行だけを書いてください。',
    'GETメソッド用のマッピングです。',
    '@GetMapping',
    '@GetMapping を付けると、このメソッドが GET リクエストを受け取る入口になります。',
    '@RequestMapping だけでも書けますが、初学者は GET / POST を明確に分ける書き方の方が理解しやすいです。',
    602
),
(
    '77777777-7777-7777-7777-000000000003',
    '66666666-6666-6666-6666-000000000001',
    'PathVariableでIDを受け取る',
    1,
    'fill_blank',
    E'URL に含まれる id を受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@GetMapping("/{id}")\npublic String getTask(__________) {\n    return "task";\n}',
    E'空欄には引数1つ分だけを書いてください。',
    'URLの {id} をメソッド引数へ結びつけるアノテーションです。',
    '@PathVariable Long id',
    '@PathVariable を付けると、URLパス中の値をそのまま引数で受け取れます。',
    'RequestParam と混同しやすいですが、今回はクエリ文字列ではなくパスの一部です。',
    603
),
(
    '77777777-7777-7777-7777-000000000004',
    '66666666-6666-6666-6666-000000000001',
    'RequestParamで検索条件を受け取る',
    2,
    'fill_blank',
    E'クエリパラメータの status を受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@GetMapping("/search")\npublic String search(__________) {\n    return status;\n}',
    E'空欄には引数1つ分だけを書いてください。',
    'URLの ?status=done のような値を受け取るときに使います。',
    '@RequestParam String status',
    '@RequestParam はクエリパラメータを受け取るための基本アノテーションです。',
    '@PathVariable と混同すると、URL設計と受け取り方がずれてしまいます。',
    604
),
(
    '77777777-7777-7777-7777-000000000005',
    '66666666-6666-6666-6666-000000000002',
    'RequestBodyでJSONを受け取る',
    2,
    'fill_blank',
    E'POSTされた JSON を CreateTaskRequest に受け取りたいです。\n空欄に入る引数だけを答えてください。\n\n@PostMapping\npublic String createTask(__________) {\n    return request.getTitle();\n}',
    E'空欄には引数1つ分だけを書いてください。',
    'JSONボディをJavaオブジェクトへ変換して受け取りたい場面です。',
    '@RequestBody CreateTaskRequest request',
    '@RequestBody を付けると、リクエストボディのJSONを指定したクラスへ変換して受け取れます。',
    'RequestParam を使うと、JSONボディではなくクエリパラメータとして扱われます。',
    701
),
(
    '77777777-7777-7777-7777-000000000006',
    '66666666-6666-6666-6666-000000000002',
    '201 Createdでレスポンスを返す',
    3,
    'fill_blank',
    E'作成成功時に 201 Created を返したいです。\n空欄に入る return の右辺だけを答えてください。\n\n@PostMapping\npublic ResponseEntity<TaskResponse> create(@RequestBody CreateTaskRequest request) {\n    TaskResponse response = service.create(request);\n    return __________;\n}',
    E'空欄には return の右辺だけを書いてください。',
    '新規作成成功時は 200 OK ではなく 201 Created を返すことがあります。',
    'ResponseEntity.status(HttpStatus.CREATED).body(response)',
    'ResponseEntity を使うと、HTTPステータスとレスポンスボディをまとめて明示できます。',
    'ResponseEntity.ok(response) でも動きますが、作成系APIでは CREATED を返す方が意図が伝わりやすいです。',
    702
),
(
    '77777777-7777-7777-7777-000000000007',
    '66666666-6666-6666-6666-000000000003',
    'Serviceクラスの基本アノテーション',
    1,
    'fill_blank',
    E'ビジネスロジックを持つクラスとして Spring に管理させたいです。\n空欄に入るアノテーションだけを答えてください。\n\n__________\npublic class TaskService {\n}',
    E'空欄には1行だけを書いてください。',
    'Controller でも Repository でもない、中間の業務ロジック層です。',
    '@Service',
    '@Service はサービス層のクラスをSpring管理のBeanとして登録するときの代表的なアノテーションです。',
    '@Component でも登録できますが、役割を明確にするために @Service を使う方が読みやすいです。',
    801
),
(
    '77777777-7777-7777-7777-000000000008',
    '66666666-6666-6666-6666-000000000003',
    'コンストラクタインジェクションの代入',
    2,
    'fill_blank',
    E'コンストラクタで受け取った repository をフィールドへ代入したいです。\n空欄に入る1行だけを答えてください。\n\n@Service\npublic class TaskService {\n    private final TaskRepository taskRepository;\n\n    public TaskService(TaskRepository taskRepository) {\n        __________\n    }\n}',
    E'空欄には1行だけを書いてください。',
    '引数名とフィールド名が同じなので、this を使います。',
    'this.taskRepository = taskRepository;',
    'コンストラクタインジェクションでは、受け取った依存オブジェクトを final フィールドへ代入する形が基本です。',
    'this を付け忘れると、引数同士の代入になってしまいフィールドが初期化されません。',
    802
),
(
    '77777777-7777-7777-7777-000000000009',
    '66666666-6666-6666-6666-000000000003',
    'JPA Repositoryの継承',
    2,
    'fill_blank',
    E'タスクの永続化を担当する Repository インターフェースを作りたいです。\n空欄に入る継承先だけを答えてください。\n\npublic interface TaskRepository extends __________ {\n}',
    E'空欄には型名だけを書いてください。',
    'Spring Data JPA の基本形です。',
    'JpaRepository<Task, Long>',
    'JpaRepository<Entity, ID型> の形で継承すると、基本的なCRUDメソッドを自動で使えるようになります。',
    'ID型を Integer にしてしまう、Entity型を DTO にしてしまう、の2つが初学者で起きやすいミスです。',
    803
),
(
    '77777777-7777-7777-7777-000000000010',
    '66666666-6666-6666-6666-000000000004',
    '必須入力のバリデーション',
    2,
    'fill_blank',
    E'タイトルを必須入力にしたいです。\n空欄に入るアノテーションだけを答えてください。\n\npublic class CreateTaskRequest {\n    __________\n    private String title;\n}',
    E'空欄には1行だけを書いてください。',
    '空文字や空白だけを弾きたいときに使います。',
    '@NotBlank(message = "title is required")',
    '@NotBlank は null だけでなく空文字や空白文字だけの入力も不正として扱えます。',
    '@NotNull だと空文字を許してしまうため、文字列の必須チェックとしては弱いです。',
    901
),
(
    '77777777-7777-7777-7777-000000000011',
    '66666666-6666-6666-6666-000000000004',
    'リクエストDTOに@Validを付ける',
    2,
    'fill_blank',
    E'CreateTaskRequest に書いたバリデーションを有効にしたいです。\n空欄に入る引数だけを答えてください。\n\n@PostMapping\npublic ResponseEntity<Void> create(__________) {\n    return ResponseEntity.ok().build();\n}',
    E'空欄には引数1つ分だけを書いてください。',
    'バリデーション対象のDTOには @Valid を付けて受け取ります。',
    '@Valid @RequestBody CreateTaskRequest request',
    '@Valid を付けることで、DTOに書かれたアノテーションベースの入力チェックが実行されます。',
    '@RequestBody だけだとDTOへの変換はされても、バリデーションは走りません。',
    902
),
(
    '77777777-7777-7777-7777-000000000012',
    '66666666-6666-6666-6666-000000000004',
    '例外ハンドラの対象指定',
    3,
    'fill_blank',
    E'TaskNotFoundException をまとめて処理したいです。\n空欄に入るアノテーションだけを答えてください。\n\n@ControllerAdvice\npublic class GlobalExceptionHandler {\n\n    __________\n    public ResponseEntity<String> handleTaskNotFound(TaskNotFoundException e) {\n        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());\n    }\n}',
    E'空欄には1行だけを書いてください。',
    '特定の例外クラスをハンドラメソッドに結びつけます。',
    '@ExceptionHandler(TaskNotFoundException.class)',
    '@ExceptionHandler を付けると、その例外が発生したときにこのメソッドでレスポンスを組み立てられます。',
    '@ControllerAdvice を付けただけでは、どの例外をどのメソッドで処理するかまでは決まりません。',
    903
)
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
    updated_at = timezone('utc'::text, now());
