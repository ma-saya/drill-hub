-- =============================================
-- STEP 7: Todo写経ドリルを安全に追加する
-- - 既存データは削除しない
-- - Java 技術の中に Todo写経ドリル用テーマを追加する
-- - 問題詳細画面の「あなたのコード」欄で手打ち練習できる code 問題を追加する
-- - 同じIDのデータがある場合だけ内容を更新する
-- - study_records は一切触らない
-- =============================================

BEGIN;

DO $$
DECLARE
  current_definition TEXT;
BEGIN
  SELECT pg_get_constraintdef(oid)
  INTO current_definition
  FROM pg_constraint
  WHERE conname = 'problems_type_check';

  IF current_definition IS NULL
    OR current_definition NOT LIKE '%code%'
    OR current_definition NOT LIKE '%procedure%'
    OR current_definition NOT LIKE '%concept%' THEN
    IF current_definition IS NOT NULL THEN
      ALTER TABLE problems DROP CONSTRAINT problems_type_check;
    END IF;

    ALTER TABLE problems
      ADD CONSTRAINT problems_type_check
      CHECK (type IN ('normal', 'fill_blank', 'code', 'procedure', 'concept'));
  END IF;
END $$;

INSERT INTO technologies (id, name, slug, description, display_order, is_active)
VALUES
(
  '90000000-0000-0000-0000-000000000001',
  'Java',
  'java',
  'Java基礎の実装問題',
  1,
  true
)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now());

-- 以前の Testing 知識問題SQLを実行済みの場合は、技術一覧の集計から外す。
-- 問題データは下の ON CONFLICT で Java: Todo写経ドリルへ移動する。
UPDATE technologies
SET
  is_active = false,
  updated_at = timezone('utc'::text, now())
WHERE slug = 'testing';

INSERT INTO themes (id, technology_id, name, description, display_order)
VALUES
(
  '77777777-aaaa-aaaa-aaaa-000000000001',
  (SELECT id FROM technologies WHERE slug = 'java'),
  'Java: Todo写経ドリル',
  'Todoアプリの基本構造を手で打って覚えるための問題',
  79
)
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
  display_order,
  is_active
)
VALUES
(
  '99999999-9999-9999-9999-000000000001',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'Taskクラスを手で作る',
  1,
  'code',
  $body$Todoアプリで扱う Task クラスを作ってください。
まずは「データを入れる箱」を自分の手で打てるようにする練習です。$body$,
  $body$クラス名: Task
フィールド:
- private int id
- private String title
- private boolean completed

コンストラクタ:
- id と title を受け取る
- completed は false で初期化する

メソッド:
- getId()
- getTitle()
- isCompleted()
- complete()$body$,
  $body$フィールドは private にして、外から読むために getter を用意します。完了状態の変更は complete() に寄せます。$body$,
  $body$public class Task {
    private int id;
    private String title;
    private boolean completed;

    public Task(int id, String title) {
        this.id = id;
        this.title = title;
        this.completed = false;
    }

    public int getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public boolean isCompleted() {
        return completed;
    }

    public void complete() {
        this.completed = true;
    }
}$body$,
  $body$Todoアプリでは、まず1件分のデータを表すクラスを作ります。id、title、completed の3つを自然に打てるようになると、次の Service 実装に進みやすくなります。$body$,
  $body$completed をコンストラクタ引数に含めると、追加直後から完了済みにできてしまいます。今回は追加直後は未完了に固定します。$body$,
  13001,
  true
),
(
  '99999999-9999-9999-9999-000000000002',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'TodoServiceのフィールドを作る',
  1,
  'code',
  $body$Todoを複数管理する TodoService クラスの骨組みを作ってください。
この問題では、リストと次のIDを持たせるところまでを練習します。$body$,
  $body$クラス名: TodoService
フィールド:
- private List<Task> tasks
- private int nextId

初期値:
- tasks は new ArrayList<>()
- nextId は 1$body$,
  $body$List と ArrayList を使うため、import が必要です。$body$,
  $body$import java.util.ArrayList;
import java.util.List;

public class TodoService {
    private List<Task> tasks = new ArrayList<>();
    private int nextId = 1;
}$body$,
  $body$Service は Todo の追加、一覧、完了、削除などの処理をまとめるクラスです。まずは内部に tasks と nextId を持たせます。$body$,
  $body$tasks を null のままにすると、追加時に NullPointerException になります。必ず new ArrayList<>() で初期化します。$body$,
  13002,
  true
),
(
  '99999999-9999-9999-9999-000000000003',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'Todoを追加するaddメソッドを書く',
  1,
  'code',
  $body$TodoService に Todo を追加する add メソッドを書いてください。
Todoアプリの Create 処理を手で覚えるための練習です。$body$,
  $body$メソッド名: add
引数: String title
戻り値: Task

処理:
1. nextId と title で Task を作る
2. nextId を 1 増やす
3. tasks に追加する
4. 作った Task を返す$body$,
  $body$Task を作ってから、IDの重複を避けるために nextId を増やします。$body$,
  $body$public Task add(String title) {
    Task task = new Task(nextId, title);
    nextId++;
    tasks.add(task);
    return task;
}$body$,
  $body$add は Todoアプリの基本中の基本です。オブジェクトを作る、IDを進める、リストに入れる、返す、の流れを何度も打って覚えます。$body$,
  $body$nextId++ を忘れると、複数のTaskが同じIDになってしまいます。tasks.add(task) を忘れると、作っただけで保存されません。$body$,
  13003,
  true
),
(
  '99999999-9999-9999-9999-000000000004',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'Todo一覧を返すfindAllメソッドを書く',
  1,
  'code',
  $body$TodoService に Todo 一覧を返す findAll メソッドを書いてください。
Read 処理の基本練習です。$body$,
  $body$メソッド名: findAll
引数: なし
戻り値: List<Task>

処理:
- tasks を返す$body$,
  $body$まずはシンプルに内部リストを返す形で大丈夫です。$body$,
  $body$public List<Task> findAll() {
    return tasks;
}$body$,
  $body$Todo一覧表示では、保存しているリストを返す処理が必要です。まずは最小構成で流れを覚えます。$body$,
  $body$戻り値を void にすると一覧を呼び出し側で使えません。List<Task> を返す形にします。$body$,
  13004,
  true
),
(
  '99999999-9999-9999-9999-000000000005',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'IDでTodoを探すfindByIdメソッドを書く',
  2,
  'code',
  $body$TodoService に ID で Task を探す findById メソッドを書いてください。
更新や削除の前に、対象データを見つける練習です。$body$,
  $body$メソッド名: findById
引数: int id
戻り値: Task

処理:
- tasks を順番に見る
- id が一致した Task を返す
- 見つからない場合は null を返す$body$,
  $body$まずは拡張for文で書くと、処理の流れが追いやすいです。$body$,
  $body$public Task findById(int id) {
    for (Task task : tasks) {
        if (task.getId() == id) {
            return task;
        }
    }
    return null;
}$body$,
  $body$ID検索は Update / Delete の前提になります。まずは見つかったら返す、なければ null という単純な形を手で打てるようにします。$body$,
  $body$ループの中で見つからなかった瞬間に return null すると、最初の1件しか確認できません。return null はループの後に書きます。$body$,
  13005,
  true
),
(
  '99999999-9999-9999-9999-000000000006',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'Todoを完了にするcompleteメソッドを書く',
  2,
  'code',
  $body$TodoService に Todo を完了にする complete メソッドを書いてください。
Update 処理の基本練習です。$body$,
  $body$メソッド名: complete
引数: int id
戻り値: boolean

処理:
1. findById(id) で Task を探す
2. 見つからなければ false を返す
3. 見つかれば complete() を呼ぶ
4. true を返す$body$,
  $body$対象が存在しない場合を先に処理すると書きやすいです。$body$,
  $body$public boolean complete(int id) {
    Task task = findById(id);
    if (task == null) {
        return false;
    }

    task.complete();
    return true;
}$body$,
  $body$完了処理は、検索して、状態を変えて、成功失敗を返す流れです。小さいですが実務の更新処理に近い形です。$body$,
  $body$task が null のまま task.complete() を呼ぶと NullPointerException になります。存在しないIDのケースを先に確認します。$body$,
  13006,
  true
),
(
  '99999999-9999-9999-9999-000000000007',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'Todoを削除するdeleteメソッドを書く',
  2,
  'code',
  $body$TodoService に Todo を削除する delete メソッドを書いてください。
Delete 処理の基本練習です。$body$,
  $body$メソッド名: delete
引数: int id
戻り値: boolean

処理:
- 指定した id の Task を tasks から削除する
- 削除できたら true
- 見つからなければ false$body$,
  $body$removeIf を使うと、条件に一致する要素を安全に削除できます。$body$,
  $body$public boolean delete(int id) {
    return tasks.removeIf(task -> task.getId() == id);
}$body$,
  $body$removeIf は条件に一致して削除できた場合 true を返します。Todoの削除処理を短く書ける便利な形です。$body$,
  $body$拡張for文で回しながら tasks.remove(task) を呼ぶと ConcurrentModificationException の原因になります。$body$,
  13007,
  true
),
(
  '99999999-9999-9999-9999-000000000008',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  '空タイトルを拒否する入力チェックを書く',
  2,
  'code',
  $body$TodoService の add メソッドに、空タイトルを拒否する入力チェックを追加してください。
バリデーションの基本練習です。$body$,
  $body$メソッド名: add
引数: String title
戻り値: Task

追加する条件:
- title が null なら IllegalArgumentException
- title が空文字なら IllegalArgumentException
- 前後の空白は trim する$body$,
  $body$title == null を先に確認します。null に対して trim() を呼ぶとエラーになります。$body$,
  $body$public Task add(String title) {
    if (title == null || title.trim().isEmpty()) {
        throw new IllegalArgumentException("title is required");
    }

    Task task = new Task(nextId, title.trim());
    nextId++;
    tasks.add(task);
    return task;
}$body$,
  $body$実務では入力値をそのまま保存せず、最低限のチェックを入れます。null と空文字を拒否するだけでも、アプリの壊れ方をかなり減らせます。$body$,
  $body$title.trim().isEmpty() を先に書くと、title が null のときに NullPointerException になります。null チェックを先に書きます。$body$,
  13008,
  true
),
(
  '99999999-9999-9999-9999-000000000009',
  '77777777-aaaa-aaaa-aaaa-000000000001',
  'TodoServiceを一通り完成させる',
  3,
  'code',
  $body$TodoService を一通り完成させてください。
これまでの add / findAll / findById / complete / delete をまとめて手で打つ総合ドリルです。$body$,
  $body$クラス名: TodoService
フィールド:
- private List<Task> tasks
- private int nextId

メソッド:
- Task add(String title)
- List<Task> findAll()
- Task findById(int id)
- boolean complete(int id)
- boolean delete(int id)

add では null と空文字を拒否してください。$body$,
  $body$まずフィールド、次に add、findAll、findById、complete、delete の順で書くと整理しやすいです。$body$,
  $body$import java.util.ArrayList;
import java.util.List;

public class TodoService {
    private List<Task> tasks = new ArrayList<>();
    private int nextId = 1;

    public Task add(String title) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("title is required");
        }

        Task task = new Task(nextId, title.trim());
        nextId++;
        tasks.add(task);
        return task;
    }

    public List<Task> findAll() {
        return tasks;
    }

    public Task findById(int id) {
        for (Task task : tasks) {
            if (task.getId() == id) {
                return task;
            }
        }
        return null;
    }

    public boolean complete(int id) {
        Task task = findById(id);
        if (task == null) {
            return false;
        }

        task.complete();
        return true;
    }

    public boolean delete(int id) {
        return tasks.removeIf(task -> task.getId() == id);
    }
}$body$,
  $body$TodoService の一連の流れを手で打てるようになると、Spring Boot の Service 層や CRUD API に進んだときも理解しやすくなります。$body$,
  $body$各メソッドを個別に覚えるだけでなく、add で追加したデータを findById / complete / delete が使う、というつながりを意識します。$body$,
  13009,
  true
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
  is_active = EXCLUDED.is_active,
  updated_at = timezone('utc'::text, now());

COMMIT;
