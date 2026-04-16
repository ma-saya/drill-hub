type ProblemSeed = {
  id: string
  theme_id: string
  themeName: string
  title: string
  level: number
  type: string
  statement: string
  requirements?: string
  hint: string
  answer: string
  explanation: string
  common_mistakes: string
}

const SQL_SHARED_CONTEXT = `テーブル定義:
departments(id INTEGER, name VARCHAR(50))
employees(id INTEGER, name VARCHAR(50), department_id INTEGER, salary INTEGER, status VARCHAR(20))
customers(id INTEGER, name VARCHAR(50), region VARCHAR(20))
orders(id INTEGER, customer_id INTEGER, total INTEGER, status VARCHAR(20), ordered_at DATE)

サンプルデータ:
departments: (1, Sales), (2, Engineering), (3, HR)
employees: (1, Aoki, 1, 400000, active), (2, Sato, 2, 550000, active), (3, Suzuki, 2, 620000, leave), (4, Tanaka, 1, 450000, active), (5, Ito, 3, 380000, active), (6, Kato, 2, 700000, active)
customers: (1, ACME, East), (2, Bright, West), (3, Central, East), (4, Delta, South)
orders: (1, 1, 120000, paid, 2024-01-10), (2, 1, 80000, pending, 2024-02-03), (3, 2, 150000, paid, 2024-01-25), (4, 3, 50000, canceled, 2024-03-01), (5, 4, 200000, paid, 2024-02-14), (6, 2, 90000, paid, 2024-03-20)`

const sqlProblem = (
  id: string,
  theme_id: string,
  themeName: string,
  title: string,
  level: number,
  task: string,
  result: string,
  answer: string,
  hint: string,
  explanation: string,
  common_mistakes: string
): ProblemSeed => ({
  id,
  theme_id,
  themeName,
  title,
  level,
  type: 'code',
  statement: `${SQL_SHARED_CONTEXT}\n\n課題: ${task}\n期待する結果: ${result}`,
  requirements: 'SQL を 1 文だけ書いてください。',
  hint,
  answer,
  explanation,
  common_mistakes,
})

export const SQL_PROBLEM_SEEDS: ProblemSeed[] = [
  sqlProblem('local-sql-001', 'local-sql-select', 'SQL: SELECT', '社員名だけを取得する SELECT 文を書く', 1, 'employees テーブルから社員名だけを id 順に取得してください。', 'Aoki, Sato, Suzuki, Tanaka, Ito, Kato の順に name 列が返ること。', 'SELECT name FROM employees ORDER BY id;', '必要な列は name だけです。', '取得したい列だけを SELECT に書くのが基本です。', 'SELECT * にすると不要な列まで返ります。'),
  sqlProblem('local-sql-002', 'local-sql-select', 'SQL: SELECT', '部署名を取得する SELECT 文を書く', 1, 'departments テーブルから部署名だけを id 順に取得してください。', 'Sales, Engineering, HR の順に name 列が返ること。', 'SELECT name FROM departments ORDER BY id;', 'departments テーブルの name 列を使います。', '単一テーブルから 1 列を取得する基本問題です。', 'テーブル名を employees にすると別データを見に行ってしまいます。'),
  sqlProblem('local-sql-003', 'local-sql-select', 'SQL: SELECT', '社員名と給与を同時に取得する', 1, 'employees テーブルから name と salary を id 順に取得してください。', '各社員の name と salary の 2 列が返ること。', 'SELECT name, salary FROM employees ORDER BY id;', '2 列ほしいので SELECT の後に列をカンマ区切りで並べます。', '複数列を返したいときは SELECT に列を並べます。', 'salary だけ、または name だけにすると要件を満たしません。'),
  sqlProblem('local-sql-004', 'local-sql-select', 'SQL: SELECT', '注文番号と金額を取得する', 1, 'orders テーブルから id と total を id 順に取得してください。', '各注文の id と total の 2 列が返ること。', 'SELECT id, total FROM orders ORDER BY id;', 'orders テーブルから必要な 2 列だけを選びます。', '注文番号と金額だけを取りたいときの基本 SELECT です。', 'customer_id を取ると金額が分からず要件不足です。'),
  sqlProblem('local-sql-005', 'local-sql-select', 'SQL: SELECT', '顧客名と地域を取得する', 1, 'customers テーブルから name と region を id 順に取得してください。', '各顧客の name と region が返ること。', 'SELECT name, region FROM customers ORDER BY id;', 'customers テーブルの 2 列です。', '顧客一覧の基本取得です。', 'orders テーブルには region がないので顧客テーブルを見る必要があります。'),
  sqlProblem('local-sql-006', 'local-sql-select', 'SQL: SELECT', '社員名と在籍状態を取得する', 1, 'employees テーブルから name と status を id 順に取得してください。', '各社員の name と status が返ること。', 'SELECT name, status FROM employees ORDER BY id;', 'status 列は employees テーブルにあります。', '一覧用に複数列を選ぶ基本パターンです。', 'department_id を取っても在籍状態にはなりません。'),
  sqlProblem('local-sql-007', 'local-sql-select', 'SQL: SELECT', '部署テーブルの全列を取得する', 1, 'departments テーブルの全列を id 順に取得してください。', 'id と name の両方が返ること。', 'SELECT * FROM departments ORDER BY id;', '今回は全列取得なのでワイルドカードを使えます。', '全列取得が許される問題では SELECT * も選択肢になります。', 'employees を見ると別テーブルになるので条件違いです。'),
  sqlProblem('local-sql-008', 'local-sql-select', 'SQL: SELECT', '注文の顧客IDと注文日を取得する', 1, 'orders テーブルから customer_id と ordered_at を id 順に取得してください。', '各注文の customer_id と ordered_at が返ること。', 'SELECT customer_id, ordered_at FROM orders ORDER BY id;', 'orders テーブルの 2 列です。', '必要な列だけを取り出す基本 SELECT です。', 'id を返すだけでは注文日が分かりません。'),
  sqlProblem('local-sql-009', 'local-sql-where', 'SQL: WHERE / 条件', 'active の社員だけを取得する', 1, 'employees テーブルから status が active の社員名を id 順に取得してください。', 'Aoki, Sato, Tanaka, Ito, Kato が返ること。', "SELECT name FROM employees WHERE status = 'active' ORDER BY id;", 'status 列で絞り込みます。', '単一条件の絞り込みです。', 'active をクォートなしで書くと文字列比較になりません。'),
  sqlProblem('local-sql-010', 'local-sql-where', 'SQL: WHERE / 条件', '給与50万円以上の社員を取得する', 1, 'employees テーブルから salary が 500000 以上の社員名を salary の高い順で取得してください。', 'Kato, Suzuki, Sato が返ること。', 'SELECT name FROM employees WHERE salary >= 500000 ORDER BY salary DESC;', '数値比較なので >= が使えます。', '数値条件と並び替えを組み合わせる基本形です。', '500000 を文字列として比較しないように注意します。'),
  sqlProblem('local-sql-011', 'local-sql-where', 'SQL: WHERE / 条件', 'Engineering かつ高給与の社員を取得する', 2, 'employees テーブルから department_id が 2 で、salary が 600000 より大きい社員名を salary の高い順で取得してください。', 'Kato, Suzuki が返ること。', 'SELECT name FROM employees WHERE department_id = 2 AND salary > 600000 ORDER BY salary DESC;', '部署条件と給与条件の 2 つがあります。', '複数条件は AND でつなぎます。', 'OR にすると条件が緩くなって別の社員まで入ります。'),
  sqlProblem('local-sql-012', 'local-sql-where', 'SQL: WHERE / 条件', '2月以降の paid 注文を取得する', 2, 'orders テーブルから status が paid で、ordered_at が 2024-02-01 以降の注文 id を id 順に取得してください。', '5, 6 が返ること。', "SELECT id FROM orders WHERE status = 'paid' AND ordered_at >= '2024-02-01' ORDER BY id;", 'status と ordered_at の両方で絞ります。', '文字列条件と日付条件の組み合わせです。', 'pending の注文 2 は paid ではないので入りません。'),
  sqlProblem('local-sql-013', 'local-sql-where', 'SQL: WHERE / 条件', 'East 以外の顧客を取得する', 1, 'customers テーブルから region が East ではない顧客名を id 順に取得してください。', 'Bright, Delta が返ること。', "SELECT name FROM customers WHERE region <> 'East' ORDER BY id;", '否定条件なので <> を使えます。', '特定値以外を取る基本パターンです。', 'East の顧客まで入れないように条件を反対にしないことが大事です。'),
  sqlProblem('local-sql-014', 'local-sql-where', 'SQL: WHERE / 条件', 'leave 中または給与40万円未満の社員を取得する', 2, 'employees テーブルから status が leave、または salary が 400000 未満の社員名を id 順に取得してください。', 'Suzuki, Ito が返ること。', "SELECT name FROM employees WHERE status = 'leave' OR salary < 400000 ORDER BY id;", 'どちらかを満たせばよい条件です。', 'どちらかの条件を満たすケースでは OR を使います。', 'AND にすると該当件数が減り、Ito が入らなくなります。'),
  sqlProblem('local-sql-015', 'local-sql-join', 'SQL: JOIN', '社員名と部署名を結合して取得する', 2, 'employees と departments を結合して、社員名と部署名を employee の id 順に取得してください。', 'Aoki-Sales, Sato-Engineering などのように name と department name が対応して返ること。', 'SELECT e.name, d.name FROM employees e INNER JOIN departments d ON e.department_id = d.id ORDER BY e.id;', 'employees.department_id と departments.id を結びます。', '外部キーで別テーブルの名前を引く基本 JOIN です。', 'ON 句を忘れると正しく結合できません。'),
  sqlProblem('local-sql-016', 'local-sql-join', 'SQL: JOIN', '顧客名と注文金額を取得する', 2, 'customers と orders を結合して、顧客名と注文 total を orders.id 順に取得してください。', 'ACME-120000, ACME-80000, Bright-150000 などのように返ること。', 'SELECT c.name, o.total FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;', 'orders.customer_id と customers.id を結びます。', '注文だけでは顧客名が分からないので JOIN が必要です。', 'customers.name を取得しないと顧客情報が見えません。'),
  sqlProblem('local-sql-017', 'local-sql-join', 'SQL: JOIN', 'paid 注文の顧客名と金額を取得する', 2, 'paid の注文だけについて、顧客名と total を orders.id 順に取得してください。', 'ACME-120000, Bright-150000, Delta-200000, Bright-90000 が返ること。', "SELECT c.name, o.total FROM orders o INNER JOIN customers c ON o.customer_id = c.id WHERE o.status = 'paid' ORDER BY o.id;", 'JOIN した後に status を絞ります。', 'JOIN と絞り込みはよく一緒に使います。', 'orders.status の条件を付け忘れると pending や canceled も入ります。'),
  sqlProblem('local-sql-018', 'local-sql-join', 'SQL: JOIN', 'Engineering の社員名を部署名条件で取得する', 2, 'departments.name が Engineering の社員名を employees.id 順に取得してください。', 'Sato, Suzuki, Kato が返ること。', "SELECT e.name FROM employees e INNER JOIN departments d ON e.department_id = d.id WHERE d.name = 'Engineering' ORDER BY e.id;", '部署名条件は departments テーブルにあります。', '部署名で絞りたいときは部署テーブルまで JOIN します。', 'department_id = Engineering のような比較は型が合いません。'),
  sqlProblem('local-sql-019', 'local-sql-join', 'SQL: JOIN', '注文金額と顧客地域を取得する', 2, 'orders と customers を結合して、orders.id 順に total と region を取得してください。', '各注文ごとに total と region が返ること。', 'SELECT o.total, c.region FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;', '地域は customers テーブルにあります。', '注文テーブルだけでは地域が分からないため JOIN が必要です。', 'orders に region 列はありません。'),
  sqlProblem('local-sql-020', 'local-sql-join', 'SQL: JOIN', 'Sales 所属の社員名と給与を取得する', 2, 'departments.name が Sales の社員について、社員名と給与を employees.id 順に取得してください。', 'Aoki-400000, Tanaka-450000 が返ること。', "SELECT e.name, e.salary FROM employees e INNER JOIN departments d ON e.department_id = d.id WHERE d.name = 'Sales' ORDER BY e.id;", '部署名で絞ってから name と salary を出します。', '部署条件と社員列取得を同時に扱う基本 JOIN です。', 'department_id = 1 と書いてもよいですが、今回は部署名条件を使う意図です。'),
  sqlProblem('local-sql-021', 'local-sql-join', 'SQL: JOIN', '部署名と社員名を部署ID順に取得する', 2, 'departments と employees を結合して、部署名と社員名を departments.id, employees.id の順で並べて取得してください。', 'Sales-Aoki, Sales-Tanaka, Engineering-Sato などのように返ること。', 'SELECT d.name, e.name FROM departments d INNER JOIN employees e ON d.id = e.department_id ORDER BY d.id, e.id;', '並び順を 2 段階で指定します。', '並び順を複数指定すると見やすい一覧にできます。', 'ORDER BY を 1 列だけにすると期待順にならないことがあります。'),
  sqlProblem('local-sql-022', 'local-sql-join', 'SQL: JOIN', '顧客名と注文状態を取得する', 2, 'orders と customers を結合して、顧客名と注文 status を orders.id 順に取得してください。', 'ACME-paid, ACME-pending, Bright-paid などのように返ること。', 'SELECT c.name, o.status FROM orders o INNER JOIN customers c ON o.customer_id = c.id ORDER BY o.id;', 'status は orders テーブルにあります。', '別テーブルの名称と状態をまとめて見る典型例です。', 'customer_id の数字だけでは顧客名になりません。'),
  sqlProblem('local-sql-023', 'local-sql-group-by', 'SQL: GROUP BY', '部署ごとの社員数を集計する', 2, 'departments と employees を使って、部署ごとの社員数を部署名つきで取得してください。', 'Sales-2, Engineering-3, HR-1 が返ること。', 'SELECT d.name, COUNT(*) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;', '部署名ごとに COUNT(*) します。', '集計ではグループ化した単位ごとに件数を数えます。', 'GROUP BY なしで COUNT(*) を使うと全体件数しか出ません。'),
  sqlProblem('local-sql-024', 'local-sql-group-by', 'SQL: GROUP BY', '部署ごとの平均給与を集計する', 2, 'departments と employees を使って、部署ごとの平均給与を部署名つきで取得してください。', 'Sales-425000, Engineering-623333..., HR-380000 が返ること。', 'SELECT d.name, AVG(e.salary) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;', '平均を取りたいので AVG(salary) を使います。', '平均給与のような集計でも GROUP BY が基本です。', 'salary をそのまま SELECT すると集計になりません。'),
  sqlProblem('local-sql-025', 'local-sql-group-by', 'SQL: GROUP BY', '顧客ごとの paid 合計金額を集計する', 2, 'paid の注文だけを対象に、顧客ごとの total 合計を顧客名つきで取得してください。', 'ACME-120000, Bright-240000, Delta-200000 が返ること。', "SELECT c.name, SUM(o.total) FROM orders o INNER JOIN customers c ON o.customer_id = c.id WHERE o.status = 'paid' GROUP BY c.name ORDER BY c.id;", 'paid のみを絞ってから SUM します。', '集計前に絞ると、必要なデータだけで合計できます。', 'pending を除外しないと ACME の合計がずれます。'),
  sqlProblem('local-sql-026', 'local-sql-group-by', 'SQL: GROUP BY', '注文状態ごとの件数を集計する', 2, 'orders テーブルで status ごとの件数を取得してください。', 'paid-4, pending-1, canceled-1 が返ること。', 'SELECT status, COUNT(*) FROM orders GROUP BY status ORDER BY status;', 'status ごとに COUNT(*) します。', 'カテゴリごとの件数確認は GROUP BY の定番です。', 'ORDER BY を入れないと表示順が不安定になることがあります。'),
  sqlProblem('local-sql-027', 'local-sql-group-by', 'SQL: GROUP BY', '部署ごとの最高給与を取得する', 2, 'departments と employees を使って、部署ごとの最高給与を部署名つきで取得してください。', 'Sales-450000, Engineering-700000, HR-380000 が返ること。', 'SELECT d.name, MAX(e.salary) FROM employees e INNER JOIN departments d ON e.department_id = d.id GROUP BY d.name ORDER BY d.id;', '最大値を出すので MAX(salary) を使います。', '部署ごとの上限値を見るときの基本パターンです。', 'AVG を使うと平均給与になってしまいます。'),
  sqlProblem('local-sql-028', 'local-sql-group-by', 'SQL: GROUP BY', '地域ごとの顧客数を集計する', 2, 'customers テーブルで region ごとの顧客数を取得してください。', 'East-2, South-1, West-1 が返ること。', 'SELECT region, COUNT(*) FROM customers GROUP BY region ORDER BY region;', 'region 単位で COUNT(*) します。', '単一テーブルでもカテゴリ集計に GROUP BY を使います。', 'name ごとに数えると 1 件ずつになってしまいます。'),
  sqlProblem('local-sql-029', 'local-sql-subquery', 'SQL: サブクエリ', '平均給与より高い社員を取得する', 3, 'employees テーブルから、全社員の平均給与より高い社員名を salary の高い順に取得してください。', 'Kato, Suzuki, Sato が返ること。', 'SELECT name FROM employees WHERE salary > (SELECT AVG(salary) FROM employees) ORDER BY salary DESC;', '平均給与は SELECT AVG(salary) ... で別に求められます。', '比較基準を別 SELECT で作るのがサブクエリの基本です。', '平均値を手で固定値にするとデータ変更に弱くなります。'),
  sqlProblem('local-sql-030', 'local-sql-subquery', 'SQL: サブクエリ', '平均注文金額より高い注文を取得する', 3, 'orders テーブルから、平均 total より高い注文 id を id 順に取得してください。', '1, 3, 5 が返ること。', 'SELECT id FROM orders WHERE total > (SELECT AVG(total) FROM orders) ORDER BY id;', 'orders の平均 total を先に求めます。', '平均値との比較でもサブクエリが便利です。', 'paid のみを対象にしてしまうと平均基準が変わります。'),
  sqlProblem('local-sql-031', 'local-sql-subquery', 'SQL: サブクエリ', 'Engineering 部署の社員をサブクエリで取得する', 3, 'departments テーブルをサブクエリで参照し、部署名が Engineering の社員名を id 順に取得してください。', 'Sato, Suzuki, Kato が返ること。', "SELECT name FROM employees WHERE department_id = (SELECT id FROM departments WHERE name = 'Engineering') ORDER BY id;", 'department_id と departments.id をサブクエリでつなげます。', '他テーブルのキーを先に取り出して比較する形です。', '部署名を employees に直接書く列はありません。'),
  sqlProblem('local-sql-032', 'local-sql-subquery', 'SQL: サブクエリ', 'paid 注文がある顧客を取得する', 3, 'paid の注文を 1 件以上持つ顧客名を id 順に取得してください。', 'ACME, Bright, Delta が返ること。', "SELECT name FROM customers WHERE id IN (SELECT customer_id FROM orders WHERE status = 'paid') ORDER BY id;", 'orders から paid の customer_id を取り出して customers に当てます。', '複数の ID 候補を使うときは IN とサブクエリの組み合わせが便利です。', 'Central は canceled 注文しかないので含まれません。'),
  sqlProblem('local-sql-033', 'local-sql-subquery', 'SQL: サブクエリ', '最大金額の注文を取得する', 3, 'orders テーブルから total が最大の注文 id を取得してください。', '5 が返ること。', 'SELECT id FROM orders WHERE total = (SELECT MAX(total) FROM orders);', 'MAX(total) を別 SELECT で求められます。', '最大値そのものではなく、その行を取りたいときの定番形です。', 'ORDER BY total DESC LIMIT 1 でも取れますが、この問題はサブクエリを使う意図です。'),
  sqlProblem('local-sql-034', 'local-sql-subquery', 'SQL: サブクエリ', '最も高い給与の社員を取得する', 3, 'employees テーブルから salary が最大の社員名を取得してください。', 'Kato が返ること。', 'SELECT name FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);', 'MAX(salary) を使って基準値を作れます。', '最大給与の行を直接取りたいときに使う基本形です。', 'AVG や MIN を使うと別の社員が対象になります。'),
  sqlProblem('local-sql-035', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'pending の注文を paid に更新する', 2, 'orders テーブルで id = 2 の注文の status を paid に更新してください。', 'id=2 の status が pending から paid に変わること。', "UPDATE orders SET status = 'paid' WHERE id = 2;", '更新対象は 1 件だけです。', 'UPDATE は SET と WHERE の組み合わせで書きます。', 'WHERE を忘れると全件更新になります。'),
  sqlProblem('local-sql-036', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'Sales 部署の給与を5万円上げる', 3, 'Sales 部署の社員の salary を一律 50000 上げてください。', 'Aoki は 450000、Tanaka は 500000 になること。', 'UPDATE employees SET salary = salary + 50000 WHERE department_id = 1;', 'Sales の department_id は 1 です。', '既存値に加算して更新する実務でよくある形です。', 'salary = 50000 にすると一律 50000 円になってしまいます。'),
  sqlProblem('local-sql-037', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'canceled の注文を削除する', 2, 'orders テーブルから status が canceled の注文を削除してください。', 'id=4 の注文が削除されること。', "DELETE FROM orders WHERE status = 'canceled';", '削除条件は status です。', 'DELETE は削除対象を WHERE で絞るのが基本です。', 'WHERE なしの DELETE は全件削除になるので危険です。'),
  sqlProblem('local-sql-038', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'HR 部署の社員を削除する', 2, 'employees テーブルから department_id が 3 の社員を削除してください。', 'Ito が削除されること。', 'DELETE FROM employees WHERE department_id = 3;', 'HR の department_id は 3 です。', '条件に一致する行だけ削除する基本問題です。', 'department_id を 2 にすると Engineering の社員が消えてしまいます。'),
  sqlProblem('local-sql-039', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'Delta の地域を West に更新する', 2, 'customers テーブルで name が Delta の顧客の region を West に更新してください。', 'Delta の region が South から West に変わること。', "UPDATE customers SET region = 'West' WHERE name = 'Delta';", '条件は顧客名です。', '文字列条件で対象行を絞る更新です。', 'name 条件を書かないと全顧客の region が変わります。'),
  sqlProblem('local-sql-040', 'local-sql-update-delete', 'SQL: UPDATE / DELETE', 'leave 状態の社員を削除する', 2, 'employees テーブルから status が leave の社員を削除してください。', 'Suzuki が削除されること。', "DELETE FROM employees WHERE status = 'leave';", 'status 列で絞ります。', '状態列を使った削除の基本形です。', 'active を消してしまうと業務データが大きく変わってしまいます。'),
]
