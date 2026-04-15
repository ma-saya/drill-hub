-- まず既存の問題データを削除してから再投入する
DELETE FROM study_records;
DELETE FROM problems;

-- =============================================
-- テーマ1: TODOアプリ基礎 (12問)
-- =============================================

-- Lv.1 (4問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'Taskクラスの作成', 1, 'normal',
'TODOアプリで使用するTaskクラスを作成してください。',
E'クラス名: Task\nフィールド: private int id, private String title, private boolean isCompleted\nコンストラクタ: 上記3つを引数に取り、各フィールドを初期化すること\nアクセス修飾子: フィールドはすべてprivate',
'thisキーワードを使って、引数とフィールドを区別しましょう。',
E'public class Task {\n    private int id;\n    private String title;\n    private boolean isCompleted;\n\n    public Task(int id, String title, boolean isCompleted) {\n        this.id = id;\n        this.title = title;\n        this.isCompleted = isCompleted;\n    }\n}',
'Javaのクラスの基本構造を理解するための問題です。フィールド宣言、コンストラクタ、thisの使い方を確認しましょう。',
'thisをつけ忘れて、引数とフィールドが区別できなくなるミス', 1);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'Taskクラスにgetter/setterを追加', 1, 'normal',
'先ほど作成したTaskクラスに、各フィールドのgetter/setterメソッドを追加してください。',
E'メソッド名:\n  getId() -> int\n  getTitle() -> String\n  isCompleted() -> boolean\n  setId(int id) -> void\n  setTitle(String title) -> void\n  setCompleted(boolean isCompleted) -> void',
'boolean型のgetterは慣例的にisXxx()という名前にします。',
E'public int getId() {\n    return id;\n}\n\npublic String getTitle() {\n    return title;\n}\n\npublic boolean isCompleted() {\n    return isCompleted;\n}\n\npublic void setId(int id) {\n    this.id = id;\n}\n\npublic void setTitle(String title) {\n    this.title = title;\n}\n\npublic void setCompleted(boolean isCompleted) {\n    this.isCompleted = isCompleted;\n}',
'getter/setterはJavaBeansの慣例に従います。boolean型だけgetではなくisを使うのがポイントです。',
'boolean型のgetterをgetIsCompleted()と書いてしまうミス', 2);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'TaskManagerクラスの作成', 1, 'normal',
'タスクを管理するためのTaskManagerクラスを作成し、タスクを追加するメソッドを実装してください。',
E'クラス名: TaskManager\nフィールド: private List<Task> tasks (ArrayListで初期化)\nメソッド: void addTask(Task task) - リストにタスクを追加する\nメソッド: List<Task> getAllTasks() - 全タスクのリストを返す',
'List<Task>はnew ArrayList<>()で初期化します。',
E'import java.util.ArrayList;\nimport java.util.List;\n\npublic class TaskManager {\n    private List<Task> tasks = new ArrayList<>();\n\n    public void addTask(Task task) {\n        tasks.add(task);\n    }\n\n    public List<Task> getAllTasks() {\n        return tasks;\n    }\n}',
'ArrayListを使ったListの初期化と基本操作を学びます。フィールドの型はList(インターフェース)、実体はArrayListにするのが定石です。',
'Listの初期化を忘れてNullPointerExceptionが発生するミス', 3);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクの件数を取得する', 1, 'normal',
'TaskManagerクラスに、現在登録されているタスクの件数を返すメソッドを追加してください。',
E'メソッド名: int getTaskCount()\n戻り値: tasksリストの要素数を返す',
'List#size()メソッドを使います。',
E'public int getTaskCount() {\n    return tasks.size();\n}',
'Listのsize()メソッドは要素数を返します。lengthではなくsize()なのがポイントです。',
'配列と混同してtasks.lengthと書いてしまうミス', 4);

-- Lv.2 (5問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'IDによるタスク検索', 2, 'normal',
'TaskManagerクラスに、IDを指定してタスクを検索するメソッドを追加してください。該当するタスクがない場合はnullを返してください。',
E'メソッド名: Task findById(int id)\n引数: int id - 検索対象のタスクID\n戻り値: 該当するTaskオブジェクト。見つからない場合はnull',
'拡張for文でリストを走査し、IDが一致するものを探しましょう。',
E'public Task findById(int id) {\n    for (Task task : tasks) {\n        if (task.getId() == id) {\n            return task;\n        }\n    }\n    return null;\n}',
'リストの走査と条件一致による検索の基本パターンです。見つかったらすぐreturnし、最後までなければnullを返します。',
'==とequals()の使い分けを間違えるミス(intはプリミティブ型なので==でOK)', 5);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクの完了処理', 2, 'normal',
'TaskManagerクラスに、指定IDのタスクを完了状態にするメソッドを追加してください。',
E'メソッド名: boolean completeTask(int id)\n処理: 指定IDのタスクのisCompletedをtrueに変更する\n戻り値: 該当タスクが見つかりtrueに変更できたらtrue、見つからなかったらfalse',
'findByIdメソッドを活用するか、直接ループで検索して更新しましょう。',
E'public boolean completeTask(int id) {\n    Task task = findById(id);\n    if (task != null) {\n        task.setCompleted(true);\n        return true;\n    }\n    return false;\n}',
'既存のfindByIdメソッドを再利用することで、コードの重複を避けられます。戻り値をbooleanにすることで、呼び出し側で成否を判定できます。',
'nullチェックをせずにtask.setCompleted()を呼んでNullPointerExceptionになるミス', 6);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクの削除', 2, 'normal',
'TaskManagerクラスに、指定IDのタスクをリストから削除するメソッドを追加してください。',
E'メソッド名: boolean removeTask(int id)\n処理: 指定IDのタスクをtasksリストから除去する\n戻り値: 削除できたらtrue、見つからなかったらfalse',
'List#removeIf()メソッドを使うか、イテレータを使って安全に削除しましょう。',
E'public boolean removeTask(int id) {\n    return tasks.removeIf(task -> task.getId() == id);\n}',
'removeIfはJava 8以降で使えるメソッドで、条件に合致する要素を安全に削除できます。拡張for文の中でremoveするとConcurrentModificationExceptionが発生します。',
'拡張for文の中でtasks.remove()を呼んでConcurrentModificationExceptionが出るミス', 7);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクのタイトル更新', 2, 'normal',
'TaskManagerクラスに、指定IDのタスクのタイトルを変更するメソッドを追加してください。',
E'メソッド名: boolean updateTitle(int id, String newTitle)\n処理: 指定IDのタスクのtitleをnewTitleに変更する\n戻り値: 更新できたらtrue、見つからなかったらfalse',
'findByIdで対象を探してからsetTitleで更新しましょう。',
E'public boolean updateTitle(int id, String newTitle) {\n    Task task = findById(id);\n    if (task != null) {\n        task.setTitle(newTitle);\n        return true;\n    }\n    return false;\n}',
'検索して更新するというCRUDのUpdate操作の基本パターンです。',
'nullチェックを忘れるミス', 8);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', '完了済みタスク一覧の取得', 2, 'normal',
'TaskManagerクラスに、完了済みのタスクだけを返すメソッドを追加してください。',
E'メソッド名: List<Task> getCompletedTasks()\n戻り値: isCompletedがtrueのタスクだけを含む新しいリスト',
'新しいArrayListを作り、条件に合うものだけをaddしましょう。もしくはStream APIも使えます。',
E'public List<Task> getCompletedTasks() {\n    List<Task> result = new ArrayList<>();\n    for (Task task : tasks) {\n        if (task.isCompleted()) {\n            result.add(task);\n        }\n    }\n    return result;\n}',
'条件に基づいてリストをフィルタリングする基本パターンです。元のリストを変更せず、新しいリストを返すのがポイントです。',
'元のtasksリストを直接操作してしまい副作用が発生するミス', 9);

-- Lv.3 (3問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクの一括完了処理', 3, 'normal',
'TaskManagerクラスに、指定した複数のIDのタスクを一括で完了にするメソッドを追加してください。',
E'メソッド名: int completeAll(List<Integer> ids)\n処理: 引数で渡されたIDリストに含まれるタスクをすべて完了にする\n戻り値: 実際に完了にできたタスクの件数(int)',
'各IDに対してcompleteTaskを呼び出し、trueが返った回数をカウントしましょう。',
E'public int completeAll(List<Integer> ids) {\n    int count = 0;\n    for (int id : ids) {\n        if (completeTask(id)) {\n            count++;\n        }\n    }\n    return count;\n}',
'既存メソッドを再利用して、より複雑な処理を組み立てるパターンです。戻り値で処理件数を返すことで、呼び出し側が結果を確認できます。',
'completeTaskの戻り値を無視して、常にids.size()を返してしまうミス', 10);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'タスクの状態トグル', 3, 'normal',
'指定IDのタスクの完了/未完了を切り替えるメソッドを実装してください。完了なら未完了に、未完了なら完了にします。',
E'メソッド名: boolean toggleTask(int id)\n処理: 指定IDのタスクのisCompletedを反転させる(true->false, false->true)\n戻り値: 切り替えできたらtrue、見つからなかったらfalse',
'現在の値を取得して、その反対の値をセットしましょう。',
E'public boolean toggleTask(int id) {\n    Task task = findById(id);\n    if (task != null) {\n        task.setCompleted(!task.isCompleted());\n        return true;\n    }\n    return false;\n}',
'!演算子で論理値を反転できます。現在の状態によって異なる処理を行う典型的なトグルパターンです。',
'if-elseで冗長に書いてしまうミス(trueならfalse、falseならtrue)', 11);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('11111111-1111-1111-1111-111111111111', 'TaskManagerの全機能統合', 3, 'normal',
'以下のCRUD操作をすべて備えたTaskManagerクラスを1から作成してください。',
E'クラス名: TaskManager\nフィールド: private List<Task> tasks\nメソッド一覧:\n  void addTask(Task task)\n  Task findById(int id)\n  List<Task> getAllTasks()\n  boolean completeTask(int id)\n  boolean removeTask(int id)\n  int getTaskCount()',
'これまでの問題を総合して、1つのクラスにまとめます。',
E'import java.util.ArrayList;\nimport java.util.List;\n\npublic class TaskManager {\n    private List<Task> tasks = new ArrayList<>();\n\n    public void addTask(Task task) {\n        tasks.add(task);\n    }\n\n    public Task findById(int id) {\n        for (Task task : tasks) {\n            if (task.getId() == id) {\n                return task;\n            }\n        }\n        return null;\n    }\n\n    public List<Task> getAllTasks() {\n        return tasks;\n    }\n\n    public boolean completeTask(int id) {\n        Task task = findById(id);\n        if (task != null) {\n            task.setCompleted(true);\n            return true;\n        }\n        return false;\n    }\n\n    public boolean removeTask(int id) {\n        return tasks.removeIf(t -> t.getId() == id);\n    }\n\n    public int getTaskCount() {\n        return tasks.size();\n    }\n}',
'CRUD操作を1つのクラスにまとめる総合問題です。実務でもこのようにデータの追加・検索・更新・削除を1つの管理クラスに集約するパターンがよく使われます。',
'各メソッドの役割が曖昧になり、1つのメソッドに処理を詰め込みすぎるミス', 12);

-- =============================================
-- テーマ2: ユーザー管理 (12問)
-- =============================================

-- Lv.1 (4問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'Userクラスの作成', 1, 'normal',
'ユーザー管理で使用するUserクラスを作成してください。',
E'クラス名: User\nフィールド:\n  private int id\n  private String name\n  private String email\nコンストラクタ: 上記3つを引数に取り初期化すること\ngetter/setter: 全フィールド分を作成すること',
'Taskクラスと同じ要領で作れます。',
E'public class User {\n    private int id;\n    private String name;\n    private String email;\n\n    public User(int id, String name, String email) {\n        this.id = id;\n        this.name = name;\n        this.email = email;\n    }\n\n    public int getId() { return id; }\n    public String getName() { return name; }\n    public String getEmail() { return email; }\n    public void setId(int id) { this.id = id; }\n    public void setName(String name) { this.name = name; }\n    public void setEmail(String email) { this.email = email; }\n}',
'基本的なDTO(データ転送オブジェクト)の作成パターンです。',
'コンストラクタ内でthisを付け忘れるミス', 1);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'メールアドレスのバリデーション', 1, 'normal',
'メールアドレスが正しい形式かどうかを判定するメソッドを作成してください。',
E'メソッド名: boolean isValidEmail(String email)\n判定条件:\n  1. nullまたは空文字の場合はfalse\n  2. @が含まれていない場合はfalse\n  3. 上記以外はtrue',
'nullチェックを最初に行い、NullPointerExceptionを防ぎましょう。',
E'public boolean isValidEmail(String email) {\n    if (email == null || email.isEmpty()) {\n        return false;\n    }\n    return email.contains("@");\n}',
'nullチェックを最初に行うことで安全に処理できます。これはバリデーションの基本パターンです。',
'nullチェックを忘れてNullPointerExceptionが発生するミス', 2);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'パスワードの長さチェック', 1, 'normal',
'パスワードが指定した最低文字数以上かどうかを判定するメソッドを作成してください。',
E'メソッド名: boolean isValidPassword(String password, int minLength)\n判定条件:\n  1. nullまたは空文字の場合はfalse\n  2. 文字数がminLength未満の場合はfalse\n  3. 上記以外はtrue',
'String#length()メソッドで文字数を取得できます。',
E'public boolean isValidPassword(String password, int minLength) {\n    if (password == null || password.isEmpty()) {\n        return false;\n    }\n    return password.length() >= minLength;\n}',
'引数で最低文字数を受け取ることで、再利用しやすいメソッドになります。',
'>= と > を間違えるミス(minLengthぴったりはOKかNGか)', 3);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'UserManagerクラスの作成', 1, 'normal',
'ユーザーを管理するためのUserManagerクラスを作成してください。',
E'クラス名: UserManager\nフィールド: private List<User> users (ArrayListで初期化)\nメソッド:\n  void addUser(User user) - リストにユーザーを追加\n  List<User> getAllUsers() - 全ユーザーを返す\n  int getUserCount() - ユーザー数を返す',
'TaskManagerと同じ構造で作れます。',
E'import java.util.ArrayList;\nimport java.util.List;\n\npublic class UserManager {\n    private List<User> users = new ArrayList<>();\n\n    public void addUser(User user) {\n        users.add(user);\n    }\n\n    public List<User> getAllUsers() {\n        return users;\n    }\n\n    public int getUserCount() {\n        return users.size();\n    }\n}',
'管理クラスの基本パターンです。TaskManagerと構造は同じですが、扱うデータが違います。',
'Listの初期化を忘れるミス', 4);

-- Lv.2 (5問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'メールアドレスの重複チェック', 2, 'normal',
'UserManagerクラスに、同じメールアドレスのユーザーが既に登録されていないかチェックするメソッドを追加してください。',
E'メソッド名: boolean isEmailDuplicated(String email)\n処理: usersリスト内に同じemailを持つユーザーが存在するかチェック\n戻り値: 存在すればtrue、なければfalse',
'for文でリストを走査してemailを比較します。Stringの比較にはequals()を使いましょう。',
E'public boolean isEmailDuplicated(String email) {\n    for (User user : users) {\n        if (user.getEmail().equals(email)) {\n            return true;\n        }\n    }\n    return false;\n}',
'Stringの比較は==ではなくequals()を使います。これはJavaで最も重要な注意点の1つです。',
'==でStringを比較してしまい、正しく判定できないミス', 5);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'ユーザー検索(名前)', 2, 'normal',
'UserManagerクラスに、名前でユーザーを検索するメソッドを追加してください。部分一致で検索します。',
E'メソッド名: List<User> findByName(String keyword)\n処理: nameにkeywordが含まれるユーザーをすべて返す\n戻り値: 該当するUserのリスト(0件の場合は空リスト)',
'String#contains()で部分一致を確認できます。',
E'public List<User> findByName(String keyword) {\n    List<User> result = new ArrayList<>();\n    for (User user : users) {\n        if (user.getName().contains(keyword)) {\n            result.add(user);\n        }\n    }\n    return result;\n}',
'部分一致検索のパターンです。nullではなく空のリストを返すことで、呼び出し側がnullチェック不要になります。',
'該当なしの場合にnullを返してしまうミス', 6);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'ユーザー情報の更新', 2, 'normal',
'UserManagerクラスに、指定IDのユーザー情報を更新するメソッドを追加してください。',
E'メソッド名: boolean updateUser(int id, String newName, String newEmail)\n処理: 指定IDのユーザーのnameとemailを更新する\n戻り値: 更新できたらtrue、見つからなかったらfalse',
'まずIDで対象ユーザーを探し、見つかったら情報を更新します。',
E'public boolean updateUser(int id, String newName, String newEmail) {\n    for (User user : users) {\n        if (user.getId() == id) {\n            user.setName(newName);\n            user.setEmail(newEmail);\n            return true;\n        }\n    }\n    return false;\n}',
'CRUDのUpdate処理です。検索と更新を1つのメソッドで行います。',
'見つからなかった場合の処理を書き忘れるミス', 7);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'ユーザーの削除', 2, 'normal',
'UserManagerクラスに、指定IDのユーザーを削除するメソッドを追加してください。',
E'メソッド名: boolean deleteUser(int id)\n処理: 指定IDのユーザーをusersリストから削除する\n戻り値: 削除できたらtrue、見つからなかったらfalse',
'removeIf()を使うと安全に削除できます。',
E'public boolean deleteUser(int id) {\n    return users.removeIf(user -> user.getId() == id);\n}',
'CRUDのDelete処理です。removeIfはラムダ式で条件を指定して削除できる便利なメソッドです。',
'拡張for文の中でremoveを呼んでConcurrentModificationExceptionが出るミス', 8);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'ログイン判定', 2, 'normal',
'emailとpasswordを受け取り、ログインが成功するかどうかを判定するメソッドを作成してください。',
E'メソッド名: boolean login(String email, String password)\n前提: Userクラスにprivate String passwordフィールドが追加されているものとする\n処理: emailとpasswordが一致するユーザーが存在すればtrue、なければfalse',
'emailとpasswordの両方が一致するユーザーを探しましょう。Stringの比較にはequals()を使います。',
E'public boolean login(String email, String password) {\n    for (User user : users) {\n        if (user.getEmail().equals(email) && user.getPassword().equals(password)) {\n            return true;\n        }\n    }\n    return false;\n}',
'複数条件を&&で結合した検索パターンです。実務ではパスワードはハッシュ化して比較しますが、ここでは基本パターンの学習を優先します。',
'||と&&を間違えるミス(どちらか一方だけ合っていてもログインできてしまう)', 9);

-- Lv.3 (3問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'ユーザー登録の総合バリデーション', 3, 'normal',
'ユーザー登録時に複数のバリデーションを行い、問題があればエラーメッセージのリストを返すメソッドを作成してください。',
E'メソッド名: List<String> validateUser(String name, String email, String password)\n判定条件:\n  1. nameがnullまたは空文字 -> "名前は必須です"\n  2. emailがnullまたは@を含まない -> "メールアドレスの形式が不正です"\n  3. passwordがnullまたは8文字未満 -> "パスワードは8文字以上必要です"\n  4. emailが既に登録済み -> "このメールアドレスは既に使用されています"\n戻り値: 全エラーメッセージのリスト(問題なければ空リスト)',
'エラーメッセージ用の空リストを作り、各チェックで引っかかったらaddしていきましょう。',
E'public List<String> validateUser(String name, String email, String password) {\n    List<String> errors = new ArrayList<>();\n\n    if (name == null || name.isEmpty()) {\n        errors.add("名前は必須です");\n    }\n    if (email == null || !email.contains("@")) {\n        errors.add("メールアドレスの形式が不正です");\n    }\n    if (password == null || password.length() < 8) {\n        errors.add("パスワードは8文字以上必要です");\n    }\n    if (email != null && isEmailDuplicated(email)) {\n        errors.add("このメールアドレスは既に使用されています");\n    }\n\n    return errors;\n}',
'複数のバリデーションを1つのメソッドにまとめるパターンです。エラーをリストに蓄積して一括で返すことで、UIで全エラーを表示できます。',
'最初のエラーでreturnしてしまい、後続のエラーが検出されないミス', 10);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', '安全なユーザー登録メソッド', 3, 'normal',
'バリデーションを行い、問題がなければユーザーを登録するメソッドを作成してください。問題があれば例外をスローします。',
E'メソッド名: void registerUser(String name, String email, String password)\n処理:\n  1. validateUserでバリデーションを実行\n  2. エラーがあればIllegalArgumentExceptionをスロー(メッセージにエラー内容を含める)\n  3. エラーがなければ新しいUserを作成してusersに追加\n  4. IDはgetUserCount() + 1で自動採番',
'validateUserの結果を使って条件分岐しましょう。',
E'public void registerUser(String name, String email, String password) {\n    List<String> errors = validateUser(name, email, password);\n\n    if (!errors.isEmpty()) {\n        throw new IllegalArgumentException(\n            String.join(", ", errors)\n        );\n    }\n\n    int newId = getUserCount() + 1;\n    User user = new User(newId, name, email);\n    addUser(user);\n}',
'バリデーションと登録処理を組み合わせた実践的なパターンです。例外を使ったエラーハンドリングの入門にもなっています。',
'例外をスローした後にもユーザーが追加されてしまうミス(throwの位置が悪い)', 11);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('22222222-2222-2222-2222-222222222222', 'UserManagerの全機能統合', 3, 'normal',
'UserManagerクラスの全機能を統合して実装してください。',
E'クラス名: UserManager\nフィールド: private List<User> users\nメソッド一覧:\n  void addUser(User user)\n  List<User> getAllUsers()\n  int getUserCount()\n  boolean isEmailDuplicated(String email)\n  List<User> findByName(String keyword)\n  boolean updateUser(int id, String newName, String newEmail)\n  boolean deleteUser(int id)',
'これまでの問題を総合して1つのクラスにまとめます。',
E'import java.util.ArrayList;\nimport java.util.List;\n\npublic class UserManager {\n    private List<User> users = new ArrayList<>();\n\n    public void addUser(User user) {\n        users.add(user);\n    }\n\n    public List<User> getAllUsers() {\n        return users;\n    }\n\n    public int getUserCount() {\n        return users.size();\n    }\n\n    public boolean isEmailDuplicated(String email) {\n        for (User user : users) {\n            if (user.getEmail().equals(email)) {\n                return true;\n            }\n        }\n        return false;\n    }\n\n    public List<User> findByName(String keyword) {\n        List<User> result = new ArrayList<>();\n        for (User user : users) {\n            if (user.getName().contains(keyword)) {\n                result.add(user);\n            }\n        }\n        return result;\n    }\n\n    public boolean updateUser(int id, String newName, String newEmail) {\n        for (User user : users) {\n            if (user.getId() == id) {\n                user.setName(newName);\n                user.setEmail(newEmail);\n                return true;\n            }\n        }\n        return false;\n    }\n\n    public boolean deleteUser(int id) {\n        return users.removeIf(user -> user.getId() == id);\n    }\n}',
'CRUD操作の全機能統合問題です。各メソッドの役割を明確に分離することが重要です。',
'メソッド間の依存関係を意識せず、同じ処理を何度も書いてしまうミス', 12);

-- =============================================
-- テーマ3: コレクション / Stream (12問)
-- =============================================

-- Lv.1 (4問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', '完了済みタスクの抽出(穴埋め)', 1, 'fill_blank',
E'以下のコードの空欄を埋めて、isCompletedがtrueのタスクだけを抽出してください。\n\nList<Task> completed = tasks.stream()\n    .filter(task -> __________)\n    .collect(Collectors.toList());',
E'空欄に入れる式: boolean値を返すラムダ式の本体部分\nStream APIのfilterを使用すること',
'filterの中にはtrue/falseを返す式を書きます。',
'task.isCompleted()',
'filterは条件がtrueの要素だけを残します。booleanを返すメソッドをそのまま書けばOKです。',
'task.isCompleted == true のように冗長に書いてしまうミス', 1);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'タスクタイトルの一覧取得(穴埋め)', 1, 'fill_blank',
E'以下のコードの空欄を埋めて、タスクからタイトルだけを取り出したリストを作成してください。\n\nList<String> titles = tasks.stream()\n    .map(task -> __________)\n    .collect(Collectors.toList());',
E'空欄に入れる式: Taskオブジェクトからタイトル(String)を取り出す式',
'mapは各要素を別の型に変換します。getterを呼びましょう。',
'task.getTitle()',
'mapは要素を変換する操作です。Task -> Stringに変換します。',
'filterと混同してしまうミス', 2);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'リストのソート', 1, 'normal',
'タスクのリストをIDの昇順でソートするメソッドを作成してください。',
E'メソッド名: List<Task> sortById(List<Task> tasks)\n処理: 引数で受け取ったタスクリストをIDの昇順でソートして返す\n注意: 元のリストは変更しないこと',
'Comparator.comparingInt()を使ってソートしましょう。',
E'public List<Task> sortById(List<Task> tasks) {\n    List<Task> sorted = new ArrayList<>(tasks);\n    sorted.sort(Comparator.comparingInt(Task::getId));\n    return sorted;\n}',
'元のリストを変更しないために、コピーしてからソートするのがポイントです。',
'元のリストを直接ソートしてしまい、副作用が発生するミス', 3);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'リスト内の要素検索', 1, 'normal',
'タスクリストの中にタイトルが完全一致するタスクが存在するかチェックするメソッドを作成してください。',
E'メソッド名: boolean existsByTitle(List<Task> tasks, String title)\n処理: リスト内にtitleが完全一致するタスクが1つでもあればtrue\n戻り値: 存在すればtrue、なければfalse',
'Stream#anyMatch()を使うと簡潔に書けます。',
E'public boolean existsByTitle(List<Task> tasks, String title) {\n    return tasks.stream()\n        .anyMatch(task -> task.getTitle().equals(title));\n}',
'anyMatchは条件に合う要素が1つでもあればtrueを返します。existsチェックの定番パターンです。',
'equalsの代わりに==を使ってしまうミス', 4);

-- Lv.2 (5問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', '条件付きフィルタリング', 2, 'normal',
'レベルと完了状態の両方で絞り込むメソッドを作成してください。',
E'メソッド名: List<Task> filterTasks(List<Task> tasks, int level, boolean completed)\n処理: 指定されたlevelかつisCompletedが指定値のタスクだけを返す\n前提: Taskクラスにprivate int levelフィールドとgetLevel()があるものとする',
'filterの中で&&を使って複数条件を組み合わせましょう。',
E'public List<Task> filterTasks(List<Task> tasks, int level, boolean completed) {\n    return tasks.stream()\n        .filter(task -> task.getLevel() == level && task.isCompleted() == completed)\n        .collect(Collectors.toList());\n}',
'複数条件のフィルタリングはStreamを使うと非常に読みやすく書けます。',
'&&と||を間違えるミス', 5);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'mapによる変換処理', 2, 'normal',
'ユーザーリストから、表示用の文字列リストに変換するメソッドを作成してください。',
E'メソッド名: List<String> toDisplayList(List<User> users)\n処理: 各Userを "名前 (メールアドレス)" の形式に変換\n例: "田中太郎 (tanaka@example.com)"',
'mapでStringに変換し、String.format()や文字列結合を使いましょう。',
E'public List<String> toDisplayList(List<User> users) {\n    return users.stream()\n        .map(user -> user.getName() + " (" + user.getEmail() + ")")\n        .collect(Collectors.toList());\n}',
'mapを使ってオブジェクトを文字列に変換するパターンです。表示用のデータ変換でよく使います。',
'mapとforEachを混同してしまうミス', 6);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', '集計処理(完了率の計算)', 2, 'normal',
'タスクリストの完了率(%)を計算するメソッドを作成してください。',
E'メソッド名: double getCompletionRate(List<Task> tasks)\n処理: (完了済みタスク数 / 全タスク数) * 100 を計算する\n注意: リストが空の場合は0.0を返すこと\n戻り値: 完了率(例: 75.0)',
'Streamのfilterとcountを組み合わせます。int同士の割り算は小数部が消えるので注意。',
E'public double getCompletionRate(List<Task> tasks) {\n    if (tasks.isEmpty()) {\n        return 0.0;\n    }\n    long completedCount = tasks.stream()\n        .filter(Task::isCompleted)\n        .count();\n    return (double) completedCount / tasks.size() * 100;\n}',
'int同士の割り算は結果もintになる(小数が切り捨てられる)ため、doubleにキャストする必要があります。',
'int同士の割り算で小数部が消えてしまうミス', 7);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'タイトルでソート', 2, 'normal',
'タスクリストをタイトルの辞書順(昇順)でソートするメソッドを作成してください。',
E'メソッド名: List<Task> sortByTitle(List<Task> tasks)\n処理: タスクリストをtitleの辞書順で昇順ソートして返す\n注意: 元のリストは変更しないこと',
'Comparator.comparing()とメソッド参照を使うと簡潔に書けます。',
E'public List<Task> sortByTitle(List<Task> tasks) {\n    return tasks.stream()\n        .sorted(Comparator.comparing(Task::getTitle))\n        .collect(Collectors.toList());\n}',
'StreamのsortedとComparator.comparingを組み合わせたソートのパターンです。Streamを使えば元のリストを変更せずに新しいソート済みリストが得られます。',
'sortedの引数にComparatorを渡し忘れるミス', 8);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'Optionalの活用', 2, 'normal',
'IDでタスクを検索し、Optionalで返すメソッドを作成してください。',
E'メソッド名: Optional<Task> findTaskById(List<Task> tasks, int id)\n処理: 指定IDのタスクをOptionalで返す\n戻り値: 見つかればOptional.of(task)、見つからなければOptional.empty()',
'Stream#findFirst()はOptionalを返します。',
E'public Optional<Task> findTaskById(List<Task> tasks, int id) {\n    return tasks.stream()\n        .filter(task -> task.getId() == id)\n        .findFirst();\n}',
'Optionalを使うことで、nullの代わりに「値がないかもしれない」ことを明示できます。Java 8以降の推奨パターンです。',
'Optionalを使わずにnullを返してしまうミス', 9);

-- Lv.3 (3問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'Streamの複合処理', 3, 'normal',
'タスクリストから、未完了のタスクだけを取り出し、レベルの高い順(降順)にソートし、上位3件のタイトルをリストで返すメソッドを作成してください。',
E'メソッド名: List<String> getTopUncompletedTitles(List<Task> tasks)\n処理手順:\n  1. isCompletedがfalseのタスクを抽出\n  2. levelの降順でソート\n  3. 上位3件を取得\n  4. タイトルだけを取り出してリストで返す',
'filter -> sorted -> limit -> map -> collect の順で書きます。',
E'public List<String> getTopUncompletedTitles(List<Task> tasks) {\n    return tasks.stream()\n        .filter(task -> !task.isCompleted())\n        .sorted(Comparator.comparingInt(Task::getLevel).reversed())\n        .limit(3)\n        .map(Task::getTitle)\n        .collect(Collectors.toList());\n}',
'Streamのメソッドチェーンで複数の操作を組み合わせる実践的なパターンです。処理の順序が重要です。',
'limitの位置を間違えて結果が変わるミス', 10);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', 'テーマ別の問題数集計', 3, 'normal',
'タスクリストをレベルごとにグループ化し、各レベルの件数を集計するメソッドを作成してください。',
E'メソッド名: Map<Integer, Long> countByLevel(List<Task> tasks)\n処理: タスクをlevelでグループ化し、各グループの件数をカウントする\n戻り値: Map<Integer, Long> (キー: level, 値: 件数)',
'Collectors.groupingByとCollectors.countingを組み合わせます。',
E'public Map<Integer, Long> countByLevel(List<Task> tasks) {\n    return tasks.stream()\n        .collect(Collectors.groupingBy(\n            Task::getLevel,\n            Collectors.counting()\n        ));\n}',
'groupingByで分類し、downstreamコレクターでcountingすることで、グループ別の集計ができます。',
'collectの使い方が複雑で構文を間違えるミス', 11);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('33333333-3333-3333-3333-333333333333', '複数条件ソートとフィルタの組合せ', 3, 'normal',
'タスクリストから未完了タスクを抽出し、レベル昇順 -> タイトル昇順の複合条件でソートして返すメソッドを作成してください。',
E'メソッド名: List<Task> getOrganizedTasks(List<Task> tasks)\n処理:\n  1. isCompletedがfalseのタスクを抽出\n  2. levelの昇順でソート(同一レベル内はtitleの昇順)\n  3. 結果をリストで返す',
'Comparator.comparingInt().thenComparing()で複合条件ソートができます。',
E'public List<Task> getOrganizedTasks(List<Task> tasks) {\n    return tasks.stream()\n        .filter(task -> !task.isCompleted())\n        .sorted(Comparator.comparingInt(Task::getLevel)\n            .thenComparing(Task::getTitle))\n        .collect(Collectors.toList());\n}',
'thenComparingを使うことで、第1ソートキーが同じ場合に第2ソートキーで並べ替えできます。実務で頻出のパターンです。',
'thenComparingの使い方を間違えるミス', 12);

-- =============================================
-- テーマ4: ファイル / JSON (12問)
-- =============================================

-- Lv.1 (4問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', '文字列のフォーマット', 1, 'normal',
'ユーザー情報を指定フォーマットの文字列に変換するメソッドを作成してください。',
E'メソッド名: String formatUser(User user)\n出力形式: "ID: 1 / 名前: 田中太郎 / メール: tanaka@example.com"\nString.format()を使用すること',
'String.format("ID: %d / 名前: %s / メール: %s", ...)の形式で書けます。',
E'public String formatUser(User user) {\n    return String.format("ID: %d / 名前: %s / メール: %s",\n        user.getId(), user.getName(), user.getEmail());\n}',
'String.formatは書式指定子(%d, %s等)を使ってフォーマットできます。printfと同じ書式です。',
'書式指定子の%dと%sを間違えるミス', 1);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'CSV形式への変換', 1, 'normal',
'タスクの情報をCSV形式の文字列に変換するメソッドを作成してください。',
E'メソッド名: String toCsv(Task task)\n出力形式: "1,買い物をする,false"\nカンマ区切りでid,title,isCompletedの順',
'文字列結合(+)やString.format()を使いましょう。',
E'public String toCsv(Task task) {\n    return task.getId() + "," + task.getTitle() + "," + task.isCompleted();\n}',
'CSVはComma Separated Valuesの略で、カンマ区切りのデータ形式です。データのエクスポートやインポートでよく使います。',
'区切り文字をカンマ以外にしてしまうミス', 2);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'CSV文字列からの復元', 1, 'normal',
'CSV形式の文字列からTaskオブジェクトを復元するメソッドを作成してください。',
E'メソッド名: Task fromCsv(String csv)\n入力形式: "1,買い物をする,false"\n処理: カンマで分割してTaskオブジェクトを生成して返す',
'String#split(",")で分割し、各要素を適切な型に変換しましょう。',
E'public Task fromCsv(String csv) {\n    String[] parts = csv.split(",");\n    int id = Integer.parseInt(parts[0]);\n    String title = parts[1];\n    boolean isCompleted = Boolean.parseBoolean(parts[2]);\n    return new Task(id, title, isCompleted);\n}',
'文字列の分割と型変換の基本パターンです。Integer.parseIntで文字列をintに変換できます。',
'splitの結果のインデックスを間違えるミス', 3);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', '日付のフォーマット', 1, 'normal',
'現在日時を指定フォーマットで表示するメソッドを作成してください。',
E'メソッド名: String formatCurrentDate()\n出力形式: "2024/01/15 14:30:00"\nDateTimeFormatterを使用すること',
'LocalDateTime.now()で現在日時を取得し、DateTimeFormatter.ofPattern()でフォーマットを指定します。',
E'import java.time.LocalDateTime;\nimport java.time.format.DateTimeFormatter;\n\npublic String formatCurrentDate() {\n    LocalDateTime now = LocalDateTime.now();\n    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");\n    return now.format(formatter);\n}',
'Java 8以降はjava.timeパッケージを使います。MM(月)とmm(分)の大文字小文字の違いに注意です。',
'MMとmmを間違えるミス(MMが月、mmが分)', 4);

-- Lv.2 (5問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'タスク一覧のCSV出力', 2, 'normal',
'タスクリスト全体をCSV形式の文字列(ヘッダー付き)に変換するメソッドを作成してください。',
E'メソッド名: String toAllCsv(List<Task> tasks)\n出力形式:\n  1行目(ヘッダー): "id,title,isCompleted"\n  2行目以降: 各タスクのCSV\n改行はSystem.lineSeparator()を使用すること',
'StringBuilderを使って1行ずつ追加していくと効率的です。',
E'public String toAllCsv(List<Task> tasks) {\n    StringBuilder sb = new StringBuilder();\n    sb.append("id,title,isCompleted");\n    for (Task task : tasks) {\n        sb.append(System.lineSeparator());\n        sb.append(task.getId()).append(",");\n        sb.append(task.getTitle()).append(",");\n        sb.append(task.isCompleted());\n    }\n    return sb.toString();\n}',
'StringBuilderは文字列結合を効率的に行うためのクラスです。大量の文字列結合には+演算子よりStringBuilderが推奨です。',
'文字列結合を+で繰り返してパフォーマンスが悪くなるミス', 5);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'CSV文字列からリストへの復元', 2, 'normal',
'複数行のCSV文字列(ヘッダー付き)からList<Task>を復元するメソッドを作成してください。',
E'メソッド名: List<Task> fromAllCsv(String csvText)\n入力: ヘッダー行 + データ行のCSV文字列\n処理: 1行目(ヘッダー)はスキップし、2行目以降をTaskに変換してリストで返す',
'改行で分割してから、1行目を飛ばして各行をfromCsvで変換しましょう。',
E'public List<Task> fromAllCsv(String csvText) {\n    List<Task> tasks = new ArrayList<>();\n    String[] lines = csvText.split(System.lineSeparator());\n    for (int i = 1; i < lines.length; i++) {\n        tasks.add(fromCsv(lines[i]));\n    }\n    return tasks;\n}',
'ヘッダー行をスキップするためにi=1から始めるのがポイントです。既存のfromCsvメソッドを再利用しています。',
'ヘッダー行もデータとして処理してしまうミス', 6);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'JSON風文字列の生成', 2, 'normal',
'TaskオブジェクトをJSON風の文字列に変換するメソッドを作成してください。',
E'メソッド名: String toJson(Task task)\n出力例: {"id": 1, "title": "買い物", "isCompleted": false}',
'String.format()やStringBuilderで組み立てましょう。文字列値はダブルクォートで囲みます。',
E'public String toJson(Task task) {\n    return String.format(\n        "{\"id\": %d, \"title\": \"%s\", \"isCompleted\": %b}",\n        task.getId(), task.getTitle(), task.isCompleted()\n    );\n}',
'JSONはデータ交換のための標準的なフォーマットです。キーと文字列値はダブルクォートで囲みます。',
'ダブルクォートのエスケープを忘れるミス', 7);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'データの整形出力', 2, 'normal',
'タスク一覧を見やすい表形式のテキストに整形するメソッドを作成してください。',
E'メソッド名: String formatTable(List<Task> tasks)\n出力形式(各行):\n  "[完了] ID:1  買い物をする"\n  "[未了] ID:2  掃除をする"\nisCompletedがtrueなら[完了]、falseなら[未了]を先頭に付ける',
'三項演算子(条件 ? 値1 : 値2)を使うと条件による文字列切り替えが簡潔に書けます。',
E'public String formatTable(List<Task> tasks) {\n    StringBuilder sb = new StringBuilder();\n    for (Task task : tasks) {\n        String status = task.isCompleted() ? "[完了]" : "[未了]";\n        sb.append(String.format("%s ID:%d  %s", status, task.getId(), task.getTitle()));\n        sb.append(System.lineSeparator());\n    }\n    return sb.toString();\n}',
'三項演算子とString.formatを組み合わせた実践的な整形出力パターンです。',
'改行の入れ忘れで全部1行に表示されてしまうミス', 8);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'ファイルパスの組み立て', 2, 'normal',
'日付を含むファイル名を生成するメソッドを作成してください。',
E'メソッド名: String generateFileName(String prefix)\n出力例: "backup_20240115.csv"\nprefixが"backup"の場合、prefix + "_" + 今日の日付(yyyyMMdd) + ".csv" を返す',
'LocalDate.now()とDateTimeFormatterで日付をフォーマットしましょう。',
E'import java.time.LocalDate;\nimport java.time.format.DateTimeFormatter;\n\npublic String generateFileName(String prefix) {\n    String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));\n    return prefix + "_" + date + ".csv";\n}',
'日付を含むファイル名の動的生成パターンです。ログやバックアップのファイル名でよく使います。',
'日付フォーマットのパターン文字列を間違えるミス', 9);

-- Lv.3 (3問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'CSVファイルの入出力シミュレーション', 3, 'normal',
'タスクリストをCSV文字列に変換し、それを再度リストに復元する一連の処理を実装してください。',
E'クラス名: TaskFileManager\nメソッド:\n  String exportToCsv(List<Task> tasks) - タスクリストをCSV文字列に変換(ヘッダー付き)\n  List<Task> importFromCsv(String csv) - CSV文字列からタスクリストを復元\n動作確認: export -> import で元と同じデータが得られること',
'toAllCsvとfromAllCsvを組み合わせましょう。',
E'public class TaskFileManager {\n\n    public String exportToCsv(List<Task> tasks) {\n        StringBuilder sb = new StringBuilder();\n        sb.append("id,title,isCompleted");\n        for (Task task : tasks) {\n            sb.append(System.lineSeparator());\n            sb.append(task.getId()).append(",");\n            sb.append(task.getTitle()).append(",");\n            sb.append(task.isCompleted());\n        }\n        return sb.toString();\n    }\n\n    public List<Task> importFromCsv(String csv) {\n        List<Task> tasks = new ArrayList<>();\n        String[] lines = csv.split(System.lineSeparator());\n        for (int i = 1; i < lines.length; i++) {\n            String[] parts = lines[i].split(",");\n            tasks.add(new Task(\n                Integer.parseInt(parts[0]),\n                parts[1],\n                Boolean.parseBoolean(parts[2])\n            ));\n        }\n        return tasks;\n    }\n}',
'データのエクスポート/インポートの基本パターンです。シリアライズ(オブジェクト->文字列)とデシリアライズ(文字列->オブジェクト)を1つのクラスにまとめています。',
'エクスポートとインポートでフォーマットが不一致になるミス', 10);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'JSON配列の生成', 3, 'normal',
'タスクリスト全体をJSON配列形式の文字列に変換するメソッドを作成してください。',
E'メソッド名: String toJsonArray(List<Task> tasks)\n出力例:\n[\n  {"id": 1, "title": "買い物", "isCompleted": false},\n  {"id": 2, "title": "掃除", "isCompleted": true}\n]\n各要素の間にカンマを入れること(最後の要素の後にはカンマなし)',
'StringJoinerを使うとカンマ区切りが楽に書けます。',
E'import java.util.StringJoiner;\n\npublic String toJsonArray(List<Task> tasks) {\n    StringJoiner joiner = new StringJoiner(",\\n  ", "[\\n  ", "\\n]");\n    for (Task task : tasks) {\n        String json = String.format(\n            "{\"id\": %d, \"title\": \"%s\", \"isCompleted\": %b}",\n            task.getId(), task.getTitle(), task.isCompleted()\n        );\n        joiner.add(json);\n    }\n    return joiner.toString();\n}',
'StringJoinerは区切り文字、接頭辞、接尾辞を指定できる便利なクラスです。最後の要素の後に余分なカンマが入らないのが利点です。',
'最後の要素の後にもカンマを入れてしまうミス', 11);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('44444444-4444-4444-4444-444444444444', 'レポート生成', 3, 'normal',
'タスクリストの統計情報を含むレポート文字列を生成するメソッドを作成してください。',
E'メソッド名: String generateReport(List<Task> tasks)\n出力形式:\n  "=== タスクレポート ==="\n  "全タスク数: 10"\n  "完了済み: 6"\n  "未完了: 4"\n  "完了率: 60.0%"\n  "==================="',
'StringBuilderで1行ずつ組み立てていきましょう。',
E'public String generateReport(List<Task> tasks) {\n    int total = tasks.size();\n    long completed = tasks.stream().filter(Task::isCompleted).count();\n    long uncompleted = total - completed;\n    double rate = total == 0 ? 0.0 : (double) completed / total * 100;\n\n    StringBuilder sb = new StringBuilder();\n    sb.append("=== タスクレポート ===").append(System.lineSeparator());\n    sb.append("全タスク数: ").append(total).append(System.lineSeparator());\n    sb.append("完了済み: ").append(completed).append(System.lineSeparator());\n    sb.append("未完了: ").append(uncompleted).append(System.lineSeparator());\n    sb.append(String.format("完了率: %.1f%%", rate)).append(System.lineSeparator());\n    sb.append("===================");\n    return sb.toString();\n}',
'Streamによる集計とStringBuilderによる文字列組み立てを組み合わせた総合問題です。',
'0除算チェックを忘れるミス', 12);

-- =============================================
-- テーマ5: 疑似業務設計 (12問)
-- =============================================

-- Lv.1 (4問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'TaskDTOクラスの作成', 1, 'normal',
'APIレスポンス用のTaskDTOクラスを作成してください。エンティティとは異なり、表示に必要な情報だけを持ちます。',
E'クラス名: TaskDTO\nフィールド:\n  private int id\n  private String title\n  private String status ("完了" or "未完了")\nコンストラクタ: 上記3つを引数に取ること\ngetter: 全フィールド分(setterは不要)',
'DTOは画面表示用のデータを運ぶクラスです。setterを作らず不変にするのが一般的です。',
E'public class TaskDTO {\n    private int id;\n    private String title;\n    private String status;\n\n    public TaskDTO(int id, String title, String status) {\n        this.id = id;\n        this.title = title;\n        this.status = status;\n    }\n\n    public int getId() { return id; }\n    public String getTitle() { return title; }\n    public String getStatus() { return status; }\n}',
'DTO(Data Transfer Object)はレイヤー間でデータを受け渡すためのクラスです。setterを持たせないことで、一度作成されたら変更されないことを保証します。',
'setterを不要に作ってしまうミス(DTOは原則イミュータブル)', 1);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'TaskRepositoryインターフェースの定義', 1, 'normal',
'データアクセス層のインターフェースを定義してください。',
E'インターフェース名: TaskRepository\nメソッド定義:\n  List<Task> findAll()\n  Optional<Task> findById(int id)\n  void save(Task task)\n  void deleteById(int id)',
'インターフェースにはメソッドの型だけを定義し、実装は書きません。',
E'import java.util.List;\nimport java.util.Optional;\n\npublic interface TaskRepository {\n    List<Task> findAll();\n    Optional<Task> findById(int id);\n    void save(Task task);\n    void deleteById(int id);\n}',
'インターフェースはメソッドの「契約」を定義するものです。実装クラスはこのインターフェースに従って具体的な処理を書きます。',
'インターフェースに実装(メソッドのbody)を書いてしまうミス', 2);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'カスタム例外クラスの作成', 1, 'normal',
'タスクが見つからない場合にスローするカスタム例外クラスを作成してください。',
E'クラス名: TaskNotFoundException\n継承: RuntimeExceptionを継承すること\nコンストラクタ: String messageを受け取り、親クラスに渡すこと',
'super(message)で親クラスのコンストラクタを呼び出します。',
E'public class TaskNotFoundException extends RuntimeException {\n    public TaskNotFoundException(String message) {\n        super(message);\n    }\n}',
'カスタム例外を作ることで、一般的なExceptionとは区別したエラーハンドリングができます。RuntimeExceptionを継承するとチェック例外にならず使いやすくなります。',
'Exceptionを継承してチェック例外にしてしまい、try-catchを強制されるミス', 3);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'エンティティからDTOへの変換', 1, 'normal',
'TaskオブジェクトをTaskDTOに変換するメソッドを作成してください。',
E'メソッド名: TaskDTO toDTO(Task task)\n処理: TaskのisCompletedがtrueなら"完了"、falseなら"未完了"をstatusにセットしてTaskDTOを生成する',
'三項演算子を使って変換しましょう。',
E'public TaskDTO toDTO(Task task) {\n    String status = task.isCompleted() ? "完了" : "未完了";\n    return new TaskDTO(task.getId(), task.getTitle(), status);\n}',
'エンティティ(内部表現)からDTO(外部表現)への変換は実務で頻出するパターンです。booleanを人間が読める文字列に変換しています。',
'boolean値をそのまま文字列にしてしまうミス("true"/"false")', 4);

-- Lv.2 (5問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'InMemoryTaskRepositoryの実装', 2, 'normal',
'TaskRepositoryインターフェースをメモリ上のリストで実装してください。',
E'クラス名: InMemoryTaskRepository\n実装: TaskRepositoryインターフェースをimplementsする\n内部データ: private List<Task> tasks = new ArrayList<>()\n各メソッドの実装:\n  findAll() -> tasksをそのまま返す\n  findById(int id) -> Streamで検索しOptionalで返す\n  save(Task task) -> tasksに追加\n  deleteById(int id) -> removeIfで削除',
'implements TaskRepositoryを付けて、4つのメソッドを実装しましょう。',
E'import java.util.*;\nimport java.util.stream.*;\n\npublic class InMemoryTaskRepository implements TaskRepository {\n    private List<Task> tasks = new ArrayList<>();\n\n    @Override\n    public List<Task> findAll() {\n        return tasks;\n    }\n\n    @Override\n    public Optional<Task> findById(int id) {\n        return tasks.stream()\n            .filter(task -> task.getId() == id)\n            .findFirst();\n    }\n\n    @Override\n    public void save(Task task) {\n        tasks.add(task);\n    }\n\n    @Override\n    public void deleteById(int id) {\n        tasks.removeIf(task -> task.getId() == id);\n    }\n}',
'インターフェースの実装クラスを作る実践パターンです。@Overrideアノテーションを付けることで、インターフェースのメソッドを正しく実装していることを明示します。',
'@Overrideを付け忘れてメソッド名を打ち間違えても気づかないミス', 5);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'TaskServiceクラスの基本実装', 2, 'normal',
'ビジネスロジックを担当するTaskServiceクラスを作成してください。',
E'クラス名: TaskService\nフィールド: private TaskRepository repository\nコンストラクタ: TaskRepositoryを引数に取り、フィールドに代入\nメソッド:\n  List<TaskDTO> getAllTasks() - 全タスクを取得しDTOリストに変換して返す\n  TaskDTO getTask(int id) - IDで検索しDTOに変換して返す。見つからなければTaskNotFoundExceptionをスロー',
'repositoryを通じてデータにアクセスし、結果をDTOに変換しましょう。',
E'import java.util.List;\nimport java.util.stream.Collectors;\n\npublic class TaskService {\n    private TaskRepository repository;\n\n    public TaskService(TaskRepository repository) {\n        this.repository = repository;\n    }\n\n    public List<TaskDTO> getAllTasks() {\n        return repository.findAll().stream()\n            .map(task -> toDTO(task))\n            .collect(Collectors.toList());\n    }\n\n    public TaskDTO getTask(int id) {\n        Task task = repository.findById(id)\n            .orElseThrow(() -> new TaskNotFoundException("Task not found: " + id));\n        return toDTO(task);\n    }\n\n    private TaskDTO toDTO(Task task) {\n        String status = task.isCompleted() ? "完了" : "未完了";\n        return new TaskDTO(task.getId(), task.getTitle(), status);\n    }\n}',
'Service層はRepository(データアクセス)とDTO(表示)の間を橋渡しする役割です。コンストラクタでRepositoryを受け取る設計を依存性注入(DI)と呼びます。',
'Serviceの中で直接Listを操作してしまい、Repositoryを経由しないミス', 6);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'バリデーション処理の分離', 2, 'normal',
'タスク作成時のバリデーションを専用クラスに分離してください。',
E'クラス名: TaskValidator\nメソッド: List<String> validate(String title)\n判定条件:\n  1. titleがnullまたは空文字 -> "タイトルは必須です"\n  2. titleが50文字を超える -> "タイトルは50文字以内にしてください"\n戻り値: エラーメッセージのリスト(問題なければ空リスト)',
'バリデーション専用クラスを作ることで、Serviceクラスの責務を減らせます。',
E'import java.util.ArrayList;\nimport java.util.List;\n\npublic class TaskValidator {\n    public List<String> validate(String title) {\n        List<String> errors = new ArrayList<>();\n\n        if (title == null || title.isEmpty()) {\n            errors.add("タイトルは必須です");\n        } else if (title.length() > 50) {\n            errors.add("タイトルは50文字以内にしてください");\n        }\n\n        return errors;\n    }\n}',
'バリデーションを専用クラスに分離することで、テストしやすく保守しやすいコードになります。これが「単一責任の原則」の実践例です。',
'バリデーションをServiceやControllerに直接書いてしまい、責務が肥大化するミス', 7);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'TaskServiceにタスク追加機能を実装', 2, 'normal',
'TaskServiceにバリデーション付きのタスク追加メソッドを実装してください。',
E'メソッド名: void addTask(String title)\n処理:\n  1. TaskValidatorでバリデーション実行\n  2. エラーがあればIllegalArgumentExceptionをスロー\n  3. 問題なければ新しいTaskを作成してrepositoryに保存\nフィールドに追加: private TaskValidator validator = new TaskValidator()\nIDの採番: repository.findAll().size() + 1',
'バリデーション -> 例外 or 保存 の流れです。',
E'public void addTask(String title) {\n    TaskValidator validator = new TaskValidator();\n    List<String> errors = validator.validate(title);\n\n    if (!errors.isEmpty()) {\n        throw new IllegalArgumentException(\n            String.join(", ", errors)\n        );\n    }\n\n    int newId = repository.findAll().size() + 1;\n    Task task = new Task(newId, title, false);\n    repository.save(task);\n}',
'バリデーション -> ビジネスロジック -> データ保存 という業務アプリケーションの典型的な処理フローです。',
'バリデーション結果を確認せずに保存してしまうミス', 8);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'TaskServiceにタスク完了機能を実装', 2, 'normal',
'TaskServiceにタスクを完了にするメソッドを実装してください。',
E'メソッド名: TaskDTO completeTask(int id)\n処理:\n  1. repositoryからIDで検索\n  2. 見つからなければTaskNotFoundExceptionをスロー\n  3. 見つかればisCompletedをtrueにする\n  4. DTOに変換して返す',
'Optional#orElseThrowで「見つからなければ例外」のパターンを使いましょう。',
E'public TaskDTO completeTask(int id) {\n    Task task = repository.findById(id)\n        .orElseThrow(() -> new TaskNotFoundException("Task not found: " + id));\n\n    task.setCompleted(true);\n    return toDTO(task);\n}',
'検索 -> 存在チェック -> 更新 -> 変換 という実務で頻出する処理フローです。',
'例外をスローせずにnullを返してしまうミス', 9);

-- Lv.3 (3問)
INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', '3層アーキテクチャの全体実装', 3, 'normal',
'Repository, Service, DTOの3層構造でタスク管理システムを実装してください。全クラスを1つのコードブロックにまとめて書いてください。',
E'必要なクラス・インターフェース:\n  1. TaskDTO (id, title, status)\n  2. TaskRepository (インターフェース: findAll, findById, save, deleteById)\n  3. InMemoryTaskRepository (TaskRepositoryの実装)\n  4. TaskService (getAllTasks, getTask, addTask, completeTask)\n  5. TaskNotFoundException (カスタム例外)',
'これまでの問題を全部組み合わせた総合問題です。',
E'// TaskDTO\npublic class TaskDTO {\n    private int id;\n    private String title;\n    private String status;\n    public TaskDTO(int id, String title, String status) {\n        this.id = id; this.title = title; this.status = status;\n    }\n    public int getId() { return id; }\n    public String getTitle() { return title; }\n    public String getStatus() { return status; }\n}\n\n// TaskRepository\npublic interface TaskRepository {\n    List<Task> findAll();\n    Optional<Task> findById(int id);\n    void save(Task task);\n    void deleteById(int id);\n}\n\n// InMemoryTaskRepository\npublic class InMemoryTaskRepository implements TaskRepository {\n    private List<Task> tasks = new ArrayList<>();\n    public List<Task> findAll() { return tasks; }\n    public Optional<Task> findById(int id) {\n        return tasks.stream().filter(t -> t.getId() == id).findFirst();\n    }\n    public void save(Task task) { tasks.add(task); }\n    public void deleteById(int id) { tasks.removeIf(t -> t.getId() == id); }\n}\n\n// TaskService\npublic class TaskService {\n    private TaskRepository repository;\n    public TaskService(TaskRepository repository) { this.repository = repository; }\n    public List<TaskDTO> getAllTasks() {\n        return repository.findAll().stream().map(this::toDTO).collect(Collectors.toList());\n    }\n    public TaskDTO getTask(int id) {\n        return repository.findById(id)\n            .map(this::toDTO)\n            .orElseThrow(() -> new TaskNotFoundException("Not found: " + id));\n    }\n    public void addTask(String title) {\n        int id = repository.findAll().size() + 1;\n        repository.save(new Task(id, title, false));\n    }\n    private TaskDTO toDTO(Task t) {\n        return new TaskDTO(t.getId(), t.getTitle(), t.isCompleted() ? "完了" : "未完了");\n    }\n}',
'Repository(データアクセス), Service(ビジネスロジック), DTO(データ転送)の3層に分離するアーキテクチャです。Spring Bootなどのフレームワークでも同じ構造が使われます。',
'レイヤー間の依存方向を間違えるミス(ServiceがRepositoryに依存するのが正しい)', 10);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', 'カスタム例外による詳細エラーハンドリング', 3, 'normal',
'複数のカスタム例外を使い分けて、エラーの種類に応じた処理を行うメソッドを実装してください。',
E'例外クラス:\n  TaskNotFoundException extends RuntimeException\n  InvalidTaskException extends RuntimeException\nメソッド名: TaskDTO createAndGetTask(String title)\n処理:\n  1. titleがnullまたは空文字ならInvalidTaskExceptionをスロー\n  2. タスクを作成してrepositoryに保存\n  3. 保存後にfindByIdで取得して返す\n  4. 取得できなければTaskNotFoundExceptionをスロー',
'目的別に例外クラスを使い分けることで、呼び出し側でcatchブロックを分けられます。',
E'public class InvalidTaskException extends RuntimeException {\n    public InvalidTaskException(String message) {\n        super(message);\n    }\n}\n\npublic TaskDTO createAndGetTask(String title) {\n    if (title == null || title.isEmpty()) {\n        throw new InvalidTaskException("タイトルが空です");\n    }\n\n    int newId = repository.findAll().size() + 1;\n    Task task = new Task(newId, title, false);\n    repository.save(task);\n\n    return repository.findById(newId)\n        .map(this::toDTO)\n        .orElseThrow(() -> new TaskNotFoundException("保存したタスクが見つかりません: " + newId));\n}',
'例外の種類によってエラーの原因を明確に伝えられます。「入力値が不正」と「データが見つからない」を区別することで、呼び出し側が適切に対応できます。',
'すべてのエラーをRuntimeExceptionで済ませてしまい、エラーの区別ができないミス', 11);

INSERT INTO problems (theme_id, title, level, type, statement, requirements, hint, answer, explanation, common_mistakes, display_order) VALUES
('55555555-5555-5555-5555-555555555555', '業務フロー全体の実装', 3, 'normal',
'タスクの作成から完了までの業務フローを1つのメソッドとして実装してください。各ステップでログ出力(System.out.println)を行います。',
E'メソッド名: void executeWorkflow(TaskService service)\n処理手順:\n  1. タスクを3つ追加("設計書の作成", "コードレビュー", "テスト実行")\n  2. 全タスク一覧を表示\n  3. ID:1のタスクを完了にする\n  4. 完了後の全タスク一覧を再表示\n各ステップで適切なログを出力すること\n例外はtry-catchで処理すること',
'各操作の前後にSystem.out.printlnでログを出力しましょう。',
E'public void executeWorkflow(TaskService service) {\n    try {\n        System.out.println("=== タスク登録 ===");\n        service.addTask("設計書の作成");\n        service.addTask("コードレビュー");\n        service.addTask("テスト実行");\n        System.out.println("3件のタスクを登録しました");\n\n        System.out.println("\\n=== タスク一覧 ===");\n        for (TaskDTO dto : service.getAllTasks()) {\n            System.out.println(dto.getId() + ": " + dto.getTitle() + " [" + dto.getStatus() + "]");\n        }\n\n        System.out.println("\\n=== タスク完了処理 ===");\n        TaskDTO completed = service.completeTask(1);\n        System.out.println(completed.getTitle() + " を完了にしました");\n\n        System.out.println("\\n=== 更新後タスク一覧 ===");\n        for (TaskDTO dto : service.getAllTasks()) {\n            System.out.println(dto.getId() + ": " + dto.getTitle() + " [" + dto.getStatus() + "]");\n        }\n    } catch (TaskNotFoundException e) {\n        System.out.println("エラー: " + e.getMessage());\n    } catch (Exception e) {\n        System.out.println("予期しないエラー: " + e.getMessage());\n    }\n}',
'実務では一連の業務フローをメソッドにまとめ、例外処理で想定外の事態に備えます。ログ出力によって処理の流れが追いやすくなります。',
'例外処理を書かず、想定外のエラーでプログラムが落ちてしまうミス', 12);
