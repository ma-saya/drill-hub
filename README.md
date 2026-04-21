# Java Drill Hub

Java Drill Hub は、Java を起点に Spring Boot、SQL、Git/GitHub、Docker、Flutter などの実務周辺知識を復習するための学習アプリです。

問題を解くだけで終わらせず、コードを書き、ヒントや解説を確認し、自己評価と苦手登録で復習対象を管理できるようにしています。

## 作った目的

入社前学習として、文法や用語を「知っている」状態から、実務寄りの小アプリ制作で使える状態へ近づけるために作りました。

このアプリ自体は知識確認と復習を支える位置づけです。Spring Boot の CRUD API や DB 接続など、実際に手を動かして作る練習は別の小規模アプリで進め、このアプリではその前後に必要な知識を確認します。

## 主な機能

- 技術別の問題演習
- Spring Boot、SQL、Git/GitHub などの技術別問題
- レベル、学習状態、苦手登録による絞り込み
- コード入力欄での回答作成
- ヒント、解答例、解説、よくあるミスの確認
- 自己評価による学習記録
- 苦手問題の登録
- 学習カレンダーと連続学習日数の表示
- 1日の目標問題数の設定
- ログイン時は Supabase に学習記録を保存
- 未ログイン時は localStorage で学習記録を保持

## 使用技術

- Next.js
- React
- TypeScript
- CSS Modules
- Supabase
- CodeMirror

## 要件

### 学習者向け要件

- 技術ごとに問題を探せること
- 未学習、できた、惜しい、できなかった、苦手のみで絞り込めること
- 自分の回答を書きながら考えられること
- 解答を見る前にヒントを確認できること
- 解いた結果を自己評価として残せること
- 復習したい問題を苦手として登録できること
- 毎日の学習量を見える化できること

### 入社前学習としての要件

- Java の基礎だけでなく、Spring Boot、SQL、Git/GitHub など実務で使う周辺技術も扱うこと
- Spring Boot は CRUD、DTO、バリデーション、例外処理、JPA などに段階的に触れられること
- SQL は JOIN、集計、テーブル設計、インデックスなどの前提知識を復習できること
- 作ったコードを自分のアウトプットとして説明する前の知識確認に使えること

## 工夫した点

- 問題一覧に技術別の進捗を表示し、どの分野が進んでいるか分かるようにした
- 問題一覧で Spring Boot、SQL、Git/GitHub などを技術別に絞り込めるようにした
- 苦手登録と状態フィルターを組み合わせ、復習対象を絞り込みやすくした
- ログインしていない状態でも localStorage で学習を続けられるようにした
- ログイン後は Supabase に記録を保存し、学習履歴を残せるようにした
- CodeMirror を使い、回答欄を通常のテキスト入力よりコードを書きやすい形にした
- 日次目標と連続学習日数を表示し、学習習慣を続けやすくした

## このアプリで扱わないこと

このアプリは、実務アプリそのものを作る場所ではありません。

Spring Boot の CRUD API、DB 接続、バリデーション、認証、テストなどは、別の小規模アプリで実装します。このアプリでは、その制作に必要な知識の確認と復習を担当します。

## 今後の学習方針

1. Java Drill Hub で Spring Boot、SQL、Git/GitHub の基礎を復習する
2. 別フォルダで小規模アプリを作る
3. 小規模アプリには README、要件、工夫点、テストを追加する
4. 作ったものを自分の言葉で説明できるように振り返りを書く

小規模アプリでは、以下を段階的に扱う予定です。

- Java コンソールアプリ
- ファイル保存付き Todo
- Spring Boot CRUD API
- Spring Boot + DB 接続
- バリデーションと例外処理
- JUnit / MockMvc / Repository テスト
- Flutter + API 通信

## 小アプリ制作で入れるテスト

小規模アプリでは、最初から完璧なテストを目指すのではなく、実務で価値が出やすい範囲から入れます。

- 正常系のテスト
- 入力値が不正な場合のテスト
- データが存在しない場合のテスト
- Service の単体テスト
- Controller の MockMvc テスト
- Repository の DB アクセステスト

詳細な方針は [docs/mini-app-test-plan.md](docs/mini-app-test-plan.md) にまとめています。

Supabase に Todo 写経ドリルを追加する場合は、[sql_step7_add_todo_drill_problems.sql](sql_step7_add_todo_drill_problems.sql) を実行します。このSQLは `DELETE` やテーブル再作成を行わず、既存の学習記録を残したまま Java の問題として Todo 実装練習を追加・更新します。

お気に入り機能を Supabase に保存する場合は、[sql_step8_add_favorite_to_study_records.sql](sql_step8_add_favorite_to_study_records.sql) を実行して `study_records.is_favorite` を追加します。未ログイン時はブラウザの localStorage に保存されます。

## セットアップ

```bash
npm install
npm run dev
```

ブラウザで `http://localhost:3000` を開きます。

## 環境変数

Supabase を使う場合は `.env.local` に以下を設定します。

```bash
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

## 確認コマンド

```bash
npm run lint
npm run build
```
