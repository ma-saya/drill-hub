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

const linux = (problem: ProblemSeed): ProblemSeed => problem

export const LINUX_PROBLEM_SEEDS: ProblemSeed[] = [
  linux({
    id: 'local-linux-001',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: '現在のディレクトリ一覧を見るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '今いるディレクトリのファイルやフォルダ一覧を確認したいです。空欄を埋めてください。\n\n__________',
    requirements: 'コマンドだけを書いてください。',
    hint: 'Linux 学習の最初に出てくる基本コマンドです。',
    answer: 'ls',
    explanation: '`ls` は現在のディレクトリ内にあるファイルやフォルダを一覧表示します。',
    common_mistakes: '`pwd` は場所確認で、一覧表示ではありません。',
  }),
  linux({
    id: 'local-linux-002',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: '現在地を表示するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '自分が今どのディレクトリにいるか確認したいです。空欄を埋めてください。\n\n__________',
    requirements: 'コマンドだけを書いてください。',
    hint: 'print working directory の略です。',
    answer: 'pwd',
    explanation: '`pwd` は現在の作業ディレクトリのパスを表示します。',
    common_mistakes: '`cd` は移動、`pwd` は現在地確認です。',
  }),
  linux({
    id: 'local-linux-003',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: 'documents ディレクトリへ移動するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`documents` ディレクトリへ移動したいです。空欄を埋めてください。\n\n__________ documents',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'change directory の略です。',
    answer: 'cd',
    explanation: '`cd documents` で指定したディレクトリへ移動できます。',
    common_mistakes: '`ls documents` は中身を見るだけで移動はしません。',
  }),
  linux({
    id: 'local-linux-004',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: '新しいフォルダを作るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`logs` という名前のディレクトリを作成したいです。空欄を埋めてください。\n\n__________ logs',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'make directory の略です。',
    answer: 'mkdir',
    explanation: '`mkdir logs` で新しいディレクトリを作成できます。',
    common_mistakes: '`touch` はファイル作成で、ディレクトリ作成ではありません。',
  }),
  linux({
    id: 'local-linux-005',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: 'file.txt を削除するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`file.txt` を削除したいです。空欄を埋めてください。\n\n__________ file.txt',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'remove の略です。',
    answer: 'rm',
    explanation: '`rm file.txt` でファイルを削除できます。',
    common_mistakes: '`rmdir` は空ディレクトリ向けで、通常のファイル削除とは用途が違います。',
  }),
  linux({
    id: 'local-linux-006',
    theme_id: 'local-linux-basic',
    themeName: 'Linux: 基本コマンド',
    title: 'ファイルをコピーするコマンド名',
    level: 1,
    type: 'fill_blank',
    statement:
      '`report.txt` を `backup.txt` として複製したいです。空欄を埋めてください。\n\n__________ report.txt backup.txt',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'copy の略です。',
    answer: 'cp',
    explanation: '`cp 元 先` でファイルやディレクトリをコピーできます。',
    common_mistakes: '`mv` は移動や名前変更で、複製ではありません。',
  }),
  linux({
    id: 'local-linux-007',
    theme_id: 'local-linux-file',
    themeName: 'Linux: ファイル操作',
    title: 'ファイル内容をそのまま表示するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`config.txt` の中身をそのまま表示したいです。空欄を埋めてください。\n\n__________ config.txt',
    requirements: 'コマンド名だけを書いてください。',
    hint: '短いファイルの確認でよく使います。',
    answer: 'cat',
    explanation: '`cat` はファイル内容を標準出力へそのまま表示します。',
    common_mistakes: '`less` はページ送りしながら読むときに向いています。',
  }),
  linux({
    id: 'local-linux-008',
    theme_id: 'local-linux-file',
    themeName: 'Linux: ファイル操作',
    title: '長いファイルをページ送りで確認するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`server.log` をページ送りしながら確認したいです。空欄を埋めてください。\n\n__________ server.log',
    requirements: 'コマンド名だけを書いてください。',
    hint: '長いログを読むときによく使います。',
    answer: 'less',
    explanation: '`less` は長いファイルをスクロールしながら確認できるコマンドです。',
    common_mistakes: '`cat` だと長い内容が一気に流れて読みづらくなります。',
  }),
  linux({
    id: 'local-linux-009',
    theme_id: 'local-linux-file',
    themeName: 'Linux: ファイル操作',
    title: '空のファイルを作るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`notes.txt` という空ファイルを新しく作りたいです。空欄を埋めてください。\n\n__________ notes.txt',
    requirements: 'コマンド名だけを書いてください。',
    hint: '存在しないファイルを作る基本コマンドです。',
    answer: 'touch',
    explanation: '`touch notes.txt` で空ファイル作成や更新日時変更ができます。',
    common_mistakes: '`mkdir` はフォルダ作成用です。',
  }),
  linux({
    id: 'local-linux-010',
    theme_id: 'local-linux-file',
    themeName: 'Linux: ファイル操作',
    title: 'config.txt を開いて編集する手順を書く',
    level: 2,
    type: 'procedure',
    statement:
      '`config.txt` をターミナル上で開いて編集したいです。Linux 初学者向けの基本手順を 2 ステップで書いてください。',
    requirements:
      'エディタでファイルを開くことを書くこと\n保存して終了することに触れること',
    hint: 'まずは `nano` を例にすると説明しやすいです。',
    answer:
      '1. `nano config.txt` のようにエディタでファイルを開く。\n2. 内容を編集し、保存してエディタを終了する。',
    explanation: 'Linux ではコマンドラインエディタでそのままファイル編集する場面がよくあります。',
    common_mistakes: '`cat` では表示だけで編集できません。',
  }),
  linux({
    id: 'local-linux-011',
    theme_id: 'local-linux-permission',
    themeName: 'Linux: 権限',
    title: '権限表示を確認するオプション',
    level: 1,
    type: 'fill_blank',
    statement:
      'ファイルの権限を `-rw-r--r--` のような形式で見たいです。空欄を埋めてください。\n\nls __________',
    requirements: 'オプションだけを書いてください。',
    hint: 'long format の略です。',
    answer: '-l',
    explanation: '`ls -l` で権限、所有者、サイズなどを詳しく表示できます。',
    common_mistakes: '`-a` は隠しファイル表示で、権限表示の主目的ではありません。',
  }),
  linux({
    id: 'local-linux-012',
    theme_id: 'local-linux-permission',
    themeName: 'Linux: 権限',
    title: '実行権限を追加するコマンド名',
    level: 1,
    type: 'fill_blank',
    statement:
      '`script.sh` に実行権限を付けたいです。空欄を埋めてください。\n\n__________ +x script.sh',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'change mode の略です。',
    answer: 'chmod',
    explanation: '`chmod +x` で実行権限を追加できます。',
    common_mistakes: '`chown` は所有者変更で、権限ビット変更ではありません。',
  }),
  linux({
    id: 'local-linux-013',
    theme_id: 'local-linux-permission',
    themeName: 'Linux: 権限',
    title: '所有者を変えるコマンド名',
    level: 2,
    type: 'fill_blank',
    statement:
      '`app.log` の所有者を `ubuntu` に変更したいです。空欄を埋めてください。\n\n__________ ubuntu app.log',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'change owner の略です。',
    answer: 'chown',
    explanation: '`chown` はファイルやディレクトリの所有者を変更するときに使います。',
    common_mistakes: '`chmod` は権限変更で、所有者変更には使えません。',
  }),
  linux({
    id: 'local-linux-014',
    theme_id: 'local-linux-permission',
    themeName: 'Linux: 権限',
    title: '実行権限付きか確認する観点を書く',
    level: 2,
    type: 'procedure',
    statement:
      '`script.sh` が実行できないとき、権限観点でまず何を確認するかを 2 点書いてください。',
    requirements:
      '`ls -l` で権限を確認することに触れること\n実行権限 `x` の有無に触れること',
    hint: 'まず見方を確認してから、x が付いているかを見ます。',
    answer:
      '1. `ls -l script.sh` で権限表示を確認する。\n2. 所有者や実行対象に `x` が付いているかを確認する。',
    explanation: '実行できない原因として、まず権限不足を疑うのが基本です。',
    common_mistakes: '内容だけ見直しても、実行権限がなければ起動できません。',
  }),
  linux({
    id: 'local-linux-015',
    theme_id: 'local-linux-process',
    themeName: 'Linux: プロセス / サーバ',
    title: '実行中プロセスを見るコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '今動いているプロセスを確認したいです。空欄を埋めてください。\n\n__________',
    requirements: 'コマンドだけを書いてください。',
    hint: 'process status の略です。',
    answer: 'ps',
    explanation: '`ps` は実行中プロセス確認の基本コマンドです。',
    common_mistakes: '`pwd` は現在地確認で、プロセス確認ではありません。',
  }),
  linux({
    id: 'local-linux-016',
    theme_id: 'local-linux-process',
    themeName: 'Linux: プロセス / サーバ',
    title: 'PID 1234 を終了するコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      'PID が 1234 のプロセスを終了したいです。空欄を埋めてください。\n\n__________ 1234',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'プロセス終了の基本コマンドです。',
    answer: 'kill',
    explanation: '`kill 1234` で指定した PID のプロセスへ終了シグナルを送れます。',
    common_mistakes: '`rm` はファイル削除で、プロセス終了には使いません。',
  }),
  linux({
    id: 'local-linux-017',
    theme_id: 'local-linux-process',
    themeName: 'Linux: プロセス / サーバ',
    title: 'サーバが起動しているか確認する手順を書く',
    level: 2,
    type: 'procedure',
    statement:
      'Spring Boot サーバが Linux 上で起動しているか確認したいです。基本的な確認手順を 2 つ書いてください。',
    requirements:
      'プロセス確認またはログ確認に触れること\nポート確認または応答確認に触れること',
    hint: '「動いているか」と「外から応答するか」の 2 観点です。',
    answer:
      '1. `ps` やログ確認で、サーバプロセスが起動しているかを確認する。\n2. ポート確認や `curl` で、実際に応答できる状態かを確認する。',
    explanation: 'サーバ確認では、プロセスと通信の両方を見ると切り分けしやすくなります。',
    common_mistakes: 'プロセスだけ見ても、ポート待受や応答異常を見落とすことがあります。',
  }),
  linux({
    id: 'local-linux-018',
    theme_id: 'local-linux-network',
    themeName: 'Linux: ネットワーク / デプロイ補助',
    title: 'HTTP 応答確認に使うコマンド',
    level: 1,
    type: 'fill_blank',
    statement:
      '`http://localhost:8080` に応答があるか確認したいです。空欄を埋めてください。\n\n__________ http://localhost:8080',
    requirements: 'コマンド名だけを書いてください。',
    hint: 'HTTP リクエスト送信の基本コマンドです。',
    answer: 'curl',
    explanation: '`curl` は URL へリクエストを送って応答確認するときに便利です。',
    common_mistakes: '`cd` や `cat` ではネットワーク確認はできません。',
  }),
  linux({
    id: 'local-linux-019',
    theme_id: 'local-linux-network',
    themeName: 'Linux: ネットワーク / デプロイ補助',
    title: '8080 番ポート確認の手順を書く',
    level: 2,
    type: 'procedure',
    statement:
      'アプリが 8080 番で待ち受けしているか確認したいです。Linux 初学者向けに基本確認手順を 2 点書いてください。',
    requirements:
      'ポート確認コマンドに触れること\n応答確認にも触れること',
    hint: '`ss` や `netstat` のようなポート確認と、`curl` のような応答確認を組み合わせると分かりやすいです。',
    answer:
      '1. `ss -lntp` などで 8080 番ポートを待ち受けしているプロセスがあるか確認する。\n2. `curl http://localhost:8080` で実際に応答が返るか確認する。',
    explanation: 'ポート待受と HTTP 応答の両方を見ると、起動確認の精度が上がります。',
    common_mistakes: 'ポートだけ見て、実際の応答が失敗しているケースを見落としやすいです。',
  }),
  linux({
    id: 'local-linux-020',
    theme_id: 'local-linux-network',
    themeName: 'Linux: ネットワーク / デプロイ補助',
    title: 'ログ確認の基本手順を書く',
    level: 2,
    type: 'procedure',
    statement:
      'サーバエラーの原因を追うために `app.log` を確認したいです。基本的な確認手順を 2 ステップで書いてください。',
    requirements:
      'まず内容を見ることに触れること\n必要なら末尾や更新を見る観点に触れること',
    hint: '`less` や `tail` を使う流れをイメージすると書きやすいです。',
    answer:
      '1. `less app.log` などでログ内容を開いて確認する。\n2. 直近のエラーを追いたい場合は末尾を重点的に確認する。',
    explanation: 'ログ確認では全体を開く視点と、直近エラーへ寄る視点の両方が役立ちます。',
    common_mistakes: 'ログを見ずに設定変更だけを繰り返すと、原因特定が遅くなりやすいです。',
  }),
]
